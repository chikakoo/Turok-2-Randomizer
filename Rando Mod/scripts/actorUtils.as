// --------------------------
// Contains functions to help with actors.
//---------------------------

//---------------------------
// Cache the def managers, since they lag when we load defs.
kIndexDefManager g_indexDefManager;
kDefManager g_defManager;
void InitDefManager()
{
	g_indexDefManager = kIndexDefManager();
	g_indexDefManager.LoadFile("defs/weaponInfo.txt");
	g_indexDefManager.LoadFile("defs/actors/health.txt");
	g_indexDefManager.LoadFile("defs/actors/pickups.txt");
	g_indexDefManager.LoadFile("defs/actors/weaponPickups.txt");
	g_indexDefManager.LoadFile("defs/actors/powerCells.txt");
	g_indexDefManager.LoadFile("defs/actors/levelKeys.txt");
	g_indexDefManager.LoadFile("defs/actors/primagenKeys.txt");
	g_indexDefManager.LoadFile("defs/actors/eagleFeathers.txt");
	g_indexDefManager.LoadFile("defs/actors/talismans.txt");
	g_indexDefManager.LoadFile("defs/actors/ap.txt");
	g_indexDefManager.LoadFile("defs/actors/keys.txt");
	g_indexDefManager.LoadFile("defs/actors/satchels.txt");
	
	g_defManager = kDefManager();
	g_defManager.LoadFile("defs/ammoInfo.txt");
}

//--------------------------
// Play the sound, show the message, and say the callout, if any.
// Does NOT handle actually getting the pickup.
//
// Has the option to include/exclude the message and callout.
void PlayPickupNotification(
	kStr pickupSound,
	kStr pickupMessage = "",
	int callout = 0)
{
	LocalPlayer.Actor().PlaySound(pickupSound);
	
	if (pickupMessage != "")
	{
		Hud.AddMessage(pickupMessage);
	}
	
	if (callout != 0)
	{
		Game.PlayVoice(callout);
	}
}

void PlayPickupNotification(kDictMem@ actorDef)
{
	kStr pickupSound;
	actorDef.GetString("pickup.pickupSound", pickupSound);
	
	kStr pickupMessage = "";
	actorDef.GetString("pickup.pickupMessage", pickupMessage);
	
	int callout = 0;
	actorDef.GetInt("pickup.callout", callout);
	
	PlayPickupNotification(pickupSound, pickupMessage, callout);
}

void PlayPickupNotification(WeaponInfo@ weaponInfo)
{
	PlayPickupNotification(
		weaponInfo.pickupSound, 
		weaponInfo.pickupMessage, 
		weaponInfo.callout);
}

void PlayPickupNotificationSound(kDictMem@ actorDef)
{
	kStr pickupSound;
	actorDef.GetString("pickup.pickupSound", pickupSound);
	PlayPickupNotification(pickupSound);
}

void PlayPickupNotificationSound(WeaponInfo@ weaponInfo)
{
	PlayPickupNotification(weaponInfo.pickupSound);
}

void PlayPickupNotificationSoundAndMessage(WeaponInfo@ weaponInfo)
{
	PlayPickupNotification(weaponInfo.pickupSound, weaponInfo.pickupMessage);
}

//---------------------------
// Tries to get the actor def of the given class.
// Returns the actor def, if found, else null.
kDictMem@ TryGetActorDefWithClass(int &in actorId, kStr &in className)
{
	kDictMem@ actorDef = g_indexDefManager.GetEntry(actorId);
	if (actorDef is null)
	{
		Sys.Print("Tried to use non-existant actor def: " + actorId + ", " + className);
		return null;
	}
	
	kStr actorClassName;
	actorDef.GetString("className", actorClassName);
	if (actorClassName != className)
	{
		@actorDef = null;
		return null;
	}
	
	return actorDef;
}

