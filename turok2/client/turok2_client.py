import asyncio
import pymem
import time
import struct
import msvcrt
from argparse import Namespace
from CommonClient import CommonContext, server_loop, gui_enabled
from ..items import map_ap_item_to_game

class Turok2Context(CommonContext):
    #TODO STILL:
    # Set self.finished_game when the game is done
    game = "Turok 2"

    def __init__(self, server_address, password):
        super().__init__(server_address, password)
    
    # APStatus - if these are not 0 or 1, they are invalid
    AP_READY = 0
    AP_PROCESSING = 1

    # APMessageType (IN are values to send, OUT are values we receive)
    AP_MSGTYPE_NONE = 0

    AP_IN_MSGTYPE_NONE = 0
    AP_IN_MSGTYPE_GET_PICKUP = 1
    AP_IN_MSGTYPE_GET_WEAPON = 2
    AP_IN_MSGTYPE_GET_MISSION_ITEMS = 3
    AP_IN_MSGTYPE_GET_AMMO = 4
    AP_IN_MSGTYPE_GET_TRAP = 5

    AP_OUT_MSGTYPE_SEND_CHECK = 5

    # Memory offsets - this is how the struct is layed out
    MAGIC = 0
    VERSION = 4
    SIGNATURE1 = 8
    SIGNATURE2 = 12

    IN_STATUS = 16
    IN_TYPE = 20
    IN_DATA = 24

    OUT_STATUS = 28
    OUT_TYPE = 32
    OUT_DATA = 36

    pattern = (b"\x4B\x52\x50\x41" + 
        b"\x01\x00\x00\x00" + 
        b"\xAD\x0D\x11\x43" +
        b"\xEF\xBE\x37\x13")
        
    ap_base = None
    game_connected = False # Really, it's when AP Base isn't found
    pm = None
        
    async def connect_to_game_async(self):
        """
        Connects to the exe_name. If it fails, it sleeps for
        5 seconds before trying again.
        """
        # When this is called, it means the game isn't connected
        self.game_connected = False

        print(f"Attempting to connect to {self.exe_name}...")
        while True:
            try:
                self.pm = pymem.Pymem(self.exe_name)
                print(f"Connected to {self.exe_name}")
                return
            except Exception:
                await asyncio.sleep(5)
                
    async def scan_for_ap_base_async(self):
        """
        Scans the process for the AP memory block.
        
        If there is an ap_base defined, it will see if it's still valid and will use that instead.
        
        Otherwise, does the scan. If it fails more than 5 times, it will attempt to reconnect
        to the game to prevent a scenerio where it's connected to a non-existent process.
        """
        # When this is called, it means the game isn't connected
        self.game_connected = False

        # Try last known address first
        if self.ap_base is not None and self.is_ap_block_valid():
            print(f"Reusing AP block at {hex(self.ap_base)}")
            self.game_connected = True
            return self.ap_base
            
        attempt = 0
        while True:
            try:            
                self.ap_base = pymem.pattern.pattern_scan_all(
                    self.pm.process_handle,
                    self.pattern
                )
                
                if not self.ap_base or not self.is_ap_block_valid():
                    raise
                
                self.game_connected = True
                print(f"Found AP block at {hex(self.ap_base)}")
                return self.ap_base
                    
            except:
                attempt += 1
                if attempt > 5:
                    print("Couldn't find AP memory block after 5 tries, trying to reconnect to game.")
                    await self.connect_to_game_async()
                    attempt = 0
                
                print("Did not find AP memory block... trying again shortly.")
                await asyncio.sleep(5)
                
    def is_ap_block_valid(self):
        """
        Checks that the AP block is valid by validating our header, and status values.
        
        If they are not valid, we need to connect and scan again because the struct may 
        have moved or the game may have closed.
        """
        try:
            return (self.read_int(self.MAGIC) == 0x4150524B and
                self.read_int(self.VERSION) == 1 and
                self.read_int(self.SIGNATURE1) == 0x43110DAD and
                self.read_int(self.SIGNATURE2) == 0x1337BEEF and
                self.read_int(self.IN_STATUS) in (0,1) and 
                self.read_int(self.OUT_STATUS) in (0,1))
        except Exception:
            return False

    def read_int(self, offset):
        """
        Helper to read the int for the given offset.
        """
        return self.pm.read_int(self.ap_base + offset)

    def write_int(self, offset, value):
        """
        Helper to write an int to the given offset.
        """
        self.pm.write_int(self.ap_base + offset, value)
        
    async def bridge_loop_async(self):
        """
        This is the main execution loop.
        Each loop, checks if the AP block is not valid, throw an exception and try to connect again.
        Tries to process outgoing messages, as well as console commands.
        """
        await self.connect_to_game_async()
        self.ap_base = await self.scan_for_ap_base_async()
        
        while True:
            try:
                if not self.is_ap_block_valid():
                    self.game_connected = False
                    raise Exception("AP block disappeared")
                    
                await self.process_outgoing() # Send checks to AP
                #process_console()  #TODO
                await asyncio.sleep(0.1)

            except Exception:
                print("Lost connection to game. Reconnecting...")
                await asyncio.sleep(5) # If the game was closed, let it close completely

                while True:
                    try:
                        await self.connect_to_game_async()
                        self.ap_base = await self.scan_for_ap_base_async()
                        print("Reconnected successfully.")
                        break
                    except Exception:
                        print("Reconnect failed, retrying...")
                        await asyncio.sleep(3)
        
    async def process_new_items_loop(self):
        """
        TODO: doc
        """
        highest_index = 0
        while True:
            if not self.game_connected:
                await asyncio.sleep(3)
                continue
                
            new_items = self.items_received[highest_index:]
            for item in new_items:
                # If we're suddenly not connected, exit out
                if not self.game_connected:
                    break
                
                highest_index += 1
                msg_type, msg_data = map_ap_item_to_game(item.item)
                await self.send_next_item_async(msg_type, msg_data)
                
            await asyncio.sleep(0.1)
            
    async def send_next_item_async(self, msg_type: int, data: int):
        """
        Sends a message to the game by:
        - Checking the IN_STATUS - if not AP_READY, do nothing, as the game is currently processing one
        - Writing the IN_TYPE and IN_DATA, so the game knows the type and what value to use
        - Writing the IN_STATUS to AP_PROCESSING so the game knows to process what we just gave it
        """
        while self.read_int(self.IN_STATUS) != self.AP_READY:
            await asyncio.sleep(0.05)

        self.write_int(self.IN_TYPE, msg_type)
        self.write_int(self.IN_DATA, data)
        self.write_int(self.IN_STATUS, self.AP_PROCESSING)
        
    async def process_outgoing(self):
        """
        Process a message from the game by:
        - Checking the OUT_STATUS - if not AP_PROCESSING, do nothing, as the game hasn't sent anything.
        - Writing the OUT_TYPE and OUT_DATA so we have the data the game sent us.
        - Doing something based on the type - currently only AP_OUT_MSGTYPE_SEND_CHECK does something.
          - This will eventually send the info to AP that the check was received.
        - Setting AP_READY to OUT_STATUS to let the game know it can send something else.
        """
        if self.read_int(self.OUT_STATUS) != self.AP_PROCESSING:
            return

        msg_type = self.read_int(self.OUT_TYPE)
        msg_data = self.read_int(self.OUT_DATA)

        # Send this check to Archipelago - msg_data is the location id
        if msg_type == self.AP_OUT_MSGTYPE_SEND_CHECK:
            await self.check_locations([msg_data])

        # Mark block ready for next message
        self.write_int(self.OUT_STATUS, self.AP_READY)
    
async def main(args: Namespace, exe_name) -> None:
    ctx = Turok2Context(args.url, None)
    ctx.exe_name = exe_name

    if gui_enabled:
        ctx.run_gui()
    ctx.run_cli()

    ctx.server_task = asyncio.create_task(server_loop(ctx), name="server loop")
    
    # Start the bridge as a background task
    asyncio.create_task(ctx.bridge_loop_async(), name="bridge loop")
    asyncio.create_task(ctx.process_new_items_loop(), name="new items loop")
    
    await ctx.exit_event.wait()
    await ctx.shutdown()