//----------------------------------
// ScriptObject for AP items.
//----------------------------------
class RandoAPItem : RandoPickupObject
{
	RandoAPItem(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// Displays the AP item message.
	void AfterReplacementTouched() override
	{
		Hud.AddMessage(m_displayString);
	}
}