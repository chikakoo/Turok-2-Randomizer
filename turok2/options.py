from dataclasses import dataclass
from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle
#todo: randomize options for health/ammo/life force tiles
#      whether to shuffle nuke parts, include it as a possible weapon, or just exclude them
#      whether to include the nuke in the random ammo packs
#      death link
#      whether to mark the pickups as important in the game

class Goal(Choice):
    """
    Defines the goal of the seed.
    - Primagen: Defeat the Primagen (vanilla)
    - Hub: Get to the hub by completing Level 1 (that's that exists so far)
    """
    display_name = "Goal"
    
    option_primagen = 0
    option_hub = 1
    
    default = option_primagen

class GameLogicDifficulty(Choice):
    """
    Affects the logic of the game itself.
    - Causal: Requires talismans that the game normally expects you to have, and 
              for you to take the intended route through areas.
    - Advanced: If you can do it without a talisman, the talisman is not guaranteed
                to be in logic. Currently puts one check in logic requiring you to
                jump to a life force tile near the Level 1's Primagen Key location.
    """
    display_name = "Game Logic Difficulty"
    
    option_casual = 0
    option_advanced = 1
    
    default = option_casual
    
class WeaponLogicDifficulty(Choice):
    """
    Affects the types of weapons that will be in logic.
    - Causal: Weapons the game normally expects you to have will be in logic.
              This includes things like a weapon that can easily snipe enemies
              during parts where it expects you to have the Tek Bow.
    - Advanced: If you can do it with the bow, no additional weapons are guaranteed
                to be in logic.
    """    
    display_name = "Weapon Logic Difficulty"
    
    option_casual = 0
    option_advanced = 1
    
    default = option_casual
    
class ForceEarlyWeapon(Toggle):
    """
    Forces an early progression weapon in the starting map so you have more than just the bow.
    """
    display_name = "Force Early Weapon"
    default = True
    
class TrapFillPercentage(Range):
    """
    Replaces a percentage of non-progression items with traps.
    """
    display_name = "Trap Fill Percentage"
    
    range_start = 0
    range_end = 100
    default = 0
    
class LifeForceFillPercentage(Range):
    """
    Replaces a percentage of non-progression, non-trap items with Life Forces.
    Higher numbers mean a more difficult seed, but keep in mind that
    most of the game consists of these normally.
    """
    display_name = "Life Force Fill Percentage"
    
    range_start = 0
    range_end = 100
    default = 50
    
class HealthFillPercentage(Range):
    """
    Replaces a percentage of non-progression, non-trap, non-Life Force items with health.
    
    If using the default Life Force settings, it's recommended to set this to at 
    least 30 so you aren't starved for health.
    """
    display_name = "Health Fill Percentage"
    
    range_start = 0
    range_end = 100
    default = 40
    
class AmmoFillPercentage(Range):
    """
    Replaces a percentage of non-progression, non-trap, non-Life Force items with ammo.

    If using the default Life Force settings, it's recommended to set this to at 
    least 30 so you aren't starved for ammo.
    
    Note that this ammo will give you ammo in a random weapon that you own,
    favoring ones that are missing ammo first.
    """
    display_name = "Health Fill Percentage"

    range_start = 0
    range_end = 100
    default = 40
    
class LocalHealthPercentage(Range):
    """
    The percentage of health forced to your local world.
    This includes the health fill percentages and those as generated filler items.
    
    Make sure to set this higher if you are playing in a big multiworld
    so you can actually get health when you need it.
    
    Setting this too high could result in generation failures.
    """
    display_name = "Local Health Percentage"
    
    range_start = 0
    range_end = 100
    default = 50
    
class LocalAmmoPercentage(Range):
    """
    The percentage of ammo forced to your local world.
    This includes the ammo fill percentages and those as generated filler items.
    
    Make sure to set this higher if you are playing in a big multiworld
    so you can actually get ammo when you need it.
    
    Setting this too high could result in generation failures.
    """
    display_name = "Local Ammo Percentage"
    
    range_start = 0
    range_end = 100
    default = 40
    
class LocalWeaponPercentage(Range):
    """
    The percentage of weapons forced to your local world.
    
    Make sure to set this higher if you are playing in a big multiworld
    so you can actually get new weapons.
    """
    display_name = "Local Weapon Percentage"
    
    range_start = 0
    range_end = 100
    default = 50
    
class BaseTrapWeight(Choice):
    """
    Base class for all trap weights.
    """
    option_none = 0
    option_low = 1
    option_medium = 2
    option_high = 4
    default = 2

class EnemyTrapWeight(BaseTrapWeight):
    """
    Likelihood of receiving a trap that spawns 1-3 random enemies near you.
    """
    display_name = "Enemy Trap"
    
@dataclass
class Turok2Options(PerGameCommonOptions):
    goal: Goal
    
    game_logic_difficulty: GameLogicDifficulty
    weapon_logic_difficulty: WeaponLogicDifficulty
    
    force_early_weapon: ForceEarlyWeapon
    
    trap_fill_percentage: TrapFillPercentage
    life_force_fill_percentage: LifeForceFillPercentage
    health_fill_percentage: HealthFillPercentage
    ammo_fill_percentage: AmmoFillPercentage
    
    local_weapon_percentage: LocalWeaponPercentage
    local_health_percentage: LocalHealthPercentage
    local_ammo_percentage: LocalAmmoPercentage
    
    enemy_trap_weight: EnemyTrapWeight
    
option_groups = [
    OptionGroup("Goal", [Goal]),
    OptionGroup("Difficulty Options", [
        GameLogicDifficulty,
        WeaponLogicDifficulty
    ]),
    OptionGroup("Progression Options", [
        ForceEarlyWeapon
    ]),
    OptionGroup("Filler Item Balancing", [
        TrapFillPercentage,
        LifeForceFillPercentage,
        HealthFillPercentage,
        AmmoFillPercentage,
        LocalWeaponPercentage,
        LocalHealthPercentage,
        LocalAmmoPercentage
    ]),
    OptionGroup("Trap Weights", [
        EnemyTrapWeight
    ])
]

option_presets = {
    "casual": {
        "game_logic_difficulty": GameLogicDifficulty.option_casual,
        "weapon_logic_difficulty": WeaponLogicDifficulty.option_casual,
        "force_early_weapon": True
    },
    "advanced": {
        "game_logic_difficulty": GameLogicDifficulty.option_advanced,
        "weapon_logic_difficulty": GameLogicDifficulty.option_advanced,
        "force_early_weapon": False
    }
}