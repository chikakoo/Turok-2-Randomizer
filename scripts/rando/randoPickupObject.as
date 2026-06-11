//----------------------------------
// ScriptObject placed on every pickup that AP cares about.
// Used to handle whether we've collected and sent pickup checks to AP.
int g_pickupMessageCooldown;
class RandoPickupObject : ScriptObject
{
	// Used in ReplaceActor to copy the position properties
    kActor@ self;
	kStr m_position;
	kStr m_name;
	int m_id;
	kStr m_actorName;
	kStr m_displayString;
	bool m_wasSentToAP;
	
	bool m_isOverRiver;
	bool m_isOverLava;
	
	//----------------------------------
	// Constructor
	// @actor: The actor that was loaded
    RandoPickupObject(kActor @actor)
    {
	    @self = actor;
		m_position = GetPositionString();
		SetReplacementEntryProperties();
		
		// Force the pickup to be non-solid - this is mainly for generated ammo
		self.WorldComponent().Flags() |= WCF_NONSOLID;
		
		// These aren't showing as important for some reason when they should
		if (self.Type() == kActor_MissionItem_BeaconPowerCell ||
			self.Type() == kActor_MissionItem_IonCapacitor)
		{
			self.Flags() |= AF_IMPORTANT;
		}
		
		if (m_id > 0 && !m_wasSentToAP)
		{
			SetRiverAndLavaProperties();
		}
    }
	
	//----------------------------------
	// Gets a unique id for the pickup.
	// Will be the key for the rando dictionary for replacements
	kStr GetPositionString(void)
	{
		if (self is null)
		{
			Sys.Print("ERROR: Attempted to get ID, but the actor is null!");
			return "";
		}
		
		kVec3 position = self.Origin();
		return "" + Game.ActiveMapID() + "_" +
			int(position.x) + "_" +
			int(position.y) + "_" +
			int(position.z);
	}
	
	//----------------------------------
	// Tries to get the name/id/display string out of the dictionary.
	// If not there, returns a placeholder for the name.
	void SetReplacementEntryProperties(void)
	{
		ReplacementEntry@ replacementEntry;
		TryGetReplacement(Game.ActiveMapID(), m_position, replacementEntry);
		
		if (replacementEntry is null)
		{
			m_name = "<NO NAME SET>";
			m_displayString = "";
			m_wasSentToAP = false;
		}
		else
		{
			m_name = replacementEntry.name;
			m_id = replacementEntry.apId;
			m_displayString = replacementEntry.displayString;
			m_wasSentToAP = replacementEntry.isSentToAP;
		}
	}
	
	void SetRiverAndLavaProperties(void)
	{
		switch(m_id)
		{
			// 3-1 Starting jump
			case 61068:
			case 61069:
			case 61070:
			case 61071:
			case 61072:
			
			// 3-1 Single river log
			case 61094:
			case 61095:
			case 61096:
			case 61097:
			
			// 3-3 Starting jump
			case 63054:
			case 63055:
			case 63056:
			case 63057:
			case 63058:
			
			// 3-3 By checkpoint ladder
			case 63068:
			case 63069:
			case 63070:
			case 63071:
				m_isOverRiver = true;
				break;
				
			// TODO: the lava locations
		}
	}
	
	//----------------------------------
	// Called every tick to see if the player is touching the pickup
	// Note that health/ammo/weapon upgrades ARE sent to AP still when touched
	// so that it knows you could have received it.
	void OnTick()
	{		
		if (m_id > 0 && !m_wasSentToAP)
		{
			kPuppet@ player = LocalPlayer.Actor();
			if (player is null)
			{
				return;
			}
			
			// Disable OnTouch until we know it can be collected
			float touchRadius = self.WorldComponent().TouchRadius();
			self.WorldComponent().TouchRadius() = 0;
			
			// Check if it's close enough - calculations without using a sqrt
			kVec3 delta = self.Origin() - player.Origin();
			float distSq = delta.UnitSq(); // Squared distance
			float triggerDistance = self.WorldComponent().Radius() + player.WorldComponent().Radius();
			if ((player.MovementComponent().Flags() & MCF_NO_GRAVITY) != 0)
			{
				// Force a bigger radius during Leap of Faith because things can be missed otherwise
				// The extra radius in other places causes issues, so only do it here
				triggerDistance += 50;
			}
			float triggerDistSq = triggerDistance * triggerDistance;
			
			if (distSq > triggerDistSq || !CanCollectPickup())
			{
				return;
			}
			
			// If close enough, we're good to pick it up
			self.WorldComponent().TouchRadius() = touchRadius;
			SendCheckToAP(m_id);
			m_wasSentToAP = true;
			
			DisplayCollectedLocationsForCurrentMap();
			
			// Turn the important flag off now, since we already sent the check
			self.Flags() &= ~AF_IMPORTANT;
			
			// Try to trigger events from the item being picked up
			TryTriggerActors(m_position);
			
			// If we're randomizing weapons, always collect the weapon pickup
			if (OPTION_RANDOMIZE_WEAPONS)
			{
				kDictMem@ itemDef = TryGetActorDefWithClass(self.Type(), "kexWeaponPickup", true);
				if (itemDef is null)
				{
					return;
				}
				
				TryGivePlayerWeapon(self.Type());
				CollectLocation(m_id, Game.ActiveMapID());
				self.Remove();
			}
		}
	}
	