//---------------------------
// Given the actor id, simulates the player picking up health.
// Respects the game's normal health pickup rules, except it
// displays the message for the health even if you didn't gain any.
bool TryGivePlayerHealth(int &in actorId)
{
	kDictMem@ healthDict = TryGetActorDefWithClass(actorId, "kexHealthPickup");
	if (healthDict is null)
	{
		return false;
	}

	float healthAmount;
	healthDict.GetFloat("pickup.health.amount", healthAmount);
	
	float playerHealth = LocalPlayer.Actor().CastToActor().Health();
	float newHealthValue = playerHealth + healthAmount;
	
	float recoveryCap;
	if (healthDict.GetFloat("rando.recoveryCap", recoveryCap))
	{
		// Full health sets the health to the cap
		if (actorId == kActor_Item_HealthFull)
		{
			newHealthValue = recoveryCap;
		}
		
		// No HP recovery if you're already at the cap
		if (playerHealth >= recoveryCap)
		{
			newHealthValue = playerHealth;
		}
		
		// Else, we want the lower of the cap or the new health value
		// so we can't go above the cap
		else 
		{
			newHealthValue = Math::Min(newHealthValue, recoveryCap);
		}
	}

	LocalPlayer.Actor().CastToActor().Health() = newHealthValue;
	PlayPickupNotification(healthDict);
	
	return true;
}

//---------------------------
// Gets the given item and adds it to your inventory.
// TODO: there are multiple things called power cells, deal with the display...
bool TryGetInventoryItem(int &in actorId)
{
	kDictMem@ missionItemDef = TryGetActorDefWithClass(actorId, "kexInventoryPickup");
	if (missionItemDef is null)
	{
		return false;
	}
	
	LocalPlayer.Inventory().Give(actorId);
	PlayPickupNotification(missionItemDef);
	HandleGiveSecondItem(actorId, missionItemDef);
	
	return true;
}

//---------------------------
// Some items (primagen keys) will disappear when you use them.
// We want to track these still, so give a second one of them.
void HandleGiveSecondItem(int &in actorId, kDictMem@ missionItemDef = null)
{
	if (missionItemDef is null)
	{
		@missionItemDef = TryGetActorDefWithClass(actorId, "kexInventoryPickup");
		if (missionItemDef is null)
		{
			return;
		}
	}
	
	bool give2;
	missionItemDef.GetBool("rando.give2", give2, false);
	if (give2)
	{
		LocalPlayer.Inventory().Give(actorId);
	}
}

//---------------------------
// Void get nuke part - also handles giving the nuke if you have 6
// since it doesn't do this unless all specific level ones exist.
void GetNukePart(void)
{
	TryGetInventoryItem(kActor_InventoryItem_NukePart);
	
	if (!LocalPlayer.HasWeapon(kActor_Wpn_Nuke) &&
		LocalPlayer.Inventory().GetCount(kActor_InventoryItem_NukePart) >= 6)
	{
		LocalPlayer.GiveWeapon(kWpn_Nuke, 1000);
	}
}


//---------------------------
// Spawns the given actor id near the player.
// Meant to be used for enemy traps.
void SpawnActorNearPlayer(int &in actorId)
{
	kActor @actor = LocalPlayer.Actor().CastToActor();
	kVec3 origin1 = kVec3(actor.Origin());
	kVec3 origin2 = kVec3(actor.Origin());
	kVec3 origin3 = kVec3(actor.Origin());
	int16 regionIdx = actor.WorldComponent()
		.GetNearPositionAndRegionIndex(origin1, origin2);
	
	ActorFactory.Spawn(actorId, origin3, 0, 0, 0, true, regionIdx);
}

//---------------------------
// Spawns the given actor on the player.
// Meant to be used for items that can't be given directly, like life force tiles.
void SpawnActorOnPlayer(int &in actorId)
{
	kActor @actor = LocalPlayer.Actor().CastToActor();
	int regionIdx = actor.WorldComponent().RegionIndex();
	kVec3 origin = kVec3(actor.Origin());
	
	ActorFactory.Spawn(actorId, origin, 0, 0, 0, true, regionIdx);
}

