from __future__ import annotations
from collections import Counter
from enum import Enum
from typing import TYPE_CHECKING, Callable
from BaseClasses import Item, ItemClassification
from .client.ap_memory_constants import APMessageType
from .options import NukeBehavior

if TYPE_CHECKING:
    from . import Turok2World
    
class ItemType(Enum):
    """
    Types used to filter the item table.
    """
    LIFE_FORCE = 0
    HEALTH = 1
    AMMO = 2
    LEVEL_KEY = 3
    PRIMAGEN_KEY = 4
    EAGLE_FEATHER = 5
    TALISMAN = 6
    NUKE_PART = 7
    MISSION_ITEM = 8
    WEAPON = 9
    TRAP = 10
    
class TrapType(Enum):
    """
    Trap types, so we can choose traps based on their weights.
    """
    ENEMY = 0
    DAMAGE = 1
    SPAM = 2
    
ITEM_TABLE = {
    # Pickups
    "Life Force 1": {
        "id": 100000, 
        "actor_id": 1705,
        "type": ItemType.LIFE_FORCE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 95
    },
    "Life Force 10": {
        "id": 100001, 
        "actor_id": 1706, 
        "type": ItemType.LIFE_FORCE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 5
    },
    
    "Silver Health": {
        "id": 100002,
        "actor_id": 1701,
        "type": ItemType.HEALTH.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 25
    },
    "Blue Health": {
        "id": 100003,
        "actor_id": 1702,
        "type": ItemType.HEALTH.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 65
    },
    "Full Health": {
        "id": 100004,
        "actor_id": 1703,
        "type": ItemType.HEALTH.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 7
    },
    "Ultra Health": {
        "id": 100005,
        "actor_id": 1704,
        "type": ItemType.HEALTH.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_PICKUP.value,
        "class": ItemClassification.filler,
        "weight": 3
    },
    
    # Ammo
    "Random Ammo Pack": {
        "id": 400000,
        "actor_id": 30000, # This is limited to an int16 in-game
        "type": ItemType.AMMO.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_AMMO.value,
        "class": ItemClassification.filler,
        "weight": 4
    },

    # Inventory items
    "Level 2 Key": {
        "id": 200001,
        "actor_id": 4310,
        "type": ItemType.LEVEL_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 3 Key": {
        "id": 200002,
        "actor_id": 4320,
        "type": ItemType.LEVEL_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 4 Key": {
        "id": 200003,
        "actor_id": 4330,
        "type": ItemType.LEVEL_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 5 Key": {
        "id": 200004,
        "actor_id": 4340,
        "type": ItemType.LEVEL_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },
    "Level 6 Key": {
        "id": 200005,
        "actor_id": 4350,
        "type": ItemType.LEVEL_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 6
    },
    
    "Primagen Key 1": {
        "id": 200006,
        "actor_id": 4360,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 2": {
        "id": 200007,
        "actor_id": 4361,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 3": {
        "id": 200008,
        "actor_id": 4362,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 4": {
        "id": 200009,
        "actor_id": 4363,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 5": {
        "id": 200010,
        "actor_id": 4364,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    "Primagen Key 6": {
        "id": 200011,
        "actor_id": 4365,
        "type": ItemType.PRIMAGEN_KEY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression_skip_balancing,
        "count": 1
    },
    
    "Level 2 Eagle Feather": {
        "id": 200012,
        "actor_id": 4402,
        "type": ItemType.EAGLE_FEATHER.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 3 Eagle Feather": {
        "id": 200013,
        "actor_id": 4400,
        "type": ItemType.EAGLE_FEATHER.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 4 Eagle Feather": {
        "id": 200014,
        "actor_id": 4404,
        "type": ItemType.EAGLE_FEATHER.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 5 Eagle Feather": {
        "id": 200015,
        "actor_id": 4403,
        "type": ItemType.EAGLE_FEATHER.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Level 6 Eagle Feather": {
        "id": 200016,
        "actor_id": 4401,
        "type": ItemType.EAGLE_FEATHER.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    
    "Leap of Faith": {
        "id": 200017,
        "actor_id": 4382,
        "type": ItemType.TALISMAN.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Breath of Life": {
        "id": 200018,
        "actor_id": 4380,
        "type": ItemType.TALISMAN.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Heart of Fire": {
        "id": 200019,
        "actor_id": 4384,
        "type": ItemType.TALISMAN.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Whispers": {
        "id": 200020,
        "actor_id": 4383,
        "type": ItemType.TALISMAN.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    "Eye of Truth": {
        "id": 200021,
        "actor_id": 4381,
        "type": ItemType.TALISMAN.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 1
    },
    
    "Nuke Part": {
        "id": 200022,
        "actor_id": 4500,
        "type": ItemType.NUKE_PART.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.useful,
        "count": 6
    },
    
    "Beacon Power Cell": {
        "id": 200100,
        "actor_id": 4200,
        "type": ItemType.MISSION_ITEM.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value,
        "class": ItemClassification.progression,
        "count": 3
    },

    # Weapons
    "War Blade": {
        "id": 300000,
        "actor_id": 2001,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Underwater Weapon", "Melee Weapon"]
    },
    "Tek Bow": {
        "id": 300001,
        "actor_id": 2002,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Long Range"]
    },
    "Pistol": {
        "id": 300002,
        "actor_id": 2004,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bird Killer"]
    },
    "Mag 60": {
        "id": 300003,
        "actor_id": 2005,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bird Killer", "Good Weapon"]
    },
    "Tranquilizer Gun": {
        "id": 300004,
        "actor_id": 2006,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bad Weapon"]
    },
    "Charge Dart Rifle": {
        "id": 300005,
        "actor_id": 2007,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Good Weapon"]
    },
    "Shotgun": {
        "id": 300006,
        "actor_id": 2008,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bird Killer", "Good Weapon"]
    },
    "Shredder": {
        "id": 300007,
        "actor_id": 2009,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bird Killer", "Good Weapon"]
    },
    "Plasma Rifle": {
        "id": 300008,
        "actor_id": 2010,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Long Range", "Bird Killer", "Good Weapon"]
    },
    "Firestorm Cannon": {
        "id": 300009,
        "actor_id": 2011,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Long Range", "Bird Killer", "Good Weapon"]
    },
    "Sunfire Pod": {
        "id": 300010,
        "actor_id": 2012,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bad Weapon"]
    },
    "Cerebral Bore": {
        "id": 300011,
        "actor_id": 2014,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Good Weapon"]
    },
    "P.F.M. Layer": {
        "id": 300012,
        "actor_id": 2015,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bad Weapon"]
    },
    "Grenade Launcher": {
        "id": 300013,
        "actor_id": 2016,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Good Weapon"]
    },
    "Scorpion Launcher": {
        "id": 300014,
        "actor_id": 2017,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Long Range", "Good Weapon"]
    },
    "Flame Thrower": {
        "id": 300015,
        "actor_id": 2110,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Good Weapon"]
    },
    "Razor Wind": {
        "id": 300016,
        "actor_id": 2111,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Good Weapon"]
    },
    "Harpoon Gun": {
        "id": 300017,
        "actor_id": 2100,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Underwater Weapon", "Bad Weapon"]
    },
    "Torpedo Launcher": {
        "id": 300018,
        "actor_id": 2101,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression, # Needed in Level 4
        "count": 1,
        "groups": ["Underwater Weapon", "Bad Weapon"]
    },
    "Nuke": {
        "id": 300019,
        "actor_id": 2112,
        "type": ItemType.WEAPON.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_WEAPON.value,
        "class": ItemClassification.progression,
        "count": 1,
        "groups": ["Land Weapon", "Bad Weapon"] # Bad in terms of ammo
    },

    # Traps
    "Enemy Trap (Silver Health)": {
        "id": 900000,
        "actor_id": 900000,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.ENEMY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 25
    },
    "Enemy Trap (Blue Health)": {
        "id": 900001,
        "actor_id": 900001,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.ENEMY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 65
    },
    "Enemy Trap (Full Health)": {
        "id": 900002,
        "actor_id": 900002,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.ENEMY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 7
    },
    "Enemy Trap (Ultra Health)": {
        "id": 900003,
        "actor_id": 900003,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.ENEMY.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 3
    },
    
    "Damage Trap (Silver Health)": {
        "id": 900010,
        "actor_id": 900010,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.DAMAGE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 25
    },
    "Damage Trap (Blue Health)": {
        "id": 900011,
        "actor_id": 900011,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.DAMAGE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 65
    },
    "Damage Trap (Full Health)": {
        "id": 900012,
        "actor_id": 900012,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.DAMAGE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 7
    },
    "Damage Trap (Ultra Health)": {
        "id": 900013,
        "actor_id": 900013,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.DAMAGE.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 3
    },
    
    "Spam Trap (Silver Health)": {
        "id": 900020,
        "actor_id": 900020,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.SPAM.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 25
    },
    "Spam Trap (Blue Health)": {
        "id": 900021,
        "actor_id": 900021,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.SPAM.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 65
    },
    "Spam Trap (Full Health)": {
        "id": 900022,
        "actor_id": 900022,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.SPAM.value,
        "msg_type": APMessageType.AP_IN_MSGTYPE_GET_TRAP.value,
        "class": ItemClassification.trap,
        "weight": 7
    },
    "Spam Trap (Ultra Health)": {
        "id": 900023,
        "actor_id": 900023,
        "type": ItemType.TRAP.value,
        "trap_type": TrapType.SPAM.value,
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

TRAPS_BY_CATEGORY = {}

TRAPS = {
    name: data
    for name, data in ITEM_TABLE.items()
    if data["type"] == ItemType.TRAP.value
}

LIFE_FORCES = {
    name: data
    for name, data in ITEM_TABLE.items()
    if data["type"] == ItemType.LIFE_FORCE.value
}

HEALTH_PICKUPS = {
    name: data
    for name, data in ITEM_TABLE.items()
    if data["type"] == ItemType.HEALTH.value
}

def get_item_name_groups() -> dict[str, set[str]]:
    groups: dict[str, set[str]] = {}

    for name, data in ITEM_TABLE.items():
        for group in data.get("groups", []):
            groups.setdefault(group, set()).add(name)

    return groups

def get_required_seed_items(world: Turok2World):
    """
    All items required to be in the seed.
    These are all weapons, and all inventory items, depending on settings
    """
    def include_item(name, data):
        # Nuke item special cases
        if name == "Nuke":
            return world.options.nuke_behavior == NukeBehavior.option_weapon_pickup
        if name == "Nuke Part":
            return world.options.nuke_behavior == NukeBehavior.option_nuke_part_hunt
        
        # Mission items depend on the setting (they are also inventory items, so do this first)
        if data["type"] == ItemType.MISSION_ITEM.value:
            return world.options.include_mission_item_locations
        
        # Inventory items always included (for now)
        if data["msg_type"] == APMessageType.AP_IN_MSGTYPE_GET_INVENTORY_ITEM.value:
            return True
        
        # Other weapons depend on whether they are shuffled
        if data["type"] == ItemType.WEAPON.value:
            return world.options.include_weapon_and_ammo_locations

        return False

    return [
        (name, data)
        for name, data in ITEM_TABLE.items()
        if include_item(name, data)
    ]

class Turok2Item(Item):
    game = "Turok 2"
    
def get_random_filler_item_name(world: Turok2World) -> str:
    """
    world.py will use this to generate filler items.
    This will generate a random filler by the item weights set in the options.
    """
    categories = [
        (ItemType.HEALTH.value, world.options.junk_item_pool_health_weight),
        (ItemType.AMMO.value, world.options.junk_item_pool_ammo_weight),
        (ItemType.LIFE_FORCE.value, world.options.junk_item_pool_life_force_weight),
        (ItemType.TRAP.value, world.options.junk_item_pool_trap_weight)
    ]
    category_names = [name for name, _ in categories]
    category_weights = [weight for _, weight in categories]
    
    # Pick a category
    chosen_category = world.random.choices(category_names, weights=category_weights, k=1)[0]

    # Pick an item from that category
    if chosen_category == ItemType.HEALTH.value:
        return get_random_health_pickup_item_name(world)
    elif chosen_category == ItemType.AMMO.value:
        return get_random_ammo_pickup_item_name(world)
    elif chosen_category == ItemType.TRAP.value:
        return get_random_trap_item_name(world)
    else:
        # Acts as the fallback
        return get_random_life_force_item_name(world)
    
def create_item_with_correct_classification(world: Turok2World, name: str) -> Turok2Item:
    """
    Creates an item by name. This is here in case we ever need to change the
    classification of any item based on the options the player chooses.
    """
    classification = DEFAULT_ITEM_CLASSIFICATIONS[name]

    return Turok2Item(
        name,
        classification,
        ITEM_NAME_TO_ID[name],
        world.player
    )

def get_random_trap_item_name(world: Turok2World) -> str | None:
    """
    Gets a random trap name to add to the item pool.
    First, chooses the category based on the options.
    Next, chooses the specific item by weighing the different game models.
    """
    # Choose the trap category
    categories = [
        (TrapType.ENEMY.value, world.options.enemy_trap_weight),
        (TrapType.DAMAGE.value, world.options.damage_trap_weight),
        (TrapType.SPAM.value, world.options.spam_trap_weight)
    ]
    categories = [(name, weight) for name, weight in categories if weight > 0]
    
    if not categories:
        return None
    
    category_names = [name for name, _ in categories]
    category_weights = [weight for _, weight in categories]
    category = world.random.choices(category_names, weights=category_weights, k=1)[0]
    
    # Choose the trap item (the model that will appear in the game)
    items = TRAPS_BY_CATEGORY[category]
    if not items:
        return None
    
    names = [name for name, _ in items]
    weights = [data.get("weight", 1) for _, data in items]
    
    return world.random.choices(names, weights=weights, k=1)[0]
    
def get_random_life_force_item_name(world: Turok2World) -> str:
    """
    Gets a random life force.
    """
    names = list(LIFE_FORCES.keys())
    weights = [data.get("weight", 1) for data in LIFE_FORCES.values()]
    return world.random.choices(names, weights=weights, k=1)[0]
    
def get_random_health_pickup_item_name(world: Turok2World) -> str:
    """
    Gets a random health pickup.
    """
    names = list(HEALTH_PICKUPS.keys())
    weights = [data.get("weight", 1) for data in HEALTH_PICKUPS.values()]
    return world.random.choices(names, weights=weights, k=1)[0]
    
def get_random_ammo_pickup_item_name(world: Turok2World) -> str:
    """
    Gets a random ammo pickup. There's currently only one, so just return it.
    """
    return "Random Ammo Pack"
    
def add_items_to_itempool(
    world: Turok2World,
    itempool: list[Item],
    number_of_unfilled_locations: int,
    percentage_sum: int,
    item_fill_percent: int,
    get_item_name_function: Callable[[Turok2World], str | None]):
    """
    Adds items to the item pool based on the percentage sum, and the percent given.
    If the sum if > 100, treat the percent as a ratio of the given sum. 
    Otherwise, use it as the percent.
    """
    if item_fill_percent <= 0:
        return
    
    if percentage_sum > 100:
        ratio = item_fill_percent / percentage_sum
    else:
        ratio = item_fill_percent / 100.0
    
    # Any rounding error will be lower than expected, which is okay
    count = int(number_of_unfilled_locations * ratio)
    
    for _ in range(count):
        name = get_item_name_function(world)
        if name:
            itempool.append(world.create_item(name))
    
def force_local_items(world: Turok2World, itempool: list[Item], item_type: int, percentage: int):
    """
    Forces the percentage of items in the item pool of the given type to
    be placed in this world.
    """
    items = [
        item for item in itempool
        if ITEM_TABLE[item.name].get("type", -1) == item_type
    ]
    world.multiworld.random.shuffle(items) # Avoids bias for earlier items
    
    locations = [
        loc for loc in world.multiworld.get_unfilled_locations(world.player)
        if loc.address is not None
        and not loc.locked
        and loc.item is None
        and loc.parent_region.name != world.origin_region_name
    ]

    # Don't try to force more items than there are locations
    count = int(len(items) * percentage / 100)
    count = min(count, len(locations))
    selected_items = items[:count]
    
    world.multiworld.random.shuffle(locations) # Avoids bias for earlier locations
    for item, loc in zip(selected_items, locations):
        loc.place_locked_item(item)
        itempool.remove(item)
        
    print(f"Forced {count} {ItemType(item_type)} items locally for Player {world.player}")

def try_force_early_weapon(world: Turok2World, itempool: list[Item]):
    """
    If the setting is on, forces a land weapon that is not bad into the starting area.
    """
    if not world.options.include_weapon_and_ammo_locations or not world.options.force_early_weapon:
        return
        
    def is_valid_early_weapon(item_name: str) -> bool:
        data = ITEM_TABLE[item_name]

        groups = data.get("groups", [])
        return ("Land Weapon" in groups 
            and "Bad Weapon" not in groups
            and "Melee Weapon" not in groups)

    weapon_items = [
        item for item in itempool
        if is_valid_early_weapon(item.name)
    ]
    
    # If we don't have a valid weapon, use any
    if not weapon_items:
        weapon_items = [
            item for item in itempool
            if ITEM_TABLE[item.name].get("type", "-1") == ItemType.WEAPON.value
        ]

    starting_locations = [
        loc for loc in world.multiworld.get_unfilled_locations(world.player)
        if loc.parent_region.name == world.origin_region_name
        and loc.address is not None
        and not loc.locked
        and loc.item is None
    ]
    
    if weapon_items and starting_locations:
        weapon = world.multiworld.random.choice(weapon_items)
        location = world.multiworld.random.choice(starting_locations)
        location.place_locked_item(weapon)
        itempool.remove(weapon)
        
        print(f"Placed early weapon {weapon.name} at {location.name} for Player {world.player}")


def create_all_items(world: Turok2World) -> None:
    """
    Creates all of the items that will go into the item pool.
    There must be exactly as many items as locations.
    """
    itempool: list[Item] = []
    
    # Populate the traps dictionary
    for name, data in TRAPS.items():
        trap_type = data["trap_type"]
        if trap_type is None:
            continue
        TRAPS_BY_CATEGORY.setdefault(trap_type, []).append((name, data))

    # Add all the required items to the pool (weapons and inventory items)
    for name, data in get_required_seed_items(world):
        for _ in range(data.get("count", 1)):
            itempool.append(world.create_item(name))
         
    # Fill the world with fillers
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    number_of_items = len(itempool)
    needed_number_of_filler_items = max(0, number_of_unfilled_locations - number_of_items)
    
    percentage_sum_of_minimum_items = (
        world.options.minimum_health_percent + 
        world.options.minimum_ammo_percent + 
        world.options.minimum_life_force_percent)
        
    add_items_to_itempool(
        world,
        itempool,
        needed_number_of_filler_items,
        percentage_sum_of_minimum_items,
        world.options.minimum_health_percent,
        get_random_health_pickup_item_name)
    add_items_to_itempool(
        world,
        itempool,
        needed_number_of_filler_items,
        percentage_sum_of_minimum_items,
        world.options.minimum_ammo_percent,
        get_random_ammo_pickup_item_name)
    add_items_to_itempool(
        world,
        itempool,
        needed_number_of_filler_items,
        percentage_sum_of_minimum_items,
        world.options.minimum_life_force_percent,
        get_random_life_force_item_name)
    
    # Recompute the number of filler items needed
    number_of_unfilled_locations = len(world.multiworld.get_unfilled_locations(world.player))
    number_of_items = len(itempool)
    needed_number_of_filler_items = max(0, number_of_unfilled_locations - number_of_items)
    
    # Fill out the rest of the pool (calls get_random_filler_item_name)
    itempool += [world.create_filler() for _ in range(needed_number_of_filler_items)]

    # Force local items depending on options
    try_force_early_weapon(world, itempool)
    force_local_items(world, itempool, ItemType.HEALTH.value, world.options.local_health_percentage)
    force_local_items(world, itempool, ItemType.AMMO.value, world.options.local_ammo_percentage)
    force_local_items(world, itempool, ItemType.WEAPON.value, world.options.local_weapon_percentage)

    world.multiworld.itempool += itempool
    
    """
    Print out the item pool by type for debugging
    Leave this commented out in released versions
    """
    
    type_counts: dict[ItemType, int] = Counter()
    total_items = len(itempool)

    for item in itempool:
        item_type = ItemType(ITEM_TABLE[item.name]["type"])
        type_counts[item_type] += 1

    print(f"Item pool summary for player {world.player}:")
    for item_type, count in type_counts.items():
        percentage = (count / total_items) * 100
        print(f"{item_type.name}: {count} ({percentage:.1f}%)")
    
    
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
 