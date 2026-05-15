//----------------------------------
// Functions to generate random enemies for the enemizer.
//----------------------------------
enum EnemizerType
{
	ENEMIZER_NONE = 0,
	ENEMIZER_SAME_LEVEL = 1,
	ENEMIZER_SAME_LEVEL_INCLUDE_OBLIVION = 2,
	ENEMIZER_SIMILAR_DIFFICULTY = 3,
	ENEMIZER_SCALE_TO_WEAPONS = 4,
	ENEMIZER_CHAOS = 5
}

enum EnemizerSpawnerType
{
	ENEMIZER_SPAWNER_NONE = 0,
	ENEMIZER_SPAWNER_USE_ENEMIZER_VALUE = 1,
	ENEMIZER_SPAWNER_EASY_ONLY = 2
}

class EnemyWeight
{
    int actor;
    int weight;
	
	EnemyWeight() { }
	EnemyWeight(int actorId, int enemyWeight)
    {
        actor = actorId;
        weight = enemyWeight;
    }
}

array<EnemyWeight> g_enemiesLevel1 = {
    EnemyWeight(kActor_AI_Raptoid, 100),
    EnemyWeight(kActor_AI_Endtrail, 100),
    EnemyWeight(kActor_AI_Compy, 35),
    EnemyWeight(kActor_AI_Raptor, 100)
};

array<EnemyWeight> g_enemiesLevel2 = {
    EnemyWeight(kActor_AI_Raptoid, 100),
    EnemyWeight(kActor_AI_Endtrail, 100),
    EnemyWeight(kActor_AI_Compy, 35),
    EnemyWeight(kActor_AI_Raptor, 100),
	
	EnemyWeight(kActor_AI_SpiderHatchling, 35),
	EnemyWeight(kActor_AI_Leaper, 100),
	EnemyWeight(kActor_AI_Deadman, 80),
	EnemyWeight(kActor_AI_LordOfTheDead, 70),
	EnemyWeight(kActor_AI_SisterOfDespair, 100)
};

array<EnemyWeight> g_enemiesLevel3 = {
	EnemyWeight(kActor_AI_Raptoid, 60),
	EnemyWeight(kActor_AI_Endtrail, 60),
	EnemyWeight(kActor_AI_Raptor, 60),
	EnemyWeight(kActor_AI_Leaper, 50),
	
	EnemyWeight(kActor_AI_WarClub, 100),
	EnemyWeight(kActor_AI_Gunner, 100),
	EnemyWeight(kActor_AI_Juggernaut, 90),
	EnemyWeight(kActor_AI_CaveWorm, 50),
	EnemyWeight(kActor_AI_SwampWasp, 35)
};

array<EnemyWeight> g_enemiesLevel4 = {
	EnemyWeight(kActor_AI_Raptoid, 60),
	EnemyWeight(kActor_AI_Endtrail, 60),
	EnemyWeight(kActor_AI_Leaper, 60),

	EnemyWeight(kActor_AI_Guardian, 100),
	EnemyWeight(kActor_AI_Sentinel, 100),
	EnemyWeight(kActor_AI_SpiderHatchling, 35),
	EnemyWeight(kActor_AI_CaveSpider, 80),
	EnemyWeight(kActor_AI_Nala, 100),
	EnemyWeight(kActor_AI_Fireborn, 100),
	EnemyWeight(kActor_AI_FleshWorm, 35)
};

array<EnemyWeight> g_enemiesLevel5 = {
	EnemyWeight(kActor_AI_Mite, 35),
	EnemyWeight(kActor_AI_Worker, 35),
	EnemyWeight(kActor_AI_Drone, 100),
	EnemyWeight(kActor_AI_Soldier, 50)
};

array<EnemyWeight> g_enemiesLevel6 = {
	EnemyWeight(kActor_AI_Trooper, 80),
	EnemyWeight(kActor_AI_BioBot, 100),
	EnemyWeight(kActor_AI_EliteGuard, 20)
};

array<EnemyWeight> g_oblivionEnemyPool = {
	EnemyWeight(kActor_AI_FleshSentinel, 100),
	EnemyWeight(kActor_AI_DeathGuard, 100),
	EnemyWeight(kActor_AI_LordOfTheFlesh, 50)
};

