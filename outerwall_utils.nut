//shorten constants for sanity
::MAX_PLAYERS <- Constants.Server.MAX_PLAYERS
::TEAM_UNASSIGNED <- Constants.ETFTeam.TEAM_UNASSIGNED
::TEAM_SPECTATOR <- Constants.ETFTeam.TEAM_SPECTATOR
::OBS_MODE_IN_EYE <- Constants.ESpectatorMode.OBS_MODE_IN_EYE
::OBS_MODE_CHASE <- Constants.ESpectatorMode.OBS_MODE_CHASE
::DMG_BURN <- Constants.FDmgType.DMG_BURN

::DEBUG_OUTPUT <- !IsDedicatedServer()

::DebugPrint <- function(Text)
{
	if(DEBUG_OUTPUT)
		printl(Text);
}

function ToggleDebug()
{
	if(DEBUG_OUTPUT)
	{
		DEBUG_OUTPUT = false;
		printl("Debug Output: OFF");
	}
	else
	{
		DEBUG_OUTPUT = true;
		printl("Debug Output: ON");
	}
}