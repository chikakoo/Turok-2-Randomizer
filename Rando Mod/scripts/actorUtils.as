// --------------------------
// Contains functions to help with actors.
// Includes functions to spawn things for the palayer.
// You can call the ones without args from the console with "call <func name>".
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
	
	g_defManager = kDefManager();
	g_defManager.LoadFile("defs/ammoInfo.txt");
}

//---------------------------
// Tries to get the actor def of the given class.
// Returns false if not found or if the class name is not correct.
// Writes the actor to actorDef, which is null if not found.
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
		Sys.Print("Actor: " + actorId + " was class " + actorClassName + ", which is not the expected " + actorClassName);
		@actorDef = null;
		return null;
	}
	
	return actorDef;
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

void Health2()
{
	TryGivePlayerHealth(kActor_Item_Health2);
}

void Health10()
{
	TryGivePlayerHealth(kActor_Item_Health10);
}

void FullHealth()
{
	TryGivePlayerHealth(kActor_Item_HealthFull);
}

void UltraHealth()
{
	TryGivePlayerHealth(kActor_Item_HealthUltra);
}

void LowHealth()
{
	LocalPlayer.Actor().CastToActor().Health() = 1;
}

//---------------------------
// Given the actor id, simulates the player picking up a weapon.
// They are given the ammo amount even if they own the weapon.
bool TryGivePlayerWeapon(int &in actorId, int &in ammoAmount = 1000)
{
	WeaponInfo@ weaponInfo = GetWeaponInfo(actorId);
	Sys.Print("DEF: " + weaponInfo.weaponDef);
	Sys.Print("MSG: " + weaponInfo.pickupMessage);
	Sys.Print("SOUND: " + weaponInfo.pickupSound);
	Sys.Print("CALL: " + weaponInfo.callout);
	
	bool ownsWeapon = LocalPlayer.HasWeapon(weaponInfo.weaponDef);
	LocalPlayer.GiveWeapon(weaponInfo.weaponDef, ammoAmount);
	if (ownsWeapon)
	{
		PlayPickupNotificationSoundAndMessage(weaponInfo);
	}
	else
	{
		PlayPickupNotification(weaponInfo);
	}

	return true;
}

void Pistol()
{
	TryGivePlayerWeapon(kActor_Item_WpnPistol);
}

//---------------------------
// Gives the player 20-75% of the max ammo of a random weapon they have.
// 75% chance of choosing from weapons with missing ammo.
void GetAmmoInRandomWeapon() {}
/*void T()
{
	array<int> ownedWeapons;
	array<int> ownedWeaponsMissingAmmo;
	array<int> ownedWeaponsWithNoAmmo;
	for (int i = 0; i < ownedWeaponsWithAmmo.length(); i++)
	{
		int weaponPickupId = ownedWeaponsWithAmmo[i];
		kDictMem@ weaponPickupDict = TryGetActorDefWithClass(weaponPickupId, "kexWeaponPickup");
		if (weaponPickupDict is null)
		{
			return false;
		}

		int weaponDef; 
		weaponPickupDict.GetInt("pickup.weapon.definition", weaponDef);
		
		if (LocalPlayer.HasWeapon(weaponDef))
		{
			ownedWeaponsWithAmmo.insertLast(weaponPickupId);
			
			int totalAmmo = LocalPlayer.GetAmmo(weaponPickupId) + 
				LocalPlayer.GetAltAmmo(weaponPickupId);
			
			if (totalAmmo > 0)
			{
				ownedWeaponsMissingAmmo.insertLast();
			}
		}
	}
	
	if (ownedWeaponsMissingAmmo.length() > 0)
	{
		
	}
	else
	{
	}
}*/

//---------------------------
// Gets the given mission item and adds it to your inventory.
// TODO: there are multiple things called power cells, deal with the display...
bool TryGetMissionItem(int &in actorId)
{
	kDictMem@ missionItemDef = TryGetActorDefWithClass(actorId, "kexInventoryPickup");
	if (missionItemDef is null)
	{
		return false;
	}
	
	LocalPlayer.Inventory().Give(actorId);
	PlayPickupNotification(missionItemDef);
	
	return true;
}

void BeaconPowerCell(void)
{
	TryGetMissionItem(kActor_MissionItem_BeaconPowerCell);
}

void Level2Key(void)
{
	TryGetMissionItem(kActor_InventoryItem_Level2Key);
	Sys.Print("" + LocalPlayer.Inventory().GetCount(kActor_InventoryItem_Level2Key));
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

void LifeForce1(void)
{
	SpawnActorOnPlayer(kActor_Item_LifeForce1);
}

void LifeForce10(void)
{
	SpawnActorOnPlayer(kActor_Item_LifeForce10);
}


//TODO: primagen keys, talismans, nuke parts


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
// Trap functions
void EnemyTrap()
{
	HandleEnemyTrap();
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