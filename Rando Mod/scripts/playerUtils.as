// --------------------------
// Contains functions to get things for the player.
// You can call the ones without args from the console with "call <func name>".
//---------------------------

//---------------------------
// Tries to get the actor def of the given class.
// Returns false if not found or if the class name is not correct.
// Writes the actor to actorDef, which is null if not found.
kDictMem@ TryGetActorDefWithClass(int &in actorId, kStr &in className)
{
	kDictMem@ actorDef = g_defManager.GetEntry(actorId);
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
void PlayPickupNotification(kDictMem@ actorDef)
{
	kStr pickupSound;
	kStr pickupMessage;
	actorDef.GetString("pickup.pickupSound", pickupSound);
	actorDef.GetString("pickup.pickupMessage", pickupMessage);
	
	int callout;
	if (actorDef.GetInt("pickup.callout", callout))
	{
		Game.PlayVoice(callout);
	}
	
	LocalPlayer.Actor().PlaySound(pickupSound);
	Hud.AddMessage(pickupMessage);
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

void SetHealthTo10()
{
	LocalPlayer.Actor().CastToActor().Health() = 10;
}

//---------------------------
// Given the actor id, simulates the player picking up a weapon.
bool TryGivePlayerWeapon(int &in actorId)
{
	kDictMem@ weaponPickupDict = TryGetActorDefWithClass(actorId, "kexWeaponPickup");
	if (weaponPickupDict is null)
	{
		return false;
	}
	
	int weaponDef; 
	weaponPickupDict.GetInt("pickup.weapon.definition", weaponDef);
	LocalPlayer.GiveWeapon(weaponDef, 1000);
	
	PlayPickupNotification(weaponPickupDict);
	
	return true;
}

void Pistol()
{
	TryGivePlayerWeapon(kActor_Item_WpnPistol);
}

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

bool IsHealthOrAmmo(kActor@ actor) 
{
	kStr className;
	actor.Definition().GetString("className", className);
	return className == "kexHealthPickup" || className == "kexAmmoPickup";
}

// TESTING
void Test()
{
}