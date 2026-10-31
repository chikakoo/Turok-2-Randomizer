//----------------------------------
// ScriptObject for enemy souls.
//----------------------------------
class RandoEnemySoul : RandoPickupObject
{
	int altTexture;
	RandoEnemySoul(kActor @actor)
	{
		super(actor);
		
		// Set the texture of the actor
		if (self.RenderMeshComponent() !is null && self.Definition() !is null)
		{
			self.RenderMeshComponent().AltTexture() = altTexture;
		}
	}
}