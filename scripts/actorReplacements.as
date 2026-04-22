// --------------------------
// Handles actor replacements/placements when a player spawns.
//---------------------------

//---------------------------
// Handles all replacements
void DoActorReplacementsOnPlayerSpawn()
{
	int16 mapId = Game.ActiveMapID();
	
	if (OPTION_WEAPON_SANITY)
	{
		UseRandomAmmoGenerators();
	}
	
	// Reset the actors to trigger BEFORE replacing actors
	g_actorsToTrigger.resize(0);
	
	// Modify actors
	ReplaceAllActors(mapId);
	DoHubModifications(mapId);
	AddWarpBarriers(mapId);
}

//---------------------------
// Add the warp barriers to the map
// If the setting is 0, it isn't used, so just return early
void AddWarpBarriers(const int16 &in mapId)
{
	if (OPTION_PROGRESSIVE_WARPS <= 0)
	{
		return;
	}

	switch(mapId)
	{
		// Port of Adia
		case kLevel_PortOfAdia_1: // Start
			AddWarpBarrier(kVec3(3840, 614.4, 307.2), kActor_InventoryItem_ProgressiveWarpL1, 1);
			break;
		case kLevel_PortOfAdia_2: // Water hub (to ships and talisman portal)
			AddWarpBarrier(kVec3(-3184.67, 295.964, 0), kActor_InventoryItem_ProgressiveWarpL1, 2);
			AddWarpBarrier(kVec3(3184.67, 318.436, 614.4), kActor_InventoryItem_ProgressiveWarpL1, 4);
			break;
		case kLevel_PortOfAdia_3: // Ships
			AddWarpBarrier(kVec3(1536, 1863.68, 307.2), kActor_InventoryItem_ProgressiveWarpL1, 3);
			break;
		case kLevel_PortOfAdia_5: // Talisman portal - not in the order the numbers suggest
			AddWarpBarrier(kVec3(-2867.2, 1382.4, 614.4), kActor_InventoryItem_ProgressiveWarpL1, 5);
			break;
		case kLevel_PortOfAdia_4: // Child 3
			AddWarpBarrier(kVec3(1843.23, 4179.359, 632.264), kActor_InventoryItem_ProgressiveWarpL1, 6);
			break;
		case kLevel_PortOfAdia_6: // Archery
			AddWarpBarrier(kVec3(-1638.4, 3379.2, 307.2), kActor_InventoryItem_ProgressiveWarpL1, 7);
			break;
		case kLevel_PortOfAdia_7: // Child 4
			AddWarpBarrier(kVec3(5222.4, 1331.2, 0), kActor_InventoryItem_ProgressiveWarpL1, 8);
			break;
		case kLevel_PortOfAdia_8: // Gated City
			AddWarpBarrier(kVec3(1843.2, 102.4, 0), kActor_InventoryItem_ProgressiveWarpL1, 9);
			break;
		// Catwalks is the last map
			
		// River of Souls
		case kLevel_RiverOfSouls_1: // Start
			AddWarpBarrier(kVec3(3686.4, 7987.2, 921.6), kActor_InventoryItem_ProgressiveWarpL2, 1);
			break;
		case kLevel_RiverOfSouls_2: // Bridge Switch 1
			AddWarpBarrier(kVec3(-4454.467, -297.377, 460.8), kActor_InventoryItem_ProgressiveWarpL2, 2);
			break;
		case kLevel_RiverOfSouls_3: // River Bridge 1
			AddWarpBarrier(kVec3(-4147.2, -307.2, -614.4), kActor_InventoryItem_ProgressiveWarpL2, 3);
			break;
		case kLevel_RiverOfSouls_4: // Gate Key Door
			AddWarpBarrier(kVec3(1945.6, 5120, 716.8), kActor_InventoryItem_ProgressiveWarpL2, 4);
			break;
		case kLevel_RiverOfSouls_5: // Soul Gate 1
			AddWarpBarrier(kVec3(-6758.399, 5529.6, -153.6), kActor_InventoryItem_ProgressiveWarpL2, 5);
			break;
		case kLevel_RiverOfSouls_6: // Long Path, Water Maze, Big Cylinder
			AddWarpBarrier(kVec3(-102.4, 870.4, 614.4), kActor_InventoryItem_ProgressiveWarpL2, 6);
			AddWarpBarrier(kVec3(-2913.747, 6870.931, -4761.6), kActor_InventoryItem_ProgressiveWarpL2, 7);
			AddWarpBarrier(kVec3(6092.8, -1689.6, -3532.8), kActor_InventoryItem_ProgressiveWarpL2, 9);
			break;
		case kLevel_RiverOfSouls_9: // Graveyard 1 (between last 2 of map 6)
			AddWarpBarrier(kVec3(-1684.48, -337.92, -4761.6), kActor_InventoryItem_ProgressiveWarpL2, 8);
			break;
		case kLevel_RiverOfSouls_7: // LF Jump Pads (2 warps on same level)
			AddWarpBarrier(kVec3(-4044.035, 7276.109, -51.2), kActor_InventoryItem_ProgressiveWarpL2, 10);
			AddWarpBarrier(kVec3(3072, -3635.2, 716.8), kActor_InventoryItem_ProgressiveWarpL2, 10);
			break;
		case kLevel_RiverOfSouls_8: // Last Map
			AddWarpBarrier(kVec3(745.576, -1540.403, 716.8), kActor_InventoryItem_ProgressiveWarpL2, 11);
			break;
		// Graveyard 2/3 are the other maps, and they don't lead anywhere
		
		// Death Marshes
		case kLevel_DeathMarsh_1: // Start (ammo storage and level progression)
			AddWarpBarrier(kVec3(-445.089, -4813.84, 921.6), kActor_InventoryItem_ProgressiveWarpL3, 1);
			AddWarpBarrier(kVec3(30.72, -4782.08, 921.6), kActor_InventoryItem_ProgressiveWarpL3, 1);
			break;
		case kLevel_DeathMarsh_2: // Checkpoint 1
			AddWarpBarrier(kVec3(-2225.035, 4691.924, 0), kActor_InventoryItem_ProgressiveWarpL3, 2);
			break;
		case kLevel_DeathMarsh_3: // Oblivion
			AddWarpBarrier(kVec3(1228.8, 3850, 0), kActor_InventoryItem_ProgressiveWarpL3, 3);
			break;
		case kLevel_DeathMarsh_4: // Ammo 2, Bridge Bottom, Bridge Top
			AddWarpBarrier(kVec3(-1559.966, 2460.242, 614.4), kActor_InventoryItem_ProgressiveWarpL3, 4);
			AddWarpBarrier(kVec3(842.321, -5330.751, 307.2), kActor_InventoryItem_ProgressiveWarpL3, 4);
			AddWarpBarrier(kVec3(3686.4, 4157.44, 1228.8), kActor_InventoryItem_ProgressiveWarpL3, 5);
			break;
		case kLevel_DeathMarsh_5: // Long Bridge
			AddWarpBarrier(kVec3(768, -8755.2, 921.6), kActor_InventoryItem_ProgressiveWarpL3, 6);
			break;
		case kLevel_DeathMarsh_6: // Talisman
			AddWarpBarrier(kVec3(3225.6, -307.2, -614.4), kActor_InventoryItem_ProgressiveWarpL3, 7);
			break;
		case kLevel_DeathMarsh_7: // Ammo 3 and Exit
			AddWarpBarrier(kVec3(-2319.356, 3483.491, 0), kActor_InventoryItem_ProgressiveWarpL3, 8);
			AddWarpBarrier(kVec3(-3440.40, 829.756, 0), kActor_InventoryItem_ProgressiveWarpL3, 8);
			break;
		// Other maps are the ammo maps and the end Raptor battle
		
		// Lair of the Blind Ones
		case kLevel_BlindLair_1: // Start (Prim key + progress)
			AddWarpBarrier(kVec3(-2969.6, -5683.2, -1536), kActor_InventoryItem_ProgressiveWarpL4, 1);
			AddWarpBarrier(
				kVec3(3174.4, 3330.4, -2250), 
				kActor_InventoryItem_ProgressiveWarpL4,
				1,
				1251);
			break;
		case kLevel_BlindLair_2: // Water Rooms
			AddWarpBarrier(
				kVec3(5478.4, -3276.8, -4100), 
				kActor_InventoryItem_ProgressiveWarpL4, 
				2,
				130);
			break;
		case kLevel_BlindLair_3:  // Falling Rocks
			AddWarpBarrier(kVec3(2600.96, -5273.6, -1863.68), kActor_InventoryItem_ProgressiveWarpL4, 3);
			break;
		case kLevel_BlindLair_4:  // Waterfall (Vent 1 + Progress)
			AddWarpBarrier(kVec3(3112.96, 3287.04, -2457.6), kActor_InventoryItem_ProgressiveWarpL4, 4);
			AddWarpBarrier(kVec3(-1105.92, -4423.68, -2488.32), kActor_InventoryItem_ProgressiveWarpL4, 4);
			break;
		case kLevel_BlindLair_5:  // Water Maze (Vent 2 + Progress)
			AddWarpBarrier(kVec3(3891.2, 3328, -3379.2), kActor_InventoryItem_ProgressiveWarpL4, 5);
			AddWarpBarrier(kVec3(2355.2, -3891.2, -3072), kActor_InventoryItem_ProgressiveWarpL4, 5);
			break;
		case kLevel_BlindLair_6:  // Small Lava
			AddWarpBarrier(kVec3(2354, -800, -3338.24), kActor_InventoryItem_ProgressiveWarpL4, 6);
			break;
		case kLevel_BlindLair_7:  // Big Lava
			AddWarpBarrier(kVec3(-1187, -5435.04, -4628.48), kActor_InventoryItem_ProgressiveWarpL4, 7);
			break;
		case kLevel_BlindLair_8:  // Blue Cave (Lower and Post Vent 3)
			AddWarpBarrier(
				kVec3(-6585, 3595, -2489.874),
				kActor_InventoryItem_ProgressiveWarpL4, 
				8,
				1297);
			AddWarpBarrier(kVec3(2928.64, 2355.2, -2539.52), kActor_InventoryItem_ProgressiveWarpL4, 10);
			break;
		case kLevel_BlindLair_11: // Vent 3
			AddWarpBarrier(kVec3(0, -4761.6, -2457.6), kActor_InventoryItem_ProgressiveWarpL4, 9);
			break;
		// Others are the other two vents
		
		// Hive of the Mantids
		case kLevel_HiveTop: // Start - 402
			AddWarpBarrier(kVec3(10.24, 465.92, -230.4), kActor_InventoryItem_ProgressiveWarpL5, 1);
			break;
		case kLevel_Hive_1: // Force Fields
			AddWarpBarrier(kVec3(4761.6, 1075.2, -307.2), kActor_InventoryItem_ProgressiveWarpL5, 2);
			break;
		case kLevel_Hive_2: // Pit 1
			AddWarpBarrier(kVec3(-2150.4, -5836.8, -1228.8), kActor_InventoryItem_ProgressiveWarpL5, 3);
			break;
		case kLevel_Hive_3: // Switch Loop
			AddWarpBarrier(kVec3(5990.4, 307.2, -1843.2), kActor_InventoryItem_ProgressiveWarpL5, 4);
			break;
		case kLevel_Hive_4: // Pit 2
			AddWarpBarrier(kVec3(-2457.6, 2764.8, -2764.8), kActor_InventoryItem_ProgressiveWarpL5, 5);
			break;
		case kLevel_Hive_5: // Pit 3
			AddWarpBarrier(kVec3(-307.2, -4761.6, -614.4), kActor_InventoryItem_ProgressiveWarpL5, 6);
			break;
		case kLevel_Hive_6: // Water
			AddWarpBarrier(kVec3(2457.6, -10147.84, -614.4), kActor_InventoryItem_ProgressiveWarpL5, 7);
			break;
		case kLevel_Hive_7: // Inner Hive
			AddWarpBarrier(kVec3(-4454.4, 3686.4, 614.4), kActor_InventoryItem_ProgressiveWarpL5, 8);
			break;
		case kLevel_Hive_10: // Embryo 1
			AddWarpBarrier(kVec3(-3686.4, -2764.8, 0), kActor_InventoryItem_ProgressiveWarpL5, 9);
			break;
		case kLevel_Hive_8: // Exit Map (embryo 2, 3, master computer, prim key)
			AddWarpBarrier(kVec3(-152.6, 4454.4, 0), kActor_InventoryItem_ProgressiveWarpL5, 10);
			AddWarpBarrier(kVec3(3532.8, -3840, 614.4), kActor_InventoryItem_ProgressiveWarpL5, 10);
			AddWarpBarrier(kVec3(-614.4, -1382.4, 614.4), kActor_InventoryItem_ProgressiveWarpL5, 10);
			AddWarpBarrier(kVec3(3993.6, 0, 614.4), kActor_InventoryItem_ProgressiveWarpL5, 10);
			break;
		// The rest are maps that lead back to existing ones, or are dead ends
		
		// Primagen's Lightship
		case kLevel_Lightship_1: // Hub (all 4 wings)
			AddWarpBarrierForL6(kVec3(-3020, -3532.8, 0), 1);
			AddWarpBarrierForL6(kVec3(-3948.333, 3229.040, 0), 3);
			AddWarpBarrierForL6(kVec3(2609.031, 4532.526, 0), 6);
			AddWarpBarrierForL6(kVec3(4217.492, -2917.491, 0), 9);
			break;
		case kLevel_Lightship_2: // Wing 1 Start
			AddWarpBarrierForL6(kVec3(6239.653, -459.862, 0), 2);
			break;
		case kLevel_Lightship_3: // Wing 2 Start
			AddWarpBarrierForL6(kVec3(-767.074, 5036.014, -1228.8), 4);
			break;
		case kLevel_Lightship_4: // Wing 2 Generator
			AddWarpBarrierForL6(kVec3(3991.330, 3168.541, 0), 5);
			break;
		case kLevel_Lightship_5: // Wing 3 Start
			AddWarpBarrierForL6(kVec3(-3005.715, 3071.414, 1382.402), 7);
			break;
		case kLevel_Lightship_6: // Wing 3 Generator
			AddWarpBarrierForL6(kVec3(-611.706, -3768.962, -153.604), 8);
			break;
		case kLevel_Lightship_7: // Wing 4 Start
			AddWarpBarrierForL6(kVec3(3754.658, 2.79, 0), 10);
			break;
		case kLevel_Lightship_8: // Assembly 1
			AddWarpBarrierForL6(kVec3(-155.676, -4078.439, 307.207), 11);
			break;
		case kLevel_Lightship_9: // Assembly 2
			AddWarpBarrierForL6(kVec3(-614.715, -3302.234, 307.207), 12);
			break;
		case kLevel_Lightship_10: // Assembly 3
			AddWarpBarrierForL6(kVec3(-1616.721, -767.995, 6.814), 13);
			break;
	}
}

