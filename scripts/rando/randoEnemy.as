//----------------------------------
// A script for all enemies that can be randomized.
//----------------------------------
class RandoEnemy : ScriptActor
{
	// The original actor (that this one replaced; null if not replaced)
	kActor@ originalActor;
	
	// The action object entry this is associated with
	// If null, either enemysanity is off, or this isn't a check anymore
	ActionObjectEntry@ apEntry;
	
	// Whether this is the replaced actor (i.e. not the original)
	bool isReplacedActor;
	
	// Whether this is an actor that is never replaced in enemizer
	// Used by some Mites in level 5 and Sisters of Despair in level 2
	bool neverReplacedActor;
	
	// Whether the original actor wouldn't be visible
	// Used to show the replacement when necessary
	bool isNotYetShown;
	
	// Whether this was a spawn that we processed
	bool processedSpawn;
	
	// Whether the important indicator was shown
	// Used for performance reasons
	bool importantShown;

	//----------------------------------
	// Constructor
	// @actor: The actor that was loaded
    RandoEnemy(kActor @actor)
    {
		super(@actor);
		SetApEntry();
	}
	
	//----------------------------------
	// Sets a pointer to the original actor.
	// Marks this one as replaced.
	// Unsets the AP entry from the original actor so the kill/important marker can be properly handled.
	void SetOriginalActor(kActor@ actor)
	{
		@originalActor = actor;
		this.isReplacedActor = true;
		SetApEntry();
	}
	
	//----------------------------------
	// Sets whether this is a processed spawn
	void SetProcessedSpawn(const bool &in processedSpawn)
	{
		this.processedSpawn = processedSpawn;
		if (processedSpawn)
		{
			@apEntry = null;
		}
	}
	
	//----------------------------------
	// Sets whether the original actor wouldn't yet be visible to the player
	void SetIsNotYetShown(const bool &in isNotYetShown)
	{
		this.isNotYetShown = isNotYetShown;
		if (isNotYetShown)
		{
			self.Flags() |= AF_HIDDEN;
		}
	}
	
	//----------------------------------
	// Sets whether the actor is never replaced in enemizer
	// Also tries to set the ApEntry, because this would change whether this gets a value
	void SetNeverReplacedActor(const bool &in neverReplacedActor)
	{
		this.neverReplacedActor = neverReplacedActor;
		SetApEntry();
	}
	
	//----------------------------------
	// Looks up the AP entry so it can be processed when the enemy dies.
	// Sets to null if it's already checked or there is no entry.
	//
	// We'll only use AP entries for replacements when enemizer is in use so the important icon
	// is only placed on enemies that are visible.
	//
	// We'll also only use AP entries for enemies that are available for all difficulties.
	void SetApEntry()
	{
		@apEntry = null;
		if (!neverReplacedActor && ( // Always try to look up the entry if it's never replaced
				(OPTION_ENEMIZER != 0 && !isReplacedActor) ||  // Skip original enemizer enemies
				processedSpawn || // Already processed, so there'll be no entry
				
				// Only process enemies present in all difficulties
				((self.Flags() & (1 << 10)) == 0) || // easy
				((self.Flags() & (1 << 11)) == 0) || // normal
				((self.Flags() & (1 << 12)) == 0) || // hard
				((self.Flags() & (1 << 13)) == 0)) // hardcore
			)
		{
			return;
		}
		
		ActionObjectEntry@ actionObjectEntry;
		TryGetActionObjectEntryForCurrentMap(self.TID(), actionObjectEntry);
		if (actionObjectEntry !is null && !actionObjectEntry.isSentToAP && actionObjectEntry.apId > 0)
		{
			@apEntry = actionObjectEntry;
		}
	}
	
	//----------------------------------
	// Serializes the instance data
	void OnSerialize(kDict &out dict)
    {
		SERIALIZE(isReplacedActor);
		SERIALIZE(isNotYetShown);
		SERIALIZE(isNotYetShown);
		SERIALIZE(processedSpawn);
		SERIALIZE(neverReplacedActor);
		SERIALIZE(importantShown);
	}
	
	//----------------------------------
	// Deserializes the instance data.
	// Finds the AP entry.
	// Finds the original actor based on the tag ids.
	void OnDeserialize(kDict &in dict)
    {
		DESERIALIZE_BOOL(isReplacedActor);
		DESERIALIZE_BOOL(isNotYetShown);
		DESERIALIZE_BOOL(processedSpawn);
		DESERIALIZE_BOOL(neverReplacedActor);
		DESERIALIZE_BOOL(importantShown);
		SetApEntry();
		
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
		if (apEntry !is null)
		{		
			apEntry.SendCheckToAP();
			self.Flags() &= ~AF_IMPORTANT;
			@apEntry = null;
		}

		if (!isReplacedActor)
		{
			return;
		}
		
		// Don't kill the original actor if it's stale to avoid crashes
		if (originalActor !is null && !originalActor.IsStale())
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
		// If this enemy is a check, show the important indicator when it's visible
		if (g_markEnemies &&
			!importantShown &&
			apEntry !is null &&
			((self.Flags() & AF_HIDDEN) == 0))
		{
			self.Flags() |= AF_IMPORTANT;
			importantShown = true;
		}
		
		// Handles linked enemies
		if (apEntry !is null && apEntry.isSentToAP)
		{
			self.Flags() &= ~AF_IMPORTANT;
		}
	
		if (OPTION_ENEMIZER == 0)
		{
			return;
		}
		
		if (self.TID() <= 0)
		{
			// This is a processed enemy, so no need to replace them
			if (processedSpawn || isReplacedActor)
			{
				return;
			}
			
			// If we're not processing spawned enemies, don't replace them
			// Totems will be replaced based on the enemizer setting itself, so handle that separately
			int16 mapId = Game.ActiveMapID();
			if (OPTION_ENEMIZER_SPAWNERS == ENEMIZER_SPAWNER_NONE && 
				!IsTotemLevel(mapId))
			{
				processedSpawn = true;
				return;
			}
			
			processedSpawn = true;
			ReplaceEnemyActor(self, true);
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