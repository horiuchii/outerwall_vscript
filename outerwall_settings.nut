::PlayerCurrentSettingQuery <- array(MAX_PLAYERS, null)

::SetPlayerSettingQuery <- function(iSetting)
{
	local player_index = activator.GetEntityIndex();
	PlayerCurrentSettingQuery[player_index] = iSetting;
	ResetProfileProgress[player_index] = 0;
	UpdateSettingsText(player_index);
}

const LEADERBOARD_RESET_TIME = 300

::ProfileSelection <- array(MAX_PLAYERS, 0)
::AchievementSelection <- array(MAX_PLAYERS, 0)
::CosmeticSelection <- array(MAX_PLAYERS, 0)
::ResetProfileProgress <- array(MAX_PLAYERS, 0)
::LastUpdatedLeaderboard <- 0

::CheckSettingButton <- function(client)
{
	local player_index = client.GetEntityIndex();

	local buttons = NetProps.GetPropInt(client, "m_nButtons");

	if(PlayerCurrentSettingQuery[player_index] == null)
	{
		NetProps.SetPropFloat(client, "m_flNextAttack", 0);
		return;
	}

	local ButtonPressed = null;
	NetProps.SetPropFloat(client, "m_flNextAttack", 9999999);

	//If our previous key capture doesn't contain attack key && new one does.
	if(!(PreviousButtons[player_index] & IN_ATTACK) && buttons & IN_ATTACK)
		ButtonPressed = BUTTON_MOUSE1;
	else if(!(PreviousButtons[player_index] & IN_ATTACK2) && buttons & IN_ATTACK2)
		ButtonPressed = BUTTON_MOUSE2;
	else if(!(PreviousButtons[player_index] & IN_ATTACK3) && buttons & IN_ATTACK3)
		ButtonPressed = BUTTON_MOUSE3;

	if(ButtonPressed == null)
		return;

	switch(PlayerCurrentSettingQuery[player_index])
	{
		case eSettingQuerys.DisplayTime:
		{
			if(ButtonPressed != BUTTON_MOUSE1)
				return;

			PlayerSettingDisplayTime[player_index] = (!!!PlayerSettingDisplayTime[player_index]).tointeger();
			break;
		}
		case eSettingQuerys.DisplayCheckpoint:
		{
			if(ButtonPressed != BUTTON_MOUSE1)
				return;

			local current_setting = PlayerSettingDisplayCheckpoint[player_index];
			if(current_setting == 0)
				PlayerSettingDisplayCheckpoint[player_index] = 1;
			else if(current_setting == 1)
				PlayerSettingDisplayCheckpoint[player_index] = 2;
			else if(current_setting == 2)
				PlayerSettingDisplayCheckpoint[player_index] = 0;

			break;
		}
		case eSettingQuerys.Soundtrack:
		{
			if(ButtonPressed == BUTTON_MOUSE3)
				return;

			local current_track = PlayerSoundtrackList[player_index];
			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(current_track == OUTERWALL_SETTING_SOUNDTRACK_OPTION.len() - 1)
					current_track = 0;
				else
					current_track++;
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(current_track == 0)
					current_track = OUTERWALL_SETTING_SOUNDTRACK_OPTION.len() - 1;
				else
					current_track--;
			}

			SetPlayerSoundtrack(current_track, client);
			break;
		}
		case eSettingQuerys.Encore:
		{
			if(ButtonPressed != BUTTON_MOUSE1)
				return;

			if(IsPlayerEncorable(player_index) || IsPlayerSpecial(player_index))
				PlayerEncoreStatus[player_index] = (!!!PlayerEncoreStatus[player_index]).tointeger();
			else
				return;

			EncoreTeamCheck(client);
			break;
		}
		case eSettingQuerys.Profile:
		{
			if(ButtonPressed == BUTTON_MOUSE3)
				return;

			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(ProfileSelection[player_index] == 7)
					ProfileSelection[player_index] = 0;
				else
					ProfileSelection[player_index]++;
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(ProfileSelection[player_index] == 0)
					ProfileSelection[player_index] = 7;
				else
					ProfileSelection[player_index]--;
			}

			UpdatePlayerStatsText(client);
			break;
		}
		case eSettingQuerys.Achievement:
		{
			if(ButtonPressed == BUTTON_MOUSE3)
				return;

			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(AchievementSelection[player_index] == eAchievements.MAX - 2)
					AchievementSelection[player_index] = 0;
				else
					AchievementSelection[player_index]++;
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(AchievementSelection[player_index] == 0)
					AchievementSelection[player_index] = eAchievements.MAX - 1;
				else
					AchievementSelection[player_index]--;
			}

			UpdateAchievementStatsText(client);
			break;
		}
		case eSettingQuerys.Cosmetic:
		{
			if(ButtonPressed == BUTTON_MOUSE3)
				return;

			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(CosmeticSelection[player_index] == OUTERWALL_COSMETIC_NAME.len() - 1)
					CosmeticSelection[player_index] = 0;
				else
					CosmeticSelection[player_index]++;
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(!!PlayerAchievements[player_index][Cosmetic_Requirement[CosmeticSelection[player_index]]])
				{
					if(PlayerCosmeticEquipped[player_index] - 1 == CosmeticSelection[player_index])
						PlayerCosmeticEquipped[player_index] = 0;
					else
						PlayerCosmeticEquipped[player_index] = CosmeticSelection[player_index] + 1;
				}
				else
					return;
			}

			UpdateCosmeticEquipText(client);
			break;
		}
		case eSettingQuerys.ResetProfile:
		{
			if(ResetProfileProgress[player_index] == -1 || ResetProfileProgress[player_index] == -2 || ButtonPressed == BUTTON_MOUSE3)
				return;

			if(ButtonPressed == ResetProfile_Answers[ResetProfileProgress[player_index]])
			{
				// if(ResetProfileProgress[player_index] == 7)
				// 	//playsound
				// else if(ResetProfileProgress[player_index] == 6)
				// 	//playsound

				if(ResetProfileProgress[player_index] == ResetProfile_Answers.len() - 1)
				{
					ResetProfileProgress[player_index] = -2;

					if(PlayerPreventSaving[player_index] == true)
					{
						ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to reset your save due to a previous error.");
						UpdateResetProfileText(client);
						return;
					}

					ResetPlayerDataArrays(player_index);
					PlayerSaveGame(client);
					PlayerLoadGame(player_index);
					EncoreTeamCheck(client);
					RemovePlayerFromLeaderboardEntries(PlayerAccountID[player_index]);
				}
				else
					ResetProfileProgress[player_index]++;
			}
			else
				ResetProfileProgress[player_index] = -1;

			UpdateResetProfileText(client);
			break;
		}
		case eSettingQuerys.Leaderboard:
		{
			if(!leaderboard_loaded)
				return;

			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(leaderboard_max_page == 1)
					return;

				SetLeaderboardPage(current_leaderboard_page + 1);
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(leaderboard_max_page == 1)
					return;

				SetLeaderboardPage(current_leaderboard_page - 1);
			}
			else if(ButtonPressed == BUTTON_MOUSE3)
			{
				if(LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME > Time())
					return;

				LastUpdatedLeaderboard = Time();
				PopulateLeaderboard();
			}
			UpdateLeaderboardText(client);
			break;
		}
	}

	if(PlayerCurrentSettingQuery[player_index] == eSettingQuerys.Achievement || (PlayerCurrentSettingQuery[player_index] == eSettingQuerys.Cosmetic && ButtonPressed == 1))
		EmitSoundOnClient(SND_MENU_MOVE, client);
	else
		EmitSoundOnClient(SND_MENU_SELECT, client);

	if(PlayerCurrentSettingQuery[player_index] <= eSettingQuerys.Encore)
		UpdateSettingsText(player_index);
}

