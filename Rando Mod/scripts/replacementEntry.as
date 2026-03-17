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
		const kStr &in initDisplayString)
    {
        name = initName;
        apId = initApId;
		position = initPosition;
		mapId = position.Atoi();
		replacementActorId = kActor_Item_APItem;
        displayString = initDisplayString;
		isSentToAP = false;
		isCollected = false;
    }
}

