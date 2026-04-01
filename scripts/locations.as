//------------------------------
// Since we can't use kDict or AngelScript dictionaries, we will
// have to keep track of our data with arrays.
//
// Thankfully, we only usually need the data from a single map,
// so this class will make use of an array of arrays, keyed by the map id.
//
// So, this is an array<array<ReplacementEntry@>>.
//------------------------------
array<array<ReplacementEntry@>> g_mapReplacements;
array<array<int>> g_mapLevelNumberToMapIds; // To get all maps for a level

enum LevelNumber
{
	LEVEL_HUB = 0,
	LEVEL_PORT_OF_ADIA = 1,
	LEVEL_RIVER_OF_SOULS = 2,
	LEVEL_DEATH_MARSHES = 3,
	LEVEL_LAIR_OF_THE_BLIND_ONES = 4,
	LEVEL_HIVE_OF_THE_MANTIDS = 5,
	LEVEL_PRIMAGENS_LIGHTSHIP = 6,
	LEVEL_UNMAPPED = 7
}

//------------------------------
// Initialize to handle maps up to an index of 135 (136 includes index 0).
// 135 is the largest map id we need this for.
//
// Also sets up our level id to map numbers array, used to display all
// checks for a given map.
void InitMapReplacements(void)
{
    g_mapReplacements.resize(136); // 0–135 inclusive
    for (uint i = 0; i < g_mapReplacements.length(); i++)
    {
        g_mapReplacements[i] = array<ReplacementEntry@>();
    }
	
	g_mapLevelNumberToMapIds.resize(LEVEL_UNMAPPED + 1);
	for (uint i = 0; i < g_mapLevelNumberToMapIds.length(); i++)
    {
        g_mapLevelNumberToMapIds[i] = array<int>();
    }
	
	// All maps
	array<int>@ portOfAdiaMaps = g_mapLevelNumberToMapIds[LEVEL_PORT_OF_ADIA];
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_1);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_2);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_3);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_4);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_5);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_6);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_7);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_8);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_9);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_T);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_OBL);
	portOfAdiaMaps.insertLast(kLevel_PortOfAdia_Totem);
	
	array<int>@ riverOfSoulsMaps = g_mapLevelNumberToMapIds[LEVEL_RIVER_OF_SOULS];
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_1);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_2);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_3);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_4);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_5);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_6);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_7);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_8);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_9);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_10);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_11);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_T);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_OBL);
	riverOfSoulsMaps.insertLast(kLevel_RiverOfSouls_Totem);
	
	array<int>@ deathMarshesMaps = g_mapLevelNumberToMapIds[LEVEL_DEATH_MARSHES];
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_1);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_2);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_3);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_4);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_5);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_6);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_7);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_8);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_9);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_10);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_11);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_T);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_OBL);
	deathMarshesMaps.insertLast(kLevel_DeathMarsh_Totem);
	
	array<int>@ lairOfTheBlindOnesMaps = g_mapLevelNumberToMapIds[LEVEL_LAIR_OF_THE_BLIND_ONES];
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_1);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_2);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_3);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_4);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_5);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_6);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_7);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_8);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_9);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_10);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_11);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_T);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_OBL);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindLair_Totem);
	lairOfTheBlindOnesMaps.insertLast(kLevel_BlindOneBoss);
	
	array<int>@ hiveOfTheMantidsMaps = g_mapLevelNumberToMapIds[LEVEL_HIVE_OF_THE_MANTIDS];
	hiveOfTheMantidsMaps.insertLast(kLevel_HiveTop);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_1);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_2);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_3);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_4);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_5);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_6);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_7);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_8);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_9);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_10);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_11);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_12);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_13);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_T);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_OBL);
	hiveOfTheMantidsMaps.insertLast(kLevel_Hive_Totem);
	hiveOfTheMantidsMaps.insertLast(kLevel_QueenBoss);
	
	array<int>@ primagensLightshipMaps = g_mapLevelNumberToMapIds[LEVEL_PRIMAGENS_LIGHTSHIP];
	primagensLightshipMaps.insertLast(kLevel_Lightship_1);
	primagensLightshipMaps.insertLast(kLevel_Lightship_2);
	primagensLightshipMaps.insertLast(kLevel_Lightship_3);
	primagensLightshipMaps.insertLast(kLevel_Lightship_4);
	primagensLightshipMaps.insertLast(kLevel_Lightship_5);
	primagensLightshipMaps.insertLast(kLevel_Lightship_6);
	primagensLightshipMaps.insertLast(kLevel_Lightship_7);
	primagensLightshipMaps.insertLast(kLevel_Lightship_8);
	primagensLightshipMaps.insertLast(kLevel_Lightship_9);
	primagensLightshipMaps.insertLast(kLevel_Lightship_10);
	primagensLightshipMaps.insertLast(kLevel_LightShip_T);
	primagensLightshipMaps.insertLast(kLevel_LightShip_OBL);
	primagensLightshipMaps.insertLast(kLevel_MotherBoss);
}

