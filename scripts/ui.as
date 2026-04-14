// --------------------------
// UI functions (well, held button functions)
//---------------------------
uint16 g_menuButtonHeldTime = 5;
int g_messageCooldown = 0;
int g_progressMenuDisplayTime = 330;
RandoUI g_ui;

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
			//DisplayLevelProgress();
			g_ui.Activate();
			
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
				"Ion Capacitors: " + inventory.GetCount(kActor_MissionItem_IonCapacitor) + 
				"  -  Blue Laser Cells: " + inventory.GetCount(kActor_MissionItem_BlueLaserCell) + 
				"  -  Red Laser Cells: " + inventory.GetCount(kActor_MissionItem_RedLaserCell),
				g_progressMenuDisplayTime);
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

// --------------------------
// UI class - we will create a "fake" UI using actors.
// This is based off of BP's Turok 2 Co-op Mod and borrows its design from it.
// --------------------------

// UI Constants
const float UI_BASE_FOV = 90.0f;
const float UI_SCALE = 0.7075f;
const float UI_SCREEN_WIDTH = 1.0f;
const float UI_SCREEN_HEIGHT = 0.75f;
const float UI_MOUSE_SPEED = 0.75f;
const float UI_MOUSE_SIZE = 0.05f;
const float UI_MOUSE_LERP_TIME = 0.25f;
	
class RandoUI
{
	// TODO: track the player's HP and if it's ever lower, close out
	
	// General Properties
	kActor@ owner;
	bool isActive;
	int lastOverIndex;
	
	// Player Properties
	kVec3 lastOwnerOrigin;
	int lastOwnerRegion;
	float lastOwnerYaw;
	float lastOwnerPitch;
	
	// UI Properties
	float lastFov;
	float fovRatio;
	float fovRatioInverse;
	float mouseX;
	float mouseY;
	float mouseRealX = 0.0f;
	float mouseRealY = 0.0f;
	float lastMouseX;
	float lastMouseY;
	float closeTime = 0.0f;
	kVec3 forwardDir;
	kVec3 rightDir;
	kVec3 upDir;
	
	RandoUIElement@ mouse;
	array<RandoUIElement@> elements;
	
	// Number of ticks to wait until set float camera flag on owner
	int floatCamWait; 
	
	RandoUI()
	{
		isActive = false;
		lastOverIndex = -1;
		fovRatio = 1.0f;
	}

	// --------------------------
	// Turns on the UI menu
	bool Activate()
	{
		@mouse = CreateMouse();
		mouse.SetPosition(Math::vecZero);

		@owner = LocalPlayer.Actor().CastToActor();
		kPuppet@ puppet = owner.CastToPuppet();
		
		//TODO: check if player is in warp spot
		// If not, return false and print a message
		
		lastFov = 0.0f;
		mouse.SetPosition(Math::vecZero);
		mouseX = 0.0f;
		mouseY = 0.0f;
		mouseRealX = 0.0f;
		mouseRealY = 0.0f;
		lastMouseX = 0.0f;
		lastMouseY = 0.0f;
		closeTime = 0.0f;
		
		isActive = true;
		lastOwnerOrigin = owner.Origin();
		lastOwnerRegion = owner.WorldComponent().RegionIndex();
		lastOwnerYaw = owner.Yaw();
		lastOwnerPitch = owner.Pitch();
		puppet.PlayerFlags() &= ~PF_FLOATCAM;
		puppet.PlayerFlags() |= PF_NOWEAPON;
		floatCamWait = 2;
		
		kQuat ownerRot(lastOwnerPitch, 0.0f, lastOwnerYaw);
		forwardDir = kVec3(0.0f, 1.0f, 0.0f) * ownerRot;
		rightDir = kVec3(1.0f, 0.0f, 0.0f) * ownerRot;
		upDir = kVec3(0.0f, 0.0f, 1.0f) * ownerRot;
		
		SetUpUIScreen();
			
		return true;
	}
	
