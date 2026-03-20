import settings
import typing
from . import components as components
from collections.abc import Mapping
from worlds.AutoWorld import World
from . import items, locations, regions, rules, web_world
from . import options as turok2_options
from .turok2_seed import gen_turok2_seed

class Turok2Settings(settings.Group):
    class Turok2Path(settings.FilePath):
        """
        Path to the Turok 2 executable.
        """
        is_exe = True
        description = "Turok 2 Executable"
    turok2_path: Turok2Path = Turok2Path(
        "C:/Program Files (x86)/Steam/steamapps/common/Turok 2 - Seeds of Evil/horus_Shipping_Playfab_Steam_x64.exe")

class Turok2World(World):
    """
    Turok 2 is an FPS about fighting genetically modified dinosaurs and other creatures.
    This is specifially for the 2017 Nightdive remaster.
    """        
    game = "Turok 2"
    web = web_world.Turok2WebWorld()
    
    options_dataclass = turok2_options.Turok2Options
    options: turok2_options.Turok2Options
    
    settings: typing.ClassVar[Turok2Settings]

    location_name_to_id = locations.LOCATIONS_BY_ID
    item_name_to_id = items.ITEM_NAME_TO_ID
    item_name_groups = items.get_item_name_groups()
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
        
    def generate_output(self, output_directory: str) -> None:
        gen_turok2_seed(self, output_directory)