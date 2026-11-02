//----------------------------------
// ScriptObject for enemy souls.
//----------------------------------
class RandoEnemySoul : RandoPickupObject
{
	RandoEnemySoul(kActor @actor)
	{
		super(actor);
		
		// Set the texture of the actor
		if (self.RenderMeshComponent() !is null && self.Definition() !is null)
		{
			int altTextureIndex;
			if (self.Definition().GetInt("rando.altTexture", altTextureIndex))
			{
				self.RenderMeshComponent().AltTexture() = altTextureIndex - 1;
			}
		}
	}
}