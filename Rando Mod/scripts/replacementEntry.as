//------------------------------
// Represents an actor to be replaced
// - name: The friendly name of the actor
// - apId: The location's AP id = MapID### (e.g. 51001 is item 2 on map 51)
// - position: The quantized position of the actor on the map
//  - MapId_X_Y_Z
// - mapId: Computed from the position
// - replacementActorId: The actor id to replace this with (see common.txt for the macros)
// - displayString: The display string to display when collected (only filled for AP items)
// - isSentToAP: Whether the player has sent the check to AP (may not be collected!)
// - isCollected: Whether the player has this check
//------------------------------
class ReplacementEntry
{
	kStr name;
    int apId;
	kStr position;
	int mapId;
    int replacementActorId;
	kStr displayString;
	bool isSentToAP;
	bool isCollected;
	
	ReplacementEntry() {}
	
    ReplacementEntry(
		const kStr &in initName,
		const int &in initApId,
		const kStr &in initPosition,
		const int &in initReplacementActorId)
    {
        name = initName;
        apId = initApId;
		position = initPosition;
		mapId = position.Atoi();
        replacementActorId = initReplacementActorId;
		displayString = "";
		isSentToAP = false;
		isCollected = false;
    }
	
	ReplacementEntry(
		const kStr &in initName,
		const int &in initApId,
		const kStr &in initPosition,
		const kStr &in initDisplayString)
    {
        name = initName;
        apId = initApId;
		position = initPosition;
		mapId = position.Atoi();
		replacementActorId = kActor_Item_APItem;
        displayString = initDisplayString;
		isSentToAP = false;
		isCollected = false;
    }
}


//TODO: the below functions don't really belong here

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