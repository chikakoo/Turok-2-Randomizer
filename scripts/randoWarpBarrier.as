// --------------------------
// An actor for blocking players getting to warps to support progressive warp portals.
//---------------------------
class RandoWarpBarrier : ScriptActor
{
	int m_messageCooldown = 0;
	int m_progressMenuDisplayTime = 330;
	
	int progressiveWarpItemId = -1;
	int progressiveWarpsNeeded = 99;
	
	bool hasWarpBack = false;
	int warpBackRegion;
	
	//---------------------------
	// Constructor
	// Creates the warp frame under the warp itself.
	RandoWarpBarrier(kActor @actor) 
	{ 
		super(@actor);
		self.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
	}
	
	//---------------------------
	// Sets the barrier info so it can be removed when the items are in inventory.
	void SetBarrierInfo(const int &in itemId, const int &in needed)
	{
		progressiveWarpItemId = itemId;
		progressiveWarpsNeeded = needed;
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
	// The count of progressive warps needed.
	// This is affected by the progressive warp setting, which can make it less than the raw value.
	int GetProgressiveWarpsLeftToEnter()
	{
		int progressiveWarpStrength = OPTION_PROGRESSIVE_WARPS;
		if (progressiveWarpStrength <= 0)
		{
			return 0;
		}
		
		int numberNeeded = int(Math::Ceil(float(progressiveWarpsNeeded) / float(progressiveWarpStrength)));
		return numberNeeded - GetInventoryItemCurrentTotal(progressiveWarpItemId);
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
	// Tries printing the progressive warp message.
	// Resets the cooldown timer if it does print it.
	void TryPrintWarpMessage()
	{
		if (m_messageCooldown <= 0)
		{
			int progressiveWarpsLeftToEnter = GetProgressiveWarpsLeftToEnter();
			kStr warpString = progressiveWarpsLeftToEnter == 1 ? "warp" : "warps";
			Hud.AddMessage(
				"You need " + progressiveWarpsLeftToEnter + " more progressive " + warpString + " to enter here!",
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
		
		if (progressiveWarpItemId != -1 && GetProgressiveWarpsLeftToEnter() <= 0)
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