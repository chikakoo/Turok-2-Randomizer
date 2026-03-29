class RandoPlayerObject : ScriptObject
{
    kActor@ self;
	int m_messageCooldown = 0;
	uint16 m_menuButtonHeldTime = 5;
	int m_progressMenuDisplayTime = 330;
	
	// An array of ascii characters so we can get the index easily
	array<kStr> m_asciiChars = {
		"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
		"", "", ' ', '!', '"', "", "", '%', '&', '\'', '(', ')', '*', '+', ',', '-', ".", "/", '0', '1', '2', '3', '4', '5', '6',
		'7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
		'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f',
		'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', ""
	};
	
	//---------------------------
	// Constructor
	// @actor: The actor that was loaded
    RandoPlayerObject(kActor @actor)
    {
		@self = actor;
    }
	
	//---------------------------
	// Resets the state of the globals on a save load.
	// Also handles actor replacements.
	void OnSpawn(void)
	{
		int16 mapId = Game.ActiveMapID();
	
		// If the map is the intro map, it's a new game, so reset everything
		if (mapId == kLevel_Level1Intro_1)
		{
			// IsCollected and IsSentToAP should be false for every location
			ResetCollectedStatuses();
			
			// Reset the messages in flight and unset the queue
			g_outgoingMessageInFlight = false;
			g_outgoingMessageQueue.resize(0);
			
			// Set outgoing index to 0 to receive all items from AP
			ResetAPForLoadData(0);
			
			// Give max explosive shells to allow the Flare Gun to be 
			// used and to prevent depots from spawning it prematurely
			LocalPlayer.GiveWeapon(kWpn_Flare, 1000);
			
		}
		
		// Check the goal - there's two checks here in case it's the
		// Primagen, which has two different maps for the two endings
		if (OPTION_GOAL_PRIMAGEN && 
			(mapId == kLevel_Ending || mapId == kLevel_EndingB))
		{
			g_AP.IsGoalReached = 1;
		}
		
		// If the goal is x levels, check that that was done
		if (OPTION_GOAL_LEVELS > 0 &&
			OPTION_GOAL_LEVELS <= LocalPlayer.Inventory().GetCount(kActor_Misc_TotemInventory))
		{
			g_AP.IsGoalReached = 1;
		}
		
		//RemoveAllGenerators(); //TODO: disable this, enable the next
		if (OPTION_INCLUDE_WEAPONS_AND_AMMO)
		{
			UseRandomAmmoGenerators();
		}
		
		// Replace all the actors that should be replaced
		ReplaceAllActors();
	}
	
	//----------------------------------
	// Replaces all actors with the intended replacemnt.
	// STOP iterating on the player, as that would be the LAST actor spawned.
	// We prevent infinite spawn loops this way.
	void ReplaceAllActors()
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
			int16 mapId = Game.ActiveMapID();
			posStr = "" + mapId + "_" +
				int(position.x) + "_" +
				int(position.y) + "_" +
				int(position.z);
			if (TryGetReplacement(mapId, posStr, replacement))
			{
				if (replacement.isCollected)
				{
					Sys.Print("COLLECTED ON SPAWN: " + replacement.name + " (" + posStr + ")" + " (" + replacement.apId + ")");
					actorsToRemove.insertLast(actor);
					continue;
				}
				
				ReplaceActor(actor, replacement);
				
			}
			else
			{	
				HandleWhetherActorShouldHaveBeenReplaced(actor, posStr);
			}				
		}
		
		for (uint i = 0; i < actorsToRemove.length(); i++)
		{
			actorsToRemove[i].Remove();
		}
	}
	
	//----------------------------------
	// Called when an actor was NOT replaced.
	// Checks if it should have been. If so, prints to the console and
	// marks it as important so it's easier to find.
	//
	// We may want to NOT execute this in release versions, since
	// it does nothing for the player.
	void HandleWhetherActorShouldHaveBeenReplaced(kActor@ actor, kStr posStr)
	{
		kDictMem@ actorDef = actor.Definition();
		if (actorDef is null)
		{
			return;
		}
		
		kStr actorClassName;
		if (actorDef.GetString("className", actorClassName))
		{
			// These are all the current randomized actor types
			if (actorClassName == "kexAmmoPickup" ||
				actorClassName == "kexHealthPickup" ||
				actorClassName == "kexInventoryPickup" ||
				actorClassName == "kexLifeForcePickup" ||
				actorClassName == "kexWeaponPickup")
			{
				Sys.Print("NOT MAPPED: " + posStr + " (" + GetFriendlyActorName(actor.Type()) + ")"); 
				actor.Flags() |= AF_IMPORTANT;  // TODO: remove this after mapping stuff
			}
		}
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
		
		// Fixes console warnings
		if (initialActor.ModeStateComponent() !is null)
		{
			Sys.Print("MODE STATE ACTUALLY WAS SET??");
			replacedActor.ModeStateComponent().SetMode(
				initialActor.ModeStateComponent().Mode());
		}
		
		// Turn on collision for health/ammo detection and to
		// have a common place to show the pickup status message
		newWorldComponent.Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;

		// Flag the actor as important so it can be found easier
		// If it was already sent to AP, do not do this since it was "collected" already
		if (!replacement.isSentToAP)
		{
			//replacedActor.Flags() |= AF_IMPORTANT; // TODO: enable this when done adding items
		}
		
	    initialActor.Remove();
	}
	
	//---------------------------
	// Serializes the collectedLocations, sentToAPLocations, and g_outgoingMessageQueue by converting it to a trailing-pipe string
	// e.g. "51001|51002" for two locations
	void OnSerialize(kDict &out dict)
    {
		// Collected locations/sent to AP locations
		kStr collectedLocations;
		kStr sentToAPLocations;
		for (uint i = 0; i < g_mapReplacements.length(); i++)
		{
			array<ReplacementEntry@>@ locations = g_mapReplacements[i];
			for (uint j = 0; j < locations.length(); j++)
			{
				if (locations[j].isCollected)
				{
					collectedLocations += "" + locations[j].apId + "|";
				}
				
				if (locations[j].isSentToAP)
				{
					sentToAPLocations += "" + locations[j].apId + "|";
				}
			}
		}
		
		if (collectedLocations.Length() > 0)
		{
			SERIALIZE(collectedLocations);
		}
		
		if (sentToAPLocations.Length() > 0)
		{
			SERIALIZE(sentToAPLocations);
		}
		
		// Outgoing message queue
		kStr outgoingMessageQueue;
		for (uint i = 0; i < g_outgoingMessageQueue.length(); i++)
		{
			outgoingMessageQueue += "" + g_outgoingMessageQueue[i] + "|";
		}
		
		if (outgoingMessageQueue.Length() > 0)
		{
			SERIALIZE(outgoingMessageQueue);
		}
	
		SERIALIZE(g_AP.OutgoingLastProcessedItemIdx);
		Sys.Print("Saved last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
	}

	//---------------------------
	// Deserializes the saved data on the player object:
	// - Writes the collected locations (see below)
	// - Writes the highest processed item index into the outgoing one so the client can read it
	// - Clears out any incoming/outgoing data because it's invalid at this point
	void OnDeserialize(kDict &in dict)
    {
		ResetCollectedStatuses();
		
		DeserializeLocationFlags(dict, "collectedLocations");
		DeserializeLocationFlags(dict, "sentToAPLocations");
		
		// Reset the messages in flight and unset the queue
		g_outgoingMessageInFlight = false;
		g_outgoingMessageQueue.resize(0);
		DeserializeOutgoingMessageQueue(dict);
		
		// We are now ready to receive data, so reset everything
		DESERIALIZE_INT(g_AP.OutgoingLastProcessedItemIdx);
		ResetAPForLoadData(g_AP.OutgoingLastProcessedItemIdx);
		
		Sys.Print("Loaded last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
	}
	
	//---------------------------
	// Deserializes the saved location data on the player object:
	// - Reads the collected locations by converting the trailing pipe string
	//   and setting the flags on the replacement objects.
	void DeserializeLocationFlags(
		kDict &in dict,
		const kStr &in key)
	{
		kStr data;
		if (!dict.GetString(key, data))
		{
			return;
		}
	
		kStr current = "";
		for (uint i = 0; i < data.Length(); i++)
		{
			int8 c = data[i];
			if (c == "|"[0])
			{		
				int apId = current.Atoi();
				int mapId = ConvertMapIdFromApId(apId);
				if (key == "collectedLocations")
				{
					CollectLocation(apId, mapId);
				}
				else
				{
					MarkSentToAP(apId, mapId);
				}
				
				current = "";
			}
			else
			{
				current += m_asciiChars[c];
			}
		}
	}
	
	//---------------------------
	// Deserializes the saved outgoing message queue data on the player object:
	// - Reads the items to sync by converting the trailing pipe string
	//   and then places them into the array.
	void DeserializeOutgoingMessageQueue(kDict &in dict)
	{
		kStr data;
		if (!dict.GetString("outgoingMessageQueue", data))
		{
			return;
		}
	
		kStr current = "";
		for (uint i = 0; i < data.Length(); i++)
		{
			int8 c = data[i];
			if (c == "|"[0])
			{		
				g_outgoingMessageQueue.insertLast(current.Atoi());
				current = "";
			}
			else
			{
				current += m_asciiChars[c];
			}
		}
	}
	
	//---------------------------
	// Checks for incoming and outgoing messages
	void OnTick(void)
	{
		if (!CinemaPlayer.Playing())
		{
			ProcessIncomingMessages();
			ProcessOutgoingMessages();
		}
		
		if (m_messageCooldown > 0) 
		{
			m_messageCooldown--;
			return;
		}
		
		TryDisplayProgressMenu();
	}
	
	//---------------------------
	// Displays a progress menu for the player depending on what buttons are held for the
	// set number of frames.
	//
	// Current level progress: Zoom in and out
	// Current game progress: Zoom in, out, and jump
	void TryDisplayProgressMenu()
	{
		if (LocalPlayer.ButtonHeldTime(8) > m_menuButtonHeldTime && 
			LocalPlayer.ButtonHeldTime(9) > m_menuButtonHeldTime)
		{
			if (LocalPlayer.ButtonHeldTime(1) > m_menuButtonHeldTime)
			{
				DisplayGameProgress();
			}
			else
			{
				DisplayLevelProgress();
			}
			
			m_messageCooldown = m_progressMenuDisplayTime + 30;
		}
	}
	
	//---------------------------
	// Displays level-specific progress, including:
	// - Location collection progress for the current map
	// - Location collection progress for the entire Level
	// - Special items that don't show up correctly in the pause menu
	void DisplayLevelProgress()
	{
		kPlayerInventory@ inventory = LocalPlayer.Inventory();
		int16 mapId = Game.ActiveMapID();
		switch(GetLevelNumberFromMapId(mapId))
		{
			case LEVEL_PORT_OF_ADIA:
				Hud.AddMessage(
					"Power Cells: " + inventory.GetCount(kActor_MissionItem_BeaconPowerCell),
					m_progressMenuDisplayTime);
				break;
			case LEVEL_RIVER_OF_SOULS:
				Hud.AddMessage(
					"Gate Keys: " + inventory.GetCount(kActor_MissionItem_GateKey) +
					"  -  Graveyard Keys: " + inventory.GetCount(kActor_MissionItem_GraveyardKey),
					m_progressMenuDisplayTime);
				break;
			case LEVEL_DEATH_MARSHES:
				Hud.AddMessage(
					"Satchel Charges: " + inventory.GetCount(kActor_MissionItem_L3SatchelCharge),
					m_progressMenuDisplayTime);
				break;
			default:
				Hud.AddMessage("Unmapped map id!");
				return;
		}
		
		DisplayCollectedLocationsForLevel(mapId, "Level Checks", m_progressMenuDisplayTime);
		DisplayCollectedLocationsForCurrentMap(m_progressMenuDisplayTime);
	}
	
	//---------------------------
	// Displays progress for the entire game, including:
	// - Location collection progress
	// - Special items that don't show up correctly in the pause menu
	void DisplayGameProgress()
	{
		kPlayerInventory@ inventory = LocalPlayer.Inventory();
		Hud.AddMessage(
			"Nuke Parts: " + inventory.GetCount(kActor_InventoryItem_NukePart) + "/6",
			m_progressMenuDisplayTime);
			
		Hud.AddMessage(
			"Keys 2-6: " +
			int(Math::Min(inventory.GetCount(kActor_InventoryItem_Level2Key), 3)) +
			int(Math::Min(inventory.GetCount(kActor_InventoryItem_Level3Key), 3)) +
			int(Math::Min(inventory.GetCount(kActor_InventoryItem_Level4Key), 3)) +
			int(Math::Min(inventory.GetCount(kActor_InventoryItem_Level5Key), 3)) +
			int(Math::Min(inventory.GetCount(kActor_InventoryItem_Level6Key), 6)) +
			
			" - Feathers 2-6: " +
			(inventory.GetCount(kActor_Feather_2) > 0 ? "2" : "X") +
			(inventory.GetCount(kActor_Feather_3) > 0 ? "3" : "X") +
			(inventory.GetCount(kActor_Feather_4) > 0 ? "4" : "X") +
			(inventory.GetCount(kActor_Feather_5) > 0 ? "5" : "X") +
			(inventory.GetCount(kActor_Feather_6) > 0 ? "6" : "X") +
			
			" - Prim Keys 1-6: " +
			(inventory.GetCount(kActor_PrimagenKey_1) > 0 ? "1" : "X") + 
			(inventory.GetCount(kActor_PrimagenKey_2) > 0 ? "2" : "X") + 
			(inventory.GetCount(kActor_PrimagenKey_3) > 0 ? "3" : "X") + 
			(inventory.GetCount(kActor_PrimagenKey_4) > 0 ? "4" : "X") + 
			(inventory.GetCount(kActor_PrimagenKey_5) > 0 ? "5" : "X") + 
			(inventory.GetCount(kActor_PrimagenKey_6) > 0 ? "6" : "X"),
			m_progressMenuDisplayTime);
			
		Hud.AddMessage(
			(inventory.GetCount(kActor_Talisman_LeapOfFaith) > 0 ? "[Leap] " : "") +
			(inventory.GetCount(kActor_Talisman_BreathOfLife) > 0 ? "[Breath] " : "") +
			(inventory.GetCount(kActor_Talisman_HeartOfFire) > 0 ? "[Fire] " : "") +
			(inventory.GetCount(kActor_Talisman_Whispers) > 0 ? "[Whispers] " : "") +
			(inventory.GetCount(kActor_Talisman_EyeOfTruth) > 0 ? "[Eye] " : ""),
			m_progressMenuDisplayTime);
			
		DisplayCollectedLocationsForGame(m_progressMenuDisplayTime);
	}

	//----------------------------------
	// Process incoming messages if we aren't processing a message already.
	void ProcessIncomingMessages(void)
	{
		if (g_AP.IncomingStatus != AP_PROCESSING)
		{
			return;
		}
		
		int data = g_AP.IncomingMessageData;
		switch(g_AP.IncomingMessageType)
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
		
		// Set this back to ready so AP knows it can send more
		g_AP.IncomingMessageType = AP_MSGTYPE_NONE;
		g_AP.IncomingMessageData = 0;
		
		// Set the index so we know what was processed last
		g_AP.OutgoingLastProcessedItemIdx = g_AP.IncomingLastProcessedItemIdx;
		g_AP.IncomingStatus = AP_READY;
		
		Sys.Print("Updated last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
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
		Sys.Print("Sent check to AP: " + apId);
		
		// Now the python script knows it can read the data we set
		g_AP.OutgoingStatus = AP_PROCESSING;
		
		// Mark as in-flight, but don't remove yet
		g_outgoingMessageInFlight = true;
	}
}