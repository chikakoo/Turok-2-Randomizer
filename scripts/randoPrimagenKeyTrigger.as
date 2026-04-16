// --------------------------
// An actor to let the player know the current level status.
// It should only spawn when the level requirements are not met.
//---------------------------
class RandoPrimagenKeyTrigger : ScriptObject
{
	kActor@ self;
	int16 m_messageCooldown;

	//---------------------------
	// Constructor
	RandoPrimagenKeyTrigger(kActor @actor)
	{
		@self = actor;
		actor.WorldComponent().Flags() |= WCF_NONSOLID;
		actor.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		m_messageCooldown = 0;
	}
	
	//---------------------------
	// Display a message when collided with.
	void OnTick(void)
	{
		if (m_messageCooldown > 0)
		{
			m_messageCooldown--;
		}
	}
	
	//---------------------------
	// Display a message when collided with.
	void OnCollide(kActor@ pCollider)
	{
		if (m_messageCooldown <= 0)
		{
			int levelsCompleted = GetInventoryItemCurrentTotal(kActor_Misc_TotemInventory);
			Hud.AddMessage(
				"Level goal not met: " + levelsCompleted + "/" + OPTION_GOAL_LEVELS,
				240);
			m_messageCooldown = 360;
		}
	}
	
	// --------------------------
	// Needs to exist with OnDeserialize to prevent errors
	void OnSerialize(kDict& out dict)
	{
	}
	
	// --------------------------
	// Remove on a deserialize, as they are created on spawn
	// This prevents multiple of these from existing at a time
	void OnDeserialize(kDict& in dict)
	{			
		self.Remove();
	}
}