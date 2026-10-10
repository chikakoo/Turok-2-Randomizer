//----------------------------------
// ScriptObject for weapon pickups.
//----------------------------------
class RandoWeapon : RandoPickupObject
{
	RandoWeapon(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// If we're randomizing weapons, always collect the weapon pickup
	void AfterSentToAP() override
	{		
		if (OPTION_RANDOMIZE_WEAPONS)
		{
			TryGivePlayerWeapon(self.Type());
			CollectLocation(m_id, Game.ActiveMapID());
			self.Remove();
		}
	}
}