//------------------------------
// Contains trap-related functions.

// Trap ideas: 
// - more enemy spawns (or just have it be a random one)
// - ammo traps (self.ConsumeAmmo/ConsumeAltAmmo)
// - player damage traps (self.InflictDamage(kDamageInfo))
//
// Damage trap idea
//kDamageInfo damageInfo;
//damageInfo.hits = 10;
//damageInfo.flags = DF_NORMAL;
//LocalPlayer.Actor().CastToActor().InflictDamage(damageInfo);
//------------------------------

//------------------------------
// Triggers the trap for the given actor id.
// If this isn't a trap actor, doesn't do anything.
// This will be the data that AP sends us.
void TryTriggerTrap(const int &in trapId)
{
	switch(trapId)
	{
		case kActor_Trap_Enemy:
			Hud.AddMessage("It's a trap!");
			HandleEnemyTrap();
			
	}
}

void HandleEnemyTrap()
{
	array<int> possibleEnemies = {
		kActor_AI_Raptoid,
		kActor_AI_Endtrail,
		kActor_AI_Raptor,
		kActor_AI_SwampWasp,
		kActor_AI_CaveWorm,
		kActor_AI_Grub,
		kActor_AI_Drone,
		kActor_AI_Leaper
	};
	
	int selectedActor = RandomInt(possibleEnemies);
	int numberToSpawn = RandomInt(1, 3);
	for (int i = 0; i < numberToSpawn; i++)
	{
		SpawnActorNearPlayer(selectedActor);
	}
}