	// --------------------------
	// Turns off the UI menu
	void Deactivate()
	{
		isActive = false;
		Clear();
		
		if (mouse !is null)
		{
			mouse.Remove();
			@mouse = null;
		}

		if (owner !is null)
		{
			kPuppet@ puppet = owner.CastToPuppet();
			puppet.PlayerFlags() &= ~(PF_FLOATCAM);
			
			// TODO: check if player is dead, and don't do this otherwise
			puppet.PlayerFlags() &= ~(PF_NOWEAPON);
		}
	}
	
	// --------------------------
	// Removes all elements
	void Clear()
	{
		if (elements is null)
		{
			return;
		}
		
		int elementsLength = int(elements.length());
		for (int i = elementsLength - 1; i >= 0; i--)
		{
			RemoveElement(i);
		}
	}
	
	// --------------------------
	// Removes an element from the UI
	void RemoveElement(const int index)
	{
		elements[index].Remove();
		elements.removeAt(index);
	}
	
	// --------------------------
	// Sets up the main UI screen
	void SetUpUIScreen()
	{
		//TODO: add elements
	}
	
	// --------------------------
	// Adds an image to the UI
	RandoUIElement@ AddImage(
		const int windowId, 
		const kStr& in key, 
		const int textureIndex, 
		const float width, 
		const float height, 
		const kVec3& in pos = Math::vecZero)
	{
		RandoUIElement@ element = CreateUIElement(
			windowId,
			key,
			textureIndex, 
			width,
			height,
			pos);
		return element;
	}
	
	// --------------------------
	// Create a UI element
	RandoUIElement@ CreateUIElement(
		const int windowId,
		const kStr& in key,
		const int textureIndex,
		const float width,
		const float height,
		const kVec3 &in pos = Math::vecZero)
	{
		kActor@ actor = ActorFactory.Spawn(
			kActor_UI_Element, 
			Math::vecZero,
			0, 0, 0);
		RandoUIElement@ element = cast<RandoUIElement@>(GetScript(actor));
		
		if (element !is null)
		{
			elements.insertLast(element);
			element.windowId = windowId;
			element.key = key;
			element.textureIndex = textureIndex;
			element.SetTexture(textureIndex);
			element.SetSize(width, height);
			element.SetPosition(pos);
			element.fovRatio = fovRatio;
			element.UpdateScale();
		}
		return element;
	}
	
	// --------------------------
	// Create a mouse, using the mouse texture
	RandoUIElement@ CreateMouse()
	{
		const int cursorIndex = 0; //TODO: how does this work
	
		kActor@ actor = ActorFactory.Spawn(
			kActor_UI_Element, 
			Math::vecZero,
			0, 0, 0);
		RandoUIElement@ element = cast<RandoUIElement@>(GetScript(actor));
		if (element !is null)
		{
			element.textureIndex = cursorIndex;
			element.SetTexture(cursorIndex);
			element.SetSize(UI_MOUSE_SIZE, UI_MOUSE_SIZE);
			element.SetPosition(Math::vecZero);
			element.fovRatio = fovRatio;
			element.UpdateScale();
		}
		return element;
	}
	
