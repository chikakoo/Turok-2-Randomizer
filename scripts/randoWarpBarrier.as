// --------------------------
// An actor for blocking players getting to warps to support progressive warp portals.
//---------------------------
class RandoWarpBarrier : ScriptObject
{
	int m_messageCooldown = 0;
	int m_progressMenuDisplayTime = 330;
	
	//---------------------------
	// Constructor
	// Creates the warp frame under the warp itself.
	RandoWarpBarrier(kActor @actor) 
	{ 
		actor.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
	}
	
	//---------------------------
	// Warps to the appropriate level's warp point.
	void OnTouch(kActor@ pInstigator)
	{
		if (m_messageCooldown <= 0)
		{
			Hud.AddMessage("You need more progressive warps to enter here!", m_progressMenuDisplayTime);
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
	}
}