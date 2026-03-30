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
	
	// Constructor
	// @actor: The actor that was loaded
    RandoPickupObject(kActor @actor)
    {
	    @self = actor;
		m_position = GetPositionString();
		SetReplacementEntryProperties();
		
		// Force the pickup to be non-solid - this is mainly for generated ammo
		self.WorldComponent().Flags() |= WCF_NONSOLID;
    }
	
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
	
	// This is called when the actor is collided with, even if not collected.
	// Note that health and ammo ARE sent to AP still when touched
	// so that it knows you could have received it.
	void OnCollide(kActor@ pCollider)
	{			
		if (m_id != 0 && 
			!m_wasSentToAP &&
			!(pCollider is null) &&
			pCollider.InstanceOf("kexPuppet"))
		{			
			SendCheckToAP(m_id);
			DisplayCollectedLocationsForCurrentMap();
			if (IsHealthOrAmmo(self))
			{
				PlayPickupNotificationSound(self.Definition());
			}
			
			// Turn the flags off now, since we already sent the check
			self.WorldComponent().Flags() &= ~WCF_INVOKE_COLLIDE_CALLBACK;
			self.Flags() &= ~AF_IMPORTANT;
			
			// Try to trigger doors
			if (IsDoorTriggeringActor(m_position))
			{
				TriggerDoors();
			}
		}
	}
	
	// Called when the actor is collected.
	// Marks it as collected so it won't respawn.
	void OnTouch(kActor@ pInstigator)
	{
		Sys.Print(m_position);
	
		if (self.Type() == kActor_Item_RandomAmmo)
		{
			GetAmmoInRandomWeapon();
		}
			
		if (m_id != 0)
		{
			CollectLocation(m_id, Game.ActiveMapID());
			SendCheckToAP(m_id);
			
			// If this item is marked with rando.give2, do this to give the second one
			// This is true for primagen keys currently
			HandleGiveSecondItem(self.Type());
			
			// Try to trigger it if it is a trap.
			// If it isn't, this doesn't do anything.
			if (TryTriggerTrap(self.Type()))
			{
			}
			
			// If it's an AP item, display the check
			else if (self.Type() == kActor_Item_APItemProgression ||
				self.Type() == kActor_Item_APItemNonProgression)
			{
				Hud.AddMessage(m_displayString);
			}
		}
	}
}