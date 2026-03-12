import pymem
import time
import struct
import msvcrt

# Enum values
AP_READY = 0
AP_PROCESSING = 1

AP_MSGTYPE_NONE = 0

AP_IN_MSGTYPE_GET_WEAPON = 1
AP_IN_MSGTYPE_GET_AMMO = 2
AP_IN_MSGTYPE_GET_TRAP = 3

AP_OUT_MSGTYPE_SEND_CHECK = 4

# Memory offsets
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
    global pm

    while True:
        try:
            pm = pymem.Pymem(PROCESS)
            print(f"Connected to {PROCESS}")
            return
        except Exception:
            print(f"Could not connect to {PROCESS}... Trying again shortly.")
            time.sleep(5)
    
# Print the memory block to see if it's correct
# Turn off if not debugging
def print_memory_block():
    block = pm.read_bytes(ap_base, 64)
    for i in range(0, 64, 4):
        val = struct.unpack("<I", block[i:i+4])[0]
        print(f"{i:02X}: {val} (0x{val:08X})")

def scan_for_ap_base():
    attempt = 0
    while True:
        try:            
            addr = pymem.pattern.pattern_scan_all(
                pm.process_handle,
                pattern
            )
            
            #print_memory_block()
            
            if not addr or not is_valid_ap_block(addr):
                raise
            
            print(f"Found AP block at {hex(addr)}")
            return addr
                
        except:
            attempt += 1
            if attempt > 5:
                print("Couldn't find AP memory block after 5 tries, trying to reconnect to game.")
                connect_to_process()
                attempt = 0
            
            print("Did not find AP memory block... trying again shortly.")
            time.sleep(3)
            
def is_valid_ap_block(addr):
    if pm.read_int(addr + VERSION) != 1:
        return False

    incoming_status = pm.read_int(addr + IN_STATUS)
    outgoing_status = pm.read_int(addr + OUT_STATUS)
    
    return (incoming_status in (0,1) and 
        outgoing_status in (0,1))
        
connect_to_process()
ap_base = scan_for_ap_base()

def read_int(offset):
    return pm.read_int(ap_base + offset)

def write_int(offset, value):
    pm.write_int(ap_base + offset, value)

def send_message(msg_type, data):
    status = read_int(IN_STATUS)

    if status != AP_READY:
        print("Game not ready for incoming message")
        return

    write_int(IN_TYPE, msg_type)
    write_int(IN_DATA, data)

    write_int(IN_STATUS, AP_PROCESSING)


def process_outgoing():
    status = read_int(OUT_STATUS)

    if status != AP_PROCESSING:
        return

    msg_type = read_int(OUT_TYPE)
    msg_data = read_int(OUT_DATA)

    if msg_type == AP_OUT_MSGTYPE_SEND_CHECK:
        print(f"Location check received: {msg_data}")

    write_int(OUT_STATUS, AP_READY)


def process_console():
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

    elif parts[0] == "quit":
        exit()

print("AP bridge started")
print("Commands: weapon X, ammo X, trap X, dump")

while True:
    try:
        if read_int(MAGIC) != 0x4150524B:
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
