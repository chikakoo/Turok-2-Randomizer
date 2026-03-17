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

//------------------------------
// Initialize to handle up to an index of 135 (136 includes index 0).
// 135 is the largest map id we need this for.
void InitMapReplacements(void)
{
    g_mapReplacements.resize(136); // 0–135 inclusive

    for (uint i = 0; i < g_mapReplacements.length(); i++)
    {
        g_mapReplacements[i] = array<ReplacementEntry@>();
    }
}

//------------------------------
// Initialize the replacement array using the "patch file" AP generates.
// This is just a bunch of calls to the below AddReplacement functions.
void InitActorReplacements()
{
	#include "rando/randoReplacements.txt"
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
	array<ReplacementEntry@>@ locations = g_mapReplacements[mapId];
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
// Gets the replacement on the current map with the given AP id.
// Returns null if not found.
ReplacementEntry@ GetCurrentMapReplacementWithApId(const int &in apId)
{
	array<ReplacementEntry@>@ locations = g_mapReplacements[Game.ActiveMapID()];
    for (uint i = 0; i < locations.length(); i++)
    {
        if (locations[i].apId == apId)
		{
			return locations[i];
		}
    }
	
	return null;
}

//------------------------------
// Marks the given location as collected by setting it in the map.
// We handle sending to AP in SendCheckToAP - see that documentation.
// apId: The AP id to mark as collected
void CollectLocation(const int &in apId)
{
	ReplacementEntry@ location = GetCurrentMapReplacementWithApId(apId);
	if (location !is null)
	{
		location.isCollected = true;
	}
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
// Puts the location in the outgoing message queue for AP.
// This is different from collecting it, as you could touch health/ammo that
// you cannot pick up. We still want to send that to AP.
// apId: The AP id to send to AP
void SendCheckToAP(const int &in apId)
{
	ReplacementEntry@ location = GetCurrentMapReplacementWithApId(apId);
	if (location !is null)
	{
		location.isSentToAP = true;
		g_outgoingMessageQueue.insertLast(
			APOutgoingMessage(AP_OUT_MSGTYPE_SEND_CHECK, apId));
	}
}

//------------------------------
// Marks the location as sent to AP.
// Used when loading a save with locations already sent to AP.
// apId: The AP id to mark as sent to AP
void MarkSentToAP(const int &in apId)
{
	ReplacementEntry@ location = GetCurrentMapReplacementWithApId(apId);
	if (location !is null)
	{
		location.isSentToAP = true;
	}
}