array<EnemyWeight> g_enemiesSimiliarLevel1 = {
	EnemyWeight(kActor_AI_Raptoid, 100),
	EnemyWeight(kActor_AI_Endtrail, 100),
	EnemyWeight(kActor_AI_Compy, 25),
	EnemyWeight(kActor_AI_Raptor, 100),
	
	EnemyWeight(kActor_AI_SpiderHatchling, 25),
	EnemyWeight(kActor_AI_Leaper, 100),
	EnemyWeight(kActor_AI_Deadman, 80),
	
	EnemyWeight(kActor_AI_SwampWasp, 25),
	
	EnemyWeight(kActor_AI_Nala, 100),
	EnemyWeight(kActor_AI_Fireborn, 100),
	EnemyWeight(kActor_AI_FleshWorm, 25),
	EnemyWeight(kActor_AI_Grub, 25),
	
	EnemyWeight(kActor_AI_Mite, 25),
	EnemyWeight(kActor_AI_Worker, 25)
};

array<EnemyWeight> g_enemiesSimiliarLevel2 = {
	EnemyWeight(kActor_AI_Raptoid, 100),
	EnemyWeight(kActor_AI_Endtrail, 100),
	EnemyWeight(kActor_AI_Compy, 25),
	EnemyWeight(kActor_AI_Raptor, 100),
	
	EnemyWeight(kActor_AI_SpiderHatchling, 25),
	EnemyWeight(kActor_AI_Leaper, 100),
	EnemyWeight(kActor_AI_Deadman, 80),
	EnemyWeight(kActor_AI_LordOfTheDead, 70),
	EnemyWeight(kActor_AI_SisterOfDespair, 100),
	
	EnemyWeight(kActor_AI_WarClub, 100),
	EnemyWeight(kActor_AI_SwampWasp, 25),
	
	EnemyWeight(kActor_AI_Nala, 100),
	EnemyWeight(kActor_AI_Fireborn, 100),
	EnemyWeight(kActor_AI_FleshWorm, 25),
	EnemyWeight(kActor_AI_Grub, 25),
	
	EnemyWeight(kActor_AI_Mite, 25),
	EnemyWeight(kActor_AI_Worker, 25),
	
	EnemyWeight(kActor_AI_FleshSentinel, 100)
};

array<EnemyWeight> g_enemiesSimiliarLevel3 = {
	EnemyWeight(kActor_AI_Raptoid, 100),
	EnemyWeight(kActor_AI_Endtrail, 100),
	EnemyWeight(kActor_AI_Raptor, 100),
	
	EnemyWeight(kActor_AI_Leaper, 100),
	EnemyWeight(kActor_AI_Deadman, 80),
	EnemyWeight(kActor_AI_LordOfTheDead, 70),
	EnemyWeight(kActor_AI_SisterOfDespair, 100),
	
	EnemyWeight(kActor_AI_WarClub, 100),
	EnemyWeight(kActor_AI_Gunner, 100),
	EnemyWeight(kActor_AI_Juggernaut, 90),
	EnemyWeight(kActor_AI_CaveWorm, 50),
	EnemyWeight(kActor_AI_SwampWasp, 25),
	
	EnemyWeight(kActor_AI_Nala, 100),
	EnemyWeight(kActor_AI_Fireborn, 100),
	EnemyWeight(kActor_AI_FleshWorm, 25),
	EnemyWeight(kActor_AI_Grub, 25),
	
	EnemyWeight(kActor_AI_FleshSentinel, 100),
	EnemyWeight(kActor_AI_DeathGuard, 100)
};

array<EnemyWeight> g_enemiesSimiliarLevel4 = {
	EnemyWeight(kActor_AI_Raptoid, 100),
	EnemyWeight(kActor_AI_Endtrail, 100),
	EnemyWeight(kActor_AI_Leaper, 100),
	
	EnemyWeight(kActor_AI_WarClub, 100),
	EnemyWeight(kActor_AI_Gunner, 100),
	EnemyWeight(kActor_AI_Juggernaut, 90),
	EnemyWeight(kActor_AI_CaveWorm, 50),
	EnemyWeight(kActor_AI_SwampWasp, 25),
	
	EnemyWeight(kActor_AI_Guardian, 100),
	EnemyWeight(kActor_AI_Sentinel, 100),
	EnemyWeight(kActor_AI_SpiderHatchling, 25),
	EnemyWeight(kActor_AI_CaveSpider, 80),
	EnemyWeight(kActor_AI_Nala, 100),
	EnemyWeight(kActor_AI_Fireborn, 100),
	EnemyWeight(kActor_AI_FleshWorm, 25),
	
	EnemyWeight(kActor_AI_Mite, 25),
	EnemyWeight(kActor_AI_Worker, 25),
	EnemyWeight(kActor_AI_Drone, 80),
	
	EnemyWeight(kActor_AI_FleshSentinel, 100),
	EnemyWeight(kActor_AI_DeathGuard, 100)
};