::UpdateSettingsText <- function(player_index)
{
	local SettingName = null;
	local SettingDesc = null;
	local SettingOption = null;

	if(PlayerCurrentSettingQuery[player_index] > eSettingQuerys.Encore || PlayerCurrentSettingQuery[player_index] == null)
		return;

	SettingName = TranslateString(OUTERWALL_SETTING_TITLE, player_index) + " - " + TranslateString(OUTERWALL_SETTING_NAME[PlayerCurrentSettingQuery[player_index]], player_index);
	SettingDesc = TranslateString(OUTERWALL_SETTING_DESC[PlayerCurrentSettingQuery[player_index]], player_index);

	switch(PlayerCurrentSettingQuery[player_index])
	{
		case eSettingQuerys.DisplayTime:
		{
			SettingOption = TranslateString(OUTERWALL_SETTING_OPTION[PlayerSettingDisplayTime[player_index].tointeger()], player_index);
			break;
		}
		case eSettingQuerys.DisplayCheckpoint:
		{
			SettingOption = TranslateString(OUTERWALL_SETTING_CHECKPOINTTIME_OPTION[PlayerSettingDisplayCheckpoint[player_index].tointeger()], player_index);
			break;
		}
		case eSettingQuerys.Soundtrack:
		{
			SettingOption = TranslateString(OUTERWALL_SETTING_SOUNDTRACK_OPTION[PlayerSoundtrackList[player_index]], player_index);
			break;
		}
		case eSettingQuerys.Encore:
		{
			SettingOption = TranslateString(OUTERWALL_SETTING_OPTION[PlayerEncoreStatus[player_index].tointeger()], player_index);
			break;
		}
		default: break;
	}

	if(SettingName == null || SettingDesc == null || SettingOption == null)
		return;

	local SettingsText = SettingName + "\n" + SettingDesc + "\n\n" + TranslateString(OUTERWALL_SETTING_CURRENT, player_index) + SettingOption + "\n";

	if(!IsPlayerEncorable(player_index) && PlayerCurrentSettingQuery[player_index] == eSettingQuerys.Encore)
		SettingsText += TranslateString(OUTERWALL_SETTING_ENCORE_NOQUALIFY, player_index);
	else
	{
		if(PlayerCurrentSettingQuery[player_index] == eSettingQuerys.Soundtrack)
		{
			SettingsText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NEXTPAGE, player_index) + "\n";
			SettingsText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_PREVPAGE, player_index);
		}
		else
			SettingsText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_TOGGLE, player_index);
	}


	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", SettingsText);
}

