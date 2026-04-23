//------------------------------
// Represents an action object that acts as a check
// - name: The friendly name of the actor
// - apId: The location's AP id = MapID### (e.g. 51001 is item 2 on map 51)
// - tagId: The tag id of the actor - will uniquely identify it on the map
// - mapId: Computed from the AP id
// - givenActorId: If not 0 - the item actor to reward the player with after getting this check
// - displayString: The display string to display when collected (only filled for AP items)
// - isSentToAP: Whether the player has sent the check to AP (used for resyncing)
//------------------------------
class ActionObjectEntry
{
	kStr name;
	int apId;
	int tagId;
	int mapId;
	int givenActorId;
	kStr displayString;
	bool isSentToAP;
	
	ActionObjectEntry() {}
	
	ActionObjectEntry(
		const kStr &in name,
		const int &in apId,
		const int &in tagId,
		const int &in givenActorId,
		const kStr &in displayString = "")
	{
		this.name = name;
		this.apId = apId;
		this.tagId = tagId;
		this.givenActorId = givenActorId;
		this.displayString = displayString;
		this.mapId = ConvertMapIdFromApId(apId);
		this.isSentToAP = false;
	}
	
	//------------------------------
	// Puts the location in the outgoing message queue for AP.
	// Handles processing the message as well so you get the item from the check.
	void SendCheckToAP()
	{
		Sys.Print("OUTSIDE");
		if (!this.isSentToAP)
		{
			this.isSentToAP = true;
			g_outgoingMessageQueue.insertLast(apId);
			
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
// - position: The position of the actor, to identify it on the map
//  - This is in the format: <map-id>_x_y_z, so Atoi will get the map id
// - replacementActorId: The actor id to replace this with
void AddActionObject(
	const kStr &in name, 
	const int &in apId,
	const int &in tagId,
	const int &in givenActorId,
	const kStr &in displayString = "")
{
	ActionObjectEntry @entry = ActionObjectEntry(
		name, apId, tagId, givenActorId, displayString);
    g_actionObjectEntries[entry.mapId].insertLast(entry);
}

//------------------------------
// Tries to get the replacement for the given actor id.
// Will return false if not found.
// - tagId: The tag id of the entry to get
// - actionObjectEntry: The retrieved entry
// Returns true if the replacement was found; false otherwise.
bool TryGetActionObjectEntryForCurrentMap(
	const int &in tagId,
	ActionObjectEntry@ &out actionObjectEntry)
{
	int mapId = Game.ActiveMapID();
	array<ActionObjectEntry@>@ locations;
	if (!TryGetReplacementArray(mapId, locations))
	{
		return false;
	}

    for (uint i = 0; i < locations.length(); i++)
    {
        ActionObjectEntry @entry = locations[i];
        if (entry.tagId == tagId)
        {
			@actionObjectEntry = entry;
            return true;
        }
    }
    return false;
}

//------------------------------
// Tries to get the replacement array for the given map id.
// If not found, locations is null and returns false.
// If found, locations is the found location and returns true.
bool TryGetReplacementArray(
	const int16 &in mapId, 
	array<ActionObjectEntry@>@ &out locations)
{
	if (mapId < 0 || mapId >= int16(g_actionObjectEntries.length()))
	{
		@locations = null;
		return false;
	}
	
	@locations = g_actionObjectEntries[mapId];
	return locations !is null;
}