// --------------------------
// Handles actor replacements/placements when a player spawns.
//---------------------------

//---------------------------
// Handles all replacements
void DoActorReplacementsOnPlayerSpawn()
{
	int16 mapId = Game.ActiveMapID();
	
	//RemoveAllGenerators(); //TODO: disable this, enable the next
	if (OPTION_INCLUDE_WEAPONS_AND_AMMO)
	{
		UseRandomAmmoGenerators();
	}
	
	// Reset the actors to trigger BEFORE replacing actors
	g_actorsToTrigger.resize(0);
	
	// Replace all the actors that should be replaced
	ReplaceAllActors(mapId);
	DoHubModifications(mapId);
}

//----------------------------------
// Replaces all actors with the intended replacement.
// STOP iterating on the player, as that would be the LAST actor spawned.
// We prevent infinite spawn loops this way.
//
// Also stores any doors we need to trigger when an actor is collected.
void ReplaceAllActors(const int16 &in mapId)
{
	kActorIterator actorIterator;
	kActor@ actor;
	ReplacementEntry@ replacement;
	kVec3 position;
	kStr posStr;
	array<kActor@> actorsToRemove; // Remove outside of the iterator, to be safe
	while(!((@actor = actorIterator.GetNext()) is null) &&
		!actor.InstanceOf("kexPuppet")) // STOP on the player so we don't iterate forever
	{			
		position = actor.Origin();
		posStr = "" + mapId + "_" +
			int(position.x) + "_" +
			int(position.y) + "_" +
			int(position.z);

		if (DoMapSpecificEdits(actor, mapId))
		{
			actorsToRemove.insertLast(actor);
		}
		
		else if (ShouldReplaceActor(actor, posStr))
		{
			if (TryGetReplacement(mapId, posStr, replacement))
			{
				if (replacement.isCollected)
				{
					actorsToRemove.insertLast(actor);
					continue;
				}
				
				ReplaceActor(actor, replacement);
			}
			//else 
			//{
				// TODO: remove this after mapping stuff
				//Sys.Print("NOT MAPPED: " + posStr + " (" + GetFriendlyActorName(actor.Type()) + ")"); 
				//actor.Flags() |= AF_IMPORTANT;
			//}
		}
		
		if (IsActorToTrigger(mapId, actor.TID()))
		{
			g_actorsToTrigger.insertLast(actor);
		}
	}
	
	for (uint i = 0; i < actorsToRemove.length(); i++)
	{
		actorsToRemove[i].Remove();
	}
}

//----------------------------------
// Checks if an actor should be replaced, based on the actor class.
//
// Certain actors of other types might spawn on others (like if an actor is at 0, 0, 0),
// and we'll crash if we try to replace those.
bool ShouldReplaceActor(kActor@ actor, kStr posStr)
{
	kDictMem@ actorDef = actor.Definition();
	if (actorDef !is null)
	{
		kStr actorClassName;
		if (actorDef.GetString("className", actorClassName))
		{
			return actorClassName == "kexAmmoPickup" ||
				actorClassName == "kexHealthPickup" ||
				actorClassName == "kexInventoryPickup" ||
				actorClassName == "kexLifeForcePickup" ||
				actorClassName == "kexWeaponPickup";
		}
	}
	
	return false;
}

//----------------------------------
// Replace the given actor with the given replacement
void ReplaceActor(kActor@ initialActor, ReplacementEntry@ replacement)
{
	kWorldComponent@ worldComponent = initialActor.WorldComponent();
	kActor@ replacedActor = ActorFactory.Spawn(
		replacement.replacementActorId,
		initialActor.Origin(),
		initialActor.Yaw(),
		initialActor.Pitch(),
		initialActor.Roll(),
		true, // Unknown - always set to true
		worldComponent.RegionIndex());
		
	kWorldComponent@ newWorldComponent = replacedActor.WorldComponent();
	newWorldComponent.Radius() = worldComponent.Radius();
	newWorldComponent.Height() = worldComponent.Height();
	newWorldComponent.Flags() = worldComponent.Flags();
	
	// Flag the actor as important so it can be found easier
	// If it was already sent to AP, do not do this since it was "collected" already
	if (!replacement.isSentToAP)
	{
		replacedActor.Flags() |= AF_IMPORTANT; // TODO: enable this when done adding items
	}
	
	initialActor.Remove();
}

