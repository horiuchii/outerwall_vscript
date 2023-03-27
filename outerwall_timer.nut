const PF_MEDAL_MODEL = "models/beepin/pf_medal/pf_medal.mdl"
const PF_MEDAL_SKIN_IRIDESCENT = 1;
const PF_MEDAL_SKIN_GOLD = 2;
const PF_MEDAL_SKIN_SILVER = 3;
const PF_MEDAL_SKIN_BRONZE = 4;
const TIMER_PLAYERHUDTEXT = "outerwall_timer_gametext_";

const NO_MEDAL_COLOR = "008B8B";

::MedalTypes <-
[
	"Bronze"
	"Silver"
	"Gold"
	"Iridecent"
]

::MedalColors <-
[
	"D2691E" //bronze
	"C0C0C0" //silver
	"FFD700" //gold
	"B71111" //iridescence
]

::ZoneTimes <-
[
	// bronze, silver, gold, iridescence
	[85, 70, 50, 35], //oside
	[60, 45, 35, 30], //last cave
	[70, 55, 45, 30], //balcony
	[65, 45, 35, 25], //inner wall
	[135, 100, 70, 60], //hell
	[145, 110, 80, 75], //wind fortress
	[155, 135, 115, 100], //sand pit
	//[300, 350, 300, 250] //final cave
]

::ZoneTimes_Encore <-
[
	// bronze, silver, gold, iridescence
	[85, 70, 50, 35], //oside
	[60, 45, 35, 30], //last cave
	[70, 55, 45, 30], //balcony
	[65, 45, 35, 25], //inner wall
	[135, 100, 70, 60], //hell
	[145, 110, 80, 75], //wind fortress
	[155, 135, 115, 100], //sand pit
	//[300, 350, 300, 250] //final cave
]

::ZoneLaps_Encore <-
[
	// bronze, silver, gold, iridescence
	[0, 0, 0, 0], //oside
	[0, 0, 0, 0], //last cave
	[0, 0, 0, 0], //balcony
	[0, 0, 0, 0], //inner wall
	[0, 0, 0, 0], //hell
	[0, 0, 0, 0], //wind fortress
	[0, 0, 0, 0], //sand pit
	//[0, 0, 0, 0] //final cave
]

::MedalLocations <-
[
	Vector(2328,896,-11928), //oside
	Vector(5472,-2688,12056), //lastcave
	Vector(4704,-4368,14056), //balcony
	Vector(-4736,-4456,-12728), //inner wall
	Vector(-5696,-1247,12457), //hell
	Vector(5663,4704,14856), //wind fortress
	Vector(4928,6944,-13392) //sand pit
	//Vector(4928,6944,-13392) //final cave
]

::ZoneNames <-
[
	"Outer Wall"
	"Last Cave"
	"Balcony"
	"Inner Wall"
	"Sacred Grounds"
	"Wind Fortress"
	"Sand Pit"
	//"Final Cave"
]

::ZoneSuffixes <-
[
	"'s"
	"'s"
	"'s"
	"'s"
	"'"
	"'"
	"'s"
	//"'s"
]

::PlayerStartTime <- array(MAX_PLAYERS, 0)
::PlayerMedalTimeHUDStatusArray <- array(MAX_PLAYERS, false)
::PlayerCheatedCurrentRun <- array(MAX_PLAYERS, false)

::DisplayTime <- function(client, bLapText, iMedal = 3)
{
	local player_index = client.GetEntityIndex();
	
	local time = Time() - PlayerStartTime[player_index];
	local timedecimal = (round(time - time.tointeger(), 1) * 10).tostring();
	local Min = time.tointeger() / 60;
	local Sec = time.tointeger() - (Min * 60);
	local SecString = format("%s%i", Sec < 10 ? "0" : "", Sec);
	
	local message = bLapText ? OUTERWALL_TIMER_LAPTIME : OUTERWALL_TIMER_FINALTIME;
	
	local messagecolor = null;
	if(iMedal == null)
		messagecolor = NO_MEDAL_COLOR;
	else
		messagecolor = bLapText ? "FF0000" : MedalColors[iMedal];
	
	ClientPrint(client, HUD_PRINTTALK, "\x07" + messagecolor + TranslateString(message) + "\x01" + Min + ":" + SecString + "." + timedecimal);
}

::CreateMedalTimeText <- function()
{
	for(local iArrayIndex = 1; iArrayIndex < MAX_PLAYERS; iArrayIndex++)
	{
		local gametext = SpawnEntityFromTable("game_text",
		{
			targetname = TIMER_PLAYERHUDTEXT + iArrayIndex,
			message = "You're not supposed to see this. How'd you do it?",
			channel = 5,
			color = "240 255 0",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.025,
			y = 0.375
		})
		
		Entities.DispatchSpawn(gametext);
	}
}

::UpdateMedalTimeText <- function(player_index)
{
	local MedalTimesText = format(TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_MEDALTIMES, player_index), ZoneNames[PlayerZoneList[player_index]], ZoneSuffixes[PlayerZoneList[player_index]]) + "\n" + "------------------------" + "\n";
	for(local medal_index = 3 ; medal_index > -1 ; medal_index--)
	{
		local Milestone = ZoneTimes[PlayerZoneList[player_index]][medal_index];
		local Min = Milestone / 60;
		local Sec = Milestone - (Min * 60);
		local SecString = format("%s%i", Sec < 10 ? "0" : "", Sec);
		MedalTimesText += TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY[medal_index], player_index) + Min + ":" + SecString + "\n";
	}
	
	local best_medal = PlayerBestMedalArray[player_index][PlayerZoneList[player_index]] == -1 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[PlayerBestMedalArray[player_index][PlayerZoneList[player_index]]], player_index);
	local best_time = PlayerBestTimeArray[player_index][PlayerZoneList[player_index]].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : PlayerBestTimeArray[player_index][PlayerZoneList[player_index]];
	
	MedalTimesText += "\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL, player_index) + best_medal;
	MedalTimesText += "\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_TIME, player_index) + best_time; //TODO: FORMAT TIME
	
	//TODO: if in encore, show best laps
	
	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", MedalTimesText);
}

::SetMedalTimeHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	if(bSetHUD)
		EmitSoundOnClient(SND_CHECKPOINT, activator);
	
	PlayerMedalTimeHUDStatusArray[player_index] = bSetHUD;
}

::StartPlayerTimer <- function(client)
{
	local player_index = client.GetEntityIndex();
	PlayerStartTime[player_index] = Time();
	PlayerCheatedCurrentRun[player_index] = false;
}

::CheckPlayerMedal <- function(iZone, client)
{
	local player_index = client.GetEntityIndex();
	
	local player_best_medal = PlayerBestMedalArray[player_index][iZone];
	DebugPrint("Player " + player_index + "'s best medal for stage " + iZone + " is " + player_best_medal);
	
	local total_time = Time() - PlayerStartTime[player_index];
	DebugPrint("Player " + player_index + "'s time for stage " + iZone + " is " + total_time);
	
	local medal = null;
	local best_medal_qualified = null;
	local medal_times = ZoneTimes[iZone];
	
	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		if(total_time < medal_times[medal_index])
		{
			if(player_best_medal >= medal_index)
			{
				DebugPrint(player_best_medal + " is better than " + medal_index);
				continue;
			}
			
			// only allow iri, gold and silver for bonus 7 if lap 2 is active
			if(iZone == 7 && medal_index >= 1 && PlayerLapTwoStatus[player_index] != true)
				continue;
			
			medal = medal_index;
			break;
		}
	}
	
	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		if(total_time < medal_times[medal_index])
		{
			// only allow iri, gold and silver for bonus 7 if lap 2 is active
			if(iZone == 7 && medal_index >= 1 && PlayerLapTwoStatus[player_index] != true)
				continue;
			
			best_medal_qualified = medal_index;
			break;
		}
	}
	
	if(medal != null)
	{
		PlayerBestMedalArray[player_index][iZone] = medal;
		DebugPrint("Setting player " + player_index + "'s best medal for stage " + iZone + " to " + medal);
		
		ClientPrint(client, HUD_PRINTTALK, "\x07" + MedalColors[medal] + TranslateString(OUTERWALL_TIMER_MESSAGE[medal][RandomInt(0, OUTERWALL_TIMER_MESSAGE[medal].len() - 1)], player_index) + format(TranslateString(OUTERWALL_TIMER_ACHIEVED, player_index), ZoneNames[iZone], ZoneSuffixes[iZone]) + TranslateString(OUTERWALL_TIMER_MEDAL_ACHIEVED[medal], player_index));
		
		SpawnPropMedal(medal, iZone, client);
	}
	
	if(medal == null && player_best_medal == -1)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + NO_MEDAL_COLOR + TranslateString(OUTERWALL_TIMER_MESSAGE_NOMEDAL[RandomInt(0, OUTERWALL_TIMER_MESSAGE_NOMEDAL.len() - 1)], player_index) + format(TranslateString(OUTERWALL_TIMER_FAILEDTOQUALIFY, player_index), ZoneNames[iZone], ZoneSuffixes[iZone]));
	}
	
	if(PlayerSettingDisplayTime[player_index] == true)
	{
		DisplayTime(activator, false, best_medal_qualified);
	}
	
	local bNewTimeRecord = false;
	
	//set bNewTimeRecord if we surpass or are equal to our best medal && our time is better than the best time
	if(best_medal_qualified >= player_best_medal && total_time < PlayerBestTimeArray[player_index][iZone])
	{
		bNewTimeRecord = true;
		PlayerBestTimeArray[player_index][iZone] = total_time;
	}
	
	if(medal != null || bNewTimeRecord)
	{
		PlayerSaveGame(client);
		PlayerUpdateLeaderboardTimes(player_index);
	}
}

::SpawnPropMedal <- function(medal_type, iZone, client)
{
	local prop_skin = null;
	local medal_sound = null;
	local prop_origin = MedalLocations[iZone];

	switch(medal_type)
	{
		case 3: prop_skin = PF_MEDAL_SKIN_IRIDESCENT; medal_sound = SND_MEDAL_IRIDESCENT; break;
		case 2: prop_skin = PF_MEDAL_SKIN_GOLD; medal_sound = SND_MEDAL_GOLD; break;
		case 1: prop_skin = PF_MEDAL_SKIN_SILVER; medal_sound = SND_MEDAL_SILVER; break;
		case 0: prop_skin = PF_MEDAL_SKIN_BRONZE; medal_sound = SND_MEDAL_BRONZE; break;
		default: prop_skin = 5; medal_sound = null;
	}
	
	local medal = SpawnEntityFromTable("prop_dynamic",
	{
		model = PF_MEDAL_MODEL,
		skin = prop_skin,
		origin = prop_origin,
		modelscale = 1.0,
		DefaultAnim = "spin",
		playbackrate = 0.50,
		solid = 0,
		DisableBoneFollowers = true
	})
	
	Entities.DispatchSpawn(medal);
	client.EmitSound(medal_sound);
	local particle_origin = prop_origin;
	particle_origin.z += 20;
	DispatchParticleEffect("outerwall_medal_" + MedalTypes[medal_type], particle_origin, Vector(0,90,0));
	EntFireByHandle(medal, "Kill", "", 10.0, client, null);
}