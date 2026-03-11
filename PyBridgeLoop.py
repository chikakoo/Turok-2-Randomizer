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

IN_STATUS = 8
IN_TYPE = 12
IN_DATA = 16

OUT_STATUS = 20
OUT_TYPE = 24
OUT_DATA = 28

# Processing
PROCESS = "horus_Shipping_Playfab_Steam_x64.exe"

pm = pymem.Pymem(PROCESS)

pattern = b"\x4B\x52\x50\x41\x01\x00\x00\x00" + (b"\x00\x00\x00\x00" * 6)

ap_base = pymem.pattern.pattern_scan_all(
    pm.process_handle,
    pattern
)

if not ap_base:
    raise RuntimeError("AP block not found")

print(f"Found AP block at {hex(ap_base)}")

# Print the memory block to see if it's correct
#for i in range(0, 64, 4):
#    val = struct.unpack("<I", block[i:i+4])[0]
#    print(f"{i:02X}: {val} (0x{val:08X})")

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

    elif parts[0] == "quit":
        exit()

print("AP bridge started")
print("Commands: weapon X, ammo X, trap X")

while True:
    process_outgoing()
    process_console()
