// --------------------------
// Functions to spawn things for the palayer.
// You can call the ones without args from the console with "call <func name>".
// --------------------------

// --------------------------
// Lists all the debug commands
void Help(void)
{
	Sys.Print("Debug commands - invoke them by doing \"call EnterCommandHere\"");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Archipelago");
	Sys.Print("-----------------");
	Sys.Print("PrintAPMemory (the memory block the client communicates with)");
	Sys.Print("Resync (every check you've done at ~10 per second, so it will take time)");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Life Forces");
	Sys.Print("-----------------");
	Sys.Print("LifeForce1");
	Sys.Print("LifeForce10");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Health Pickups");
	Sys.Print("-----------------");
	Sys.Print("Health2");
	Sys.Print("Health10");
	Sys.Print("FullHealth");
	Sys.Print("UltraHealth");
	Sys.Print("LowHealth (sets health to 1)");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Level Keys");
	Sys.Print("-----------------");
	Sys.Print("Level2Key");
	Sys.Print("Level3Key");
	Sys.Print("Level4Key");
	Sys.Print("Level5Key");
	Sys.Print("Level6Key");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Primagen Keys");
	Sys.Print("-----------------");
	Sys.Print("PrimagenKey1");
	Sys.Print("PrimagenKey2");
	Sys.Print("PrimagenKey3");
	Sys.Print("PrimagenKey4");
	Sys.Print("PrimagenKey5");
	Sys.Print("PrimagenKey6");
	Sys.Print("AllPrimagenKeys");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Nuke Parts");
	Sys.Print("-----------------");
	Sys.Print("NukePart");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Eagle Feathers");
	Sys.Print("-----------------");
	Sys.Print("Feather2");
	Sys.Print("Feather3");
	Sys.Print("Feather4");
	Sys.Print("Feather5");
	Sys.Print("Feather6");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Talismans");
	Sys.Print("-----------------");
	Sys.Print("LeapOfFaith");
	Sys.Print("BreathOfLife");
	Sys.Print("HeartOfFire");
	Sys.Print("Whispers");
	Sys.Print("EyeOfTruth");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Mission Items");
	Sys.Print("-----------------");
	Sys.Print("BeaconPowerCell");
	Sys.Print("GateKey");
	Sys.Print("GraveyardKey");
	Sys.Print("L3SatchelCharge");
	Sys.Print("CaveDoorKey");
	Sys.Print("L4SatchelCharge");
	Sys.Print("L5SatchelCharge");
	Sys.Print("IonCapacitor");
	Sys.Print("BlueLaserCell");
	Sys.Print("RedLaserCell");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Weapons");
	Sys.Print("-----------------");
	Sys.Print("WarBlade");
	Sys.Print("Bow");
	Sys.Print("TekBow");
	Sys.Print("Pistol");
	Sys.Print("Mag60");
	Sys.Print("Tranquilizer");
	Sys.Print("ChargeDartRifle");
	Sys.Print("Shotgun");
	Sys.Print("Shredder");
	Sys.Print("PlasmaRifle");
	Sys.Print("FirestormCannon");
	Sys.Print("SunfirePod");
	Sys.Print("CerebralBore");
	Sys.Print("PFMLayer");
	Sys.Print("GrenadeLauncher");
	Sys.Print("ScorpionLauncher");
	Sys.Print("HarpoonGun");
	Sys.Print("TorpedoLauncher");
	Sys.Print("FlameThrower");
	Sys.Print("RazorWind");
	Sys.Print("Nuke");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Ammo");
	Sys.Print("-----------------");
	Sys.Print("GetAmmoInRandomWeapon");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("Traps");
	Sys.Print("-----------------");
	Sys.Print("HandleEnemyTrap");
	Sys.Print("HandleDamageTrap");
	Sys.Print("HandleSpamTrap");
	Sys.Print("");
	Sys.Print("-----------------");
	Sys.Print("AP Specific Items");
	Sys.Print("ProgressiveWarpL1");
	Sys.Print("ProgressiveWarpL2");
	Sys.Print("ProgressiveWarpL3");
	Sys.Print("ProgressiveWarpL4");
	Sys.Print("ProgressiveWarpL5");
	Sys.Print("ProgressiveWarpL6");
}

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
void Health2(void)
{
	TryGivePlayerHealth(kActor_Item_Health2);
}

