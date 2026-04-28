// --------------------------
// An actor for blocking players getting to level 1 without the keys.
//---------------------------
class RandoLevel1Barrier : ScriptActor
{
	int m_messageCooldown = 0;
	int m_progressMenuDisplayTime = 330;
	
	//---------------------------
	// Constructor - turns on the collision callback and turns off damage
	RandoLevel1Barrier(kActor @actor) 
	{ 
		super(@actor);
		self.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		self.Flags() |= AF_NODAMAGE;
	}
	
	//---------------------------
	// Warps to the appropriate level's warp point.
	void OnTouch(kActor@ pInstigator)
	{	
		if (m_messageCooldown <= 0 && pInstigator.InstanceOf("kexPuppet"))
		{
			TryPrintWarpMessage();
		}
	}
	
	//---------------------------
	// Tries printing the barrier message.
	// Resets the cooldown timer if it does print it.
	void TryPrintWarpMessage(void)
	{
		if (m_messageCooldown <= 0)
		{
			int keysLeftToEnter = GetKeysLeftToEnter();
			kStr warpString = keysLeftToEnter == 1 ? "key" : "keys";
			Hud.AddMessage(
				"" + keysLeftToEnter + " more level 1 " + warpString + " required.",
				m_progressMenuDisplayTime);
			m_messageCooldown = 360;
		}
	}
	
	//---------------------------
	// Gets the number of level 1 keys needed to pass the barrier.
	int GetKeysLeftToEnter(void)
	{
		return 3 - GetInventoryItemCollectedTotal(kActor_InventoryItem_Level1Key);
	}
	
	//---------------------------
	// Count down the message cooldown, if necessary
	void OnTick(void)
	{
		if (m_messageCooldown > 0)
		{
			m_messageCooldown--;
		}
		
		if (GetKeysLeftToEnter() <= 0)
		{
			self.Remove();
		}
	}
	
	// --------------------------
	// Needs to exist with OnDeserialize to prevent errors
	void OnSerialize(kDict& out dict)
	{
	}
	
	// --------------------------
	// Remove on a deserialize, as they are created on spawn
	// This prevents multiple barriers from existing at a time
	void OnDeserialize(kDict& in dict)
	{			
		self.Remove();
	}
}