//---------------------------
// Replace all ammo generators with those that spawn the random ammo pickup.
void UseRandomAmmoGenerators(void)
{
	// Check if the map has any generators we want to replace
	int16 mapId = Game.ActiveMapID();
	if (!DoesMapHaveAmmoGeneratorsToReplace(mapId))
	{
		return;
	}

	// Iterate through all the actors and replace the ones we want to replace
	kActorIterator cIterator;
	kActor@ pActor;
	array<kActor@> actorsToRemove;
	while(!((@pActor = cIterator.GetNext()) is null) && 
		pActor.Type() != kActor_Generator_RandomAmmo)
	{
		kVec3 position = pActor.Origin();
		kStr posStr = "" +
			int(position.x) + "_" +
			int(position.y) + "_" +
			int(position.z);
			
		// TESTING
		//if (pActor.HasComponent("kexGeneratorComponent"))
		//{
		//	Sys.Print("GENERATOR AT: " + posStr);
		//}
			
		if (IsAmmoGeneratorToReplace(mapId, posStr))
		{
			actorsToRemove.insertLast(pActor);
			ActorFactory.Spawn(
				kActor_Generator_RandomAmmo,
				pActor.Origin(),
				pActor.Yaw(),
				pActor.Pitch(),
				pActor.Roll(),
				true, // Unknown - always set to true
				pActor.WorldComponent().RegionIndex());
		}
	}
	
	// Remove everything we flagged
	for (uint i = 0; i < actorsToRemove.length(); i++)
	{
		actorsToRemove[i].Remove();
	}
}

//---------------------------
// Temporary stupid thing to remove all generators and generated items from the map
void RemoveAllGenerators(void)
{
	kActorIterator cIterator;
	kActor@ pActor;
	array<kActor@> actorsToRemove;
	array<kStr> generatorPositions;
	while(!((@pActor = cIterator.GetNext()) is null))
	{
		if (pActor.HasComponent("kexGeneratorComponent"))
		{
			kVec3 position = pActor.Origin();
			kStr posStr = "" + int(position.x) + "_" +
				int(position.y) + "_" +
				int(position.z);
				
			actorsToRemove.insertLast(pActor);
			generatorPositions.insertLast(posStr);
		}
	}
	
	Hud.AddMessage("Removing " + generatorPositions.length() + " generator(s).");
	
	kActorIterator cIterator2;
	while(!((@pActor = cIterator2.GetNext()) is null))
	{
		for (uint i = 0; i < generatorPositions.length(); i++)
		{
			kVec3 position2 = pActor.Origin();
			kStr posStr2 = "" + int(position2.x) + "_" +
				int(position2.y) + "_" +
				int(position2.z);
			if (posStr2 == generatorPositions[i])
			{
				actorsToRemove.insertLast(pActor);
			}
		}
	}
	
	for (uint i = 0; i < actorsToRemove.length(); i++)
	{
		actorsToRemove[i].Remove();
	}
}


//---------------------------
// Helper function that a couple places use.
// Helps determine if it's an actor that can be sent to AP, but 
// not collected.
bool IsHealthOrAmmo(kActor@ actor) 
{
	kStr className;
	actor.Definition().GetString("className", className);
	return className == "kexHealthPickup" || className == "kexAmmoPickup";
}

//---------------------------
// Doors to trigger on the current map
// Used when grabbing a randomized actor needs to trigger doors
// Cleared/set on player spawn
array<kActor@> g_doorsToTrigger;

//---------------------------
// Trigger all the doors to trigger.
void TriggerDoors(void)
{
	if (g_doorsToTrigger is null)
	{
		return;
	}
	
	Sys.Print("LENGTH: " + g_doorsToTrigger.length());
	for (uint i = 0; i < g_doorsToTrigger.length(); i++)
	{
		g_doorsToTrigger[i].ModeStateComponent().SetMode(DOOR_MODE_OPEN);
	}
}

//---------------------------
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
