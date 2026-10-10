//----------------------------------
// ScriptObject for traps.
//
// More trap ideas: 
// - ammo traps (self.ConsumeAmmo/ConsumeAltAmmo)
//----------------------------------
enum EnemyTrapType
{
	ENEMY_TRAP_SAME_LEVEL = 0,
	ENEMY_TRAP_SAME_LEVEL_INCLUDE_OBLIVION = 1,
	ENEMY_TRAP_SIMILAR_DIFFICULTY = 2,
	ENEMY_TRAP_SCALE_TO_WEAPONS = 3,
	ENEMY_TRAP_CHAOS = 4
}

class RandoTrap : RandoPickupObject
{
	int trapType;
	RandoTrap(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// Triggers the trap based on the type.
	void AfterReplacementTouched() override
	{
		TriggerTrap(trapType);
	}
}

//------------------------------
// Triggers the trap for the given actor id.
// If this isn't a trap actor, doesn't do anything.
// This will be the data that AP sends us.
bool TryTriggerTrap(const int &in actorId)
{
	int trapType;
	switch(actorId)
	{
		case kActor_Trap_Enemy_Silver_Health:
		case kActor_Trap_Enemy_Blue_Health:
		case kActor_Trap_Enemy_Full_Health:
		case kActor_Trap_Enemy_Ultra_Health:
			trapType = RANDO_TRAP_TYPE_ENEMY;
			break;
		case kActor_Trap_Damage_Silver_Health:
		case kActor_Trap_Damage_Blue_Health:
		case kActor_Trap_Damage_Full_Health:
		case kActor_Trap_Damage_Ultra_Health:
			trapType = RANDO_TRAP_TYPE_DAMAGE;
			break;
		case kActor_Trap_Spam_Silver_Health:
		case kActor_Trap_Spam_Blue_Health:
		case kActor_Trap_Spam_Full_Health:
		case kActor_Trap_Spam_Ultra_Health:
			trapType = RANDO_TRAP_TYPE_SPAM;
			break;
		default:
			return false;
	}
	
	TriggerTrap(trapType);
	return true;
}

//------------------------------
// Triggers the trap, given the trap type.
void TriggerTrap(const int &in trapType)
{
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
}

//------------------------------
// Spawns a set of 1-3 random enemies near the player.
void HandleEnemyTrap()
{
	Hud.AddMessage("It's a trap!");
	int numberToSpawn = RandomInt(1, 3);
	
	for (int i = 0; i < numberToSpawn; i++)
	{
		SpawnActorNearPlayer(GenerateRandomEnemyForEnemyTrap());
	}
}

//------------------------------
// Damages the player by 10% of their current health, rounded up.
void HandleDamageTrap()
{
	Hud.AddMessage("Ow!");
	
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