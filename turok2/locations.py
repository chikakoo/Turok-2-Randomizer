from __future__ import annotations
import json
import pkgutil
from typing import TYPE_CHECKING
from BaseClasses import ItemClassification, Location, CollectionState
from worlds.generic.Rules import set_rule
from .options import GameLogicDifficulty, WeaponLogicDifficulty
from . import items

if TYPE_CHECKING:
    from .world import Turok2World

class Turok2Location(Location):
    game = "Turok 2"

LOCATION_TABLE = {}
LOCATIONS_BY_ID = {}

def create_all_locations(world: Turok2World) -> None:
    
    data = json.loads(pkgutil.get_data(__name__, "data.json").decode())

    for region in data.get("regions", []):
        region_locations = region.get("locations", {})
        for loc_name, loc_info in region_locations.items():
            LOCATION_TABLE[loc_name] = {
                "ap_id": loc_info["ap_id"],
                "position": loc_info["position"],
                "rule": loc_info.get("rule")
            }
            LOCATIONS_BY_ID[loc_info["ap_id"]] = loc_name
            
    # TODO: set up regions from the json so things link correctly
    entireGame = world.get_region("Entire Game")
    entireGame.add_locations(
        LOCATION_TABLE,
        Turok2Location)
        
    apply_location_rules(world)
    
def apply_location_rules(world: Turok2World):
    for loc_name, data in LOCATION_TABLE.items():
        if data.get("rule") is not None:
            location = world.get_location(loc_name)
            rule_func = build_rule(data["rule"], world)
            set_rule(location, rule_func)
        
def build_rule(rule_json, world: Turok2World):
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
    return lambda state: all(rule(state) for rule in subrules)
    
def make_or_rule(subrules):
    return lambda state: any(rule(state) for rule in subrules)
    
def build_has_rule(has_data, world: Turok2World):
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
        return lambda state: state.has_from_list(valid_items, player, count)
        
    raise Exception(f"Invalid 'has' rule: {has_data}")
    
def advanced_game_logic(world: Turok2World):
    enabled = world.options.game_logic_difficulty == GameLogicDifficulty.option_advanced
    return lambda state: enabled
    
def advanced_weapon_logic(world: Turok2World):
    enabled = world.options.weapon_logic_difficulty == WeaponLogicDifficulty.option_advanced
    return lambda state: enabled
    
NAMED_RULES = {
    "advanced_game_logic": advanced_game_logic,
    "advanced_weapon_logic": advanced_weapon_logic
}