array<EnemyWeight> g_enemiesSimiliarLevel5 = {
	EnemyWeight(kActor_AI_WarClub, 100),
	EnemyWeight(kActor_AI_Gunner, 100),
	EnemyWeight(kActor_AI_Juggernaut, 90),
	EnemyWeight(kActor_AI_SwampWasp, 25),
	
	EnemyWeight(kActor_AI_Guardian, 100),
	EnemyWeight(kActor_AI_Sentinel, 100),
	EnemyWeight(kActor_AI_CaveSpider, 80),
	
	EnemyWeight(kActor_AI_Mite, 25),
	EnemyWeight(kActor_AI_Worker, 25),
	EnemyWeight(kActor_AI_Drone, 100),
	EnemyWeight(kActor_AI_Soldier, 50),
	
	EnemyWeight(kActor_AI_BioBot, 100),
	
	EnemyWeight(kActor_AI_FleshSentinel, 100),
	EnemyWeight(kActor_AI_DeathGuard, 100),
	EnemyWeight(kActor_AI_LordOfTheFlesh, 35)
};

array<EnemyWeight> g_enemiesSimiliarLevel6 = {
	EnemyWeight(kActor_AI_Gunner, 100),
	EnemyWeight(kActor_AI_Juggernaut, 90),
	
	EnemyWeight(kActor_AI_Guardian, 100),
	EnemyWeight(kActor_AI_Sentinel, 100),
	EnemyWeight(kActor_AI_CaveSpider, 100),
	
	EnemyWeight(kActor_AI_Drone, 100),
	EnemyWeight(kActor_AI_Soldier, 50),
	
	EnemyWeight(kActor_AI_Trooper, 80),
	EnemyWeight(kActor_AI_BioBot, 100),
	EnemyWeight(kActor_AI_EliteGuard, 35),
	
	EnemyWeight(kActor_AI_FleshSentinel, 100),
	EnemyWeight(kActor_AI_DeathGuard, 100),
	EnemyWeight(kActor_AI_LordOfTheFlesh, 35)
};

array<int> g_allEnemies = {
	kActor_AI_Raptoid,
	kActor_AI_Endtrail,
	kActor_AI_Compy,
	kActor_AI_Raptor,
	
	kActor_AI_SpiderHatchling,
	kActor_AI_Leaper,
	kActor_AI_Deadman,
	kActor_AI_LordOfTheDead,
	kActor_AI_SisterOfDespair,
	
	kActor_AI_WarClub,
	kActor_AI_Gunner,
	kActor_AI_Juggernaut,
	kActor_AI_CaveWorm,
	kActor_AI_SwampWasp,
	
	kActor_AI_Guardian,
	kActor_AI_Sentinel,
	kActor_AI_CaveSpider,
	kActor_AI_Nala,
	kActor_AI_Fireborn,
	kActor_AI_FleshWorm,
	kActor_AI_Grub,
	
	kActor_AI_Mite,
	kActor_AI_Worker,
	kActor_AI_Drone,
	kActor_AI_Soldier,
	
	kActor_AI_Trooper,
	kActor_AI_BioBot,
	kActor_AI_EliteGuard,
	
	kActor_AI_FleshSentinel,
	kActor_AI_DeathGuard,
	kActor_AI_LordOfTheFlesh
};

array<int> g_easySpawnerEnemies = {
	kActor_AI_Compy,
	kActor_AI_SwampWasp,
	kActor_AI_FleshWorm,
	kActor_AI_Grub,
	kActor_AI_Mite,
	kActor_AI_Worker
};

//----------------------------------
// Generate a random enemy based on the enemizer setting.
int GenerateRandomEnemy(const bool &in isFromSpawner = false)
{
	if (isFromSpawner &&
		OPTION_ENEMIZER > 0 && 
		OPTION_ENEMIZER_SPAWNERS == ENEMIZER_SPAWNER_EASY_ONLY)
	{
		return RandomInt(g_easySpawnerEnemies);
	}

	switch (OPTION_ENEMIZER)
	{
		case ENEMIZER_NONE:
			Sys.Print("ERROR: Trying to generate enemy when enemizer is off!");
			return kActor_AI_Raptoid;
		case ENEMIZER_SAME_LEVEL:
			return GetEnemyForCurrentLevel(false);
		case ENEMIZER_SAME_LEVEL_INCLUDE_OBLIVION:
			return GetEnemyForCurrentLevel(true);
		case ENEMIZER_SIMILAR_DIFFICULTY:
			return GetSimilarEnemyForLevel(GetLevelNumberFromMapId(Game.ActiveMapID()));
		case ENEMIZER_SCALE_TO_WEAPONS:
			return GetEnemyScaledToWeapons();
		case ENEMIZER_CHAOS:
			return RandomInt(g_allEnemies);
	}
			
	Sys.Print("ERROR: Unknown enemizer setting: " + OPTION_ENEMIZER);
	return kActor_AI_Raptoid;
}