//----------------------------------
// Actor edits specific to maps.
// Returns whether to remove the actor.
bool DoMapSpecificEdits(kActor@ actor, const int &in mapId)
{
	switch(mapId)
	{
		// Edit the Primagen Key turn-ins to handle level requirements
		case kLevel_Hub:
			if (!AreLevelRequirementsUsed() ||
				AreLevelRequirementsUsedAndMet())
			{
				break;
			}
		
			if (actor.TID() == 19 ||
				actor.TID() == 20 ||
				actor.TID() == 21 ||
				actor.TID() == 22 ||
				actor.TID() == 23 ||
				actor.TID() == 24) 
				{
					actor.WorldComponent().TouchRadius() = 0;
				}
			break;
	
		// Open the door to the hub if the setting is on
		case kLevel_PortOfAdia_1:
			if (OPTION_OPEN_HUB && actor.TID() == 450)
			{
				actor.ModeStateComponent().SetMode(DOOR_MODE_OPEN);
			}
			break;
			
		// Remove the actors that close the last graveyard so the player can't get stuck there
		case kLevel_RiverOfSouls_11:
			if (actor.TID() == 200001)
			{
				return true;
			}
			break;
	}
	
	return false;
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
			
			Sys.Print("GENERATOR AT: " + posStr);
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
// Modifies the Primagen Key turn-ins so they aren't active if level requirements aren't met.
// Places the hub warps in the level so the player can always go back.
void DoHubModifications(const int16 &in mapId)
{
	kVec3 origin;
	switch(mapId)
	{
		// Primagen Key turn-ins - only modified if level requirements are used and not met
		case kLevel_Hub:
			if (!AreLevelRequirementsUsed() ||
				AreLevelRequirementsUsedAndMet())
			{
				break;
			}
			
			origin.x = -30.72;
			origin.y = 51.2;
			origin.z = 0;
			ActorFactory.Spawn(
				kActor_Hub_PrimagenKeyTrigger,
				origin,
				0, 0, 0);
			break;
			
		// Add hub warps to each level
		case kLevel_RiverOfSouls_1:
			origin.x = -2887.68;
			origin.y = -10629.12;
			origin.z = 0;
			ActorFactory.Spawn(
				kActor_Portal_HubWarp,
				origin,
				-1.5708,
				0,
				0);
			break;
		case kLevel_DeathMarsh_1:
			origin.x = -1658.88;
			origin.y = -6205.44;
			origin.z = 614.39996;
			ActorFactory.Spawn(
				kActor_Portal_HubWarp,
				origin,
				-1.5708,
				0,
				0);
			break;
		case kLevel_BlindLair_1:
			origin.x = 337.91998;
			origin.y = -2600.96;
			origin.z = -624.64;
			ActorFactory.Spawn(
				kActor_Portal_HubWarp,
				origin,
				-1.09626003056,
				0,
				0);
			break;
		case kLevel_HiveTop:
			origin.x = -1566.72;
			origin.y = 2826.24;
			origin.z = 0;
			ActorFactory.Spawn(
				kActor_Portal_HubWarp,
				origin,
				-0.560292001832,
				0,
				0);
			break;
		case kLevel_Lightship_1:
			origin.x = 1341.44;
			origin.y = -4444.1597;
			origin.z = 0;
			ActorFactory.Spawn(
				kActor_Portal_HubWarp,
				origin,
				1.5584278067,
				0,
				0);
			break;
	}
}

//---------------------------
// Whether level requirements are met.
// Will return false if there are no level requirements.
bool AreLevelRequirementsUsedAndMet()
{
	return AreLevelRequirementsUsed() &&
		(LocalPlayer.Inventory().GetCount(kActor_Misc_TotemInventory) >= OPTION_GOAL_LEVELS);
}

//---------------------------
// Whether level requirements are being used.
bool AreLevelRequirementsUsed()
{
	return OPTION_GOAL_LEVELS > 0;
}

//---------------------------
// Whether Primagen requirements are being used and are met.
bool ArePrimagenRequirementsUsedAndMet(const int &in mapId)
{
	return (OPTION_GOAL_PRIMAGEN_LAIR && mapId == kLevel_PrimagenBoss) ||
		(OPTION_GOAL_DEFEAT_PRIMAGEN && 
			(mapId == kLevel_Ending || mapId == kLevel_EndingB));
}

//---------------------------
// Whether Primagen requirements are being used.
bool ArePrimagenRequirementsUsed()
{
	return OPTION_GOAL_PRIMAGEN_LAIR || OPTION_GOAL_DEFEAT_PRIMAGEN;
}