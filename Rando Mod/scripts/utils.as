//------------------------------
// Utility functions that don't fit elsewhere.
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
	int indexToChoose = RandomInt(0, intArray.length() - 1);
    return intArray[indexToChoose];
}