//------------------------------
// Initialize the replacement array using the "patch file" AP generates.
// This is just a bunch of calls to the below AddReplacement functions.
void InitActorReplacements()
{
	#include "rando/randoReplacements.as"
}

//------------------------------
// Gets an internal level number for the given map id.
int GetLevelNumberFromMapId(const int &in mapId)
{
	switch(mapId)
	{
		case kLevel_PortOfAdia_1:
		case kLevel_PortOfAdia_2:
		case kLevel_PortOfAdia_3:
		case kLevel_PortOfAdia_4:
		case kLevel_PortOfAdia_5:
		case kLevel_PortOfAdia_6:
		case kLevel_PortOfAdia_7:
		case kLevel_PortOfAdia_8:
		case kLevel_PortOfAdia_9:
		case kLevel_PortOfAdia_T:
		case kLevel_PortOfAdia_OBL:
		case kLevel_PortOfAdia_Totem:
			return LEVEL_PORT_OF_ADIA;

		case kLevel_RiverOfSouls_1:
		case kLevel_RiverOfSouls_2:
		case kLevel_RiverOfSouls_3:
		case kLevel_RiverOfSouls_4:
		case kLevel_RiverOfSouls_5:
		case kLevel_RiverOfSouls_6:
		case kLevel_RiverOfSouls_7:
		case kLevel_RiverOfSouls_8:
		case kLevel_RiverOfSouls_9:
		case kLevel_RiverOfSouls_10:
		case kLevel_RiverOfSouls_11:
		case kLevel_RiverOfSouls_T:
		case kLevel_RiverOfSouls_OBL:
		case kLevel_RiverOfSouls_Totem:
			return LEVEL_RIVER_OF_SOULS;
			
		case kLevel_DeathMarsh_1:
		case kLevel_DeathMarsh_2:
		case kLevel_DeathMarsh_3:
		case kLevel_DeathMarsh_4:
		case kLevel_DeathMarsh_5:
		case kLevel_DeathMarsh_6:
		case kLevel_DeathMarsh_7:
		case kLevel_DeathMarsh_8:
		case kLevel_DeathMarsh_9:
		case kLevel_DeathMarsh_10:
		case kLevel_DeathMarsh_11:
		case kLevel_DeathMarsh_T:
		case kLevel_DeathMarsh_OBL:
		case kLevel_DeathMarsh_Totem:
			return LEVEL_DEATH_MARSHES;
			
		case kLevel_BlindLair_1:
		case kLevel_BlindLair_2:
		case kLevel_BlindLair_3:
		case kLevel_BlindLair_4:
		case kLevel_BlindLair_5:
		case kLevel_BlindLair_6:
		case kLevel_BlindLair_7:
		case kLevel_BlindLair_8:
		case kLevel_BlindLair_9:
		case kLevel_BlindLair_10:
		case kLevel_BlindLair_11:
		case kLevel_BlindLair_T:
		case kLevel_BlindLair_OBL:
		case kLevel_BlindLair_Totem:
		case kLevel_BlindOneBoss:
			return LEVEL_LAIR_OF_THE_BLIND_ONES;
			
		case kLevel_HiveTop:
		case kLevel_Hive_1:
		case kLevel_Hive_2:
		case kLevel_Hive_3:
		case kLevel_Hive_4:
		case kLevel_Hive_5:
		case kLevel_Hive_6:
		case kLevel_Hive_7:
		case kLevel_Hive_8:
		case kLevel_Hive_9:
		case kLevel_Hive_10:
		case kLevel_Hive_11:
		case kLevel_Hive_12:
		case kLevel_Hive_13:
		case kLevel_Hive_T:
		case kLevel_Hive_OBL:
		case kLevel_Hive_Totem:
		case kLevel_QueenBoss:
			return LEVEL_HIVE_OF_THE_MANTIDS;
			
		case kLevel_Lightship_1:
		case kLevel_Lightship_2:
		case kLevel_Lightship_3:
		case kLevel_Lightship_4:
		case kLevel_Lightship_5:
		case kLevel_Lightship_6:
		case kLevel_Lightship_7:
		case kLevel_Lightship_8:
		case kLevel_Lightship_9:
		case kLevel_Lightship_10:
		case kLevel_LightShip_T:
		case kLevel_LightShip_OBL:
		case kLevel_MotherBoss:
			return LEVEL_PRIMAGENS_LIGHTSHIP;
	}
	
	return LEVEL_UNMAPPED;
}

