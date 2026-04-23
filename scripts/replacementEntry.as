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
		const kStr &in initDisplayString,
		const bool &in isProgression = false)
    {
        name = initName;
        apId = initApId;
		position = initPosition;
		mapId = position.Atoi();
		replacementActorId = isProgression
			? kActor_Item_APItemProgression
			: kActor_Item_APItemNonProgression;
        displayString = initDisplayString;
		isSentToAP = false;
		isCollected = false;
    }
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