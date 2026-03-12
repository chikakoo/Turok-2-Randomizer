from __future__ import annotations
from typing import TYPE_CHECKING
from BaseClasses import CollectionState
from worlds.generic.Rules import add_rule, set_rule

if TYPE_CHECKING:
    from .world import APQuestWorld
    
def set_all_rules(world: APQuestWorld) -> None:
    '''
    Set all the rules for how entrances/locations/and the completion condition.
    Regions themselves don't have rules, but the entrances connecting them do.
    '''
    set_all_entrance_rules(world)
    set_all_location_rules(world)
    set_completion_condition(world)
    
def set_all_entrance_rules(world: APQuestWorld) -> None:
    '''
    Sets rules for going through entrances.
    '''
    #TODO: do this when we start having logic!
    pass
    
def set_all_location_rules(world: APQuestWorld) -> None:
    '''
    Sets rules for getting location checks.
    '''
    #TODO: do this when we start having logic!
    pass
    
    
def set_completion_condition(world: APQuestWorld) -> None:
    '''
    The victory condition.
    '''
    # Finally, we need to set a completion condition for our world, defining what the player needs to win the game.
    # You can just set a completion condition directly like any other condition, referencing items the player receives:
    world.multiworld.completion_condition[world.player] = lambda state: state.has_all(("Sword", "Shield"), world.player)

    # In our case, we went for the Victory event design pattern (see create_events() in locations.py).
    # So lets undo what we just did, and instead set the completion condition to:
    world.multiworld.completion_condition[world.player] = lambda state: state.has("Victory", world.player)