//------------------------------
// Add to the map for a local item.
// - name: The friendly name of the actor
// - apId: The AP id of the location
// - position: The position of the actor, to identify it on the map
//  - This is in the format: <map-id>_x_y_z, so Atoi will get the map id
// - replacementActorId: The actor id to replace this with
void AddReplacement(
	const kStr &in name, 
	const int &in apId, 
	const kStr &in position,
	const int &in replacementActorId)
{
	ReplacementEntry @entry = ReplacementEntry(
		name, apId, position, replacementActorId);
    g_mapReplacements[entry.mapId].insertLast(entry);
}

//------------------------------
// Add to the array for an off-world AP item.
// - name: The friendly name of the actor
// - apId: The AP id of the location
// - position: The position of the actor, to identify it on the map
// - displayString: What text to display when picking up the item
// - isProgression: Affects whether we use the gold or gray outined model
void AddReplacement(
	const kStr &in name,
	const int &in apId, 
	const kStr &in position,
	const kStr &in displayString,
	const bool &in isProgression = false)
{
	ReplacementEntry @entry = ReplacementEntry(
		name, apId, position, displayString, isProgression);
    g_mapReplacements[entry.mapId].insertLast(entry);
}

//------------------------------
// Tries to get the replacement array for the given map id.
// If not found, locations is null and returns false.
// If found, locations is the found location and returns true.
bool TryGetReplacementArray(
	const int16 &in mapId, 
	array<ReplacementEntry@>@ &out locations)
{
	if (mapId < 0 || mapId >= int16(g_mapReplacements.length()))
	{
		@locations = null;
		return false;
	}
	
	@locations = g_mapReplacements[mapId];
	return locations !is null;
}

//------------------------------
// Tries to get the replacement for the given actor id.
// Will return false if not found.
// - mapId: The map id (passed directly for performance reasons)
// - position: The position of the actor to get
// - replacementEntry: The retrieved entry
// Returns true if the replacement was found; false otherwise.
bool TryGetReplacement(
	const int16 &in mapId,
	const kStr &in position,
	ReplacementEntry@ &out replacementEntry)
{
	array<ReplacementEntry@>@ locations;
	if (!TryGetReplacementArray(mapId, locations))
	{
		return false;
	}

    for (uint i = 0; i < locations.length(); i++)
    {
        ReplacementEntry @entry = locations[i];
        if (entry.position == position)
        {
			@replacementEntry = entry;
            return true;
        }
    }
    return false;
}

//------------------------------
// Gets the replacement on the given map with the given AP id.
// Returns null if not found.
ReplacementEntry@ GetReplacementWithApId(
	const int &in apId, const int &in mapId)
{
	array<ReplacementEntry@>@ locations;
	if (!TryGetReplacementArray(mapId, locations))
	{
		return null;
	}
	
    for (uint i = 0; i < locations.length(); i++)
    {
        if (locations[i].apId == apId)
		{
			return @locations[i];
		}
    }
	
	return null;
}

//------------------------------
// Sets the isCollected and isSentToAP flags back to false for all entries.
// This is only done on a new game or save load.
// Save loads will reset the value to whatever was serialized.
void ResetCollectedStatuses()
{
	for (uint i = 0; i < g_mapReplacements.length(); i++)
	{
		array<ReplacementEntry@>@ locations = g_mapReplacements[i];
		for (uint j = 0; j < locations.length(); j++)
		{
			locations[j].isCollected = false;
			locations[j].isSentToAP = false;
		}
	}
}

//------------------------------
// Displays a string indicating collection progress for the current map:
// locations checked / total locations.
void DisplayCollectedLocationsForCurrentMap(const int &in visibleTime = 120)
{
	array<ReplacementEntry@>@ locations = 
		g_mapReplacements[Game.ActiveMapID()];
	int totalCollected = 0;
	for (uint i = 0; i < locations.length(); i++)
	{
		if (locations[i].isCollected || locations[i].isSentToAP)
		{
			totalCollected++;
		}
	}
	
	Hud.AddMessage(
		"Map progress: " + totalCollected + "/" + locations.length(),
		visibleTime);
}