//----------------------------------
// Gets an enemy belonging the current level.
// Will include oblivion enemies if the flag is passed.
int GetEnemyForCurrentLevel(const bool &in includeOblivion)
{
	int16 mapId = Game.ActiveMapID();
	if (IsOblivionMap(mapId))
	{
		return PickWeightedEnemy(g_oblivionEnemyPool);
	}
	
	array<EnemyWeight> enemyPool;
	if (includeOblivion)
	{
		enemyPool = g_oblivionEnemyPool;
	}
	
	switch(GetLevelNumberFromMapId(mapId))
	{
		case LEVEL_PORT_OF_ADIA:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel1);
			break;
		case LEVEL_RIVER_OF_SOULS:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel2);
			break;
		case LEVEL_DEATH_MARSHES:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel3);
			break;
		case LEVEL_LAIR_OF_THE_BLIND_ONES:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel4);
			break;
		case LEVEL_HIVE_OF_THE_MANTIDS:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel5);
			break;
		case LEVEL_PRIMAGENS_LIGHTSHIP:
			enemyPool.insertAt(enemyPool.length(), g_enemiesLevel6);
			break;
	}
	
	if (enemyPool.length() == 0)
	{
		Sys.Print("ERROR: No valid enemies for level!");
		return kActor_AI_Raptoid;
	}
	
	return PickWeightedEnemy(enemyPool);
}

//----------------------------------
// Gets a similar enemy in difficulty for the given level
int GetSimilarEnemyForLevel(const int16 &in level)
{
	array<EnemyWeight> enemyPool;
	switch(level)
	{
		case LEVEL_PORT_OF_ADIA:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel1);
			break;
		case LEVEL_RIVER_OF_SOULS:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel2);
			break;
		case LEVEL_DEATH_MARSHES:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel3);
			break;
		case LEVEL_LAIR_OF_THE_BLIND_ONES:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel4);
			break;
		case LEVEL_HIVE_OF_THE_MANTIDS:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel5);
			break;
		case LEVEL_PRIMAGENS_LIGHTSHIP:
			enemyPool.insertAt(enemyPool.length(), g_enemiesSimiliarLevel6);
			break;
	}
	
	if (enemyPool.length() == 0)
	{
		Sys.Print("ERROR: No valid similar enemies for level!");
		return kActor_AI_Raptoid;
	}
	
	return PickWeightedEnemy(enemyPool);
}

//----------------------------------
// Gets an enemy scaled to the current weapons the player owns.
// This uses GetSimilarEnemyForLevel, passing the level in based on weapon count.
//
// Scaling currently based on unique weapons -
// Level 1: 0-2
// Level 2: 3-4
// Level 3: 5-7
// Level 4: 8-10
// Level 5: 11-13
// Level 6: 14+
int GetEnemyScaledToWeapons()
{
	int16 levelToScaleTo;
	if (g_numberOfOwnedProgressionWeapons < 3)
	{
		levelToScaleTo = LEVEL_PORT_OF_ADIA;
	}
	else if (g_numberOfOwnedProgressionWeapons < 5)
	{
		levelToScaleTo = LEVEL_RIVER_OF_SOULS;
	}
	else if (g_numberOfOwnedProgressionWeapons < 8)
	{
		levelToScaleTo = LEVEL_DEATH_MARSHES;
	}
	else if (g_numberOfOwnedProgressionWeapons < 11)
	{
		levelToScaleTo = LEVEL_LAIR_OF_THE_BLIND_ONES;
	}
	else if (g_numberOfOwnedProgressionWeapons < 14)
	{
		levelToScaleTo = LEVEL_HIVE_OF_THE_MANTIDS;
	}
	else
	{
		levelToScaleTo = LEVEL_PRIMAGENS_LIGHTSHIP;
	}
	
	return GetSimilarEnemyForLevel(levelToScaleTo);
}

//----------------------------------
// Picks an enemy from the list of EnemyWeights
int PickWeightedEnemy(array<EnemyWeight>@ enemies)
{
	// Compute the total weight
    int totalWeight = 0;
    for (uint i = 0; i < enemies.length(); i++)
    {
        totalWeight += enemies[i].weight;
    }
	
	if (totalWeight <= 0 || enemies.length() == 0)
	{
		Sys.Print("ERROR: Invalid enemy pool!");
		return kActor_AI_Raptoid;
	}

	// Roll a value and get the selection
    int roll = RandomInt(0, totalWeight - 1);
    for (uint i = 0; i < enemies.length(); i++)
    {
        if (roll < enemies[i].weight)
        {
            return enemies[i].actor;
        }
        roll -= enemies[i].weight;
    }

	// Fallback
	Sys.Print("ERROR: Did not roll any enemy!");
    return kActor_AI_Raptoid;
}