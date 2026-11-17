//------------------------------
// Represents an actor location that acts as a check
// - name: The friendly name of the actor
// - apId: The location's AP id = MapID### (e.g. 51001 is item 2 on map 51)
// - tagId: The tag id of the actor - will uniquely identify it on the map
// - mapId: Computed from the AP id
// - givenActorId: If not 0 - the item actor to reward the player with after getting this check
// - displayString: The display string to display when collected (only filled for AP items)
// - isSentToAP: Whether the player has sent the check to AP (used for resyncing)
//------------------------------
class APActorLocation
{
	kStr name;
	int apId;
	int tagId;
	int mapId;
	int givenActorId;
	kStr displayString;
	bool isSentToAP;
	
	APActorLocation() {}
	
	APActorLocation(
		const kStr &in name,
		const int &in apId,
		const int &in tagId,
		const int &in givenActorId)
	{
		this.name = name;
		this.apId = apId;
		this.tagId = tagId;
		this.givenActorId = givenActorId;
		this.displayString = "";
		this.mapId = ConvertMapIdFromApId(apId);
		this.isSentToAP = false;
	}
	
	APActorLocation(
		const kStr &in name,
		const int &in apId,
		const int &in tagId,
		const kStr &in displayString,
		const bool &in isProgression = false)
	{
		this.name = name;
		this.apId = apId;
		this.tagId = tagId;
		this.givenActorId = 0;
		this.displayString = displayString;
		this.mapId = ConvertMapIdFromApId(apId);
		this.isSentToAP = false;
	}
	
	//------------------------------
	// Puts the location in the outgoing message queue for AP.
	// Handles processing the message as well so you get the item from the check.
	void SendCheckToAP()
	{
		if (!this.isSentToAP)
		{
			this.isSentToAP = true;
			g_outgoingMessageQueue.insertLast(apId);
			
			if (mapId > 0)
			{
				DisplayCollectedLocationsForCurrentMap();
			}
			
			if (this.givenActorId > 0)
			{
				ProcessMessage(this.givenActorId);
			}
			
			if (displayString != "")
			{
				Hud.AddMessage(displayString);
			}
		}
	}
}

//------------------------------
// Add to the map for a local item.
// - name: The friendly name of the actor
// - apId: The AP id of the location
// - tagId: The tag of the actor to identify it on the map
// - givenActorId: The actor id the player will receive
void AddAPActorLocation(
	const kStr &in name, 
	const int &in apId,
	const int &in tagId,
	const int &in givenActorId)
{
	APActorLocation @entry = APActorLocation(
		name, apId, tagId, givenActorId);
    g_apActorLocations[entry.mapId].insertLast(entry);
}

//------------------------------
// Add to the map for a remote item.
// - name: The friendly name of the actor
// - apId: The AP id of the location
// - tagId: The tag of the actor to identify it on the map
// - displayString: The string to display when the actor is triggered
void AddAPActorLocation(
	const kStr &in name, 
	const int &in apId,
	const int &in tagId,
	const kStr &in displayString = "")
{
	APActorLocation @entry = APActorLocation(
		name, apId, tagId, displayString);
    g_apActorLocations[entry.mapId].insertLast(entry);
}

//------------------------------
// Tries to send the ap actor location with the matching tag id on the given map to AP.
// If it doesn't exist, it doesn't do anything.
void TrySendAPActorLocationToAP(const int &in tagId, const int16 &in mapId)
{
	APActorLocation@ apActorLocation;
	if (TryGetAPActorLocationForMap(tagId, apActorLocation, mapId))
	{
		apActorLocation.SendCheckToAP();
	}
}

//------------------------------
// Tries to get the replacement for the given actor id.
// Will return false if not found.
// - tagId: The tag id of the entry to get
// - apActorLocation: The retrieved entry
// Returns true if the replacement was found; false otherwise.
bool TryGetAPActorLocationForCurrentMap(
	const int &in tagId,
	APActorLocation@ &out apActorLocation)
{
	return TryGetAPActorLocationForMap(tagId, apActorLocation, Game.ActiveMapID());
}

//------------------------------
// Tries to get the replacement for the given actor id.
// Will return false if not found.
// - tagId: The tag id of the entry to get
// - apActorLocation: The retrieved entry
// Returns true if the replacement was found; false otherwise.
bool TryGetAPActorLocationForMap(
	const int &in tagId,
	APActorLocation@ &out apActorLocation,
	const int16 &in mapId)
{
	array<APActorLocation@>@ locations;
	if (!TryGetAPActorLocationArray(mapId, locations))
	{
		return false;
	}

    for (uint i = 0; i < locations.length(); i++)
    {
        APActorLocation @entry = locations[i];
        if (entry.tagId == tagId)
        {
			@apActorLocation = entry;
            return true;
        }
    }
    return false;
}

//------------------------------
// Tries to get the ap actor location array for the given map id.
// If not found, locations is null and returns false.
// If found, locations is the found location and returns true.
bool TryGetAPActorLocationArray(
	const int16 &in mapId, 
	array<APActorLocation@>@ &out locations)
{
	if (mapId < 0 || mapId >= int16(g_apActorLocations.length()))
	{
		@locations = null;
		return false;
	}
	
	@locations = g_apActorLocations[mapId];
	return locations !is null;
}

//------------------------------
// Gets the ap actor location entry on the given map with the given AP id.
// Returns null if not found.
APActorLocation@ GetAPActorLocationWithApId(
	const int &in apId, const int &in mapId)
{
	array<APActorLocation@>@ locations;
	if (!TryGetAPActorLocationArray(mapId, locations))
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
// Marks the ap actor location as sent to AP.
// Used when loading a save with objects already sent to AP.
// - apId: The AP id to mark as sent to AP
// - mapId: The map the object is on
void MarkAPActorLocationSentToAP(const int &in apId, const int &in mapId)
{
	APActorLocation@ location = GetAPActorLocationWithApId(apId, mapId);
	if (location !is null)
	{
		location.isSentToAP = true;
	}
}