//------------------------------
// Displays a string indicating collection progress for the current level:
// locations checked / total locations.
void DisplayCollectedLocationsForLevel(
	const int &in mapId,
	const kStr &in prefix,
	const int &in visibleTime = 120)
{
	int totalCollected;
	int totalLocations;
	CalculateTotalLocationsCheckedForLevelFromMap(
		mapId,
		totalCollected, 
		totalLocations);

	Hud.AddMessage(
		prefix + ": " + totalCollected + "/" + totalLocations,
		visibleTime);
}

//------------------------------
// Calculates the total locations on the level, given the level number.
// Outputs the total collected locations and total locations.
void CalculateTotalLocationsCheckedForLevel(
	const int &in levelNumber,
	int &out totalCollected, 
	int &out totalLocations)
{
	totalCollected = 0;
	totalLocations = 0;

	array<int>@ mapIds = g_mapLevelNumberToMapIds[levelNumber];
	for (uint i = 0; i < mapIds.length(); i++)
	{
		array<ReplacementEntry@>@ locations = 
			g_mapReplacements[mapIds[i]];
		
		totalLocations += locations.length();
		
		for (uint j = 0; j < locations.length(); j++)
		{
			if (locations[j].isCollected || locations[j].isSentToAP)
			{
				totalCollected++;
			}
		}
	}
}

//------------------------------
// Calculates the total locations on the level, given a map id in that level.
// Outputs the total collected locations and total locations.
void CalculateTotalLocationsCheckedForLevelFromMap(
	const int &in mapId,
	int &out totalCollected, 
	int &out totalLocations)
{
	int levelNumber = GetLevelNumberFromMapId(mapId);
	CalculateTotalLocationsCheckedForLevel(levelNumber, totalCollected, totalLocations);
}

//------------------------------
// Displays a string indicating collection progress for the current level:
// locations checked / total locations.
void DisplayCollectedLocationsForGame(const int &in visibleTime = 120)
{
	int totalCollected = 0;
	int totalChecks = 0;
	
	int levelCollected;
	int levelTotal;
	
	array<int> levels = {
		LEVEL_PORT_OF_ADIA,
		LEVEL_RIVER_OF_SOULS,
		LEVEL_DEATH_MARSHES,
		LEVEL_LAIR_OF_THE_BLIND_ONES,
		LEVEL_HIVE_OF_THE_MANTIDS,
		LEVEL_PRIMAGENS_LIGHTSHIP
	};
	
	kStr output = "Levels: ";
	
	for (uint i = 0; i < levels.length(); i++)
	{
		CalculateTotalLocationsCheckedForLevel(levels[i], levelCollected, levelTotal);
		totalCollected += levelCollected;
        totalChecks += levelTotal;
		
        if (i > 0)
        {
            output += " - ";
        }

        output += "" + levelCollected + "/" + levelTotal;
	}
	
	Hud.AddMessage(output, visibleTime);
	Hud.AddMessage(
		"Total Checks: " + totalCollected + "/" + totalChecks,
		visibleTime);
}

//------------------------------
// Puts the location in the outgoing message queue for AP.
// This is different from collecting it, as you could touch health/ammo that
// you cannot pick up. We still want to send that to AP.
// apId: The AP id to send to AP
void SendCheckToAP(const int &in apId)
{
	ReplacementEntry@ location = GetReplacementWithApId(apId, Game.ActiveMapID());
	if (location !is null && !location.isSentToAP)
	{
		location.isSentToAP = true;
		g_outgoingMessageQueue.insertLast(apId);
	}
}

//------------------------------
// Marks the given location as collected by setting it in the map.
// We handle sending to AP in SendCheckToAP - see that documentation.
// apId: The AP id to mark as collected
void CollectLocation(const int &in apId, const int &in mapId)
{
	ReplacementEntry@ location = GetReplacementWithApId(apId, mapId);
	if (location !is null)
	{
		location.isCollected = true;
	}
}

//------------------------------
// Marks the location as sent to AP.
// Used when loading a save with locations already sent to AP.
// apId: The AP id to mark as sent to AP
void MarkSentToAP(const int &in apId, const int &in mapId)
{
	ReplacementEntry@ location = GetReplacementWithApId(apId, mapId);
	if (location !is null)
	{
		location.isSentToAP = true;
	}
}

