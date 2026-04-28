// --------------------------
// Used to get a script object off of a ScriptActor
// --------------------------
ScriptActor@ g_scriptResult;

// --------------------------
// Runs the user event, which will set the result to g_scriptResult
ScriptActor@ GetScript(kActor@ actor)
{
	@g_scriptResult = null;
	Event.RunAction(
		@actor, 
		null, 
		ACTION_USER, 
		Math::vecZero, 
		RANDO_MSG_GET_SCRIPT,
		0, 0, 0);
	ScriptActor@ scriptResult = @g_scriptResult;
	@g_scriptResult = null;
	
	return @scriptResult;
}