::AttemptAutoUpdatePlayerStatsText <- function()
{
	if(ProfileSelection[activator.GetEntityIndex()] == 0)
		UpdatePlayerStatsText(activator);
}

::UpdatePlayerStatsText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local StatsText = "";

	StatsText += TranslateString(OUTERWALL_PROFILE_TITLE, player_index) + " (" + (ProfileSelection[player_index] + 1) + " / 8) - ";

	if(ProfileSelection[player_index] == 0)
	{
		StatsText += TranslateString(OUTERWALL_STATS_SUBTITLE_STATS, player_index);
		StatsText += "\n" + TranslateString(OUTERWALL_STATS_TIMEPLAYED, player_index) + FormatTimeHours(PlayerSecondsPlayed[player_index]) + "\n";

		local achievement_count = 0;
		foreach(playerdata in PlayerAchievements[player_index])
			achievement_count += playerdata.tointeger();

		StatsText += TranslateString(OUTERWALL_STATS_ACHIEVEMENTS, player_index) + achievement_count + " / " + (eAchievements.MAX - 1) + "\n";
		StatsText += TranslateString(OUTERWALL_STATS_TIMESHURT, player_index) + PlayerTimesHurt[player_index] + "\n";
		StatsText += TranslateString(OUTERWALL_STATS_RUNSRAN, player_index) + PlayerRunsRan[player_index] + "\n"

		if(IsPlayerEncorable(player_index))
		{
			StatsText += TranslateString(OUTERWALL_STATS_LAPSRAN, player_index) + PlayerLapsRan[player_index] + "\n";

			local total_time = 0;
			foreach(time in PlayerBestTimeArray[player_index])
				total_time += time;

			StatsText += TranslateString(OUTERWALL_STATS_TOTALTIME, player_index) + FormatTime(round(total_time, 2)) + "\n";
		}
		else
			StatsText += "\n\n";

		StatsText += "\n";
	}
	else
	{
		local iZone = ProfileSelection[player_index] - 1;
		StatsText += TranslateString(OUTERWALL_STATS_SUBTITLE_TIMES, player_index) + "\n";
		StatsText += "[" + ZoneNames[iZone] + "] ~ " + (iZone == 0 ? "Main Stage" : "Bonus " + iZone) + "\n";
		StatsText += TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : GetPlayerBestMedal(player_index, iZone, false) == -1 ? TranslateString(OUTERWALL_TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, false)], player_index)) + "\n";
		StatsText += TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_TIME, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : FormatTime(PlayerBestTimeArray[player_index][iZone])) + "\n";

		local checktime = [
			PlayerBestCheckpointTimeArrayOne[player_index][iZone]
			PlayerBestCheckpointTimeArrayTwo[player_index][iZone]
		]

		for(local i = 0; i < 2; i++)
		{
			StatsText += format(TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT, player_index), i + 1);
			if(PlayerBestTimeArray[player_index][iZone] == 5000)
				StatsText += TranslateString(OUTERWALL_TIMER_NONE, player_index);
			else
				StatsText += checktime[i] == 5000 ? TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT_SKIPPED, player_index) : FormatTime(checktime[i]);

			StatsText += "\n";
		}

		if(IsPlayerEncorable(player_index))
		{
			StatsText += TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL_ENCORE, player_index) + (GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : TranslateString(OUTERWALL_TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, true)], player_index));
			StatsText += (iZone != 6 ? ("\n" + TranslateString(OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_LAP, player_index)) + (GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(OUTERWALL_TIMER_NONE, player_index) : PlayerBestLapCountEncoreArray[player_index][iZone]) : "\n") + "\n";
		}
		else
			StatsText += "\n\n";
	}

	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NEXTPAGE, player_index) + "\n";
	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_PREVPAGE, player_index) + "\n";

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateAchievementStatsText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local StatsText = "";

	StatsText += TranslateString(OUTERWALL_ACHIEVEMENT_TITLE, player_index) + " ";
	StatsText += "(" + (AchievementSelection[player_index] + 1) + " / " + (eAchievements.MAX - 1) + ")\n";

	if((!IsPlayerEncorable(player_index) && AchievementSelection[player_index] > eAchievements.NormalIri) ||
	(AchievementSelection[player_index] == eAchievements.SecretClimb && !!!PlayerAchievements[player_index][eAchievements.SecretClimb]) ||
	(AchievementSelection[player_index] == eAchievements.SecretSmokey && !!!PlayerAchievements[player_index][eAchievements.SecretSmokey]))
	{
		StatsText += "???\n???\n\n"
	}
	else
	{
		StatsText += TranslateString(OUTERWALL_ACHIEVEMENT_NAME[AchievementSelection[player_index]], player_index) + "\n";
		StatsText += TranslateString(OUTERWALL_ACHIEVEMENT_DESC[AchievementSelection[player_index]], player_index) + "\n";
	}

	StatsText += !!PlayerAchievements[player_index][AchievementSelection[player_index]] ? "[O]\n" : "[X]\n";
	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NEXTPAGE, player_index) + "\n";
	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_PREVPAGE, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateCosmeticEquipText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local EquipText = "";

	EquipText += TranslateString(OUTERWALL_COSMETIC_TITLE, player_index) + " ";
	EquipText += "(" + (CosmeticSelection[player_index] + 1) + " / " + OUTERWALL_COSMETIC_NAME.len() + ")\n";

	EquipText += TranslateString(OUTERWALL_COSMETIC_NAME[CosmeticSelection[player_index]], player_index) + "\n";
	EquipText += TranslateString(OUTERWALL_COSMETIC_DESC[CosmeticSelection[player_index]], player_index) + "\n";

	EquipText += "\n";

	EquipText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NEXTPAGE, player_index) + "\n";

	//if our cosmetic achievement isnt met, display the not unlocked message
	if(!!!PlayerAchievements[player_index][Cosmetic_Requirement[CosmeticSelection[player_index]]])
		EquipText += format(TranslateString(OUTERWALL_COSMETIC_REQUIREMENT, player_index), TranslateString(OUTERWALL_ACHIEVEMENT_NAME[Cosmetic_Requirement[CosmeticSelection[player_index]]], player_index));
	else if(CosmeticSelection[player_index] + 1 == PlayerCosmeticEquipped[player_index])
		EquipText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_UNEQUIP, player_index);
	else
		EquipText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_EQUIP, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", EquipText);
}

