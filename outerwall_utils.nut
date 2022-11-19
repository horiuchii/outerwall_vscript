IsDedicatedServer() ? ::DEBUG_OUTPUT <- false : ::DEBUG_OUTPUT <- true


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