// Represents an actor to be replaced
// - name: The friendly name of the actor
// - key: The key of the actor its AP id = MapID### (e.g. 51001 is item 2 on map 51)
// - position: The quantized position of the actor on the map
//  - MapId_X_Y_Z
// - value: The actor id (see common.txt for the macros)
// - displayString: The display string to display when collected (only filled for AP items)
// - wasReplaced: Whether this actor was already replaced (used to prevent replacement loops)
class ReplacementEntry
{
	kStr name;
    int key;
	kStr position;
    int value;
	kStr displayString;
	bool wasReplaced;
	
	ReplacementEntry() {}
	
    ReplacementEntry(
		const kStr &in n, 
		const int &in k, 
		const kStr &in p, 
		const int &in v)
    {
        name = n;
        key = k;
		position = p;
        value = v;
		displayString = "";
        wasReplaced = false;
    }
	
	ReplacementEntry(
		const kStr &in n, 
		const int &in k, 
		const kStr &in p, 
		const kStr &in d)
    {
        name = n;
        key = k;
		position = p;
		value = kActor_Item_APItem;
        displayString = d;
        wasReplaced = false;
    }
}

// The global for the actor replacements
array<ReplacementEntry> g_actorReplacements;

// The global for location ids already collected
array<int> g_collectedLocations;

// The previous map that OnSpawn tried to replace an actor on
int16 g_previousMapId = 0;

// Whether we've initialized the state on a save load yet.
// Set on the first OnDeserialize and unset on the first OnSpawn call.
bool g_perSaveInitialized = false;

// Cache the def manager, since it lags when we load defs
kIndexDefManager g_defManager;
void InitDefManager()
{
	g_defManager = kIndexDefManager();
	g_defManager.LoadFile("defs/actors/health.txt");
	g_defManager.LoadFile("defs/actors/pickups.txt");
	g_defManager.LoadFile("defs/actors/weaponPickups.txt");
	g_defManager.LoadFile("defs/actors/powerCells.txt");
	g_defManager.LoadFile("defs/actors/levelKeys.txt");
}

// Initialize the replacement array
void InitActorReplacements()
{
	#include "rando/randoReplacements.txt"
}

// Add to the array for a local item.
// - name: The friendly name of the actor
// - key: The key to replace (the AP id of the actor)
// - position: The position of the actor, to identify it on the map
// - value: The value to replace it with (the enum id of the actor)
void AddReplacement(
	const kStr &in name, 
	const int &in key, 
	const kStr &in position,
	const int &in value)
{
	g_actorReplacements.insertLast(
		ReplacementEntry(name, key, position, value));
}

// Add to the array for an off-world AP item.
// - name: The friendly name of the actor
// - key: The key to replace (the AP id of the actor)
// - position: The position of the actor, to identify it on the map
// - displayString: The string to display when picked up (the enum id of the actor)
void AddReplacement(
	const kStr &in name, 
	const int &in key, 
	const kStr &in position,
	const kStr &in displayString)
{
	g_actorReplacements.insertLast(
		ReplacementEntry(name, key, position, displayString));
}

// Tries to get the replacement for the given actor id.
// Will return false if not found.
// - position: The position of the actor to replace
//  - we CANNOT use the key because it can't be calculated from the Turok data
// - replacementEntry: The retrieved entry (set even if the entry was replaced)
// Returns true if the replacement was found; false otherwise.
bool TryGetReplacement(const kStr &in position, ReplacementEntry &out replacementEntry)
{
    for (uint i = 0; i < g_actorReplacements.length(); i++)
    {
        ReplacementEntry @entry = g_actorReplacements[i];
        if (entry.position == position)
        {
			replacementEntry = entry;
					
            if (entry.wasReplaced)
			{
				return false;
			}
                
            entry.wasReplaced = true;  // Prevent loops in this map instance
            return true;
        }
    }
    return false;
}

// Checks if the location is in the collected array.
// id: The id to check
bool IsLocationCollected(const int &in id)
{
    for (uint i = 0; i < g_collectedLocations.length(); i++)
    {
        if (g_collectedLocations[i] == id)
		{
			return true;
		}
    }

    return false;
}

// Marks the given location as collected by putting it in the array.
// We handle sending to AP in SendCheckToAP - see that documentation.
// id: The id to mark as collected
void CollectLocation(const int &in id)
{
    g_collectedLocations.insertLast(id);
}

// Puts the location in the outgoing message queue for AP.
// This is different from collecting it, as you could touch health/ammo that
// you cannot pick up. We still want to send that to AP.
// id: The id to send to AP
void SendCheckToAP(const int &in id)
{
	g_outgoingMessageQueue.insertLast(
		APOutgoingMessage(AP_OUT_MSGTYPE_SEND_CHECK, id));
}

// Reset the collected locations/replacement flags on a save load
// This flag is unset in OnSpawn
void ResetOnSaveLoad()
{
	if (Game.ActiveMapID() == kLevel_Level1Intro_1)
	{
		g_previousMapId = kLevel_Level1Intro_1;
		g_collectedLocations.removeRange(0, g_collectedLocations.length());
		ResetReplacementFlags();
	}
}

