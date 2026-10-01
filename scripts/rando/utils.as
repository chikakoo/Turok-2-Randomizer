//------------------------------
// Utility functions that don't fit elsewhere.
//------------------------------

//------------------------------
// Generates a random int, between the min and max, inclusive.
int RandomInt(int &in min, int &in max)
{
	int minValue, maxValue;
	if (min <= max)
	{
		minValue = min;
		maxValue = max;
	}
    else
	{
		minValue = max;
		maxValue = min;
	}
	
	return minValue + Math::RandMax(maxValue - minValue + 1);
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

//------------------------------
// Gets a random EnemyWeight value from the given array.
EnemyWeight@ RandomEnemyWeight(array<EnemyWeight@>@ enemyWeightArray)
{
	if (enemyWeightArray.length() == 0)
    {
        return null;
    }
	
	int indexToChoose = RandomInt(0, enemyWeightArray.length() - 1);
    return enemyWeightArray[indexToChoose];
}

//------------------------------
// Gets a random multiplier for a given percentage range which can be used
// used to modify a value by multiplying by it.
//
// For example, a value of 10 will return a value between 0.9 and 1.1, meaning
// the value can be adjusted by +/- 10%.
float RandomPercentageMultiplier(const float &in range)
{
	if (range < 0 || range >= 100)
	{
		Sys.Print("ERROR: Tried to get random multiplier for: " + range);
		return 1;
	}

	return Math::RandRange(100 - range, 100 + range) / 100.0f;
}