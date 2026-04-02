// --------------------------
// UI functions (well, held button functions)
//---------------------------
uint16 g_menuButtonHeldTime = 5;
int g_messageCooldown = 0;
int g_progressMenuDisplayTime = 330;

//---------------------------
// Displays a progress menu for the player depending on what buttons are held for the
// set number of frames.
//
// Warp to Hub: Zoom in, out, up, down, left, right
// Current level progress: Zoom in and out
// Current game progress: Zoom in, out, and jump
void TryDisplayProgressMenu()
{
	if (g_messageCooldown > 0) 
	{
		g_messageCooldown--;
		return;
	}

	if (LocalPlayer.ButtonHeldTime(8) > g_menuButtonHeldTime && 
		LocalPlayer.ButtonHeldTime(9) > g_menuButtonHeldTime)
	{
		if (LocalPlayer.ButtonHeldTime(1) > g_menuButtonHeldTime)
		{
			DisplayGameProgress();
		}
		
		else
		{
			DisplayLevelProgress();
		}
		
		g_messageCooldown = g_progressMenuDisplayTime + 30;
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
				g_progressMenuDisplayTime);
			break;
		case LEVEL_RIVER_OF_SOULS:
			Hud.AddMessage(
				"Gate Keys: " + inventory.GetCount(kActor_MissionItem_GateKey) +
				"  -  Graveyard Keys: " + inventory.GetCount(kActor_MissionItem_GraveyardKey),
				g_progressMenuDisplayTime);
			break;
		case LEVEL_DEATH_MARSHES:
			Hud.AddMessage(
				"Satchel Charges: " + inventory.GetCount(kActor_MissionItem_L3SatchelCharge),
				g_progressMenuDisplayTime);
			break;
		case LEVEL_LAIR_OF_THE_BLIND_ONES:
			Hud.AddMessage(
				"Satchel Charges: " + inventory.GetCount(kActor_MissionItem_L4SatchelCharge) +
				"  -  Cave Door Keys: " + inventory.GetCount(kActor_MissionItem_CaveDoorKey),
				g_progressMenuDisplayTime);
			break;
		case LEVEL_HIVE_OF_THE_MANTIDS:
			Hud.AddMessage(
				"Satchel Charges: " + inventory.GetCount(kActor_MissionItem_L5SatchelCharge),
				g_progressMenuDisplayTime);
			break;
		case LEVEL_PRIMAGENS_LIGHTSHIP:
			Hud.AddMessage(
				"Ion Capacitors: TODO");
			break;
		default:
			Hud.AddMessage("Unmapped map id!");
			return;
	}
	
	DisplayCollectedLocationsForLevel(mapId, "Level Checks", g_progressMenuDisplayTime);
	DisplayCollectedLocationsForCurrentMap(g_progressMenuDisplayTime);
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
		g_progressMenuDisplayTime);
		
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
		g_progressMenuDisplayTime);
		
	Hud.AddMessage(
		(inventory.GetCount(kActor_Talisman_LeapOfFaith) > 0 ? "[Leap] " : "") +
		(inventory.GetCount(kActor_Talisman_BreathOfLife) > 0 ? "[Breath] " : "") +
		(inventory.GetCount(kActor_Talisman_HeartOfFire) > 0 ? "[Fire] " : "") +
		(inventory.GetCount(kActor_Talisman_Whispers) > 0 ? "[Whispers] " : "") +
		(inventory.GetCount(kActor_Talisman_EyeOfTruth) > 0 ? "[Eye] " : ""),
		g_progressMenuDisplayTime);
		
	DisplayCollectedLocationsForGame(g_progressMenuDisplayTime);
}