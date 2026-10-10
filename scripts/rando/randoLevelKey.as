//----------------------------------
// ScriptObject for level keys.
//----------------------------------
class RandoLevelKey : RandoPickupObject
{
	RandoLevelKey(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// If using level key packs, give the rest of the keys
	// The game will have given one already, so give the rest!
	void AfterReplacementTouched() override
	{
		if (OPTION_UNLOCK_METHOD_ONE_KEY)
		{
			int count = self.Type() == kActor_InventoryItem_Level6Key ? 5 : 2;
			TryGetInventoryItems(self.Type(), count);
		}
	}
}

//---------------------------
// Returns whether the given actor id is for a level key.
bool IsLevelKey(const int &in actorId)
{
	return actorId == kActor_InventoryItem_Level1Key ||
		actorId == kActor_InventoryItem_Level2Key ||
		actorId == kActor_InventoryItem_Level3Key ||
		actorId == kActor_InventoryItem_Level4Key ||
		actorId == kActor_InventoryItem_Level5Key ||
		actorId == kActor_InventoryItem_Level6Key;
}