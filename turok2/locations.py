from __future__ import annotations
import json
import pkgutil
from typing import TYPE_CHECKING
from BaseClasses import ItemClassification, Location, CollectionState, Entrance, Region
from worlds.generic.Rules import set_rule
from .options import GameLogicDifficulty, WeaponLogicDifficulty, Goal
from . import items

if TYPE_CHECKING:
    from .world import Turok2World

class Turok2Location(Location):
    game = "Turok 2"

LOCATION_TABLE = {}
LOCATION_NAME_TO_ID = {}

def _build_location_name_to_id():
    """
    Build the location name to id dictionary for the world to use.
    This has to be done at import time, or the world won't have it.
    """
    data = json.loads(pkgutil.get_data(__name__, "data.json").decode())

    for region_data in data.get("regions", []):
        for loc_name, loc_info in region_data.get("locations", {}).items():
            LOCATION_NAME_TO_ID[loc_name] = loc_info["ap_id"]

_build_location_name_to_id()

def create_locations(world: Turok2World) -> None:
    """
    Creates the locations by looking at all of the regions defined in the json data.
    Includes putting a "rule" property in the table to construct the rules later on.
    """
    data = json.loads(pkgutil.get_data(__name__, "data.json").decode())

    for region_data in data.get("regions", []):
        region_name = region_data["name"]
        region_obj = world.get_region(region_name)
        
        region_locations = region_data.get("locations", {})
        for loc_name, loc_info in region_locations.items():
            location = Turok2Location(
                world.player,
                loc_name,
                loc_info["ap_id"],
                region_obj
            )
            region_obj.locations.append(location)
            
            LOCATION_TABLE[loc_name] = {
                "ap_id": loc_info["ap_id"],
                "position": loc_info["position"],
                "rule": loc_info.get("rule")
            }

def create_regions_and_entrances(world: Turok2World) -> None:
    """
    Creates regions and connects them together based on the json data.
    Includes putting a "rule_json" property in the table to construct the rules later on.
    """
    data = json.loads(pkgutil.get_data(__name__, "data.json").decode())

    region_map = {}

    # Create all regions
    for region_data in data.get("regions", []):
        region_name = region_data["name"]
        region = Region(region_name, world.player, world.multiworld)
        region_map[region_name] = region
        world.multiworld.regions.append(region)

    # Connect the regions with entrances
    for region_data in data.get("regions", []):
        from_region = region_map[region_data["name"]]

        for exit_data in region_data.get("exits", []):
            to_region = region_map[exit_data["to"]]

            entrance_name = f"{from_region.name} -> {to_region.name}"
            entrance = from_region.connect(
                to_region,
                entrance_name
            )
            entrance.rule_json = exit_data.get("rule")
    
def apply_location_rules(world: Turok2World):
    """
    Set the rules grabbed from the json earlier for for each location.
    """
    for loc_name, data in LOCATION_TABLE.items():
        if data.get("rule") is not None:
            location = world.get_location(loc_name)
            rule_func = build_rule(data["rule"], world)
            set_rule(location, rule_func)

def apply_entrance_rules(world: Turok2World) -> None:
    """
    Set the rules grabbed from the json earlier for for each entrance.
    """
    for region in world.multiworld.regions:
        for entrance in region.exits:
            rule_json = getattr(entrance, "rule_json", None)

            if rule_json is not None:
                rule = build_rule(rule_json, world)
                set_rule(entrance, rule)
        
def build_rule(rule_json, world: Turok2World):
    """
    Builds the rule, given the json.
    Supports specific functions, and/or, and has, which will check for items or categories.
    - See NAMED_RULES for the specific functions supported.
    """
    player = world.player

    if isinstance(rule_json, str):
        if rule_json not in NAMED_RULES:
            raise Exception(f"Unknown named rule: {rule_json}")
        return NAMED_RULES[rule_json](world)

    if "and" in rule_json:
        subrules = [build_rule(r, world) for r in rule_json["and"]]
        return make_and_rule(subrules)

    if "or" in rule_json:
        subrules = [build_rule(r, world) for r in rule_json["or"]]
        return make_or_rule(subrules)

    if "has" in rule_json:
        return build_has_rule(rule_json["has"], world)
        
    raise Exception(f"Unknown rule: {rule_json}")
    
def make_and_rule(subrules):
    """Makes the 'and' rule."""
    return lambda state: all(rule(state) for rule in subrules)
    
def make_or_rule(subrules):
    """Makes the 'or' rule."""
    return lambda state: any(rule(state) for rule in subrules)
    
def build_has_rule(has_data, world: Turok2World):
    """
    Checks whether the player...
    - Has the given item, if passed a string
    - Has all the given items, if passed a list
    - Has the given count of items, if given an "item" object
    - Has the given count of unique items of the given category, if given a "category" object
      - If it contains an "exclude" property, will not include items in that category
    """
    player = world.player
    
    # Simple case: the string or string array is passed directly
    if isinstance(has_data, str):
        return lambda state: state.has(has_data, player)
        
    if isinstance(has_data, list):
        if not all(isinstance(x, str) for x in has_data):
            raise Exception(f"'has' list must contain only strings: {has_data}")
        return lambda state: state.has_all(has_data, player)
        
    # Complex case: "has" is an object
    item = has_data.get("item")
    category = has_data.get("category")
    count = has_data.get("count", 1)
    exclude = has_data.get("exclude", [])
    
    if item:
        return lambda state: state.has(item, player, count)
    if category:
        if category not in world.item_name_groups:
            raise Exception(f"Unknown category: {category}")
            
        base_items = set(world.item_name_groups[category])
        
        # Apply exclusions - groups and items work here
        for ex in exclude:
            if ex in world.item_name_groups:
                base_items -= set(world.item_name_groups[ex])
            elif ex in items.ITEM_TABLE:
                base_items.discard(ex)
            else:
                raise Exception(f"Unknown exclusion: {ex}")
        
        valid_items = tuple(base_items)
        return lambda state: state.has_from_list_unique(valid_items, player, count)
        
    raise Exception(f"Invalid 'has' rule: {has_data}")
    
def advanced_game_logic(world: Turok2World):
    """Checks advanced game logic is on."""
    enabled = world.options.game_logic_difficulty == GameLogicDifficulty.option_advanced
    return lambda state: enabled
    
def advanced_weapon_logic(world: Turok2World):
    """Checks advanced weapon logic is on."""
    enabled = world.options.weapon_logic_difficulty == WeaponLogicDifficulty.option_advanced
    return lambda state: enabled

NAMED_RULES = {
    "advanced_game_logic": advanced_game_logic,
    "advanced_weapon_logic": advanced_weapon_logic
}
    
def create_completion_condition(world: Turok2World):
    """
    Creates the completion condition based on the goal setting.
    - Primagen: Defeat the Primagen (vanilla) - this is the fallback
    - Hub: Get to the hub by completing Level 1
    """
    if world.options.goal == Goal.option_hub:
        victory_region = world.multiworld.get_region("Hub", world.player)
    else:
        victory_region = world.multiworld.get_region("Primagen Boss", world.player)
        
    victory_region.add_event(
        "Final Boss Defeated", 
        "Victory",
        location_type=Turok2Location, 
        item_type=items.Turok2Item
    )

    world.multiworld.completion_condition[world.player] = \
        lambda state: state.has("Victory", world.player)