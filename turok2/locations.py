from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import ItemClassification, Location
from . import items

if TYPE_CHECKING:
    from .world import APQuestWorld

LOCATION_NAME_TO_ID = {
    "PoA Start - LF1 on Box": 51000,
    "PoA Start - LF1 in Left Ship Half 1": 51001,
    "PoA Start - LF1 in Left Ship Half 2": 51002,
    "PoA Start - LF1 After First Ladder 1": 51003,
    "PoA Start - LF1 After First Ladder 2": 51004,
    "PoA Start - LF1 After First Ladder 3": 51005,
    "PoA Start - LF1 After First Ladder 4": 51006,
    "PoA Start - LF10 in Left Ship Half": 51007,
    "PoA Start - LF10 in Right Ship Half 1": 51008,
    "PoA Start - LF10 in Right Ship Half 2": 51009,
    "PoA Start - LF10 in Right Ship Half 3": 51010,
    "PoA Start - LF10 Underwater Alcove 1": 51011,
    "PoA Start - LF10 Underwater Alcove 2": 51012,
    "PoA Start - LF10 Underwater Alcove 3": 51013,
    "PoA Start - LF10 Underwater Alcove 4": 51014,
    "PoA Start - LF10 Underwater Alcove 5": 51015,
    "PoA Start - Arrows on Boxes": 51016,
    "PoA Start - Power Cell": 51017,
    "PoA Start - Pistol": 51018
}

class Turok2Location(Location):
    game = "Turok 2"
    
def get_location_names_with_ids(location_names: list[str]) -> dict[str, int | None]:
    '''
    Helper fuunction to assist with creating locations.
    Gets all matching locations in the listed name.
    '''
    return ({location_name: LOCATION_NAME_TO_ID[location_name] for location_name in location_names})
    
def get_location_names_with_prefix(prefix: str) -> dict[str, int | None]:
    '''
    Helper fuunction to assist with creating locations.
    Gets all locations matching the given prefix (DO NOT include the hyphen part)
    '''
    full_prefix = prefix + " - "
    return {name: loc_id for name, loc_id in LOCATION_NAME_TO_ID.items() if name.startswith(full_prefix)}

def create_all_locations(world: APQuestWorld) -> None:
    create_regular_locations(world)
    create_events(world)

def create_regular_locations(world: APQuestWorld) -> None:
    '''
    Creates all locations. Locations are added to the regions
    created in region.py.
    '''
    entireGame = world.get_region("Entire Game")
    entireGame.add_locations(
        get_location_names_with_prefix("PoA Start"),
        Turok2Location)
    
def create_events(world: APQuestWorld) -> None:
    '''
    Define any events here that aren't just having an item.
    We will probably put mission objectives here.
    '''
    pass