	//----------------------------------
	// Checks the appropriate flags for river/lava talismans.
	// Displays a message reminding the player that it is not collectable.
	bool CanCollectPickup()
	{
		if (m_isOverRiver && OPTION_DISABLE_PICKUPS_OVER_RIVER)
		{
			if (GetInventoryItemCurrentTotal(kActor_Talisman_BreathOfLife) == 0)
			{
				TryDisplayPickupMessage("Breath of Life is required to collect this.");
				return false;
			}
		}
		
		else if (m_isOverLava && OPTION_DISABLE_PICKUPS_OVER_LAVA)
		{
			if (GetInventoryItemCurrentTotal(kActor_Talisman_HeartOfFire) == 0)
			{
				TryDisplayPickupMessage("Heart of Fire is required to collect this.");
				return false;
			}
		}
	
		return true;
	}
	
	//----------------------------------
	// Tries to display the given pickup message.
	// Sets the cooldown if it does display it.
	void TryDisplayPickupMessage(const kStr &in message)
	{
		if (g_pickupMessageCooldown <= 0)
		{
			Hud.AddMessage(message, 360);
			g_pickupMessageCooldown = 420;
		}
	}
	
	//----------------------------------
	// Called when the actor is collected.
	// Marks it as collected so it won't respawn.
	void OnTouch(kActor@ pInstigator)
	{
		if (self.Type() == kActor_Item_RandomAmmo)
		{
			if (Game.ActiveMapID() == kLevel_Hub)
			{
				FillAmmoInAllWeapons();
			}
			else
			{
				GetAmmoInRandomWeapon();
			}
			
			// This is a non-AP item ammo replacement, so we should still mark it as collected
			// We should also still try to trigger its actors too in case there's a pickup trigger
			if (m_id < 0)
			{
				CollectLocation(m_id, Game.ActiveMapID());
				TryTriggerActors(m_position);
			}
		}
		
		// If this item is an inventory item, do this to track the total you've ever received
		// Don't do this for weapons if it was sent to AP already (third param)
		HandleTrackInventoryItems(self.Type(), null, m_wasSentToAP);
		
		if (m_id > 0)
		{
			CollectLocation(m_id, Game.ActiveMapID());
			SendCheckToAP(m_id);
			
			// In case we triggered this before our OnTick detection...
			if (!m_wasSentToAP)
			{
				DisplayCollectedLocationsForCurrentMap();
			}
			m_wasSentToAP = true;
			
			// Try to trigger it if it is a trap.
			// If it isn't, this doesn't do anything.
			if (TryTriggerTrap(self.Type()))
			{
			}
			
			// If it's an AP item, display the check
			else if (self.Type() == kActor_Item_APItemProgression ||
				self.Type() == kActor_Item_APItemUseful ||
				self.Type() == kActor_Item_APItemNonProgression)
			{
				Hud.AddMessage(m_displayString);
			}
			
			// If using level key packs, give the rest of the keys
			// The game will have given one already, so give the rest!
			else if (OPTION_UNLOCK_METHOD_ONE_KEY && IsLevelKey(self.Type()))
			{
				int count = self.Type() == kActor_InventoryItem_Level6Key ? 5 : 2;
				TryGetInventoryItems(self.Type(), count);
			}
			
			// Only gives the keys if necessary
			TryGiveAllLevelKeysForWarp(self.Type());
			
			// Try to trigger events from the item being picked up
			// Done here as well to make absolutely sure that it's triggered
			// Not doing so can lead to softlocks
			TryTriggerActors(m_position);
		}
	}
}