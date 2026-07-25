// --------------------------
// An actor for detecting when players walk to certain parts of the map.
// This is used for auto-tabbing in trackers.
//---------------------------
class RandoMapDetection : ScriptActor
{
	// The map id to set when the actor is touched
	int mapId = 0;

	//---------------------------
	// Constructor - turns off damage and collision and turns on the collision callback
	RandoMapDetection(kActor @actor) 
	{ 
		super(@actor);
		self.Flags() |= AF_NODAMAGE;
		self.WorldComponent().Flags() |= WCF_NONSOLID;
		self.WorldComponent().Flags() |= WCF_INVOKE_COLLIDE_CALLBACK;
	}
	
	//---------------------------
	// Sets the map id
	void SetMapId(const int &in mapId)
	{
		this.mapId = mapId;
	}
	
	//---------------------------
	// Sets the radius and touch radius
	void SetRadius(const float &in radius)
	{
		self.WorldComponent().Radius() = radius;
		self.WorldComponent().TouchRadius() = radius;
	}
	
	//---------------------------
	// Sets the height
	void SetHeight(const float &in height)
	{
		self.WorldComponent().Height() = height;
	}
	
	//---------------------------
	// Sets the map id
	void OnCollide(kActor@ pCollider)
	{	
		if (pCollider is null || pCollider !is LocalPlayer.Actor().CastToActor())
		{
			return;
		}
	
		if (mapId != 0)
		{
			g_AP.CurrentMapId = mapId;
		}
	}
	
	//--------------------------
	// Needs to exist with OnDeserialize to prevent errors
	void OnSerialize(kDict& out dict)
	{
	}
	
	//--------------------------
	// Remove on a deserialize, as they are created on spawn
	// This prevents multiple actors from existing at a time
	// The alternative would require serializing the warp data
	void OnDeserialize(kDict& in dict)
	{			
		self.Remove();
	}
}