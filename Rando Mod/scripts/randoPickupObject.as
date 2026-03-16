class RandoPickupObject : ScriptObject
{
	// Used in ReplaceActor to copy the position properties
    kActor@ self;
	kStr m_position;
	kStr m_name;
	int m_id;
	kStr m_actorName;
	kStr m_displayString;
	
	// Constructor
	// @actor: The actor that was loaded
    RandoPickupObject(kActor @actor)
    {
	    @self = actor;
		m_position = GetPositionString();
		SetReplacementEntryProperties();
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
		ReplacementEntry replacementEntry;
		TryGetReplacement(m_position, replacementEntry);
		
		if (replacementEntry is null)
		{
			m_name = "<NO NAME SET>";
			m_displayString = "";
		}
		else
		{
			m_name = replacementEntry.name;
			m_id = replacementEntry.key;
			m_displayString = replacementEntry.displayString;
		}
	}
	
	// This is called when the actor is collided with, even if not collected.
	// Note that health and ammo ARE sent to AP still when touched
	// so that it knows you could have received it.
	void OnCollide(kActor@ pCollider)
	{
		if (m_id != 0 && 
			!(pCollider is null) &&
			pCollider.InstanceOf("kexPuppet"))
		{
			Sys.Print("SENT TO AP: " + ToString());
			SendCheckToAP(m_id);
			
			// Turn the flag off now, since we already sent the check
			// It will turn back on when the map reloads, but at least
			// we don't be spamming AP with useless messages every tick!
			self.WorldComponent().Flags() &= ~WCF_INVOKE_COLLIDE_CALLBACK;
			
			// If it's an AP item, display the check
			if (m_displayString != "")
			{
				Hud.AddMessage(m_displayString);
			}
			
			if (IsHealthOrAmmo(self))
			{
				PlayPickupNotification(self.Definition());
			}
		}
	}
	
	// Called when the actor is collected.
	// Marks it as collected so it won't respawn.
	void OnTouch(kActor@ pInstigator)
	{
		Sys.Print(m_position);
		//Sys.Print("COLLECTED: " + ToString());
		Hud.AddMessage("AP GET");
		
		if (m_id != 0)
		{
			CollectLocation(m_id);
		}
	}
	
	// Called when the actor is spawned in the map.
	// Replaces the actor with a different one, in the same position.
	// If it was already replaced or collected, don't do anything.
	void OnSpawn(void)
	{
		if (IsLocationCollected(m_id))
		{
			Sys.Print("COLLECTED ON SPAWN: " + ToString());
			self.Remove();
			return;
		}

		ReplacementEntry replacement;
		EnsureMapInit(); // Resets replacement flags if map is now different
		
		if (!TryGetReplacement(m_position, replacement)) 
		{ 
			if (!replacement.wasReplaced) 
			{ 
				Sys.Print("NOT MAPPED: " + ToString() + " (" + GetFriendlyActorName(self.Type()) + ")"); 
				
				// TODO: remove this later, this is only to help find them to map them
				// we MAY include this as an option, but only if m_id is set
				self.Flags() |= AF_IMPORTANT;
			}
			
			return; 
		}
		
		kWorldComponent@ worldComponent = self.WorldComponent();
		kActor@ replacedActor = ActorFactory.Spawn(
			replacement.value,
			self.Origin(),
			self.Yaw(),
			self.Pitch(),
			self.Roll(),
			true, // Unknown - always set to true
			worldComponent.RegionIndex());
			
		kWorldComponent@ newWorldComponent = replacedActor.WorldComponent();
		newWorldComponent.Radius() = worldComponent.Radius();
		newWorldComponent.Height() = worldComponent.Height();
		newWorldComponent.Flags() = worldComponent.Flags();
		
		// Fixes console warnings
		if (self.ModeStateComponent() !is null)
		{
			replacedActor.ModeStateComponent().SetMode(
				self.ModeStateComponent().Mode());
		}
		
		// Turn on the flag so that collision can be detected
		// We need to be able to detect touching health/ammo
		// pickups even when we don't have full so we can send the AP check
		if (IsHealthOrAmmo(replacedActor))
		{
			newWorldComponent.Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		}
		
	    self.Remove();
	}
	
	kStr ToString()
	{
		return m_name + " (" + m_position + ")" + " (" + m_id + ")";
	}
	
	bool IsHealthOrAmmo(kActor@ actor) 
	{
		kStr className;
		actor.Definition().GetString("className", className);
		return className == "kexHealthPickup" || className == "kexAmmoPickup";
	}
	
	// Debug helper to print the flags of an actor
	void PrintFlags(int flags)
	{
		kStr flagStr = "Flags:";

		for (int i = 0; i < 24; i++)
		{
			if ((flags & (1 << i)) != 0)
			{
				flagStr += " " + i;
			}
		}
		
		Sys.Print(flagStr);
	}
}