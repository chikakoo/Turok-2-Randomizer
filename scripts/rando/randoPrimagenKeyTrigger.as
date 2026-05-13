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
			if (LocalPlayer.Inventory().HasBeenPickedUpBefore(kActor_InventoryItem_VisitedPrimagen))
			{
				DoPlayerWarp(0, 17602, kLevel_PrimagenBoss, true);
				return;
			}
			
			int levelsCompleted = GetNumberOfFinishedLevels();
			if (levelsCompleted < OPTION_GOAL_LEVELS)
			{
				Hud.AddMessage(
					"Level goal not met: " + levelsCompleted + "/" + OPTION_GOAL_LEVELS,
					240);
				m_messageCooldown = 360;
			}
		}
	}
}