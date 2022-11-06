function OuterwallMain()
{
	PrecacheSound("outerwall/snd_quote_walk.mp3");
	
	CheckSoldierHoliday();
}

function CheckSoldierHoliday()
{
	const TF_SOLDIER_HOLIDAY = 12;

	if (!IsHolidayActive(TF_SOLDIER_HOLIDAY))
	{
		EntFire("soldier_statue", "kill");
	}
}

::RoundEndEvent <- function()
{
	EntFire("outerwall_soundscape", "kill");
	EntFire("outerwall_soundscape_empty_trigger", "Enable");
}

::PlayerZoneList <- array(33)

::PlayerSpawnEvent <- function()
{
	if (activator.GetClassname() != "player")
		return;

	local client = activator.GetEntityIndex();
	
	switch(PlayerZoneList[client])
	{		
		case 1: //last cave
		{
			activator.SetOrigin(Vector(7024,-3504,10740));
			activator.SetAngles(0,90,0);
			break;
		}
		
		case 2: //balcony
		{
			activator.SetOrigin(Vector(4616,-2208,12020));
			activator.SetAngles(0,90,0);
			break;
		}
		
		case 3: //inner wall
		{
			activator.SetOrigin(Vector(-1392,7904,-13788));
			activator.SetAngles(0,270,0);
			break;
		}
		
		case 4: //hell
		{
			activator.SetOrigin(Vector(-704,-10368,13284));
			activator.SetAngles(0,90,0);
			break;
		}
		
		case 5: //wind fortress
		{
			activator.SetOrigin(Vector(-1824,7616,13412));
			activator.SetAngles(0,0,0);
			break;
		}
		
		default: //oside
		{
			activator.SetOrigin(Vector(3328,-320,-14044));
			activator.SetAngles(0,180,0);
			break;
		}
	}
}

::SetPlayerZone <- function(zone)
{
	if(activator.GetClassname() != "player")
		return;

	local client = activator.GetEntityIndex();
	
	PlayerZoneList[client] = zone;
}