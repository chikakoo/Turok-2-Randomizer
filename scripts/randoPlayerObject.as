enum RandoUndefinedPlayerFlags
{
	PF_FLOATCAM = 1 << 11,
	PF_NOWEAPON = 1 << 21
};

class RandoPlayerObject : ScriptObject
{
    kActor@ self;
	RandoUI@ ui;
	
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
	// If the player isn't scoped...
	// ZOOM IN: Show game status UI
	// ZOOM OUT: Display level progress message
	void TryDisplayProgressMenu()
	{
		if (g_messageCooldown > 0) 
		{
			g_messageCooldown--;
		}
		else if ((LocalPlayer.Buttons() & BC_SCOPEZOOMOUT) != 0 && !IsScoped())
		{
			ui.DisplayLevelProgress();
			g_messageCooldown = g_progressMenuDisplayTime + 30;
		}
		
		if (g_uiCooldown > 0)
		{
			g_uiCooldown--;
		}
		else if ((LocalPlayer.Buttons() & BC_SCOPEZOOMIN) != 0 && !IsScoped())
		{
			if (!ui.Activate())
			{
				g_uiCooldown = 30;
			}
		}
	}
	
	//---------------------------
	// Resets the state of the globals on a save load.
	// Also handles actor replacements.
	void OnSpawn(void)
	{
		if (ui !is null)
		{
			ui.Deactivate();
		}
		
		int16 mapId = Game.ActiveMapID();
	
		// If the map is the intro map, it's a new game, so reset everything
		if (mapId == kLevel_Level1Intro_1)
		{
			// IsCollected and IsSentToAP should be false for every location
			ResetCollectedStatuses();
			
			// Reset the messages in flight and unset the queue
			g_outgoingMessageInFlight = false;
			g_outgoingMessageQueue.resize(0);
			g_AP.IsGoalReached = 0;
			
			// Set outgoing index to 0 to receive all items from AP
			ResetAPForLoadData(0);
			
			// Give max explosive shells to allow the Flare Gun to be 
			// used and to prevent depots from spawning it prematurely
			LocalPlayer.GiveWeapon(kWpn_Flare, 1000);
			
			// Give the starting inventory
			array<int> startingInventoryItems = { OPTION_STARTING_INVENTORY_ITEMS };
			for (uint i = 0; i < startingInventoryItems.length(); i++)
			{
				TryGetInventoryItem(startingInventoryItems[i], true);
			}
			
			array<int> startingWeapons = { OPTION_STARTING_WEAPONS };
			for (uint i = 0; i < startingWeapons.length(); i++)
			{
				TryGivePlayerWeapon(startingWeapons[i], 1000, true);
			}
			
			CinemaPlayer.StopCinema();
			DoPlayerWarp(0, 10099, kLevel_Hub, false);
		}
		
		//-------------------------
		// Goals!
		
		// Check whether levels give primagen keys
		// Only give them once
		if (mapId == kLevel_Hub &&
			OPTION_GOAL_LEVELS_GIVE_PRIMAGEN_KEYS &&
			AreLevelRequirementsUsedAndMet() &&
			GetInventoryItemCollectedTotal(kActor_PrimagenKey_1) == 0)
		{
			AllPrimagenKeys();
		}
		
		// If the Primagen goal is active, check that for the goal
		// Any level requirement will be covered already becuase the
		// player can't place the key if it isn't met
		if (ArePrimagenRequirementsUsed())
		{
			if (ArePrimagenRequirementsUsedAndMet(mapId))
			{
				g_AP.IsGoalReached = 1;
			}
		}
		
		// Else, check whether the level goal is met
		// We must check the level here because we don't want to goal before bosses are defeated
		else if (mapId == kLevel_Hub &&
			AreLevelRequirementsUsed() && 
			AreLevelRequirementsUsedAndMet())
		{
			g_AP.IsGoalReached = 1;
		}
		
		// Handle the actor replacements
		DoActorReplacementsOnPlayerSpawn();
		
		// Show a warning for the riding Gun
		if (mapId == kLevel_RiverOfSouls_1)
		{
			kStr autoSwitchValue;
			if (Sys.GetCvarValue("g_autoswitchnewweapon", autoSwitchValue))
			{
				if (autoSwitchValue == "1")
				{
					Hud.AddMessage("!!! If softlocked, press Tilde, then type warp 125 !!!", 600);
					Hud.AddMessage("!!! Disable Auto-Switch new weapon before getting on the mount !!!", 600);
				}
			}
		}
		
		// Show level progress on spawn as a convenience
		DisplayCollectedLocationsForCurrentMap();
	}
	
	//---------------------------
	// Serializes the collectedLocations, sentToAPLocations, and g_outgoingMessageQueue by converting it to a trailing-pipe string
	// e.g. "51001|51002" for two locations
	void OnSerialize(kDict &out dict)
    {
		// We never want to save the UI, so close it out on a save
		if (ui !is null)
		{
			ui.Deactivate();
		}
		
		// Collected locations/sent to AP locations (pickups)
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
		
		// Action objects sent to AP
		kStr sentToAPActionObjects;
		for (uint i = 0; i < g_actionObjectEntries.length(); i++)
		{
			array<ActionObjectEntry@>@ locations = g_actionObjectEntries[i];
			for (uint j = 0; j < locations.length(); j++)
			{
				if (locations[j].isSentToAP)
				{
					sentToAPActionObjects += "" + locations[j].apId + "|";
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
		
		if (sentToAPActionObjects.Length() > 0)
		{
			SERIALIZE(sentToAPActionObjects);
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
		//Sys.Print("Saved last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
	}

	//---------------------------
	// Deserializes the saved data on the player object:
	// - Writes the collected locations (see below)
	// - Writes the highest processed item index into the outgoing one so the client can read it
	// - Clears out any incoming/outgoing data because it's invalid at this point
	void OnDeserialize(kDict &in dict)
    {
		if (ui !is null)
		{
			ui.Deactivate();
		}
		
		ResetCollectedStatuses();
		g_AP.IsGoalReached = 0;
		
		DeserializeLocationFlags(dict, "collectedLocations");
		DeserializeLocationFlags(dict, "sentToAPLocations");
		DeserializeActionObjectFlags(dict);
		
		// Reset the messages in flight and unset the queue
		g_outgoingMessageInFlight = false;
		g_outgoingMessageQueue.resize(0);
		DeserializeOutgoingMessageQueue(dict);
		
		// We are now ready to receive data, so reset everything
		DESERIALIZE_INT(g_AP.OutgoingLastProcessedItemIdx);
		ResetAPForLoadData(g_AP.OutgoingLastProcessedItemIdx);
		
		//Sys.Print("Loaded last processed index: " + g_AP.OutgoingLastProcessedItemIdx);
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
	// Deserializes the saved location data on the player object:
	// - Reads the collected locations by converting the trailing pipe string
	//   and setting the flags on the replacement objects.
	void DeserializeActionObjectFlags(kDict &in dict)
	{
		kStr data;
		if (!dict.GetString("sentToAPActionObjects", data))
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
				MarkActionObjectSentToAP(apId, mapId);
				
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
		
		if (ui is null)
        {
            @ui = RandoUI();
        }
		ui.OnTick();
		
		TryDisplayProgressMenu();
	}
}

//---------------------------
// Checks if the player is using their scope
bool IsScoped(void)
{
	return LocalPlayer.WeaponActor() !is null && LocalPlayer.WeaponActor().ScopeReady();
}