// --------------------------
// An actor for allowing the player to return to the hub.
// This is important so they can always return to Level 1.
//---------------------------
class RandoHubWarp : ScriptObject
{
	//---------------------------
	// Constructor
	// Creates the warp frame under the warp itself.
	RandoHubWarp(kActor @actor) 
	{ 
		actor.WorldComponent().Flags() |= WCF_NONSOLID;
		actor.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
		
		kActor@ frame = ActorFactory.Spawn(
			kActor_Portal_HubWarpFrame,
			actor.Origin(),
			actor.Yaw(),
			actor.Pitch(),
			actor.Roll());
	}
	
	//---------------------------
	// Warps to the appropriate level's warp point.
	void OnCollide(kActor@ pCollider)
	{
		switch(Game.ActiveMapID())
		{
            case kLevel_RiverOfSouls_1:
                DoPlayerWarp(0, 12999, kLevel_Hub, true);
                break;
            case kLevel_DeathMarsh_1:
                DoPlayerWarp(0, 13999, kLevel_Hub, true);
                break;
			case kLevel_BlindLair_1:
                DoPlayerWarp(0, 14999, kLevel_Hub, true);
                break;
			case kLevel_HiveTop:
                DoPlayerWarp(0, 15999, kLevel_Hub, true);
                break;
			case kLevel_Lightship_1:
                DoPlayerWarp(0, 16999, kLevel_Hub, true);
                break;
			default:
				DoPlayerWarp(0, 11999, kLevel_Hub, true);
		}
	}
}