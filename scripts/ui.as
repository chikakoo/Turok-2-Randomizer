// --------------------------
// UI constants for opening menus
//---------------------------
uint16 g_menuButtonHeldTime = 5;
int g_messageCooldown = 0;
int g_progressMenuDisplayTime = 330;

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
const float UI_MOUSE_SIZE = 0.025f;

// Background image placements
const float UI_BACKGROUND_WIDTH = 0.636364f;
const float UI_BACKGROUND_HEIGHT = 0.70f;

const int UI_ICON_SIZE = 28;

const int UI_OFFSET_HEADER = 44;
const int UI_OFFSET_ROW_HEIGHT = 77;
const int UI_OFFSET_ROW_BOTTOM = 22;

const int UI_OFFSET_LEVEL_KEY = 70;
const int UI_OFFSET_PROGRESSIVE_WARP = 125;
const int UI_OFFSET_FEATHER = 176;
const int UI_OFFSET_PRIMAGEN_KEY = 227;
const int UI_OFFSET_TALISMAN = 278;

const int UI_OFFSET_MISSION_ITEM_1 = 453;
const int UI_OFFSET_MISSION_ITEM_2 = 397;
const int UI_OFFSET_MISSION_ITEM_3 = 352;

const int UI_OFFSET_NUKE_X = 468;
const int UI_OFFSET_NUKE_Y = 539;

const int UI_WARP_BUTTON_WIDTH = 157;
const int UI_WARP_BUTTON_HEIGHT = 28;

const int UI_OFFSET_WARP_HOME_X_ = 130;
const int UI_OFFSET_WARP_HUB_X = 336;
const int UI_OFFSET_WARP_BUTTON_Y = 528;

class RandoUI
{
	// General Properties
	kActor@ owner;
	bool isActive;
	int lastOverIndex;
	float lastPlayerHealth;
	
