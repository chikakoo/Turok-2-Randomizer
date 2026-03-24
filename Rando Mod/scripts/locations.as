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
	
	// Port of Adia
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
		case kLevel_PortOfAdia_OBL:
			return LEVEL_PORT_OF_ADIA;
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
// - replacementActorId: The actor id to replace this with
void AddReplacement(
	const kStr &in name,
	const int &in apId, 
	const kStr &in position,
	const kStr &in displayString)
{
	ReplacementEntry @entry = ReplacementEntry(
		name, apId, position, displayString);
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