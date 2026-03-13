from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import Item, ItemClassification

if TYPE_CHECKING:
    from .world import Turok2World
    
AP_IN_MSGTYPE_NONE = 0
AP_IN_MSGTYPE_GET_PICKUP = 1
AP_IN_MSGTYPE_GET_WEAPON = 2
AP_IN_MSGTYPE_GET_MISSION_ITEMS = 3
AP_IN_MSGTYPE_GET_AMMO = 4
AP_IN_MSGTYPE_GET_TRAP = 5
    
ITEM_TABLE = {
    # Pickups
    "Life Tile 1": {
        "id": 100000, 
        "actor_id": 1705,
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.filler,
        "weight": 8
    },
    "Life Tile 2": {
        "id": 100001, 
        "actor_id": 1706, 
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.filler,
        "weight": 3
    },
    "Silver Health": {
        "id": 100002,
        "actor_id": 1701,
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.useful,
        "weight": 3
    },
    "Blue Health": {
        "id": 100003,
        "actor_id": 1702,
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.useful,
        "weight": 5
    },
    "Full Health": {
        "id": 100004,
        "actor_id": 1703,
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.useful,
        "weight": 2
    },
    "Ultra Health": {
        "id": 100005,
        "actor_id": 1704,
        "msg_type": AP_IN_MSGTYPE_GET_PICKUP,
        "class": ItemClassification.useful,
        "weight": 1
    },

    # Mission items
    # TODO: hopefully we don't need the actor_id for these and can just modify the inventory instead
    "Beacon Power Cell": {
        "id": 200000,
        "actor_id": 4200,
        "msg_type": AP_IN_MSGTYPE_GET_MISSION_ITEMS,
        "class": ItemClassification.progression,
        "count": 1 # TODO: this is actually like 4, or something
    },

    # Weapons
    "Pistol": {
        "id": 300000,
        "actor_id": 2004,
        "msg_type": AP_IN_MSGTYPE_GET_WEAPON,
        "class": ItemClassification.progression,
        "count": 1 # This will unlock the pistol, we may want options for how many of these
    },

    # Ammo
    
    # TODO: make a universal ammo type
    "Clip (Pistol)": {
        "id": 400000,
        "actor_id": 2500,
        "msg_type": AP_IN_MSGTYPE_GET_AMMO,
        "class": ItemClassification.filler,
        "weight": 4
    },

    # Traps
    "Endtrail Trap": {
        "id": 900000,
        "actor_id": 201,
        "msg_type": AP_IN_MSGTYPE_GET_TRAP,
        "class": ItemClassification.trap
    }
}

ITEM_NAME_TO_ID = {
    name: data["id"]
    for name, data in ITEM_TABLE.items()
}

ID_TO_ITEM = {
    data["id"]: data for data in ITEM_TABLE.values()
}

DEFAULT_ITEM_CLASSIFICATIONS = {
    name: data["class"]
    for name, data in ITEM_TABLE.items()
}

PROGRESSION_ITEMS = [
    name for name, data in ITEM_TABLE.items()
    if data["class"] == ItemClassification.progression
]

# "Filler" items just have the filler classification, meaning they aren't useful
FILLER_ITEMS = [
    name for name, data in ITEM_TABLE.items()
    if data["class"] == ItemClassification.filler
]

# "Useful" items aren't progression, but the player might want them
# They are often in the filler item pool because they aren't required
USEFUL_ITEMS = [
    name for name, data in ITEM_TABLE.items()
    if data["class"] == ItemClassification.useful
]

TRAPS = [
    name for name, data in ITEM_TABLE.items()
    if data["class"] == ItemClassification.trap
]

class Turok2Item(Item):
    game = "Turok 2"
    
def get_random_filler_item_name(world: Turok2World) -> str:
    '''
    world.py will use this to generate filler items.
    This will generate a random filler by weight based on filler/useful items.
    '''
    items = FILLER_ITEMS + USEFUL_ITEMS
    weights = {
        name: data["weight"]
        for name, data in filler_possibilities
    }
    
    return world.random.choices(items, weights=weights, k=1)[0]
    
def create_item_with_correct_classification(world: Turok2World, name: str) -> APQuestItem:
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
    
def create_all_items(world: APQuestWorld) -> None:
    '''
    Creates all of the items that will go int the item pool.
    There must be exactly as many items as locations.
    '''
    
    # All items that must be in the pool
    # Currently, all useful and progression items
    # TODO: this can be tweaked with settings, with % of useful and filler being options
    itempool = []

    # All progression items are included
    for item in PROGRESSION_ITEMS:
        count = item.count if item.count is not None else 1
        for _ in range(item.count):
            itempool.append(world.create_item(item))

    number_of_items = len(itempool)
    
    # TODO: add guaranteed number of "fillers" to the pool
    
    # Add filler items to the pool - includes items marked as filler and useful
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    needed_number_of_filler_items = number_of_unfilled_locations - number_of_items
    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]

    world.multiworld.itempool += itempool
    
    # If we make options for this...
    # To start with items, do world.push_precollected(created_item)
    
def map_ap_item_to_game(ap_item_id):
    """
    Maps the given AP item id to the game so that the appropriate message
    type and actor id can be sent.
    
    If the item is not mapped returns NONE so the game will ignore the item.
    """
    item = ID_TO_ITEM.get(ap_item_id)
    
    if not item:
        print(f"Unknown AP item id {ap_item_id}")
        return AP_IN_MSGTYPE_NONE, 0
        
    return item["msg_type"], item["actor_id"]
 