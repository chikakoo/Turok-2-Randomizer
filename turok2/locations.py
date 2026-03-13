from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import ItemClassification, Location
from . import items

if TYPE_CHECKING:
    from .world import APQuestWorld

LOCATION_TABLE = {
    "PoA Start - LF1 on Box": { "ap_id": 51000, "position": "51_702_-660_-153" },
    "PoA Start - LF1 in Left Ship Half 1": { "ap_id": 51001, "position": "51_-1342_116_-1095" },
    "PoA Start - LF1 in Left Ship Half 2": { "ap_id": 51002, "position": "51_-1405_86_-1095" },
    "PoA Start - LF1 After First Ladder 1": { "ap_id": 51003, "position": "51_2203_1180_0" },
    "PoA Start - LF1 After First Ladder 2": { "ap_id": 51004, "position": "51_2273_1115_0" },
    "PoA Start - LF1 After First Ladder 3": { "ap_id": 51005, "position": "51_2306_985_0" },
    "PoA Start - LF1 After First Ladder 4": { "ap_id": 51006, "position": "51_2304_892_52" },
    "PoA Start - LF10 in Left Ship Half": { "ap_id": 51007, "position": "51_-1465_56_-1095" },
    "PoA Start - LF10 in Right Ship Half 1": { "ap_id": 51008, "position": "51_-1122_412_-1075" },
    "PoA Start - LF10 in Right Ship Half 2": { "ap_id": 51009, "position": "51_-1021_347_-1075" },
    "PoA Start - LF10 in Right Ship Half 3": { "ap_id": 51010, "position": "51_-916_276_-1075" },
    "PoA Start - LF10 Underwater Alcove 1": { "ap_id": 51011, "position": "51_708_-919_-1198" },
    "PoA Start - LF10 Underwater Alcove 2": { "ap_id": 51012, "position": "51_739_-384_-1198" },
    "PoA Start - LF10 Underwater Alcove 3": { "ap_id": 51013, "position": "51_746_100_-1198" },
    "PoA Start - LF10 Underwater Alcove 4": { "ap_id": 51014, "position": "51_746_601_-1198" },
    "PoA Start - LF10 Underwater Alcove 5": { "ap_id": 51015, "position": "51_739_1134_-1198" },
    "PoA Start - Arrows on Boxes": { "ap_id": 51016, "position": "51_562_514_-102" },
    "PoA Start - Power Cell": { "ap_id": 51017, "position": "51_2304_0_0" },
    "PoA Start - Pistol": { "ap_id": 51018, "position": "51_2615_1227_359" }
}

class Turok2Location(Location):
    game = "Turok 2"
    
def get_location_names_with_ids(location_names: list[str]) -> dict[str, int | None]:
    '''
    Helper function to assist with creating locations.
    Gets all matching location ap_ids in the listed name.
    '''
    return {
        location_name: LOCATION_TABLE[location_name]["ap_id"]
        for location_name in location_names
    }
    
def get_location_names_with_prefix(prefix: str) -> dict[str, int | None]:
    '''
    Helper fuunction to assist with creating locations.
    Gets all locations matching the given prefix (DO NOT include the hyphen part)
    '''
    full_prefix = prefix + " - "
    return {
        name: data["ap_id"]
        for name, data in LOCATION_TABLE.items()
        if name.startswith(full_prefix)
    }

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