//------------------------------
// Intended to be called from the console. Adds ALL sent locations to the outgoing queue.
// Used (hopefully never) in the case where the server doesn't know everything we received.
void Resync()
{
	// Reset outgoing state first - we're resending everything again anyway!
    g_outgoingMessageQueue.resize(0);
    g_outgoingMessageInFlight = false;
    g_AP.OutgoingStatus = AP_READY;
	
	for (uint i = 0; i < g_mapReplacements.length(); i++)
	{
		array<ReplacementEntry@>@ locations = g_mapReplacements[i];
		for (uint j = 0; j < locations.length(); j++)
		{
			if (locations[j] !is null && locations[j].isSentToAP)
			{
				g_outgoingMessageQueue.insertLast(locations[j].apId);
			}
		}
	}
}

//------------------------------
// The AP id is in this format: MMXXX or MMMXXX.
// We can get the map (M) part with some simple math.
int ConvertMapIdFromApId(const int &in apId)
{
	return apId / 1000;
}

//------------------------------
// For performance, checks if the map has ammo generators to replace
bool DoesMapHaveAmmoGeneratorsToReplace(const int16 &in mapId)
{
	switch(mapId)
	{
		case kLevel_RiverOfSouls_5:
		case kLevel_RiverOfSouls_9:
		case kLevel_RiverOfSouls_10:
		case kLevel_RiverOfSouls_8:
		case kLevel_RiverOfSouls_11:
		case kLevel_DeathMarsh_8:
			return true;
	}
	
	return false;
}

//------------------------------
// Returns whether the passed position is an ammo generator we need to replace.
bool IsAmmoGeneratorToReplace(
	const int16 &in mapId,
	const kStr &in position)
{
	switch(mapId)
	{
		// Soul Gate 1
		case kLevel_RiverOfSouls_5:
			return position == "-3635_3788_-612" ||
				position == "-4659_3788_-612";
		// Graveyard 1
		case kLevel_RiverOfSouls_9:
			return position == "-672_795_-4761" ||
				position == "-1172_793_-4761";
		// Graveyard 2
		case kLevel_RiverOfSouls_10:
			return position == "153_-1638_1024" ||
				position == "153_-102_1024";
		// Soul Gate 2
		case kLevel_RiverOfSouls_8:
			return position == "10547_-972_872" ||
				position == "10547_-1996_872";
		// Graveyard 3
		case kLevel_RiverOfSouls_11:
			return position == "-1382_-4147_0" ||
				position == "-1280_-2611_0" ||
				position == "870_-1996_0" ||
				position == "870_6195_4" ||
				position == "-716_6195_1";
		
		// Ratpor Battle	
		case kLevel_DeathMarsh_8:
			return position == "-2150_-1177_0" ||
				position == "-1945_-1382_0" ||
				position == "-2150_-1587_0" ||
				position == "-2355_-1382_0";
	}
	
	return false;
}

//------------------------------
// Whether this is an actor that needs to be triggered by our pickup.
bool IsActorToTrigger(
	const int16 &in mapId,
	const int &in tagId) 
{
	switch(mapId)
	{
		// Raptor Rooms
		case kLevel_DeathMarsh_8:
			return tagId == 200001 || 
				tagId == 200002 ||
				tagId == 200003 || 
				tagId == 200004 ||
				tagId == 200005;

		// Level Key Trap 1
		case kLevel_BlindLair_3:
			return tagId == 200009 ||
				tagId == 200010 ||
				tagId == 200011 ||
				tagId == 200012 ||
				tagId == 200013 ||
				tagId == 200014 ||
				tagId == 200015;
				
		// Level Key Trap 2
		case kLevel_BlindLair_8:
			return tagId == 200032 || 
				tagId == 200033 ||
				tagId == 200034 ||
				tagId == 200035 ||
				tagId == 200036 ||
				tagId == 200037 ||
				tagId == 200038;
				
		// Level Key Trap 3
		case kLevel_BlindLair_6:
			return tagId == 200031 || 
				tagId == 200032 ||
				tagId == 200033 || 
				tagId == 200034;
	}
	
	return false;
}

//------------------------------
// Whether this is an actor to trigger an action object.
// If this gets too big, we'll want a switch-case on the map.
bool IsActorTriggeringActor(const kStr &in position)
{
	return position == "68_-2150_-1381_30" ||
		position == "100_1074_3630_-2437" ||
		position == "105_-5429_-3174_-2734" ||
		position == "103_-8652_-149_-3604";
}