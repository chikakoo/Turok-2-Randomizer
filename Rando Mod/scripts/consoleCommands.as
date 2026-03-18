// --------------------------
// Functions to spawn things for the palayer.
// You can call the ones without args from the console with "call <func name>".
// --------------------------

// --------------------------
// Life force tiles
void LifeForce1(void)
{
	SpawnActorOnPlayer(kActor_Item_LifeForce1);
}

void LifeForce10(void)
{
	SpawnActorOnPlayer(kActor_Item_LifeForce10);
}

// --------------------------
// Health pickups, including one to set it to 1, for testing.
void Health2()
{
	TryGivePlayerHealth(kActor_Item_Health2);
}

void Health10()
{
	TryGivePlayerHealth(kActor_Item_Health10);
}

void FullHealth()
{
	TryGivePlayerHealth(kActor_Item_HealthFull);
}

void UltraHealth()
{
	TryGivePlayerHealth(kActor_Item_HealthUltra);
}

void LowHealth()
{
	LocalPlayer.Actor().CastToActor().Health() = 1;
}

// --------------------------
// Level-specific items
void BeaconPowerCell(void)
{
	TryGetInventoryItem(kActor_MissionItem_BeaconPowerCell);
}

// --------------------------
// Level keys
void Level2Key(void)
{
	TryGetInventoryItem(kActor_InventoryItem_Level2Key);
}

void Level3Key(void)
{
	TryGetInventoryItem(kActor_InventoryItem_Level3Key);
}

void Level4Key(void)
{
	TryGetInventoryItem(kActor_InventoryItem_Level4Key);
}

void Level5Key(void)
{
	TryGetInventoryItem(kActor_InventoryItem_Level5Key);
}

void Level6Key(void)
{
	TryGetInventoryItem(kActor_InventoryItem_Level6Key);
}

//---------------------------
// Primagen Keys
void PrimagenKey1(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_1);
}

void PrimagenKey2(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_2);
}

void PrimagenKey3(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_3);
}

void PrimagenKey4(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_4);
}

void PrimagenKey5(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_5);
}

void PrimagenKey6(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_6);
}

//---------------------------
// Nuke parts
void NukePart(void)
{
	GetNukePart();
}

//---------------------------
// Eagle feathers
void Feather2(void)
{
	TryGetInventoryItem(kActor_Feather_2);
}

void Feather3(void)
{
	TryGetInventoryItem(kActor_Feather_3);
}

void Feather4(void)
{
	TryGetInventoryItem(kActor_Feather_4);
}

void Feather5(void)
{
	TryGetInventoryItem(kActor_Feather_5);
}

void Feather6(void)
{
	TryGetInventoryItem(kActor_Feather_6);
}

//---------------------------
// Talismans
void LeapOfFaith(void)
{
	TryGetInventoryItem(kActor_Talisman_LeapOfFaith);
}

void BreathOfLife(void)
{
	TryGetInventoryItem(kActor_Talisman_BreathOfLife);
}

void HeartOfFire(void)
{
	TryGetInventoryItem(kActor_Talisman_HeartOfFire);
}

void Whispers(void)
{
	TryGetInventoryItem(kActor_Talisman_Whispers);
}

void EyeOfTruth(void)
{
	TryGetInventoryItem(kActor_Talisman_EyeOfTruth);
}

//---------------------------
// Weapons
void Pistol()
{
	TryGivePlayerWeapon(kActor_Item_WpnPistol);
}

void Shotgun()
{
	TryGivePlayerWeapon(kActor_Item_WpnShotgun);
}

void Shredder()
{
	TryGivePlayerWeapon(kActor_Item_WpnScatter);
}