// Called on every replacement attempt.
// If the map is now different, reset the replacement flags.
void EnsureMapInit()
{
    int16 mapId = Game.ActiveMapID();
    if (mapId != g_previousMapId)
    {
        g_previousMapId = mapId;
        ResetReplacementFlags();
    }
}

// Resets all of the wasReplaced flags.
void ResetReplacementFlags()
{
    for (uint i = 0; i < g_actorReplacements.length(); i++)
    {
        g_actorReplacements[i].wasReplaced = false;
    }
}

// Gets a friendly name given the actor type, for debugging
// actorType: The type of actor to get a name for
kStr GetFriendlyActorName(const int &in actorType)
{
	switch(actorType)
	{
		// Life Forces
		case kActor_Item_LifeForce1:
			return "Life Force 1";
		case kActor_Item_LifeForce10:
			return "Life Force 10";
			
		// Health
		case kActor_Item_Health2:
			return "Silver Health";
		case kActor_Item_Health10:
			return "Blue Health";
		case kActor_Item_HealthFull:
			return "Full Health (Red)";
		case kActor_Item_HealthUltra:
			return "Ultra Health (Gold)";
			
		// Weapons
		case kActor_Item_WpnWarBlade:
			return "War Blade";
		case kActor_Item_WpnTekBow:
			return "Tek Bow";
		case kActor_Item_WpnPistol:
			return "Pistol";
		case kActor_Item_WpnMag60:
			return "Mag60";
		case kActor_Item_WpnTranq:
			return "Tranquilizer Gun";
		case kActor_Item_WpnChargeDart:
			return "Charge Dart Rifle";
		case kActor_Item_WpnShotgun:
			return "Shotgun";
		case kActor_Item_WpnScatter:
			return "Shredder";
		case kActor_Item_WpnPlasmaRifle:
			return "Plasma Rifle";
		case kActor_Item_WpnFireStorm:
			return "Firestorm Cannon";
		case kActor_Item_WpnSunfirePod:
			return "Sunfire Pod";
		case kActor_Item_WpnCerebralBore:
			return "Cerebral Bore";
		case kActor_Item_WpnPFMLayer:
			return "PFM Layer";
		case kActor_Item_WpnGrenadeLauncher:
			return "Grenade Launcher";	
		case kActor_Item_WpnMissileLauncher:
			return "Scorpion Launcher";
		case kActor_Item_WpnFlameThrower:
			return "Flamethrower";
		case kActor_Item_WpnRazorWind:
			return "Razor Wind";
		case kActor_Item_WpnNuke:
			return "Nuke";
		case kActor_Item_WpnSpearGun:
			return "Harpoon Gun";
		case kActor_Item_WpnTorpedoLauncher:
			return "Torpedo Launcher";
			
		// Ammo
		case kActor_Item_AmmoArrows:
			return "Arrows";
		case kActor_Item_AmmoQuiver:
			return "Quiver of Arrows";
		case kActor_Item_AmmoTekArrows:
			return "Tek Arrows";
		case kActor_Item_AmmoQuiverTek:
			return "Quiver of Tek Arrows";
		case kActor_Item_AmmoClip:
			return "Pistol Clip";
		case kActor_Item_AmmoBulletBox:
			return "Box of Bullets";
		case kActor_Item_AmmoTranqDarts:
			return "Tranq Darts";
		case kActor_Item_AmmoTranqPack:
			return "Pack of Tranq Darts";
		case kActor_Item_AmmoCharge:
			return "Charge Darts";
		case kActor_Item_AmmoChargePack:
			return "Pack of Charge Darts";
		case kActor_Item_AmmoShells:
			return "Shotgun Shells";
		case kActor_Item_AmmoShellBox:
			return "Box of Shotgun Shells";
		case kActor_Item_AmmoExpShells:
			return "Explosive Shotgun Shells";
		case kActor_Item_AmmoPlasma:
			return "Plasma Rounds";
		case kActor_Item_AmmoPlasmaPack:
			return "Pack of Plasma Rounds";
		case kActor_Item_AmmoSunfirePods:
			return "Sunfire Pods";
		case kActor_Item_AmmoBores:
			return "Bores";
		case kActor_Item_AmmoGrenade:
			return "Grenade";
		case kActor_Item_AmmoGrenadeBox:
			return "Box of Grenades";
		case kActor_Item_AmmoPFM:
			return "Mine";
		case kActor_Item_AmmoMissiles:
			return "Missiles";
		case kActor_Item_AmmoSpears:
			return "Spears";
		case kActor_Item_AmmoTorpedo:
			return "Torpedo";
		case kActor_Item_AmmoGasTank:
			return "Flamethrower Tank";
		case kActor_Item_AmmoNuke:
			return "Nuke Ammo";
			
		// Mission items
		case kActor_MissionItem_BeaconPowerCell:
			return "Beacon Power Cell";
	}
	
	// Unmapped - return the type as a string
	return "" + actorType; 
}