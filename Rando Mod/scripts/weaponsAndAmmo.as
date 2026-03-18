// --------------------------
// Functions dealing with giving weapons and ammo.
//---------------------------

//---------------------------
// Given the actor id, simulates the player picking up a weapon.
// They are given the ammo amount even if they own the weapon.
bool TryGivePlayerWeapon(int &in actorId, int &in ammoAmount = 1000)
{
	WeaponInfo@ weaponInfo = GetWeaponInfo(actorId);
	bool ownsWeapon = LocalPlayer.HasWeapon(weaponInfo.weaponDef);
	LocalPlayer.GiveWeapon(weaponInfo.weaponDef, ammoAmount);
	if (ownsWeapon)
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
		Sys.Print("Weapon pickup id: " + weaponPickupId);
		
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
	float ammoPercent = RandomInt(20, 75) / 100.0;
	int standardAmmoAmount = int(Math::Ceil(weaponToGetAmmoFor.maxAmmo * ammoPercent));
	TryGivePlayerWeapon(weaponToGetAmmoFor.pickupId, standardAmmoAmount);
	
	if (weaponToGetAmmoFor.maxAltAmmo > 0)
	{
		int altAmmoAmount = int(Math::Ceil(weaponToGetAmmoFor.maxAltAmmo * ammoPercent));
		
		// We mapped the flare to use explosive rounds!
		if (weaponToGetAmmoFor.pickupId == kActor_Item_WpnShotgun ||
			weaponToGetAmmoFor.pickupId == kActor_Item_WpnScatter)
		{
			LocalPlayer.GiveWeapon(kWpn_Flare, altAmmoAmount);
		}
		
		// Normal arrows are the alt ammo for the tek bow
		// You start with the bow, so this isn't a problem
		else if (weaponToGetAmmoFor.pickupId == kActor_Item_WpnTekBow)
		{
			LocalPlayer.GiveWeapon(kWpn_Bow, altAmmoAmount);
		}
	}
}


//---------------------------
// Weapon givers, to test in the console.
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