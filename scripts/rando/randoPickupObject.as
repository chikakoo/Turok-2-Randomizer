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
		// These are vanilla and should always be marked!
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
	
	//----------------------------------
	// Sets the river/lava properties based on the pickup id.
	// Some of these are just safeties in case the player can get them.
	void SetRiverAndLavaProperties(void)
	{
		switch(m_id)
		{
			// 3-1 - in logic if setting is on
			case 61068: // Breath of Life trail
			case 61069:
			case 61070:
			case 61071:
			case 61072:
			case 61094: // Single river log
			case 61095:
			case 61096:
			case 61097:
			
			// 3-1 - NOT in logic if setting is on (for safety)
			case 61080: // Left path by LF10 ledge
			case 61081: // Left path by crane drop
			case 61082: // Left path by platforms
			case 61083: // Left path by Grenade Launcher
			case 61085: // Left corner jump at the start
			case 61086:
			case 61087: // Corner jump after platforming
			case 61088: // Corner jump by ladder
			case 61089: // Corner jump off sloped bridge
			case 61090:
			case 61091: // Jump after broken bridge
			case 61092:
			case 61093:
			case 61102: // Double river log
			
			// 3-3 - in logic if setting is on
			case 63054: // Starting jump
			case 63056:
			case 63057:
			case 63068: // Checkpoint ladder
			case 63069:
			case 63070:
			case 63071: 
			
			// 3-3 - NOT in logic if setting is on (for safety)
			case 63055: // Start of Primagen Key tunnel
			case 63058: // Starting trail, but too far to jump to
			case 63060: // Dead end before marsh area
			case 63061:
			case 63062: // Marsh area wall corner
			case 63063:
			case 63064: // Corners by watchtower
			case 63065:
			case 63066:
			case 63072: // Corner by checkpoint ladder
			case 63073: // Dead end by checkpoint
			case 63074:
			case 63075:
				m_isOverRiver = true;
				break;
				
			// 4-7
			case 104007: // Small lava
			case 104008:
			case 104009:
			case 104010:
			case 104011:
			case 104012:
			case 104016: // Big lava start left
			case 104017:
			case 104018:
			case 104019:
			case 104020:
			case 104021:
			case 104022:
			case 104023: // Big lava back Left
			case 104024:
			case 104025:
			case 104026:
			case 104027: // Big lava back
			case 104028:
			case 104029:
			case 104030:
			case 104031:
			
			// 5-9
			case 91036:
			case 91037:
			case 91038:
			case 91039:
			case 91040:
			case 91041:
			case 91042:
			case 91043:
			case 91044:
			case 91045:
			
			// 5-E3
			case 96021:
			case 96022:
			case 96023:
			case 96024:
			case 96025:
			case 96026:
			case 96027:
			case 96028:
			case 96029:
				m_isOverLava = true;
				break;
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
			// Prevent a dead player puppet from collecting stuff (this isn't normally possible)
			kPuppet@ player = LocalPlayer.Actor();
			if (player is null || (player.Health() <= 0 || (player.Flags() & AF_DEAD) != 0))
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