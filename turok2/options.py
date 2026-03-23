from dataclasses import dataclass
from Options import Choice, OptionGroup, PerGameCommonOptions, Range, Toggle
#todo:
# individual pickup weights (health, life force)
# whether to shuffle nuke parts, include it as a possible weapon, or  just exclude them
# whether to include the nuke in the random ammo packs
# death link
# whether to mark the pickups as important in the game

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
    
class IncludeHealthLocations(Toggle):
    """
    Whether to include static health pickups in the list of locations to check.
    Will result in weighted health pickups in the pool (see the relevant setting).
    """
    display_name = "Include Health Locations"
    default = True
    
class IncludeAmmoLocations(Toggle):
    """
    Whether to include static ammo pickups in the list of locations to check.
    Will result in weighted ammo pickups in the pool (see the relevant setting).
    """
    display_name = "Include Ammo Locations"
    default = True
    
class IncludeLifeForceLocations(Toggle):
    """
    Whether to include life forces in the list of locations to check.
    Will result in weighted life forces in the pool (see the relevant setting).
    """
    display_name = "Include Life Force Locations"
    default = True
    
class IncludeWeaponLocations(Toggle):
    """
    Whether to include weapon pickups in the list of locations to check.
    Will result in random weapons in the pool.
    """
    display_name = "Randomize Weapons"
    default = True
    
class MinimumHealthPercent(Range):
    """
    The minimum percent of health pickups in the pool.
    
    If all guaranteed percent options add up to more than 100%, it will weigh them relative to one other (and then no junk items are generated).
    """
    display_name = "Guaranteed Health %"
    
    range_start = 0
    range_end = 100
    default = 20
    
class MinimumAmmoPercent(Range):
    """
    The minimum percent of ammo pickups in the pool.
    If all guaranteed percent options add up to more than 100%, it will weigh them relative to one other (and then no junk items are generated).
    """
    display_name = "Guaranteed Ammo %"
    
    range_start = 0
    range_end = 100
    default = 20
    
class MinimumLifeForcePercent(Range):
    """
    The minimum percent of life forces in the pool.
    If all guaranteed percent options add up to more than 100%, it will weigh them relative to one other (and then no junk items are generated).
    
    Higher numbers mean a more difficult seed, but keep in mind that most of the game consists of these normally.
    """
    display_name = "Guaranteed Life Force %"
    
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
    default = 40
    
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
    
    
class ForceEarlyWeapon(Toggle):
    """
    Forces an early progression weapon in the starting map so you have more than just the bow.
    """
    display_name = "Force Early Weapon"
    default = True
    
class BaseWeight(Choice):
    """
    Base class for all trap weights.
    """
    option_none = 0
    option_low = 1
    option_medium = 2
    option_high = 4
    default = 2
    
class JunkItemPoolHealthWeight(BaseWeight):
    """
    The weight of health pickups in the junk item pool.
    
    You can use numbers instead of the pre-set values as well.
    """
    display_name = "Junk Item Pool Health Weight"
    default = 2
    
class JunkItemPoolAmmoWeight(BaseWeight):
    """
    The weight of ammo pickups in the junk item pool.
    
    You can use numbers instead of the pre-set values as well.
    """
    display_name = "Junk Item Pool Ammo Weight"
    default = 2
    
class JunkItemPoolLifeForceWeight(BaseWeight):
    """
    The weight of life forces in the junk item pool.
    
    You can use numbers instead of the pre-set values as well.
    """
    display_name = "Junk Item Pool Ammo Weight"
    default = 4
    
class JunkItemPoolTrapWeight(BaseWeight):
    """
    The weight of traps in the junk item pool.
    
    You can use numbers instead of the pre-set values as well.
    """
    display_name = "Junk Item Pool Trap Weight"
    default = 0

class EnemyTrapWeight(BaseWeight):
    """
    Likelihood of receiving a trap that spawns 1-3 random enemies near you.
    """
    display_name = "Enemy Trap"
    
class DamageTrapWeight(BaseWeight):
    """
    Likelihood of receiving a trap that does a small amount of damage to you.
    It will never bring your health to 0.
    """
    display_name = "Damage Trap"
    
class SpamTrapWeight(BaseWeight):
    """
    Likelihood of receiving a trap that spams your screen with useless messages.
    """
    display_name = "Spam Trap"
    
@dataclass
class Turok2Options(PerGameCommonOptions):
    goal: Goal
    
    game_logic_difficulty: GameLogicDifficulty
    weapon_logic_difficulty: WeaponLogicDifficulty

    include_health_locations: IncludeHealthLocations
    include_ammo_locations: IncludeAmmoLocations
    include_life_force_locations: IncludeLifeForceLocations
    include_weapon_locations: IncludeWeaponLocations
    
    minimum_health_percent: MinimumHealthPercent
    minimum_ammo_percent: MinimumAmmoPercent
    minimum_life_force_percent: MinimumLifeForcePercent
    
    local_weapon_percentage: LocalWeaponPercentage
    local_health_percentage: LocalHealthPercentage
    local_ammo_percentage: LocalAmmoPercentage
    
    force_early_weapon: ForceEarlyWeapon
    
    junk_item_pool_health_weight: JunkItemPoolHealthWeight
    junk_item_pool_ammo_weight: JunkItemPoolAmmoWeight
    junk_item_pool_life_force_weight: JunkItemPoolLifeForceWeight
    junk_item_pool_trap_weight: JunkItemPoolTrapWeight
    enemy_trap_weight: EnemyTrapWeight
    damage_trap_weight: DamageTrapWeight
    spam_trap_weight: SpamTrapWeight
    
option_groups = [
    OptionGroup("Goal", [Goal]),
    OptionGroup("Difficulty Options", [
        GameLogicDifficulty,
        WeaponLogicDifficulty
    ]),
    OptionGroup("Item Pool Options", [
        IncludeHealthLocations,
        IncludeAmmoLocations,
        IncludeLifeForceLocations,
        IncludeWeaponLocations,
        
        MinimumHealthPercent,
        MinimumAmmoPercent,
        MinimumLifeForcePercent,
        
        LocalWeaponPercentage,
        LocalHealthPercentage,
        LocalAmmoPercentage
    ]),
    OptionGroup("Progression Options", [
        ForceEarlyWeapon
    ]),
    OptionGroup("Junk Item Pool Weights", [
        JunkItemPoolHealthWeight,
        JunkItemPoolAmmoWeight,
        JunkItemPoolLifeForceWeight,
        JunkItemPoolTrapWeight,
        
        EnemyTrapWeight,
        DamageTrapWeight,
        SpamTrapWeight
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