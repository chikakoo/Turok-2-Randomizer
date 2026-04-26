//------------------------------
// Functions for processing the checks we send/receive from Archipelago.
//------------------------------

//----------------------------------
// Process incoming messages if we aren't processing a message already.
void ProcessIncomingMessages(void)
{
	if (g_AP.IncomingStatus != AP_PROCESSING)
	{
		return;
	}
	
	ProcessMessage(g_AP.IncomingMessageData, g_AP.IncomingMessageType);
	
	// Set this back to ready so AP knows it can send more
	g_AP.IncomingMessageType = AP_MSGTYPE_NONE;
	g_AP.IncomingMessageData = 0;
	
	// Set the index so we know what was processed last
	g_AP.OutgoingLastProcessedItemIdx = g_AP.IncomingLastProcessedItemIdx;
	g_AP.IncomingStatus = AP_READY;
	
	//Sys.Print("Updated last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
}

//----------------------------------
// Handles giving the player the item from the given data and type.
void ProcessMessage(
	const int &in data, 
	const int &in type = AP_IN_MSGTYPE_LOCAL)
{
	int typeToUse = type;
	if (type == AP_IN_MSGTYPE_LOCAL)
	{
		typeToUse = GetAPInTypeFromData(data);
	}

	switch(typeToUse)
	{
		case AP_MSGTYPE_NONE:
			// Do nothing if there's no message type!
			break;
		case AP_IN_MSGTYPE_GET_PICKUP:
			HandleGetPickup(data);
			break;
		case AP_IN_MSGTYPE_GET_WEAPON:
			TryGivePlayerWeapon(data);
			break;
		case AP_IN_MSGTYPE_GET_AMMO:
			GetAmmoInRandomWeapon();
			break;
		case AP_IN_MSGTYPE_GET_INVENTORY_ITEM:
			TryGetInventoryItem(data);
			break;
		case AP_IN_MSGTYPE_GET_TRAP:
			TryTriggerTrap(data);
			break;
		default:
			Sys.Print("Did not handle incoming message: " + g_AP.IncomingMessageType + ". Data: " + data);
	}
}

//----------------------------------
// Gets the AP message type from the type of actor.
// Used for local rewards from ActionObjects.
int GetAPInTypeFromData(const int &in data)
{
	if (data == kActor_Item_RandomAmmo)
	{
		return AP_IN_MSGTYPE_GET_AMMO;
	}
	
	kDictMem@ actorDef = g_indexDefManager.GetEntry(data);
	if (actorDef is null)
	{
		return AP_IN_MSGTYPE_LOCAL;
	}
	
	int trapType;
	if (actorDef.GetInt("rando.trapType", trapType))
	{
		return AP_IN_MSGTYPE_GET_TRAP;
	}
	
	kStr className;
	actorDef.GetString("className", className);
	
	if (className == "kexInventoryPickup")
	{
		return AP_IN_MSGTYPE_GET_INVENTORY_ITEM;
	}
	
	if (className == "kexWeaponPickup")
	{
		return AP_IN_MSGTYPE_GET_WEAPON;
	}
	
	if (className == "kexLifeForcePickup" ||
		className == "kexHealthPickup")
	{
		return AP_IN_MSGTYPE_GET_PICKUP;
	}
	
	// Couldn't match anything...
	return AP_IN_MSGTYPE_LOCAL;
}

//----------------------------------
// This includes health and life forces.
// Health will be given directly.
// Life forces have no way of being given, so they will be spawned in.
void HandleGetPickup(int &in data)
{
	kDictMem@ entry = g_indexDefManager.GetEntry(data);
	
	// ALL actors will have an entry here
	if (entry is null)
	{
		Sys.Print("Tried to use non-existant actor: " + data);
		return;
	}
	
	kStr className;
	entry.GetString("className", className);
	
	if (TryGivePlayerHealth(data))
	{
		return;
	}
	
	if (className == "kexLifeForcePickup")
	{
		SpawnActorOnPlayer(data);
	}
}

//----------------------------------
// Process messages to send to AP.
//
// We keep track of whether we're currently waiting for the server to process a message.
// Once it's processed, we remove it from the queue and unset that flag.
//
// Once the server is ready (and we aren't waiting for it anymore), we grab the
// next message from the queue and set it to the message data and type and set the
// flags so the client knows there's a new message.
//
// This is done this way so we can seriaize the outgoing message queue and reload it if
// not everything was synced before saving.
void ProcessOutgoingMessages(void)
{
	// If something is sent but not confirmed, wait
	if (g_outgoingMessageInFlight)
	{
		// If the client finished processing it, remove the message
		if (g_AP.OutgoingStatus == AP_READY)
		{
			g_outgoingMessageQueue.removeAt(0);
			g_outgoingMessageInFlight = false;
		}
	}
	
	// Do not process if AP is still processing the last message
	if (g_outgoingMessageInFlight ||
		g_AP.OutgoingStatus != AP_READY || 
		g_outgoingMessageQueue.length() == 0)
	{
		return;
	}
	
	int apId = g_outgoingMessageQueue[0];
	g_AP.OutgoingMessageData = apId;
	//Sys.Print("Sent check to AP: " + apId);
	
	// Now the python script knows it can read the data we set
	g_AP.OutgoingStatus = AP_PROCESSING;
	
	// Mark as in-flight, but don't remove yet
	g_outgoingMessageInFlight = true;
}