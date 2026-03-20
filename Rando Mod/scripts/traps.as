//------------------------------
// Contains trap-related functions.
//
// More trap ideas: 
// - ammo traps (self.ConsumeAmmo/ConsumeAltAmmo)
//------------------------------

//------------------------------
// Triggers the trap for the given actor id.
// If this isn't a trap actor, doesn't do anything.
// This will be the data that AP sends us.
bool TryTriggerTrap(const int &in trapId)
{
	kDictMem@ actorDef = g_indexDefManager.GetEntry(trapId);
	if (actorDef is null)
	{
		return false ;
	}
	
	int trapType;
	if (!actorDef.GetInt("rando.trapType", trapType))
	{
		return false;
	}
	
	switch(trapType)
	{
		case RANDO_TRAP_TYPE_ENEMY:
			HandleEnemyTrap();
			break;
		case RANDO_TRAP_TYPE_DAMAGE:
			HandleDamageTrap();
			break;
		case RANDO_TRAP_TYPE_SPAM:
			HandleSpamTrap();
			break;
	}
	
	return true;
}

//------------------------------
// Spawns a set of 1-3 random enemies near the player.
void HandleEnemyTrap()
{
	Hud.AddMessage("It's a trap!");

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

//------------------------------
// Damages the player by 10% of their current health, rounded up.
void HandleDamageTrap()
{
	Hud.AddMessage("It's a trap!");
	
	kActor@ player = LocalPlayer.Actor().CastToActor();
	float currentHealth = player.Health();
	
	kDamageInfo damageInfo;
	damageInfo.hits = Math::Max(currentHealth * 0.1, 1);
	damageInfo.flags = DF_NORMAL;
	
	if (currentHealth - damageInfo.hits <= 0)
	{
		// Don't kill the player, but do call InflictDamage for the hurt sound effect
		damageInfo.hits = 0;
	}
	
	player.InflictDamage(damageInfo);
}

//------------------------------
// Hello, would you like to order a description? Only $9.95!
void HandleSpamTrap()
{
	Hud.AddMessage("ORDER NOW WHILE SUPPLIES LAST! DON'T WAIT!", 600);
	Hud.AddMessage("hi turok i am a big fan pls frend me on fb plzzzz", 600);
	Hud.AddMessage("!!!!! Click here for a bigger Shredder !!!!!", 600);
	Hud.AddMessage("Hello? I'd like to order a pizza. Extra spicy.", 600);
	Hud.AddMessage("hi send me money and i will definitely send you more", 600);
	Hud.AddMessage("hi, asl?", 600);
	Hud.AddMessage("The Primagen is just a figment of our society, maaaan", 600);
	Hud.AddMessage("Received Nuke!                        jk", 600);
	Hud.AddMessage("SPAMSPAMSPAMSPAMSPAMSPAMSPAMSPAMSPAMSPAMSPAMSPAM", 600);
	Hud.AddMessage("1 2 3 4 5 6 7 8 9 whatcomesnextiforgot", 600);
}