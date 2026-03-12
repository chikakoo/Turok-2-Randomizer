from collections.abc import Mapping
from typing import Any
from worlds.AutoWorld import World
from . import items, locations, regions, rules, web_world
from . import options as turok2_options

class Turok2World(World):
    """
    Turok 2 is an FPS about fighting genetically modified dinosaurs and other creatures.
    This is specifially for the 2017 Nightdive remaster.
    """
    game = "Turok 2"
    
    web = web_world.Turok2WebWorld()

    location_name_to_id = locations.LOCATION_NAME_TO_ID
    item_name_to_id = items.ITEM_NAME_TO_ID
    origin_region_name = "Entire Game"

    def create_regions(self) -> None:
        regions.create_and_connect_regions(self)
        locations.create_all_locations(self)

    def create_items(self) -> None:
        items.create_all_items(self)
            
    def create_item(self, name: str) -> items.Turok2Item:
        return items.create_item_with_correct_classification(self, name)
        
    def get_filler_item_name(self) -> str:
        return items.get_random_filler_item_name(self)