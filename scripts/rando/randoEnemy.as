//----------------------------------
// A script for all enemies that can be randomized.
//----------------------------------
class RandoEnemy : ScriptActor
{
	// The original actor (that this one replaced; null if not replaced)
	kActor@ originalActor;
	
	// Whether this is the replaced actor (i.e. not the original)
	bool isReplacedActor;
	
	// Whether the original actor wouldn't be visible
	// Used to show the replacement when necessary
	bool isNotYetShown;
	
	// Whether this was a spawn that we processed
	bool processedSpawn;

	//----------------------------------
	// Constructor
	// @actor: The actor that was loaded
    RandoEnemy(kActor @actor)
    {
		super(@actor);
	}
	
	//----------------------------------
	// Sets whether this is the replaced actor
	void SetIsReplacedActor(bool &in isReplacedActor)
	{
		this.isReplacedActor = isReplacedActor;
	}
	
	//----------------------------------
	// Sets a pointer to the original actor
	void SetOriginalActor(kActor@ actor)
	{
		@originalActor = actor;
	}
	
	//----------------------------------
	// Sets whether the original actor wouldn't yet be visible to the player
	void SetIsNotYetShown(bool &in isNotYetShown)
	{
		this.isNotYetShown = isNotYetShown;
		if (isNotYetShown)
		{
			self.Flags() |= AF_HIDDEN;
		}
	}
	
	//----------------------------------
	// Serializes the instance data
	void OnSerialize(kDict &out dict)
    {
		SERIALIZE(isReplacedActor);
		SERIALIZE(isNotYetShown);
		SERIALIZE(processedSpawn);
	}
	
	//----------------------------------
	// Deserializes the instance data
	// Also finds the original actor based on the tag ids
	void OnDeserialize(kDict &in dict)
    {
		DESERIALIZE_BOOL(isReplacedActor);
		DESERIALIZE_BOOL(isNotYetShown);
		DESERIALIZE_BOOL(processedSpawn);
		
		if (!isReplacedActor)
		{
			return;
		}
		
		kActorIterator actorIterator;
		kActor@ actor;
		while((@actor = actorIterator.GetNext()) !is null)
		{
			if (actor.TID() == self.TID() &&
				actor.EnemyAIComponent() !is null)
			{
				RandoEnemy@ enemyScript = cast<RandoEnemy@>(GetScript(actor));
				if (enemyScript !is null && !enemyScript.isReplacedActor)
				{
					@originalActor = actor;
					return;
				}
			}
		}
	}
	
	//----------------------------------
	// When the replacement dies, kill the original actor to trigger any events
	// Simply setting Health to 0 does not work
	void OnDeath(kDamageInfo& in dmgInfo)
	{
		if (!isReplacedActor)
		{
			return;
		}
	
		if (originalActor !is null)
		{
			kDamageInfo damageInfo;
			damageInfo.hits = originalActor.Health() * 10.0f;
			@damageInfo.source = LocalPlayer.Actor().CastToActor();
			originalActor.InflictDamage(damageInfo);
		}
	}
	
	//----------------------------------
	// Handle visiblity every tick for replacement actors
	// - If the original wouldn't be visible, check if that changed, and if so,
	//   hide it and show the replacement
	// - Else, set the original to hidden if it's ever shown for some reason
	void OnTick(void)
	{
		if (OPTION_ENEMIZER == 0)
		{
			return;
		}
		
		if (self.TID() <= 0)
		{
			// This is a spawned enemy, which we can just ignore here as
			// they'll never trigger anything
			if (!OPTION_ENEMIZER_SPAWNERS || processedSpawn || isReplacedActor)
			{
				return;
			}
			
			processedSpawn = true;
			ReplaceEnemyActor(self);
			self.Flags() |= AF_HIDDEN;
			return;
		}
		
		if (!isReplacedActor || originalActor is null)
		{
			return;
		}
		
		bool isOriginalVisible = (originalActor.Flags() & AF_HIDDEN) == 0;
		if (isNotYetShown)
		{
			if (isOriginalVisible)
			{
				isNotYetShown = false;
				originalActor.Flags() |= AF_HIDDEN;
				self.Flags() &= ~AF_HIDDEN;
			}
		}
		else if (isOriginalVisible)
		{
			originalActor.Flags() |= AF_HIDDEN;
		}
	}
}