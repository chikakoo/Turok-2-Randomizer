//------------------------------
// Utility functions that don't fit elsewhere.
// Currently just functions for randomization (rename the file?)
//------------------------------

//------------------------------
// Generates a random int, between the min and max, inclusive.
int RandomInt(int min, int max)
{
    return min + Math::RandMax(max - min + 1);
}

//------------------------------
// Gets a random int value from the given array.
int RandomInt(array<int>@ intArray)
{
	if (intArray.length() == 0)
    {
        return 0;
    }
	
	int indexToChoose = RandomInt(0, intArray.length() - 1);
    return intArray[indexToChoose];
}

//------------------------------
// Gets a random WeaponInfo value from the given array.
WeaponInfo@ RandomWeaponInfo(array<WeaponInfo@>@ weaponInfoArray)
{
	if (weaponInfoArray.length() == 0)
    {
        return null;
    }
	
	int indexToChoose = RandomInt(0, weaponInfoArray.length() - 1);
    return weaponInfoArray[indexToChoose];
}