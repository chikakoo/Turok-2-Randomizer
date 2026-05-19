// --------------------------
// An actor to let the player know the current level status.
// It should only spawn when the level requirements are not met.
//---------------------------
class RandoPrimagenKeyTrigger : ScriptObject
{
	kActor@ self;
	int16 m_messageCooldown;
	bool m_goalMet;

	//---------------------------
	// Constructor
	RandoPrimagenKeyTrigger(kActor @actor)
	{
		@self = actor;
		actor.WorldComponent().Flags() |= WCF_NONSOLID;
		actor.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		m_messageCooldown = 0;
		m_goalMet = false;
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
			
			if (m_goalMet)
			{
				return;
			}
			
			bool goalMet = true;
			
			int levelsCompleted = GetNumberOfFinishedLevels();
			if (levelsCompleted < OPTION_GOAL_LEVELS)
			{
				Hud.AddMessage(
					"Level goal not met: " + levelsCompleted + "/" + OPTION_GOAL_LEVELS,
					240);
				m_messageCooldown = 360;
				goalMet = false;
			}
			
			int weaponsNeeded = OPTION_WEAPON_BARRIER_PRIMAGEN - g_numberOfOwnedProgressionWeapons;
			if (weaponsNeeded > 0)
			{
				Hud.AddMessage(
					"Weapon requirement not met: " + g_numberOfOwnedProgressionWeapons + "/" + OPTION_WEAPON_BARRIER_PRIMAGEN,
					240);
				m_messageCooldown = 360;
				goalMet = false;
			}
			
			// If we met the goals, re-enable Primagen key placement
			if (goalMet && OPTION_WEAPON_BARRIER_PRIMAGEN > 0)
			{
				AllowPrimagenKeyPlacement();
				m_goalMet = true;
			}
		}
	}
	
	//---------------------------
	// Resets the touch radius on the Primagen Key actors so they can be placed.
	void AllowPrimagenKeyPlacement()
	{
		if (Game.ActiveMapID() != kLevel_Hub)
		{
			return;
		}
	
		kActorIterator actorIterator;
		kActor@ actor;
		while((@actor = actorIterator.GetNext()) !is null)
		{
			if (actor.TID() == 19 ||
				actor.TID() == 20 ||
				actor.TID() == 21 ||
				actor.TID() == 22 ||
				actor.TID() == 23 ||
				actor.TID() == 24) 
				{
					actor.WorldComponent().TouchRadius() = 61.439995;
				}
		}
	}
}