	// UI Properties
	kVec3 uiOrigin;
	int uiRegion;
	float uiYaw;
	
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
		fovRatioInverse = 1.0f;
		@mouse = CreateMouse();
	}
	
	//---------------------------
	// Displays level-specific progress, including:
	// - Location collection progress for the current map
	// - Location collection progress for the entire Level
	void DisplayLevelProgress()
	{
		int16 mapId = Game.ActiveMapID();
		switch(GetLevelNumberFromMapId(mapId))
		{
			case LEVEL_PORT_OF_ADIA:
				Hud.AddMessage(
					"Power Cells: " + GetInventoryMessage(kActor_MissionItem_BeaconPowerCell),
					g_progressMenuDisplayTime);
				break;
			case LEVEL_RIVER_OF_SOULS:
				Hud.AddMessage(
					"Gate Keys: " + GetInventoryMessage(kActor_MissionItem_GateKey) +
					"  -  Graveyard Keys: " + GetInventoryMessage(kActor_MissionItem_GraveyardKey),
					g_progressMenuDisplayTime);
				break;
			case LEVEL_DEATH_MARSHES:
				Hud.AddMessage(
					"Satchel Charges: " + GetInventoryMessage(kActor_MissionItem_L3SatchelCharge),
					g_progressMenuDisplayTime);
				break;
			case LEVEL_LAIR_OF_THE_BLIND_ONES:
				Hud.AddMessage(
					"Satchel Charges: " + GetInventoryMessage(kActor_MissionItem_L4SatchelCharge) +
					"  -  Cave Door Keys: " + GetInventoryMessage(kActor_MissionItem_CaveDoorKey),
					g_progressMenuDisplayTime);
				break;
			case LEVEL_HIVE_OF_THE_MANTIDS:
				Hud.AddMessage(
					"Satchel Charges: " + GetInventoryMessage(kActor_MissionItem_L5SatchelCharge),
					g_progressMenuDisplayTime);
				break;
			case LEVEL_PRIMAGENS_LIGHTSHIP:
				Hud.AddMessage(
					"Ion Caps: " + GetInventoryMessage(kActor_MissionItem_IonCapacitor) + 
					"  -  Blue Laser Cells: " + GetInventoryMessage(kActor_MissionItem_BlueLaserCell) + 
					"  -  Red Laser Cells: " + GetInventoryMessage(kActor_MissionItem_RedLaserCell),
					g_progressMenuDisplayTime);
				break;
			default:
				Hud.AddMessage("Unmapped map id!");
				return;
		}
		
		DisplayCollectedLocationsForLevel(mapId, "Level Checks", g_progressMenuDisplayTime);
		DisplayCollectedLocationsForCurrentMap(g_progressMenuDisplayTime);
	}
	
	// --------------------------
	// Gets a message for how many inventory items you've collected and how many you have now:
	// <collected> (<current>)
	kStr GetInventoryMessage(const int &in actorId)
	{
		int collectedTotal = GetInventoryItemCollectedTotal(actorId);
		int currentTotal = GetInventoryItemCurrentTotal(actorId);
		return "" + collectedTotal + " (" + currentTotal + ")";
	}

	// --------------------------
	// Turns on the UI menu
	bool Activate()
	{
		if (isActive)
		{
			return false;
		}
	
		if (IsInTotemOrBossLevel())
		{
			Hud.AddMessage("You can't open the UI here!");
			return false;
		}
	
		@owner = LocalPlayer.Actor().CastToActor();
		kPuppet@ puppet = owner.CastToPuppet();
		kVec3 velocity = owner.MovementComponent().Velocity();
		
		const float velocityTolerance = 0.001f;
		if ((owner.WorldComponent().Flags() & WCF_ON_PLATFORM) != 0 ||
			Math::Fabs(velocity.x) > velocityTolerance ||
			Math::Fabs(velocity.y) > velocityTolerance ||
			Math::Fabs(velocity.z) > velocityTolerance)
		{
			Hud.AddMessage("Stand still to show the UI.");
			return false;
		}
		
		lastPlayerHealth = owner.Health();
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
		uiOrigin = owner.Origin();
		uiRegion = owner.WorldComponent().RegionIndex();
		uiYaw = owner.Yaw();
		owner.Pitch() = 0;
		owner.Roll() = 0;
		puppet.PlayerFlags() |= PF_NOWEAPON;
		floatCamWait = 2;
		
		kQuat ownerRot(0.0f, 0.0f, -uiYaw);
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
		mouse.self.Flags() |= AF_HIDDEN;
		Clear();

		if (owner !is null)
		{
			kPuppet@ puppet = owner.CastToPuppet();
			puppet.PlayerFlags() &= ~(PF_NOWEAPON);
		}
	}
	
	// --------------------------
	// Removes all elements
	void Clear()
	{
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
		AddBackgroundImage(RANDO_UI_TEXTURE_BACKGROUND);
		
		DisplayLevel(1, 
			-1, 0,
			kActor_InventoryItem_ProgressiveWarpL1, 9,
			-1, 
			kActor_PrimagenKey_1, 
			-1);
		DisplayLevel(2, 
			kActor_InventoryItem_Level2Key, 3,
			kActor_InventoryItem_ProgressiveWarpL2, 20,
			kActor_Feather_2, 
			kActor_PrimagenKey_2, 
			kActor_Talisman_LeapOfFaith);
		DisplayLevel(3,
			kActor_InventoryItem_Level3Key, 3,
			kActor_InventoryItem_ProgressiveWarpL3, 20,
			kActor_Feather_3, 
			kActor_PrimagenKey_3,
			kActor_Talisman_BreathOfLife);
		DisplayLevel(4,
			kActor_InventoryItem_Level4Key, 3,
			kActor_InventoryItem_ProgressiveWarpL4, 20,
			kActor_Feather_4, 
			kActor_PrimagenKey_4, 
			kActor_Talisman_HeartOfFire);
		DisplayLevel(5,
			kActor_InventoryItem_Level5Key, 3,
			kActor_InventoryItem_ProgressiveWarpL5, 20,
			kActor_Feather_5, 
			kActor_PrimagenKey_5,
			kActor_Talisman_Whispers);
		DisplayLevel(6,
			kActor_InventoryItem_Level6Key, 6,
			kActor_InventoryItem_ProgressiveWarpL6, 20,
			kActor_Feather_6, 
			kActor_PrimagenKey_6, 
			kActor_Talisman_EyeOfTruth);
		
		int nukeParts = GetInventoryItemCurrentTotal(kActor_InventoryItem_NukePart);
		kVec3 nukePosition = PositionPixelToUI(UI_OFFSET_NUKE_X, UI_OFFSET_NUKE_Y);
		bool useGreenText = nukeParts >= 6;
		AddNumberImage(nukeParts, nukePosition, useGreenText);
		
		RandoUIElement@ homeButton = AddImage(
			RANDO_UI_TEXTURE_WARP_HOME, 
			PositionPixelToUI(UI_OFFSET_WARP_HOME_X_, UI_OFFSET_WARP_BUTTON_Y),
			UI_WARP_BUTTON_WIDTH,
			UI_WARP_BUTTON_HEIGHT);
		@homeButton.onSelect = UIElementSelectCallBack(OnWarpHomeClicked);
			
		RandoUIElement@ hubButton = AddImage(
			RANDO_UI_TEXTURE_WARP_HUB, 
			PositionPixelToUI(UI_OFFSET_WARP_HUB_X, UI_OFFSET_WARP_BUTTON_Y),
			UI_WARP_BUTTON_WIDTH,
			UI_WARP_BUTTON_HEIGHT);
		@hubButton.onSelect = UIElementSelectCallBack(OnWarpHubClicked);
	}
	
	// --------------------------
	// Handle warping home
	void OnWarpHomeClicked()
	{
		Deactivate();
		DoPlayerWarp(0, 11111, kLevel_PortOfAdia_1, true);
	}

	// --------------------------
	// Handle warping to the HUB
	// TODO: don't allow this if the hub isn't "unlocked"
	void OnWarpHubClicked()
	{
		Deactivate();
		DoPlayerWarp(0, 11999, kLevel_Hub, true);
	}
	
	// --------------------------
	// Displays the status for the given Level
	// Level 1 only has primagen keys and mission items, so it returns early
	void DisplayLevel(
		const int &in level, 
		const int &in levelKeyActor, const int &in maxKeys,
		const int &in progressiveWarpActor, const int &in maxProgressiveWarps,
		const int &in featherActor,
		const int &in primagenKeyActor,
		const int &in talismanActor)
	{
		int levelHeightOffset = GetLevelRowHeightOffset(level);

		// Primagen Keys
		int primagenKeyTexture = GetInventoryItemCollectedTotal(primagenKeyActor) > 0
			? RANDO_UI_TEXTURE_COMPLETE
			: RANDO_UI_TEXTURE_INCOMPLETE;
		AddImage(primagenKeyTexture, PositionPixelToUI(UI_OFFSET_PRIMAGEN_KEY, levelHeightOffset));
		
		// Progressive Warps
		int progressiveWarps = GetInventoryItemCollectedTotal(progressiveWarpActor);
		bool useGreenProgressiveWarpText = progressiveWarps >= maxProgressiveWarps;
		AddNumberImage(
			progressiveWarps, 
			PositionPixelToUI(UI_OFFSET_PROGRESSIVE_WARP, levelHeightOffset),
			useGreenProgressiveWarpText);
		
		// Mission items
		DisplayMissionItems(level, levelHeightOffset);
		
		// Special case for level 1, as it doesn't have any more to show
		if (level == 1)
		{
			return;
		}
		
		// Level Keys
		int levelKeys = GetInventoryItemCollectedTotal(levelKeyActor);
		bool useGreenLevelKeyText = levelKeys >= maxKeys;
		AddNumberImage(
			levelKeys, 
			PositionPixelToUI(UI_OFFSET_LEVEL_KEY, levelHeightOffset),
			useGreenLevelKeyText);
		
		// Feathers
		int featherTexture = GetInventoryItemCollectedTotal(featherActor) > 0
			? RANDO_UI_TEXTURE_COMPLETE
			: RANDO_UI_TEXTURE_INCOMPLETE;
		AddImage(featherTexture, PositionPixelToUI(UI_OFFSET_FEATHER, levelHeightOffset));
		
		// Talismans
		int talismanTexture = GetInventoryItemCurrentTotal(talismanActor) > 0
			? RANDO_UI_TEXTURE_COMPLETE
			: RANDO_UI_TEXTURE_INCOMPLETE;
		AddImage(talismanTexture, PositionPixelToUI(UI_OFFSET_TALISMAN, levelHeightOffset));
	}
	
	void DisplayMissionItems(
		const int &in level,
		const int &in levelHeightOffset)
	{
		switch(level)
		{
			case 1:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_BeaconPowerCell, 3);
				break;
			case 2:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_2, kActor_MissionItem_GateKey, 2);
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_GraveyardKey, 2);
				break;
			case 3:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_L3SatchelCharge, 3);
				break;
			case 4:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_2, kActor_MissionItem_CaveDoorKey, 7);
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_L4SatchelCharge, 3);
				break;
			case 5:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_L5SatchelCharge, 4);
				break;
			case 6:
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_3, kActor_MissionItem_IonCapacitor, 16);
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_2, kActor_MissionItem_BlueLaserCell, 2);
				DisplayMissionItem(levelHeightOffset, UI_OFFSET_MISSION_ITEM_1, kActor_MissionItem_RedLaserCell, 2);
				break;
			default:
				return;
		}
	}
	
	// --------------------------
	// Displays the mission item on the UI
	// This will display the current count you have in your inventory
	// It will be in green if you have all of the items required
	void DisplayMissionItem(
		const int &in levelHeightOffset,
		const int &in widthOffset,
		const int &in missionItemActor,
		const int &in maxCount)
	{
		int missionItemCollected = GetInventoryItemCollectedTotal(missionItemActor);
		int missionItemCurrent = GetInventoryItemCurrentTotal(missionItemActor);
		
		kVec3 missionItemPosition = PositionPixelToUI(widthOffset, levelHeightOffset);
		bool useGreenText = missionItemCollected >= maxCount;
		AddNumberImage(missionItemCurrent, missionItemPosition, useGreenText);
	}
	
	// --------------------------
	// Gets the height that UI Elements can be placed for a given level (in pixels)
	int GetLevelRowHeightOffset(const int &in level)
	{
		return UI_OFFSET_HEADER + (UI_OFFSET_ROW_HEIGHT * level) - UI_OFFSET_ROW_BOTTOM;
	}
	
	// --------------------------
	// Adds the background image to the ui
	void AddBackgroundImage(
		const int textureIndex, 
		const kVec3& in pos = Math::vecZero)
	{
		CreateUIElement(textureIndex, UI_BACKGROUND_WIDTH, UI_BACKGROUND_HEIGHT,  kVec3(0.0f, 0.0f, 0.01f));
	}
	
	// --------------------------
	// Adds an image to the UI
	// Takes the width/height in pixels
	RandoUIElement@ AddImage(
		const int textureIndex, 
		const kVec3& in pos = Math::vecZero,
		const int width = UI_ICON_SIZE, 
		const int height = UI_ICON_SIZE)
	{
		kVec3 size = SizePixelToUI(width, height);
		return CreateUIElement(textureIndex, size.x, size.y, pos);
	}
	
	// --------------------------
	// Adds a number image to the UI
	// Uses the default UI icon size
	void AddNumberImage(
		const int number, 
		const kVec3& in pos,
		bool useGreenText)
	{
		AddNumberImage(number, pos, UI_ICON_SIZE, UI_ICON_SIZE, useGreenText);
	}
	
	// --------------------------
	// Adds a number image to the UI
	// Takes the width/height in pixels
	void AddNumberImage(
		const int number, 
		const kVec3& in pos = Math::vecZero,
		const int width = UI_ICON_SIZE, 
		const int height = UI_ICON_SIZE,
		bool useGreenText = false)
	{
		int num = number;
		array<int> digits;
		
		if (num == 0)
		{
			digits.insertLast(0);
		}

		while (num > 0)
		{
			digits.insertLast(num % 10);
			num /= 10;
		}
		digits.reverse();
		
		int textureIndexStart = useGreenText 
			? RANDO_UI_TEXTURE_TEXT_GREEN_START
			: RANDO_UI_TEXTURE_TEXT_START;
		kVec3 size = SizePixelToUI(width, height);
		for (uint i = 0; i < digits.length(); i++)
		{
			int textureIndex = textureIndexStart + digits[i];
			kVec3 newPos = kVec3(
				pos.x + (i * size.x), 
				pos.y,
				pos.z
			);
			AddImage(textureIndex, newPos);
		}
	}
	
	// --------------------------
	// Converts the given x and y into a size that will fit into the ui
	kVec3 SizePixelToUI(float px, float py, float pz = 0.0f)
	{
		return kVec3(
			(px / 500.0f) * UI_BACKGROUND_WIDTH,
			(py / 550.0f) * UI_BACKGROUND_HEIGHT,
			pz
		);
	}
	
	// --------------------------
	// Converts the given x and y into a position that will fit into the ui
	// Icons will be centered
	kVec3 PositionPixelToUI(float px, float py, float pz = 0.0f)
	{
		float centeredX = px - 250.0f;
		float centeredY = 275.0f - py;

		return kVec3(
			(centeredX / 250.0f) * UI_BACKGROUND_WIDTH,
			(centeredY / 275.0f) * UI_BACKGROUND_HEIGHT,
			pz
		);
	}
	
	// --------------------------
	// Create a UI element
	RandoUIElement@ CreateUIElement(
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
		kActor@ actor = ActorFactory.Spawn(
			kActor_UI_Element, 
			Math::vecZero,
			0, 0, 0);
		RandoUIElement@ element = cast<RandoUIElement@>(GetScript(actor));
		if (element !is null)
		{
			element.SetTexture(RANDO_UI_TEXTURE_CURSOR);
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
		
		if ((LocalPlayer.Buttons() & BC_JUMP) != 0 ||
			(owner !is null && (owner.Health() < lastPlayerHealth)))
		{
			Deactivate();
		}
		
		// Do nothing if not active
		if (!isActive)
		{
			mouse.self.Flags() |= AF_HIDDEN;
			return;
		}

		lastPlayerHealth = owner.Health();
		mouse.self.Flags() &= ~AF_HIDDEN;
		
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
		
		// Move the mouse
		float mouseDX = owner.Yaw().Diff(uiYaw) * UI_MOUSE_SPEED;
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
		
		// Make sure the player doesn't move
		owner.Yaw() = uiYaw;
		owner.Pitch() = 0.0f;
		owner.Roll() = 0.0f;
		owner.Origin() = uiOrigin;
		owner.WorldComponent().SetRegion(uiRegion);
		
		kPuppet@ puppet = owner.CastToPuppet();
		puppet.PlayerFlags() |= PF_HASJUMPED | PF_NOWEAPON;
		
		float playerHeight = 100.0f;
		kVec3 playerPos = puppet.Origin() + kVec3(0, 0, playerHeight);
		kVec3 elementPos = playerPos + forwardDir;

		// Go through elements and position based on the ui position
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
			if (elements[i].IsMousedOver(
					mouseX - mouse.width, 
					mouseY + (mouse.height * 0.5f)) && 
				elements[i].onSelect !is null)
			{
				float distance = elements[i].positionOffset.Distance(mousePos);
				if (distance < closestDist)
				{
					closestDist = distance;
					overIndex = i;
				}
			}
		}
		
		// Click handler
		if (LocalPlayer.ButtonHeldTime(0) > 0 && overIndex >= 0)
		{
			elements[overIndex].OnSelect();
		}
	}
}
