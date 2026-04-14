// --------------------------
// A wrapper around ScriptObject to be used by classes that need to grab
// references to the inheriting class.
// --------------------------
abstract class ScriptActor : ScriptObject
{
	kActor@ self;
	
	ScriptActor(kActor@ actor)
	{
		@self = actor;
	}
	
	// --------------------------
	// Removes the actor from the map
	void Remove()
	{
		self.Remove();
	}
	
	// --------------------------
	// Used to get this object off of the actor
	void UserEvent(
		const float x, 
		const float y, 
		const float z, 
		const float f1, 
		const float f2, 
		const float f3, 
		const float f4)
	{
		int msg = int(f1);
		switch (msg)
		{
			case RANDO_MSG_GET_SCRIPT:
			{
				@g_scriptResult = @this;
				return;
			}
		}
	}
}