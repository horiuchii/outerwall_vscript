function OuterwallMain()
{
	PrecacheSound("outerwall/snd_quote_walk.mp3");
	
	CheckSoldierHoliday();
}

function CheckSoldierHoliday()
{
	const TF_SOLDIER_HOLIDAY = 12;

	if (!IsHolidayActive(TF_SOLDIER_HOLIDAY))
		EntFire("soldier_statue", "kill");
}

::PlayerZoneList <- array(33)

::GameEventPlayerSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	
	if (client == null || client.GetTeam() <= 1)
		return;
	
	local player_index = client.GetEntityIndex();
	
	switch(PlayerZoneList[player_index])
	{		
		case 1: //last cave
			client.SetOrigin(Vector(7024,-3504,10740));
			client.SetAngles(0,90,0);
			break;
		
		case 2: //balcony
			client.SetOrigin(Vector(4616,-2208,12020));
			client.SetAngles(0,90,0);
			break;
		
		case 3: //inner wall
			client.SetOrigin(Vector(-1392,7904,-13788));
			client.SetAngles(0,270,0);
			break;
		
		case 4: //hell
			client.SetOrigin(Vector(-704,-10368,13284));
			client.SetAngles(0,90,0);
			break;
		
		case 5: //wind fortress
			client.SetOrigin(Vector(-1824,7616,13412));
			client.SetAngles(0,0,0);
			break;
		
		default: //oside
			client.SetOrigin(Vector(3328,-320,-14044));
			client.SetAngles(0,180,0);
			break;
	}
}

::SetPlayerZone <- function(zone)
{
	if (activator == null || !activator.IsPlayer())
		return;

	local player_index = activator.GetEntityIndex();
	
	PlayerZoneList[player_index] = zone;
}