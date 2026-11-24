//----------------------------------
// ScriptObject for enemy souls.
//----------------------------------

// TODO: reconsider... do the deadmen "die" when the soul gate is destroyed?
//   If reconsidering, figure out how to do enemy traps... we shouldn't count these.
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

//----------------------------------
// Looks up the enmy soul entry so it can be processed when the enemy dies.
// This applies to enemies of all difficulties that aren't enemy traps.
// These use the enemyType as the tag id
void TrySendEnemySoulCheck(kActor@ &in enemy)
{
	if (enemy is null ||
		((enemy.Flags() & (1 << 10)) == 0) || // easy
		((enemy.Flags() & (1 << 11)) == 0) || // normal
		((enemy.Flags() & (1 << 12)) == 0) || // hard
		((enemy.Flags() & (1 << 13)) == 0)) // hardcore
	{
		return;
	}
	
	// These checks use the inventory actor id as the tag so they can be looked up here
	TrySendAPActorLocationToAP(enemy.Type() + RANDO_INVENTORY_ITEM_OFFSET, kLevel_NonSpecific);
}

