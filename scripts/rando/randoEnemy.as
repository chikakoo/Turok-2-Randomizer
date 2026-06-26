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
		
		if ((OPTION_ENEMIZER != 0 && !isReplacedActor) || 
			processedSpawn ||
			((self.Flags() & (1 << 10)) == 0) || // easy
			((self.Flags() & (1 << 11)) == 0) || // normal
			((self.Flags() & (1 << 12)) == 0) || // hard
			((self.Flags() & (1 << 13)) == 0)) // hardcore
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
		// TODO: delete me
		if (self.TID() > 0 && apEntry is null)
		{
			Sys.Print("" + Game.ActiveMapID() + "_" + self.TID());
			Hud.AddMessage("" + Game.ActiveMapID() + "_" + self.TID());
			
			if (((self.Flags() & (1 << 10)) == 0) || // easy
				((self.Flags() & (1 << 11)) == 0) || // normal
				((self.Flags() & (1 << 12)) == 0) || // hard
				((self.Flags() & (1 << 13)) == 0)) // hardcore
			{
				Sys.Print("NOT AVAILABLE IN ALL DIFFICULTIES!!!!!");
				Hud.AddMessage("NOT AVAILABLE IN ALL DIFFICULTIES!!!!!");
			}
			
			self.Flags() &= ~AF_IMPORTANT;
		}
		else {
			Hud.AddMessage("" + self.TID());
		}
		
		if (apEntry !is null)
		{		
			// TODO: Keep this, delete the above
			TrySendActionObjectToAP(self.TID());
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
	
	//TODO: remove this
	bool m_checkedForAPMap;
	
	//----------------------------------
	// Handle visiblity every tick for replacement actors
	// - If the original wouldn't be visible, check if that changed, and if so,
	//   hide it and show the replacement
	// - Else, set the original to hidden if it's ever shown for some reason
	void OnTick(void)
	{
		// TODO: remove this (only enable when testing if a spawn was missed)
		if (!m_checkedForAPMap && self.TID() > 0 && apEntry is null)
		{
			if (((self.Flags() & (1 << 10)) == 0) || // easy
				((self.Flags() & (1 << 11)) == 0) || // normal
				((self.Flags() & (1 << 12)) == 0) || // hard
				((self.Flags() & (1 << 13)) == 0)) // hardcore
			{
			}
			else {
				Hud.AddMessage("MISSING ENEMY: " + self.TID() + " " + self.Type());
				Sys.Print("MISSING ENEMY: " + self.TID() + " " + self.Type());
				self.Flags() |= AF_IMPORTANT;
				importantShown = true;
			}
		}
		m_checkedForAPMap = true;
		
		// If this enemy is a check, show the important indicator when it's visible
		if (
			self.TID() > 0 && //TODO; delete this line
			//g_markEnemies && // TODO: re-enable this line
			!importantShown &&
			//apEntry !is null && // TODO: re-enable this line
			((self.Flags() & AF_HIDDEN) == 0))
		{
			//self.Flags() |= AF_IMPORTANT; //TODO: reenable this
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