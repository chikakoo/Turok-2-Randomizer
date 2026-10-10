//----------------------------------
// ScriptObject for enemy licenses.
//----------------------------------
class RandoEnemyLicense : RandoPickupObject
{
	int altTexture;
	RandoEnemyLicense(kActor @actor)
	{
		super(actor);
		
		// Set the texture of the actor
		if (self.RenderMeshComponent() !is null && self.Definition() !is null)
		{
			self.RenderMeshComponent().AltTexture() = altTexture;
		}
	}
}