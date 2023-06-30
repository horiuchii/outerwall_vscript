const PF_MEDAL_MODEL = "models/beepin/pf_medal/pf_medal.mdl"
const PF_MEDAL_SKIN_IRIDESCENT = 1;
const PF_MEDAL_SKIN_GOLD = 2;
const PF_MEDAL_SKIN_SILVER = 3;
const PF_MEDAL_SKIN_BRONZE = 4;
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
	[100, 70, 50, 40], //oside
	[75, 45, 35, 30], //last cave
	[90, 65, 55, 42], //balcony
	[70, 45, 35, 25], //inner wall
	[165, 100, 85, 65], //hell
	[175, 110, 95, 85], //wind fortress
	[185, 135, 115, 95], //sand pit
]

::ZoneLaps_Encore <-
[
	// bronze, silver, gold, iridescence
	[2, 3, 4, 5], //oside
	[2, 3, 4, 5], //last cave
	[2, 3, 4, 5], //balcony
	[2, 3, 4, 5], //inner wall
	[2, 3, 4, 5], //hell
	[2, 3, 4, 5], //wind fortress
	[155, 135, 115, 100], //sand pit
]

::MedalLocations <-
[
	Vector(2336,896,-11928), //oside
	Vector(5472,-4736,12056), //lastcave
	Vector(4704,-6416,14056), //balcony
	Vector(-4640,-8352,-12728), //inner wall
	Vector(-5696,-1247,12457), //hell
	Vector(2079,4704,14856), //wind fortress
	Vector(4928,6944,-13392) //sand pit
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
]

::LEADERBOARD_IRI <- 0;
::LEADERBOARD_GOLD <- 0;
::LEADERBOARD_SILVER <- 0;
::LEADERBOARD_BRONZE <- 0;

::SetLeaderboardMedalTimes <- function()
{
	for(local iZone = 0; iZone < ZONE_COUNT; iZone++)
	{
		for(local iMedal = 0; iMedal < 4; iMedal++)
		{
			if(iMedal == 3)
				LEADERBOARD_IRI += ZoneTimes[iZone][iMedal];
			if(iMedal == 2)
				LEADERBOARD_GOLD += ZoneTimes[iZone][iMedal];
			if(iMedal == 1)
				LEADERBOARD_SILVER += ZoneTimes[iZone][iMedal];
			if(iMedal == 0)
				LEADERBOARD_BRONZE += ZoneTimes[iZone][iMedal];
		}
	}
}

::PlayerStartTime <- array(MAX_PLAYERS, 0)
::PlayerCheckpointTimes <- ConstructTwoDimArray(MAX_PLAYERS, CHECKPOINT_COUNT, 5000)
::PlayerMedalTimeHUDStatusArray <- array(MAX_PLAYERS, false)
::PlayerCheatedCurrentRun <- array(MAX_PLAYERS, false)

::DisplayTime <- function(player_index, time, iMedal, iZone)
{
	local messagecolor = iMedal == null || iMedal == -1 ? NO_MEDAL_COLOR : MedalColors[iMedal];

	//compare time to best if applicable
	local personal_best_text = "";
	local personal_best = PlayerBestTimeArray[player_index][iZone];
	if(personal_best != 5000)
	{
		local bTimeIsImprovement = false;

		if(time < personal_best || time == personal_best)
			bTimeIsImprovement = true;

		local personal_diff = (bTimeIsImprovement ? "\x073EFF3E-" : "\x07FF0000+") + FormatTime(fabs(personal_best - time));
		personal_best_text = TranslateString(OUTERWALL_TIMER_PERSONALBEST, player_index) + personal_diff;
	}

	local rankmessage = "(" + (iMedal == null || iMedal == -1 ? TranslateString(OUTERWALL_TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[iMedal], player_index)) + ")";

	PrintToPlayerAndSpectators(player_index, "\x01" + TranslateString(OUTERWALL_TIMER_FINALTIME, player_index) + FormatTime(time) + personal_best_text + " " + "\x07" + messagecolor + rankmessage);
}

::DisplayTimeEncore <- function(player_index, time, iMedal)
{
	local messagecolor = iMedal == null || iMedal == -1 ? NO_MEDAL_COLOR : MedalColors[iMedal];
	local lapmessage = PlayerCurrentLapCount[player_index] == 1 ? OUTERWALL_TIMER_FINALTIME_LAPCOUNT[0] : OUTERWALL_TIMER_FINALTIME_LAPCOUNT[1];
	local laptext = format(TranslateString(lapmessage, player_index), PlayerCurrentLapCount[player_index]);
	local rankmessage = "(" + (iMedal == null || iMedal == -1 ? TranslateString(OUTERWALL_TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[iMedal], player_index)) + ")";

	PrintToPlayerAndSpectators(player_index, "\x01" + TranslateString(OUTERWALL_TIMER_FINALTIME, player_index) + FormatTime(time) + laptext + " " + "\x07" + messagecolor + rankmessage);
}

