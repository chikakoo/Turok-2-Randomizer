//----------------------------------
// ScriptObject for enemy licenses.
//----------------------------------
class RandoAmmoPack : RandoPickupObject
{
	RandoAmmoPack(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// Handles ammo behavior when it is touched.
	// Full refill when in the hub, else gets random ammo.
	// Also handles collecting it.
	void BeforeOnTouch() override
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
}