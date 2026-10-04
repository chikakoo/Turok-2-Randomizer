// --------------------------
// Functions dealing with giving weapons and ammo.
//---------------------------

//---------------------------
// Given the actor id, simulates the player picking up a weapon.
// They are given the ammo amount even if they own the weapon.
// Also handles tracking the ammo upgrades for weapons.
bool TryGivePlayerWeapon(
	int &in actorId, 
	int &in ammoAmount = 1000,
	bool &in skipNotifications = false,
	bool &in isAmmoOnly = false,
	kStr &in ammoMessage = "")
{
	WeaponInfo@ weaponInfo = GetWeaponInfo(actorId);
	if (weaponInfo is null)
	{	
		Sys.Print("Tried to give player undefined weapon: " + actorId);
		return false;
	}
	
	bool ownsWeapon = LocalPlayer.HasWeapon(weaponInfo.weaponDef);
	LocalPlayer.GiveWeapon(weaponInfo.weaponDef, ammoAmount);
	if (!ownsWeapon)
	{
		ComputeNumberOfOwnedProgressionWeapons();
	}

	bool hasAllAmmoUpgrades = true;
	if (!isAmmoOnly)
	{
		int unobtainedUpgrades = OPTION_PROGRESSIVE_AMMO_COUNT - GetInventoryItemCollectedTotal(actorId);
		if (unobtainedUpgrades > 0)
		{
			hasAllAmmoUpgrades = false;
			HandleTrackInventoryItems(actorId);
		}
	}
	else
	{
		PlayPickupNotification(weaponInfo.pickupSound, ammoMessage);
		return true;
	}
	
	if (skipNotifications)
	{
		return true;
	}
	
	if (ownsWeapon && hasAllAmmoUpgrades)
	{
		PlayPickupNotificationSoundAndMessage(weaponInfo);
	}
	else
	{
		PlayPickupNotification(weaponInfo);
	}

	return true;
}

//---------------------------
// Gives the player 20-75% of the max ammo of a random weapon they have.
// - 40% chance of choosing a weapon with no ammo (if any)
// - 35% chance of choosing a weapon that's missing ammo (if any)
// - Else, rolls any owned weapon
void GetAmmoInRandomWeapon()
{
	// Compute the weapon buckets based on how much ammo is missing
	array<WeaponInfo@> ownedWeapons;
	array<WeaponInfo@> ownedWeaponsMissingAmmo;
	array<WeaponInfo@> ownedWeaponsWithNoAmmo;
	for (uint i = 0; i < g_weaponPickups.length(); i++)
	{
		int weaponPickupId = g_weaponPickups[i];
		WeaponInfo@ weaponInfo = GetWeaponInfo(weaponPickupId);
		if (weaponInfo is null)
		{
			continue;
		}
		
		if (LocalPlayer.HasWeapon(weaponInfo.weaponDef))
		{
			// This covers the war blade and razor wind, as there's no ammo for them
			if (!weaponInfo.hasAmmo)
			{
				continue;
			}
			
			ownedWeapons.insertLast(weaponInfo);
			
			int totalAmmo = LocalPlayer.GetAmmo(weaponInfo.weaponDef) + 
				LocalPlayer.GetAltAmmo(weaponInfo.weaponDef);
			
			if (totalAmmo == 0)
			{
				ownedWeaponsWithNoAmmo.insertLast(weaponInfo);
			}
			else if (totalAmmo < weaponInfo.combinedMaxAmmo)
			{
				ownedWeaponsMissingAmmo.insertLast(weaponInfo);
			}
		}
	}
	
	// Choose a weapon to get ammo for
	WeaponInfo @weaponToGetAmmoFor;

	int diceRoll = RandomInt(1, 100);
	if (diceRoll <= 40 && ownedWeaponsWithNoAmmo.length() > 0)
	{
		@weaponToGetAmmoFor = RandomWeaponInfo(ownedWeaponsWithNoAmmo);
	}
	else if (diceRoll <= 85 && ownedWeaponsMissingAmmo.length() > 0)
	{
		@weaponToGetAmmoFor = RandomWeaponInfo(ownedWeaponsMissingAmmo);
	}
	else
	{
		@weaponToGetAmmoFor = RandomWeaponInfo(ownedWeapons);
	}
	
	if (weaponToGetAmmoFor is null)
	{
		Sys.Print("No valid weapon found for ammo roll");
		return;
	}
	
	// Get the ammo!
	float ammoPercent = RandomInt(OPTION_RANDOM_AMMO_MIN, OPTION_RANDOM_AMMO_MAX) / 100.0;
	if (weaponToGetAmmoFor.maxAltAmmo > 0)
	{
		int altAmmoAmount = int(Math::Ceil(weaponToGetAmmoFor.maxAltAmmo * ammoPercent));
		GiveAltAmmo(weaponToGetAmmoFor.pickupId, altAmmoAmount);
		Hud.AddMessage(GetAmmoMessage(weaponToGetAmmoFor.altAmmoType, altAmmoAmount));
	}
	
	int standardAmmoAmount = int(Math::Ceil(weaponToGetAmmoFor.maxAmmo * ammoPercent));
	kStr ammoMessage = GetAmmoMessage(weaponToGetAmmoFor.ammoType, standardAmmoAmount);
	TryGivePlayerWeapon(weaponToGetAmmoFor.pickupId, standardAmmoAmount, false, true, ammoMessage);
}