void Health10(void)
{
	TryGivePlayerHealth(kActor_Item_Health10);
}

void FullHealth(void)
{
	TryGivePlayerHealth(kActor_Item_HealthFull);
}

void UltraHealth(void)
{
	TryGivePlayerHealth(kActor_Item_HealthUltra);
}

void LowHealth(void)
{
	LocalPlayer.Actor().CastToActor().Health() = 1;
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

void AllPrimagenKeys(void)
{
	TryGetInventoryItem(kActor_PrimagenKey_1);
	TryGetInventoryItem(kActor_PrimagenKey_2);
	TryGetInventoryItem(kActor_PrimagenKey_3);
	TryGetInventoryItem(kActor_PrimagenKey_4);
	TryGetInventoryItem(kActor_PrimagenKey_5);
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
void WarBlade(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnWarBlade);
}

void Bow(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnBow);
}

void TekBow(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnTekBow);
}

void Pistol(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnPistol);
}

void Mag60(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnMag60);
}

void Tranquilizer(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnTranq);
}

void ChargeDartRifle(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnChargeDart);
}

void Shotgun(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnShotgun);
}

void Shredder(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnScatter);
}

void PlasmaRifle(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnPlasmaRifle);
}

void FirestormCannon(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnFireStorm);
}

void SunfirePod(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnSunfirePod);
}

void CerebralBore(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnCerebralBore);
}

void PFMLayer(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnPFMLayer);
}

void GrenadeLauncher(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnGrenadeLauncher);
}

void ScorpionLauncher(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnMissileLauncher);
}

void HarpoonGun(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnSpearGun);
}

void TorpedoLauncher(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnTorpedoLauncher);
}

void FlameThrower(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnFlameThrower);
}

void RazorWind(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnRazorWind);
}

void Nuke(void)
{
	TryGivePlayerWeapon(kActor_Item_WpnNuke);
}

//---------------------------
// Mission Items
void BeaconPowerCell(void)
{
	TryGetInventoryItem(kActor_MissionItem_BeaconPowerCell);
}

void GateKey(void)
{
	TryGetInventoryItem(kActor_MissionItem_GateKey);
}

void GraveyardKey(void)
{
	TryGetInventoryItem(kActor_MissionItem_GraveyardKey);
}

void L3SatchelCharge(void)
{
	TryGetInventoryItem(kActor_MissionItem_L3SatchelCharge);
}

void CaveDoorKey(void)
{
	TryGetInventoryItem(kActor_MissionItem_CaveDoorKey);
}

void L4SatchelCharge(void)
{
	TryGetInventoryItem(kActor_MissionItem_L4SatchelCharge);
}

void L5SatchelCharge(void)
{
	TryGetInventoryItem(kActor_MissionItem_L5SatchelCharge);
}

void IonCapacitor(void)
{
	TryGetInventoryItem(kActor_MissionItem_IonCapacitor);
}

void BlueLaserCell(void)
{
	TryGetInventoryItem(kActor_MissionItem_BlueLaserCell);
}

void RedLaserCell(void)
{
	TryGetInventoryItem(kActor_MissionItem_RedLaserCell);
}

//---------------------------
// AP Items
void ProgressiveWarpL1(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL1);
}

void ProgressiveWarpL2(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL2);
}

void ProgressiveWarpL3(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL3);
}

void ProgressiveWarpL4(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL4);
}

void ProgressiveWarpL5(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL5);
}

void ProgressiveWarpL6(void)
{
	TryGetInventoryItem(kActor_InventoryItem_ProgressiveWarpL6);
}

void PrintPlayerPosition(void)
{
	kVec3 origin = LocalPlayer.Actor().Origin();
	Sys.Print("" + origin.x + "," + origin.y + "," + origin.z);
	Sys.Print("REGION: " + LocalPlayer.Actor().WorldComponent().RegionIndex());
}