//---------------------------
// Adds a warp barrier at the given position, warp actor id, requiring the given number of warps
RandoWarpBarrier@ AddWarpBarrier(
	const kVec3 &in pos, 
	const int &in progressiveWarpActorId,
	const int &in progressiveWarpsNeeded)
{
	kActor@ barrier = ActorFactory.Spawn(
		kActor_ProgressionBlocker_WarpBarrier,
		pos,
		0, 0, 0
	);
	RandoWarpBarrier@ barrierScript = cast<RandoWarpBarrier@>(GetScript(barrier));
	barrierScript.SetBarrierInfo(progressiveWarpActorId, progressiveWarpsNeeded);
	return barrierScript;
}

//---------------------------
// Adds a warp barrier, setting the warp back position as well
void AddWarpBarrier(
	const kVec3 &in pos, 
	const int &in progressiveWarpActorId,
	const int &in progressiveWarpsNeeded,
	const int &in warpBackRegion)
{
	RandoWarpBarrier@ barrierScript = AddWarpBarrier(pos, progressiveWarpActorId, progressiveWarpsNeeded);
	barrierScript.SetWarpBack(warpBackRegion);
}

//---------------------------
// Adds a warp barrier for level 6
// Level 6 warps need a larger radius
void AddWarpBarrierForL6(
	const kVec3 &in pos, 
	const int &in progressiveWarpsNeeded)
{
	RandoWarpBarrier@ barrierScript = AddWarpBarrier(
		pos,
		kActor_InventoryItem_ProgressiveWarpL6, 
		progressiveWarpsNeeded);
	barrierScript.SetRadii(280.0f);
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
	if (!replacement.isSentToAP && replacement.apId > 0)
	{
		replacedActor.Flags() |= AF_IMPORTANT;
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

		// Open the door to the last graveyard gate so the player can't get stuck there
		// Afterwards, disable the component so it can't be closed
		case kLevel_RiverOfSouls_11:
			if (actor.TID() == 60 && actor.HasComponent("kexModeStateComponent"))
			{
				actor.ModeStateComponent().SetMode(DOOR_MODE_OPEN);
				actor.EnableComponent("kexModeStateComponent", false);
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
// Places the Level 1 barrier if appropriate.
void DoHubModifications(const int16 &in mapId)
{
	if (mapId != kLevel_Hub)
	{
		return;
	}

	if (AreLevelRequirementsUsed() && !AreLevelRequirementsUsedAndMet())
	{
		ActorFactory.Spawn(
			kActor_Hub_PrimagenKeyTrigger,
			kVec3(-30.72, 51.2, 0),
			0, 0, 0);
	}
	

	ActorFactory.Spawn(
		kActor_ProgressionBlocker_Level1Barrier,
		kVec3(-111.983, -2232.514, -256),
		0, 0, 0);
}

//---------------------------
// Whether level requirements are met.
// Will return false if there are no level requirements.
bool AreLevelRequirementsUsedAndMet()
{
	return AreLevelRequirementsUsed() &&
		(GetInventoryItemCurrentTotal(kActor_Misc_TotemInventory) >= OPTION_GOAL_LEVELS);
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