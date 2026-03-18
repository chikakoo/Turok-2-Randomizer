// --------------------------
// Weapon data is scattered around defs, so lets store it all together
// for quicker access.
//
// Weapons are usually referenced by the pickup, so the index will be
// based on that id, minus the id of the lowest index.
//---------------------------

// Segmented arrays here to not have big gaps with no data
array<WeaponInfo@> g_weaponInfo_2000; // 2001–2017
array<WeaponInfo@> g_weaponInfo_2100; // 2100–2101
array<WeaponInfo@> g_weaponInfo_2110; // 2110–2112

array<WeaponInfoRange> g_weaponRanges;
class WeaponInfoRange
{
    int start;
    int end;
    array<WeaponInfo@>@ data;
}

class WeaponInfo
{
	kStr pickupMessage;
	kStr pickupSound;
	int callout;
	int weaponDef;
	int maxAmmo;
	int maxAltAmmo;
	bool hasAmmo;
}

//---------------------------
// Initialize the weapon ranges and fill them with initialized WeaponData.
void InitWeaponRanges()
{
    g_weaponRanges.resize(3);

    // 2001–2017
    g_weaponRanges[0].start = 2001;
    g_weaponRanges[0].end = 2017;
    @g_weaponRanges[0].data = @g_weaponInfo_2000;

    // 2100–2101
    g_weaponRanges[1].start = 2100;
    g_weaponRanges[1].end = 2101;
    @g_weaponRanges[1].data = @g_weaponInfo_2100;

    // 2110–2112
    g_weaponRanges[2].start = 2110;
    g_weaponRanges[2].end = 2112;
    @g_weaponRanges[2].data = @g_weaponInfo_2110;

    // Allocate and construct all WeaponInfo
    for (uint r = 0; r < g_weaponRanges.length(); r++)
    {
        WeaponInfoRange @range = g_weaponRanges[r];

        int size = range.end - range.start + 1;
        range.data.resize(size);

        for (int i = 0; i < size; i++)
        {
            @range.data[i] = WeaponInfo();
        }
    }
}

//---------------------------
// Initializes the global with all the retrieved weapon info.
// The nuke has the biggest index (2112), and the war blade has the lowest (2001).
void InitWeaponInfoCache()
{
	InitWeaponRanges();
	
	array<int> weaponPickups = {
		kActor_Item_WpnWarBlade,
		kActor_Item_WpnBow,
		kActor_Item_WpnTekBow,
		kActor_Item_WpnPistol,
		kActor_Item_WpnMag60,
		kActor_Item_WpnTranq,
		kActor_Item_WpnChargeDart,
		kActor_Item_WpnShotgun,
		kActor_Item_WpnScatter,
		kActor_Item_WpnPlasmaRifle,
		kActor_Item_WpnFireStorm,
		kActor_Item_WpnSunfirePod,
		kActor_Item_WpnCerebralBore,
		kActor_Item_WpnPFMLayer,
		kActor_Item_WpnGrenadeLauncher,
		kActor_Item_WpnMissileLauncher,
		kActor_Item_WpnFlameThrower,
		kActor_Item_WpnRazorWind,
		kActor_Item_WpnNuke,
		kActor_Item_WpnSpearGun,
		kActor_Item_WpnTorpedoLauncher,
	};
	
	for (uint i = 0; i < weaponPickups.length(); i++)
	{
		int weaponPickupId = weaponPickups[i];
		
		WeaponInfo @weaponInfo = GetWeaponInfo(weaponPickupId);
		if (weaponInfo is null)
		{
			continue;
		}
		
		kDictMem@ weaponPickupDict = TryGetActorDefWithClass(
			weaponPickupId, "kexWeaponPickup");
		if (weaponPickupDict is null)
		{
			Sys.Print("Did not find weapon pickup: " + weaponPickupId);
			continue;
		}
		
		// Info from the pickup
		kStr pickupMessage;
		kStr pickupSound;
		int callout = 0;
		int weaponDefinition = 0;
		
		weaponPickupDict.GetString("pickup.pickupMessage", pickupMessage);
		weaponPickupDict.GetString("pickup.pickupSound", pickupSound);
		weaponPickupDict.GetInt("pickup.callout", callout);
		weaponPickupDict.GetInt("pickup.weapon.definition", weaponDefinition);
		
		weaponInfo.pickupMessage = pickupMessage;
		weaponInfo.pickupSound = pickupSound;
		weaponInfo.callout = callout;
		weaponInfo.weaponDef = weaponDefinition;
		
		// Ammo info
		int weaponDefId;
		weaponPickupDict.GetInt("pickup.weapon.definition", weaponDefId);
		kDictMem@ weaponDef = g_indexDefManager.GetEntry(weaponDefId);
		if (weaponDef is null)
		{
			Sys.Print("Tried to use non-existant weapon def: " + weaponDefId);
			continue;
		}
		
		kStr ammoDefKey;
		int maxAmmo = 0;
		if (weaponDef.GetString("ammo", ammoDefKey))
		{
			kDictMem@ ammoDef = g_defManager.GetEntry(ammoDefKey);
			if (ammoDef !is null)
			{
				ammoDef.GetInt("max", maxAmmo);
			}
		}
		
		int maxAltAmmo = 0;
		if (weaponDef.GetString("altAmmo", ammoDefKey))
		{
			kDictMem@ ammoDef = g_defManager.GetEntry(ammoDefKey);
			if (ammoDef !is null)
			{
				ammoDef.GetInt("max", maxAltAmmo);
			}
		}
		
		weaponInfo.maxAmmo = maxAmmo;
		weaponInfo.maxAltAmmo = maxAltAmmo;
		weaponInfo.hasAmmo = (maxAmmo + maxAltAmmo) > 0;
	}
}

//---------------------------
// Gets the weapon info out of the global by using the appropriate array. 
WeaponInfo@ GetWeaponInfo(const int &in weaponPickupId)
{
    for (uint r = 0; r < g_weaponRanges.length(); r++)
    {
        WeaponInfoRange @range = g_weaponRanges[r];
        if (weaponPickupId >= range.start && weaponPickupId <= range.end)
        {
            return range.data[weaponPickupId - range.start];
        }
    }

    Sys.Print("Invalid weaponPickupId: " + weaponPickupId);
    return null;
}
