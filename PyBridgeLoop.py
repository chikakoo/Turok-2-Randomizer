import pymem
import time
import struct
import msvcrt

"""
Enum values from the Turok 2 scripts
"""
# APStatus - if these are not 0 or 1, they are invalid
AP_READY = 0
AP_PROCESSING = 1

# APMessageType (IN are values to send, OUT are values we receive)
AP_MSGTYPE_NONE = 0

AP_IN_MSGTYPE_GET_WEAPON = 1
AP_IN_MSGTYPE_GET_AMMO = 2
AP_IN_MSGTYPE_GET_TRAP = 3

AP_OUT_MSGTYPE_SEND_CHECK = 4

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

# Processing
PROCESS = "horus_Shipping_Playfab_Steam_x64.exe"

pattern = (b"\x4B\x52\x50\x41" + 
    b"\x01\x00\x00\x00" + 
    b"\xAD\x0D\x11\x43" +
    b"\xEF\xBE\x37\x13")

def connect_to_process():
    """
    Connects to the defined process. If it fails, it sleeps for
    5 seconds before trying again.
    """
    global pm

    print(f"Attempting to connect to {PROCESS}...")
    while True:
        try:
            pm = pymem.Pymem(PROCESS)
            print(f"Connected to {PROCESS}")
            return
        except Exception:
            time.sleep(5)
    
# Print the memory block to see if it's correct
# Turn off if not debugging
def print_memory_block():
    """
    Prints 64 bytes of the current AP memory block for debugging purposes.
    """
    block = pm.read_bytes(ap_base, 64)
    for i in range(0, 64, 4):
        val = struct.unpack("<I", block[i:i+4])[0]
        print(f"{i:02X}: {val} (0x{val:08X})")

def scan_for_ap_base():
    """
    Scans the process for the AP memory block.
    
    If there is an ap_base defined, it will see if it's still valid and will use that instead.
    
    Otherwise, does the scan. If it fails more than 5 times, it will attempt to reconnect
    to the game to prevent a scenerio where it's connected to a non-existent process.
    """
    global ap_base

    # Try last known address first
    if ap_base is not None and is_ap_block_valid():
        print(f"Reusing AP block at {hex(ap_base)}")
        return ap_base
        
    attempt = 0
    while True:
        try:            
            ap_base = pymem.pattern.pattern_scan_all(
                pm.process_handle,
                pattern
            )
            
            if not ap_base or not is_ap_block_valid():
                raise
            
            print(f"Found AP block at {hex(ap_base)}")
            return ap_base
                
        except:
            attempt += 1
            if attempt > 5:
                print("Couldn't find AP memory block after 5 tries, trying to reconnect to game.")
                connect_to_process()
                attempt = 0
            
            print("Did not find AP memory block... trying again shortly.")
            time.sleep(5)
            
def is_ap_block_valid():
    """
    Checks that the AP block is valid by validating our header, and status values.
    
    If they are not valid, we need to connect and scan again because the struct may 
    have moved or the game may have closed.
    """
    try:
        return (read_int(MAGIC) == 0x4150524B and
            read_int(VERSION) == 1 and
            read_int(SIGNATURE1) == 0x43110DAD and
            read_int(SIGNATURE2) == 0x1337BEEF and
            read_int(IN_STATUS) in (0,1) and 
            read_int(OUT_STATUS) in (0,1))
    except Exception:
        return False

def read_int(offset):
    """
    Helper to read the int for the given offset.
    """
    return pm.read_int(ap_base + offset)

def write_int(offset, value):
    """
    Helper to write an int to the given offset.
    """
    pm.write_int(ap_base + offset, value)
    
connect_to_process()
ap_base = None
ap_base = scan_for_ap_base()

def send_message(msg_type, data):
    """
    Sends a message to the game by:
    - Checking the IN_STATUS - if not AP_READY, do nothing, as the game is currently processing one
    - Writing the IN_TYPE and IN_DATA, so the game knows the type and what value to use
    - Writing the IN_STATUS to AP_PROCESSING so the game knows to process what we just gave it
    """
    status = read_int(IN_STATUS)

    if status != AP_READY:
        print("Game not ready for incoming message")
        return

    write_int(IN_TYPE, msg_type)
    write_int(IN_DATA, data)

    write_int(IN_STATUS, AP_PROCESSING)


def process_outgoing():
    """
    Process a message from the game by:
    - Checking the OUT_STATUS - if not AP_PROCESSING, do nothing, as the game hasn't sent anything.
    - Writing the OUT_TYPE and OUT_DATA so we have the data the game sent us.
    - Doing something based on the type - currently only AP_OUT_MSGTYPE_SEND_CHECK does something.
      - This will eventually send the info to AP that the check was received.
    - Setting AP_READY to OUT_STATUS to let the game know it can send something else.
    """
    status = read_int(OUT_STATUS)

    if status != AP_PROCESSING:
        return

    msg_type = read_int(OUT_TYPE)
    msg_data = read_int(OUT_DATA)

    if msg_type == AP_OUT_MSGTYPE_SEND_CHECK:
        print(f"Location check received: {msg_data}")

    write_int(OUT_STATUS, AP_READY)


def process_console():
    """
    Test console that reads input in a non-blocking way. Takes several commands and
    sends the info to the game.
    """
    if not msvcrt.kbhit():
        return

    cmd = input().strip()
    parts = cmd.split()

    if parts[0] == "weapon":
        send_message(AP_IN_MSGTYPE_GET_WEAPON, int(parts[1]))

    elif parts[0] == "ammo":
        send_message(AP_IN_MSGTYPE_GET_AMMO, int(parts[1]))

    elif parts[0] == "trap":
        send_message(AP_IN_MSGTYPE_GET_TRAP, int(parts[1]))
        
    elif parts[0] == "dump":
        print_memory_block()
        
    elif parts[0] == "throw":
        raise Exception("The user told me to!")

    elif parts[0] == "quit":
        exit()

print("AP bridge started")
print("Commands: weapon X, ammo X, trap X, dump")


"""
This is the main execution loop.
Each loop, checks if the AP block is not valid, throw an exception and try to connect again.
Tries to process outgoing messages, as well as console commands.
"""
while True:
    try:
        if not is_ap_block_valid():
            raise Exception("AP block disappeared")
            
        process_outgoing()
        process_console()
        time.sleep(0.1)

    except Exception:
        print("Lost connection to game. Reconnecting...")
        time.sleep(5) # If the game was closed, let it close completely

        while True:
            try:
                connect_to_process()
                ap_base = scan_for_ap_base()
                print("Reconnected successfully.")
                break
            except Exception:
                print("Reconnect failed, retrying...")
                time.sleep(3)