//---------------------------
// Gets the ammo message given the type and amount.
kStr GetAmmoMessage(const kStr &in ammoType, const int &in amount)
{
	kStr pluralSuffix = "s";
	kStr ammoTypeStr = "Unknown Ammo";
	if (ammoType == "Ammo_Arrow")
	{
		ammoTypeStr = "Arrow";
	} 
	else if (ammoType == "Ammo_TekArrow")
	{
		ammoTypeStr = "Tek Arrow";
	}
	else if (ammoType == "Ammo_Bullet")
	{
		ammoTypeStr = "Bullet";
	}
	else if (ammoType == "Ammo_Dart")
	{
		ammoTypeStr = "Tranquilizer Dart";
	}
	else if (ammoType == "Ammo_ChargeDart")
	{
		ammoTypeStr = "Charge Dart";
	}
	else if (ammoType == "Ammo_Shell")
	{
		ammoTypeStr = "Shotgun Shell";
	}
	else if (ammoType == "Ammo_ExpShells")
	{
		ammoTypeStr = "Explosive Shell";
	}
	else if (ammoType == "Ammo_Plasma")
	{
		ammoTypeStr = "Plasma Round";
	}
	else if (ammoType == "Ammo_SunfirePod")
	{
		ammoTypeStr = "Sunfire Pod";
	}
	else if (ammoType == "Ammo_Bore")
	{
		ammoTypeStr = "Bore";
	}
	else if (ammoType == "Ammo_Mine")
	{
		ammoTypeStr = "Mine";
	}
	else if (ammoType == "Ammo_Grenades")
	{
		ammoTypeStr = "Grenade";
	}
	else if (ammoType == "Ammo_Rockets")
	{
		ammoTypeStr = "Scorpion Missile";
	}
	else if (ammoType == "Ammo_Spears")
	{
		ammoTypeStr = "Spear";
	}
	else if (ammoType == "Ammo_Torpedos")
	{
		ammoTypeStr = "Torpedo";
		pluralSuffix = "es";
	}
	else if (ammoType == "Ammo_Fuel")
	{
		ammoTypeStr = "Flame Thrower Fuel";
		pluralSuffix = "";
	}
	else if (ammoType == "Ammo_Nuke")
	{
		ammoTypeStr = "Nuke Ammo";
		pluralSuffix = "";
	}
	else
	{
		pluralSuffix = "";
	}
	
	return "" + amount + " " + ammoTypeStr + (amount == 1 ? "" : pluralSuffix);
}

//---------------------------
// Fully restores ammo in all owned weapons.
void FillAmmoInAllWeapons()
{
	for (uint i = 0; i < g_weaponPickups.length(); i++)
	{
		int weaponPickupId = g_weaponPickups[i];
		WeaponInfo@ weaponInfo = GetWeaponInfo(weaponPickupId);
		if (weaponInfo is null || 
			!weaponInfo.hasAmmo ||
			!LocalPlayer.HasWeapon(weaponInfo.weaponDef))
		{
			continue;
		}
		
		LocalPlayer.GiveWeapon(weaponInfo.weaponDef, 1000);
		GiveAltAmmo(weaponPickupId);
	}
	
	LocalPlayer.Actor().PlaySound("sounds/shaders/Ammo Pickup.ksnd");
	Hud.AddMessage("Max Ammo Pack");
}

//---------------------------
// Gives the given amount of alt ammo for the given pickup
// Defaults to max ammo
void GiveAltAmmo(const int &in pickupId, const int &in altAmmoAmount = 1000)
{
	switch(pickupId)
	{
		case kActor_Item_WpnShotgun:
			LocalPlayer.GiveWeapon(kWpn_ShotgunAlt, altAmmoAmount);
			break;
		case kActor_Item_WpnScatter:
			LocalPlayer.GiveWeapon(kWpn_ShredderAlt, altAmmoAmount);
			break;
		case kActor_Item_WpnTekBow:
			LocalPlayer.GiveWeapon(kWpn_TekBowAlt, altAmmoAmount);
			break;
	}
}