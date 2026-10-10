//----------------------------------
// ScriptObject for progressive warps.
//----------------------------------
class RandoProgressiveWarp : RandoPickupObject
{
	RandoProgressiveWarp(kActor @actor)
	{
		super(actor);
	}
	
	//----------------------------------
	// Gives all level keys if using the one warp unlock method.
	void AfterReplacementTouched() override
	{
		TryGiveAllLevelKeysForWarp(self.Type());
	}
}

//---------------------------
// If using the setting where the first progressive warp gives level keys, handles
// giving the level keys belonging to the given warp.
void TryGiveAllLevelKeysForWarp(const int &in actorId)
{
	if (!OPTION_UNLOCK_METHOD_ONE_WARP)
	{
		return;
	}

	int levelKeyActorId = kActor_InventoryItem_Level1Key;
	switch(actorId)
	{
		case kActor_InventoryItem_ProgressiveWarpL1:
			levelKeyActorId = kActor_InventoryItem_Level1Key;
			break;
		case kActor_InventoryItem_ProgressiveWarpL2:
			levelKeyActorId = kActor_InventoryItem_Level2Key;
			break;
		case kActor_InventoryItem_ProgressiveWarpL3:
			levelKeyActorId = kActor_InventoryItem_Level3Key;
			break;
		case kActor_InventoryItem_ProgressiveWarpL4:
			levelKeyActorId = kActor_InventoryItem_Level4Key;
			break;
		case kActor_InventoryItem_ProgressiveWarpL5:
			levelKeyActorId = kActor_InventoryItem_Level5Key;
			break;
		case kActor_InventoryItem_ProgressiveWarpL6:
			levelKeyActorId = kActor_InventoryItem_Level6Key;
			break;
			
		// If this is not a progressive warp, don't do anything
		default:
			return;
	}
	
	// Don't give any keys if you already have them
	if (GetInventoryItemCollectedTotal(levelKeyActorId) > 0)
	{
		return;
	}

	int count = levelKeyActorId == kActor_InventoryItem_Level6Key ? 6 : 3;
	TryGetInventoryItems(levelKeyActorId, count);
}