::UpdateResetProfileText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local ResetText = "";

	ResetText += TranslateString(OUTERWALL_RESET_PROFILE_TITLE, player_index) + "\n\n";

	if(ResetProfileProgress[player_index] == -1)
		ResetText += TranslateString(OUTERWALL_RESET_PROFILE_NORESET, player_index);
	else if(ResetProfileProgress[player_index] == -2)
		ResetText += TranslateString(OUTERWALL_RESET_PROFILE_RESET, player_index);
	else
	{
		ResetText += TranslateString(OUTERWALL_RESET_PROFILE_QUESTIONS[ResetProfileProgress[player_index]], player_index) + "\n\n";
		ResetText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_YES, player_index) + "\n";
		ResetText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NO, player_index) + "\n";
	}

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", ResetText);
}

::UpdateLeaderboardText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local LeaderText = "";

	if(!leaderboard_loaded)
	{
		LeaderText = TranslateString(OUTERWALL_LEADERBOARD_TITLE, player_index) + "\n\n" + TranslateString(OUTERWALL_LEADERBOARD_NOENTRIES, player_index)
		local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
		NetProps.SetPropString(text, "m_iszMessage", LeaderText);
		return;
	}

	LeaderText += TranslateString(OUTERWALL_LEADERBOARD_TITLE, player_index) + " (" + TranslateString(OUTERWALL_LEADERBOARD_PAGE, player_index) + current_leaderboard_page + " / " + leaderboard_max_page + ")\n";

	local player_rank = PlayerCachedLeaderboardPosition[player_index];
	if(player_rank == null)
	{
		foreach(i, ranking in leaderboard_array)
		{
			if(PlayerAccountID[player_index] == null)
				break;

			if(ranking.account_id == PlayerAccountID[player_index])
			{
				PlayerCachedLeaderboardPosition[player_index] = i + 1;
				player_rank = PlayerCachedLeaderboardPosition[player_index];
				break;
			}
		}

		if(player_rank == null)
		{
			PlayerCachedLeaderboardPosition[player_index] = -1;
			player_rank = PlayerCachedLeaderboardPosition[player_index];
		}

		DebugPrint("cached player " + player_index + "leaderboard rank: " + player_rank);
	}

	LeaderText += (TranslateString(OUTERWALL_LEADERBOARD_RANK, player_index) + (player_rank != -1 ? ("#" + player_rank) : TranslateString(OUTERWALL_TIMER_NONE, player_index))) + "\n\n";

	LeaderText += TranslateString(OUTERWALL_SETTING_BUTTON_ATTACK, player_index) + TranslateString(OUTERWALL_SETTING_NEXTPAGE, player_index) + "\n";
	LeaderText += TranslateString(OUTERWALL_SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(OUTERWALL_SETTING_PREVPAGE, player_index) + "\n";

	if(LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME > Time())
		LeaderText += format(TranslateString(OUTERWALL_LEADERBOARD_BUTTON_REFRESHWAIT, player_index), FormatTime((LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME - Time()).tointeger()));
	else
		LeaderText += TranslateString(OUTERWALL_SETTING_BUTTON_SPECIALATTACK, player_index) + TranslateString(OUTERWALL_SETTING_REFRESHLEADERBOARD, player_index);


	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", LeaderText);
}