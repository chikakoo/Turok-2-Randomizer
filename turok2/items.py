from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import Item, ItemClassification
from .client.ap_memory_constants import APMessageType

if TYPE_CHECKING:
    from .world import Turok2World
    
ITEM_TABLE = {
    # Pickups
    "Life Tile 1": {
        "id": 100000, 
        "actor_id": 1705,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 8
    },
    "Life Tile 10": {
        "id": 100001, 
        "actor_id": 1706, 
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 3
    },
    "Silver Health": {
        "id": 100002,
        "actor_id": 1701,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 3
    },
    "Blue Health": {
        "id": 100003,
        "actor_id": 1702,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 5
    },
    "Full Health": {
        "id": 100004,
        "actor_id": 1703,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.useful,
        "weight": 2
    },
    "Ultra Health": {
        "id": 100005,
        "actor_id": 1704,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.useful,
        "weight": 1
    },

    # Inventory items
    "Level 2 Key": {
        "id": 200001,
        "actor_id": 4310,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 3 Key": {
        "id": 200002,
        "actor_id": 4320,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 4 Key": {
        "id": 200003,
        "actor_id": 4330,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 5 Key": {
        "id": 200004,
        "actor_id": 4340,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 6 Key": {
        "id": 200005,
        "actor_id": 4350,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 6
    },
    
    "Primagen Key 1": {
        "id": 200006,
        "actor_id": 4360,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 2": {
        "id": 200007,
        "actor_id": 4361,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 3": {
        "id": 200008,
        "actor_id": 4362,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 4": {
        "id": 200009,
        "actor_id": 4363,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 5": {
        "id": 200010,
        "actor_id": 4364,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 6": {
        "id": 200011,
        "actor_id": 4365,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    
    "Level 2 Eagle Feather": {
        "id": 200012,
        "actor_id": 4402,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 3 Eagle Feather": {
        "id": 200013,
        "actor_id": 4400,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 4 Eagle Feather": {
        "id": 200014,
        "actor_id": 4404,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 5 Eagle Feather": {
        "id": 200015,
        "actor_id": 4403,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 6 Eagle Feather": {
        "id": 200016,
        "actor_id": 4401,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    
    "Leap of Faith": {
        "id": 200017,
        "actor_id": 4382,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Breath of Life": {
        "id": 200018,
        "actor_id": 4380,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Heart of Fire": {
        "id": 200019,
        "actor_id": 4384,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Whispers": {
        "id": 200020,
        "actor_id": 4383,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Eye of Truth": {
        "id": 200021,
        "actor_id": 4381,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    
    "Nuke Part": {
        "id": 200022,
        "actor_id": 4500,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.useful,
        "count": 6
    },
    
    "Beacon Power Cell": {
        "id": 200100,
        "actor_id": 4200,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },

    # Weapons
    "War Blade": {
        "id": 300000,
        "actor_id": 2001,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.useful,
        "count": 1
    },
    "Tek Bow": {
        "id": 300001,
        "actor_id": 2002,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Pistol": {
        "id": 300002,
        "actor_id": 2004,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Mag 60": {
        "id": 300003,
        "actor_id": 2005,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Tranquilizer Gun": {
        "id": 300004,
        "actor_id": 2006,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.useful,
        "count": 1
    },
    "Charge Dart Rifle": {
        "id": 300005,
        "actor_id": 2007,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Shotgun": {
        "id": 300006,
        "actor_id": 2008,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Shredder": {
        "id": 300007,
        "actor_id": 2009,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Plasma Rifle": {
        "id": 300008,
        "actor_id": 2010,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Firestorm Cannon": {
        "id": 300009,
        "actor_id": 2011,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Sunfire Pod": {
        "id": 300010,
        "actor_id": 2012,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.useful,
        "count": 1
    },
    "Cerebral Bore": {
        "id": 300011,
        "actor_id": 2014,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "P.F.M. Layer": {
        "id": 300012,
        "actor_id": 2015,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.useful,
        "count": 1
    },
    "Grenade Launcher": {
        "id": 300013,
        "actor_id": 2016,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Scorpion Launcher": {
        "id": 300014,
        "actor_id": 2017,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Flame Thrower": {
        "id": 300015,
        "actor_id": 2110,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Razor Wind": {
        "id": 300016,
        "actor_id": 2111,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Harpoon Gun": {
        "id": 300017,
        "actor_id": 2100,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.useful,
        "count": 1
    },
    "Torpedo Launcher": {
        "id": 300018,
        "actor_id": 2101,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Nuke": {
        "id": 300019,
        "actor_id": 2112,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1 # Setting in yaml to not have nuke parts
    },
    
    # Ammo
    "Random Ammo Pack": {
        "id": 400000,
        "actor_id": 400000,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_AMMO.value,
        "class": ItemClassification.filler,
        "weight": 4
    },

    # Traps
    "Enemy Trap (Silver Health)": {
        "id": 900000,
        "actor_id": 900000,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 25
    },
    "Enemy Trap (Blue Health)": {
        "id": 900001,
        "actor_id": 900001,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 65
    },
    "Enemy Trap (Full Health)": {
        "id": 900002,
        "actor_id": 900002,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 7
    },
    "Enemy Trap (Ultra Health)": {
        "id": 900003,
        "actor_id": 900003,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 3
    }
}

ITEM_NAME_TO_ID = {
    name: data["id"]
    for name, data in ITEM_TABLE.items()
}

ID_TO_ITEM = {
    data["id"]: (name, data)
    for name, data in ITEM_TABLE.items()
}

DEFAULT_ITEM_CLASSIFICATIONS = {
    name: data["class"]
    for name, data in ITEM_TABLE.items()
}

def get_progression_items():
    return [
        (name, data)
        for name, data in ITEM_TABLE.items()
        if data["class"] == ItemClassification.progression
    ]


def get_filler_items():
    return [
        (name, data)
        for name, data in ITEM_TABLE.items()
        if data["class"] == ItemClassification.filler
    ]


def get_useful_items():
    return [
        (name, data)
        for name, data in ITEM_TABLE.items()
        if data["class"] == ItemClassification.useful
    ]


def get_traps():
    return [
        (name, data)
        for name, data in ITEM_TABLE.items()
        if data["class"] == ItemClassification.trap
    ]

class Turok2Item(Item):
    game = "Turok 2"
    
def get_random_filler_item_name(world: Turok2World) -> str:
    '''
    world.py will use this to generate filler items.
    This will generate a random filler by weight based on filler/useful items.
    '''
    items = get_filler_items() + get_useful_items()
    names = [name for name, _ in items]
    weights = [data.get("weight", 3) for _, data in items]
    
    return world.random.choices(names, weights=weights, k=1)[0]
    
def create_item_with_correct_classification(world: Turok2World, name: str) -> Turok2Item:
    '''
    Creates an item by name. This is here in case we ever need to change the
    classification of any item based on the options the player chooses.
    '''
    classification = DEFAULT_ITEM_CLASSIFICATIONS[name]

    return Turok2Item(
        name,
        classification,
        ITEM_NAME_TO_ID[name],
        world.player
    )
    
def create_all_items(world: Turok2World) -> None:
    '''
    Creates all of the items that will go into the item pool.
    There must be exactly as many items as locations.
    '''
    
    # All items that must be in the pool
    # Currently, all useful and progression items
    # TODO: this can be tweaked with settings, with % of useful and filler being options
    itempool = []

    # All progression items are included
    for name, data in get_progression_items():
        for _ in range(data.get("count", 1)):
            itempool.append(world.create_item(name))

    number_of_items = len(itempool)
    
    # TODO: add guaranteed number of "fillers" to the pool
    
    # Add filler items to the pool - includes items marked as filler and useful
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = max(0, number_of_unfilled_locations - number_of_items)
    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]

    world.multiworld.itempool += itempool
    
    # If we make options for this...
    # To start with items, do world.push_precollected(created_item)
    
def map_ap_item_to_game(ap_item_id) -> tuple[int, int]:
    """
    Maps the given AP item id to the game so that the appropriate message
    type and actor id can be sent.
    
    If the item is not mapped returns NONE so the game will ignore the item.
    """
    name, item = ID_TO_ITEM.get(ap_item_id, (None, None))
    
    if not item:
        print(f"Unknown AP item id {ap_item_id}")
        return APMessageType.AP_MSGTYPE_NONE.value, 0
        
    return item["msg_type"], item.get("actor_id", 0)
 