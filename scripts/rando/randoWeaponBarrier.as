// --------------------------
// An actor for blocking players getting to warps to support progressive warp portals.
//---------------------------
class RandoWeaponBarrier : ScriptActor
{
	int m_messageCooldown = 0;
	int m_progressMenuDisplayTime = 330;
	int m_numberOfWeaponsNeeded = 0;
	
	bool hasWarpBack = false;
	int warpBackRegion;

	//---------------------------
	// Constructor - turns on the collision callback and turns off damage
	RandoWeaponBarrier(kActor @actor) 
	{ 
		super(@actor);
		self.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		self.Flags() |= AF_NODAMAGE;
	}
	
	//---------------------------
	// Sets the barrier info so it can be removed when the weapon requirement is met.
	void SetBarrierInfo(const int &in numberOfWeaponsNeeded)
	{
		m_numberOfWeaponsNeeded = numberOfWeaponsNeeded;
	}
	
	//---------------------------
	// Sets a region that the player will be warped back to after touching the barrier.
	// Used for when the player will fall onto the barrier and needs to be placed back on the ledge.
	void SetWarpBack(const int &in warpBackRegion)
	{
		hasWarpBack = true;
		this.warpBackRegion = warpBackRegion;
	}
	
	//---------------------------
	// Sets the radius and touch radius
	// The touch radius will be 10 units more than the radius
	void SetRadii(const int &in radius)
	{
		self.WorldComponent().Radius() = radius;
		self.WorldComponent().TouchRadius() = radius + 10.0f;
	}
	
	//---------------------------
	// Gets the number of weapons the player needs to get to enter the barrier.
	int GetNumberOfWeaponsLeftToEnter()
	{
		return m_numberOfWeaponsNeeded - g_numberOfOwnedProgressionWeapons;
	} 
	
	//---------------------------
	// Prints a message for the player indicating how many weapons they need to pass.
	void OnTouch(kActor@ pInstigator)
	{	
		if (m_messageCooldown <= 0 && pInstigator.InstanceOf("kexPuppet"))
		{
			TryPrintWarpMessage();
			
			// Just in case collide is borked somehow
			if (hasWarpBack)
			{
				LocalPlayer.Actor().CastToActor().WorldComponent().SetRegion(warpBackRegion);
			}
		}
	}
	
	//---------------------------
	// Will warp the player to the appropriate position if there is a warp back.
	// This works better than OnTouch, which is really janky if the player falls on the warp.
	void OnCollide(kActor@ pCollider)
	{
		if (hasWarpBack && pCollider.InstanceOf("kexPuppet"))
		{
			TryPrintWarpMessage();
			LocalPlayer.Actor().CastToActor().WorldComponent().SetRegion(warpBackRegion);
		}
	}
	
	//---------------------------
	// Tries printing the weapons needed message.
	// Resets the cooldown timer if it does print it.
	void TryPrintWarpMessage()
	{
		int weaponsLeftToEnter = GetNumberOfWeaponsLeftToEnter();
		if (weaponsLeftToEnter > 0)
		{
			kStr weaponString = weaponsLeftToEnter == 1 ? "weapon" : "weapons";
			Hud.AddMessage(
				"You need " + weaponsLeftToEnter + " more unique " + weaponString + " to enter here!",
				m_progressMenuDisplayTime);
			m_messageCooldown = 360;
		}
	}
	
	//---------------------------
	// Count down the message cooldown, if necessary
	void OnTick()
	{
		if (m_messageCooldown > 0)
		{
			m_messageCooldown--;
		}
		
		if (GetNumberOfWeaponsLeftToEnter() <= 0)
		{
			self.Remove();
		}
	}
	
	//--------------------------
	// Needs to exist with OnDeserialize to prevent errors
	void OnSerialize(kDict& out dict)
	{
	}
	
	//--------------------------
	// Remove on a deserialize, as they are created on spawn
	// This prevents multiple barriers from existing at a time
	// The alternative would require serializing the warp data
	void OnDeserialize(kDict& in dict)
	{			
		self.Remove();
	}
}