::DisplayLapEncore <- function(player_index)
{
	local time = (Time() - PlayerStartTime[player_index]).tofloat();
	local laptext = format(TranslateString(OUTERWALL_TIMER_FINALTIME_LAPCOUNT[1], player_index), PlayerCurrentLapCount[player_index]);

	PrintToPlayerAndSpectators(player_index, "\x07FF0000" + TranslateString(OUTERWALL_TIMER_LAPTIME, player_index) + "\x01" + FormatTime(time) + laptext);
}

::StartPlayerTimer <- function(client)
{
	local player_index = client.GetEntityIndex();
	PlayerStartTime[player_index] = Time();
	PlayerCheckpointTimes[player_index][0] = 5000;
	PlayerCheckpointTimes[player_index][1] = 5000;
	PlayerCheatedCurrentRun[player_index] = false;
	PlayerLastUseRadar[player_index] = 0;

	//detect if this bitch has the timer off.
	if(NetProps.GetPropFloat(client, "m_flMaxspeed") < 255)
		PlayerCheatedCurrentRun[player_index] = true;
}

::PlayerSetCheckpointTime <- function(player_index)
{
	local checkpoint = PlayerCheckpointStatus[player_index] - 1;

	//do we already have a time?
	if(PlayerCheckpointTimes[player_index][checkpoint] != 5000)
		return;

	//is it the first two checkpoints
	if(checkpoint != 0 && checkpoint != 1)
		return;

	//did we touch checkpoint 2 without having a time on checkpoint 1?
	if(checkpoint == 1 && PlayerCheckpointTimes[player_index][0] == 5000)
		return;

	PlayerCheckpointTimes[player_index][checkpoint] = Time() - PlayerStartTime[player_index];

	if(PlayerSettingDisplayCheckpoint[player_index] == eCheckpointOptions.Bonuses && PlayerZoneList[player_index] == eCourses.OuterWall)
		return;

	else if(PlayerSettingDisplayCheckpoint[player_index] == eCheckpointOptions.Never)
		return;

	local CheckpointString = "\x01";
	local current_checkpoint = PlayerCheckpointTimes[player_index][checkpoint];
	local iZone = PlayerZoneList[player_index];
	CheckpointString += format(TranslateString(OUTERWALL_TIMER_CHECKPOINT, player_index), ZoneNames[iZone]) + (checkpoint + 1) + " " + FormatTime(current_checkpoint);

	local checktime = [
		PlayerBestCheckpointTimeArrayOne[player_index][iZone]
		PlayerBestCheckpointTimeArrayTwo[player_index][iZone]
	]
	local checkpoint_personal_best = checktime[checkpoint];

	if(checkpoint_personal_best != 5000)
	{
		local bTimeIsImprovement = false;

		if(current_checkpoint < checkpoint_personal_best || current_checkpoint == checkpoint_personal_best)
			bTimeIsImprovement = true;

		local checkpoint_personal_diff = (bTimeIsImprovement ? "\x073EFF3E-" : "\x07FF0000+") + FormatTime(fabs(checkpoint_personal_best - current_checkpoint));
		CheckpointString += TranslateString(OUTERWALL_TIMER_PERSONALBEST, player_index) + checkpoint_personal_diff;
	}

	PrintToPlayerAndSpectators(player_index, CheckpointString);
}

::UpdateMedalTimeText <- function(player_index)
{
	local iZone = PlayerZoneList[player_index];
	local MedalTimesText = format(TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_MEDALTIMES, player_index), (!!PlayerEncoreStatus[player_index] ? TranslateString(OUTERWALL_TIMER_ENCORE, player_index) + ZoneNames[iZone] : ZoneNames[iZone]), ZoneSuffixes[iZone]) + "\n";
	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		MedalTimesText += TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY[medal_index], player_index) + ": ";
		MedalTimesText += (!!PlayerEncoreStatus[player_index] && iZone != 6) ? (TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_LAP, player_index) + ZoneLaps_Encore[iZone][medal_index]) : FormatTime(ZoneTimes[iZone][medal_index]);

		MedalTimesText += "\n";
	}

	if(!!!PlayerEncoreStatus[player_index])
	{
		MedalTimesText += "\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : GetPlayerBestMedal(player_index, iZone, false) == -1 ? TranslateString(OUTERWALL_TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, false)], player_index));
		MedalTimesText += "\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_TIME, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : FormatTime(PlayerBestTimeArray[player_index][iZone]));
	}
	else
	{
		MedalTimesText += "\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL, player_index) + (PlayerBestLapCountEncoreArray[player_index][iZone].tointeger() == 0 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(OUTERWALL_TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, true)], player_index));
		MedalTimesText += "\n" + (iZone != 6 ? (TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_LAP, player_index)) + (GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : PlayerBestLapCountEncoreArray[player_index][iZone]) : TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_TIME, player_index) + (PlayerBestSandPitTimeEncoreArray[player_index].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : FormatTime(PlayerBestSandPitTimeEncoreArray[player_index])));
	}

	if(!!!PlayerEncoreStatus[player_index])
	{
		local checktime = [
			PlayerBestCheckpointTimeArrayOne[player_index][iZone]
			PlayerBestCheckpointTimeArrayTwo[player_index][iZone]
		]

		for(local i = 0; i < 2; i++)
		{
			MedalTimesText += "\n" + format(TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT, player_index), i + 1);
			if(PlayerBestTimeArray[player_index][iZone] == 5000)
				MedalTimesText += TranslateString(OUTERWALL_TIMER_NONE, player_index);
			else
				MedalTimesText += checktime[i] == 5000 ? TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT_SKIPPED, player_index) : FormatTime(checktime[i]);
		}
	}

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", MedalTimesText);
}

::SetMedalTimeHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();

	if(bSetHUD)
	{
		local current_setting = PlayerCurrentSettingQuery[player_index];

		if(current_setting == null || current_setting == eSettingQuerys.Profile || current_setting == eSettingQuerys.Leaderboard || current_setting == eSettingQuerys.Achievement)
			EmitSoundOnClient(SND_CHECKPOINT, activator);
		else
			EmitSoundOnClient(SND_MENU_PROMPT, activator);
	}

	PlayerMedalTimeHUDStatusArray[player_index] = bSetHUD;
}

::CheckPlayerMedal <- function(iZone, client)
{
	local player_index = client.GetEntityIndex();

	local player_best_medal = GetPlayerBestMedal(player_index, iZone, !!PlayerEncoreStatus[player_index]);
	DebugPrint("Player " + player_index + "'s best medal for stage " + iZone + " is " + player_best_medal);

	local total_time = Time() - PlayerStartTime[player_index];
	DebugPrint("Player " + player_index + "'s time for stage " + iZone + " is " + total_time);

	local laps_ran = PlayerCurrentLapCount[player_index];

	local medal = null;
	local best_medal_qualified = -1;
	local medal_times = ZoneTimes[iZone];
	local medal_laps = ZoneLaps_Encore[iZone];

	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		if((!!!PlayerEncoreStatus[player_index] && total_time < medal_times[medal_index]) || (!!PlayerEncoreStatus[player_index] && laps_ran >= medal_laps[medal_index]))
		{
			if(player_best_medal >= medal_index)
			{
				DebugPrint(player_best_medal + " is better than " + medal_index);
				continue;
			}

			medal = medal_index;
			DebugPrint("we got the " + medal + " medal")
			break;
		}
	}

	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		if((!!!PlayerEncoreStatus[player_index] && total_time < medal_times[medal_index]) || (!!PlayerEncoreStatus[player_index] && laps_ran >= medal_laps[medal_index]))
		{
			best_medal_qualified = medal_index;
			break;
		}
	}

	if(medal != null)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + MedalColors[medal] + TranslateString(OUTERWALL_TIMER_MESSAGE[medal][RandomInt(0, OUTERWALL_TIMER_MESSAGE[medal].len() - 1)], player_index) + format(TranslateString(OUTERWALL_TIMER_ACHIEVED, player_index), (!!PlayerEncoreStatus[player_index] ? TranslateString(OUTERWALL_TIMER_ENCORE, player_index) + ZoneNames[iZone] : ZoneNames[iZone]), ZoneSuffixes[iZone]) + TranslateString(OUTERWALL_TIMER_MEDAL_ACHIEVED[medal], player_index));

		SpawnPropMedal(medal, iZone, client);
	}

	if(medal == null && player_best_medal == -1)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + NO_MEDAL_COLOR + TranslateString(OUTERWALL_TIMER_MESSAGE_NOMEDAL[RandomInt(0, OUTERWALL_TIMER_MESSAGE_NOMEDAL.len() - 1)], player_index) + format(TranslateString(OUTERWALL_TIMER_ACHIEVED, player_index), (!!PlayerEncoreStatus[player_index] ? TranslateString(OUTERWALL_TIMER_ENCORE, player_index) + ZoneNames[iZone] : ZoneNames[iZone]), ZoneSuffixes[iZone]) + TranslateString(OUTERWALL_TIMER_FAILEDTOQUALIFY, player_index));
	}

	if(PlayerSettingDisplayTime[player_index] == 1)
	{
		if(!!!PlayerEncoreStatus[player_index])
			DisplayTime(player_index, total_time, best_medal_qualified, iZone);
		else
			DisplayTimeEncore(player_index, total_time, best_medal_qualified);
	}

	local bNewRecord = false;

	//set bNewRecord if we surpass or are equal to our best medal && our time is better than the best time
	if(best_medal_qualified >= player_best_medal && (total_time < PlayerBestTimeArray[player_index][iZone] || laps_ran >= PlayerBestLapCountEncoreArray[player_index][iZone]))
	{
		bNewRecord = true;

		if(!!!PlayerEncoreStatus[player_index])
		{
			PlayerBestTimeArray[player_index][iZone] = total_time;
			PlayerBestCheckpointTimeArrayOne[player_index][iZone] = PlayerCheckpointTimes[player_index][0];
			PlayerBestCheckpointTimeArrayTwo[player_index][iZone] = PlayerCheckpointTimes[player_index][1];
		}
		else
		{
			PlayerBestLapCountEncoreArray[player_index][iZone] = laps_ran
		}
	}

	if(medal != null || bNewRecord)
	{
		UpdateMedalTimeText(player_index);
		CheckAchievementBatch_Medals(player_index);
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