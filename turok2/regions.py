from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import Entrance, Region

if TYPE_CHECKING:
    from .world import Turok2World

def create_and_connect_regions(world: APQuestWorld) -> None:
    create_all_regions(world)
    connect_regions(world)
    
def create_all_regions(world: Turok2World) -> None:
    '''
    Defines the regions in the game.
    The logic for how they connect is done in connect_regions.
    '''
    entireGame = Region("Entire Game", world.player, world.multiworld)
    regiions = [entireGame]
    world.multiworld.regions += regions
    
def connect_regions(world: Turok2World) -> None:
    '''
    How the previously defined regions are connected together
    '''
    # See the AP Quest version for details here
    # We don't really need to connect anything with only one region now
    #entireGame = world.get_region("Entire Game")
    
    

    