	// --------------------------
	// Updates the UI every tick - heavily copied from BP's co-op mod
	void OnTick()
	{
		// Close if neccessary
		if (closeTime > 0.0f)
		{
			closeTime -= GAME_DELTA_TIME;
			if (closeTime <= 0.0f)
			{
				Deactivate();
			}
		}
		
		if ((LocalPlayer.Buttons() & BC_JUMP) != 0)
		{
			Deactivate();
		}
		
		// Do nothing if not active
		if (!isActive)
		{
			return;
		}
		
		// Check Fov change
		kStr fovStr;
		Sys.GetCvarValue("r_fov", fovStr);
		float fov = fovStr.Atof();
		if (lastFov != fov)
		{
			lastFov = fov;
			fovRatio = fov / UI_BASE_FOV;
			fovRatioInverse = UI_BASE_FOV / fov;
				
			mouse.UpdateScale();
			for (uint i = 0; i < elements.length(); i++)
			{
				elements[i].fovRatio = fovRatio;
				elements[i].UpdateScale();
			}
		}
		
		// Move the mouse by computing where it should go, and moving
		// The elements relative to it
		float mouseDX = owner.Yaw().Diff(lastOwnerYaw) * UI_MOUSE_SPEED;
		float mouseDY = -owner.Pitch() * UI_MOUSE_SPEED;
		
		lastMouseX = mouseRealX;
		lastMouseY = mouseRealY;
		mouseRealX += mouseDX;
		mouseRealY += mouseDY;
		
		if (mouseRealX < -UI_SCREEN_WIDTH * fovRatio)
		{
			mouseRealX = -UI_SCREEN_WIDTH * fovRatio;
			mouseDX = -(lastMouseX - mouseRealX);
		}
		else if (mouseRealX > UI_SCREEN_WIDTH * fovRatio)
		{
			mouseRealX = UI_SCREEN_WIDTH * fovRatio;
			mouseDX = -(lastMouseX - mouseRealX);
		}
		
		if (mouseRealY < -UI_SCREEN_HEIGHT * fovRatio)
		{
			mouseRealY = -UI_SCREEN_HEIGHT * fovRatio;
			mouseDY = -(lastMouseY - mouseRealY);
		}
		else if (mouseRealY > UI_SCREEN_HEIGHT * fovRatio)
		{
			mouseRealY = UI_SCREEN_HEIGHT * fovRatio;
			mouseDY = -(lastMouseY - mouseRealY);
		}
		
		// Move the elements relative to the mouse
		kPuppet@ puppet = owner.CastToPuppet();
		owner.Yaw() = lastOwnerYaw;
		owner.Pitch() = 0.0f;
		owner.Roll() = 0.0f;
		owner.Origin() = lastOwnerOrigin;
		owner.WorldComponent().SetRegion(lastOwnerRegion);
		owner.MovementComponent().Velocity() = Math::vecZero;
		puppet.PlayerFlags() |= PF_HASJUMPED | PF_NOWEAPON;
		floatCamWait = MAX(floatCamWait - 1, 0);
		if (floatCamWait == 0)
		{
			puppet.PlayerFlags() |= PF_FLOATCAM;
		}
		
		float playerHeight = 100.0f;
		kVec3 playerPos = puppet.Origin() + kVec3(0, 0, playerHeight);
		//kVec3 forwardDir = GetForwardVector(owner);
		//kVec3 rightDir = GetRightVector(owner);
		//kVec3 upDir = GetUpVector(owner);
		kVec3 elementPos = playerPos + GetForwardVector(owner);

		// Go through elements and position based on player position
		int elementsLength = int(elements.length());
		for (int i = elementsLength - 1; i >= 0; i--)
		{
			elements[i].SetOwnerDirections(forwardDir, rightDir, upDir);
			elements[i].Update(owner, elementPos);
			
			// Remove any non-active elements
			if (!elements[i].isActive)
			{
				RemoveElement(i);
			}
		}
		elementsLength = int(elements.length());

		mouseX = mouseRealX * fovRatioInverse;
		mouseY = mouseRealY * fovRatioInverse;
		mouse.SetOwnerDirections(forwardDir, rightDir, upDir);
		mouse.SetPosition(kVec3(mouseRealX, mouseRealY, -0.01f));
		mouse.Update(owner, elementPos);
		
		int overIndex = -1;
		float closestDist = 9999.0f;
		kVec3 mousePos(mouseX, mouseY, 0.0f);
		for (int i = elementsLength - 1; i >= 0; i--)
		{
			if (elements[i].IsMousedOver(mouseX, mouseY) && elements[i].onSelect !is null)
			{
				float distance = elements[i].positionOffset.Distance(mousePos);
				if (distance < closestDist)
				{
					closestDist = distance;
					overIndex = i;
				}
			}
		}
		
		// Click handler (if this fails, see if lastButtons mattered)
		if ((LocalPlayer.Buttons() & BC_ATTACK) != 0 && overIndex >= 0)
		{
			elements[overIndex].OnSelect(mouseX, mouseY);
		}
	}
}
