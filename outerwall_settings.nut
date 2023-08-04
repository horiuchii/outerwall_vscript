::PlayerCurrentSettingQuery <- array(MAX_PLAYERS, null)
::PlayerCurrentMultiSettingQuery <- array(MAX_PLAYERS, eMultiSettings.DisplayTime)

::SetPlayerSettingQuery <- function(iSetting)
{
	local player_index = activator.GetEntityIndex();
	PlayerCurrentSettingQuery[player_index] = iSetting;
	ResetProfileProgress[player_index] = 0;
	PlayerCosmeticSubMenuActive[player_index] = false;
	PlayerCosmeticColorEdit[player_index] = 0;

	if(iSetting == eSettingQuerys.MultiSetting)
		UpdateMultiSettingsText(player_index);

	NetProps.SetPropFloat(activator, "m_flNextAttack", (iSetting == null ? 0 : 9999999));
}

const LEADERBOARD_RESET_TIME = 300

::ProfileSelection <- array(MAX_PLAYERS, 0)
::AchievementSelection <- array(MAX_PLAYERS, 0)
::CosmeticSelection <- array(MAX_PLAYERS, 0)
::PlayerCosmeticSubMenuActive <- array(MAX_PLAYERS, false)
::PlayerCosmeticColorEdit <- array(MAX_PLAYERS, 0)
::ResetProfileProgress <- array(MAX_PLAYERS, 0)
::LastUpdatedLeaderboard <- 0

::ResetPlayerMenuArrays <- function(player_index)
{
	ProfileSelection[player_index] = 0;
	AchievementSelection[player_index] = 0;
	CosmeticSelection[player_index] = 0;
	PlayerCurrentSettingQuery[player_index] = null;
	PlayerCurrentMultiSettingQuery[player_index] = eMultiSettings.DisplayTime;
	PlayerCosmeticSubMenuActive[player_index] = false;
	PlayerCosmeticColorEdit[player_index] = 0;
}

::CheckSettingButton <- function(client)
{
	local player_index = client.GetEntityIndex();

	local current_setting = PlayerCurrentSettingQuery[player_index];

	if(current_setting == null)
		return;

	local buttons = NetProps.GetPropInt(client, "m_nButtons");
	local ButtonPressed = null;

	//If our previous key capture doesn't contain attack key && new one does.
	if(!(PreviousButtons[player_index] & IN_ATTACK) && buttons & IN_ATTACK)
		ButtonPressed = BUTTON_MOUSE1;
	else if(!(PreviousButtons[player_index] & IN_ATTACK2) && buttons & IN_ATTACK2)
		ButtonPressed = BUTTON_MOUSE2;
	else if(!(PreviousButtons[player_index] & IN_RELOAD) && buttons & IN_RELOAD)
		ButtonPressed = BUTTON_RELOAD;

	if(ButtonPressed == null)
		return;

	switch(current_setting)
	{
		case eSettingQuerys.MultiSetting:
		{
			local current_multisetting = PlayerCurrentMultiSettingQuery[player_index];

			if(ButtonPressed == BUTTON_RELOAD)
			{
				PlayerCurrentMultiSettingQuery[player_index] = (current_multisetting != eMultiSettings.MAX - 1 ? current_multisetting + 1 : 0);
			}
			else
			{
				if(ButtonPressed != BUTTON_MOUSE1)
					return;

				switch(current_multisetting)
				{
					case eMultiSettings.DisplayTime:
					{
						//TODO: remove this when adding encore
						PlayerSettingDisplayTime[player_index] = (!!!PlayerSettingDisplayTime[player_index]).tointeger();
						break;

						local current_setting = PlayerSettingDisplayTime[player_index];
						if(current_setting == 0)
							PlayerSettingDisplayTime[player_index] = 1;
						else if(current_setting == 1)
							PlayerSettingDisplayTime[player_index] = 2;
						else if(current_setting == 2)
							PlayerSettingDisplayTime[player_index] = 0;

						break;
					}
					case eMultiSettings.DisplayCheckpoint:
					{
						local current_setting = PlayerSettingDisplayCheckpoint[player_index];
						if(current_setting == 0)
							PlayerSettingDisplayCheckpoint[player_index] = 1;
						else if(current_setting == 1)
							PlayerSettingDisplayCheckpoint[player_index] = 2;
						else if(current_setting == 2)
							PlayerSettingDisplayCheckpoint[player_index] = 0;

						break;
					}
					case eMultiSettings.PlayCharSound:
					{
						PlayerSettingPlayCharSounds[player_index] = (!!!PlayerSettingPlayCharSounds[player_index]).tointeger();
						break;
					}
					case eMultiSettings.Soundtrack:
					{
						local current_track = PlayerSoundtrackList[player_index];

						if(current_track == Soundtracks.len() - 1)
							current_track = 0;
						else
							current_track++;

						SetPlayerSoundtrack(current_track, client);
						break;
					}
					case eMultiSettings.Encore:
					{
						//TODO: REMOVE ME WHEN WE RELEASE WITH ENCORE
						return;

						if(IsPlayerEncorable(player_index))
							PlayerEncoreStatus[player_index] = (!!!PlayerEncoreStatus[player_index]).tointeger();
						else
							return;

						EncoreTeamCheck(client);
						break;
					}
				}
			}

			UpdateMultiSettingsText(player_index);
			break;
		}
		case eSettingQuerys.Profile:
		{
			if(ButtonPressed == BUTTON_RELOAD)
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
			if(ButtonPressed == BUTTON_RELOAD)
				return;

			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(AchievementSelection[player_index] == eAchievements.MAX - 1)
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
			local bEquipped = false;

			if(!PlayerCosmeticSubMenuActive[player_index])
			{
				if(ButtonPressed == BUTTON_MOUSE1)
				{
					if(CosmeticSelection[player_index] == eCosmetics.MAX - 2)
						CosmeticSelection[player_index] = 0;
					else
						CosmeticSelection[player_index]++;
				}
				else if(ButtonPressed == BUTTON_MOUSE2)
				{
					if(CosmeticSelection[player_index] == 0)
						CosmeticSelection[player_index] = eCosmetics.MAX - 2;
					else
						CosmeticSelection[player_index]--;
				}
				else if(ButtonPressed == BUTTON_RELOAD)
				{
					if(HasAchievement(Cosmetic_Requirement[CosmeticSelection[player_index]], player_index) || !!PlayerHasPlaytesterBonus[player_index])
					{
						if(CosmeticSelection[player_index] == eCosmetics.MachTrail - 1)
							PlayerCosmeticSubMenuActive[player_index] = true;
						else if(PlayerCosmeticEquipped[player_index] - 1 == CosmeticSelection[player_index])
							PlayerCosmeticEquipped[player_index] = 0;
						else
						{
							PlayerCosmeticEquipped[player_index] = CosmeticSelection[player_index] + 1;
							bEquipped = true;
						}
					}
					else
						return;
				}
			}
			else
			{
				if(ButtonPressed == BUTTON_MOUSE1)
				{
					if(PlayerCosmeticColorEdit[player_index] == 3)
						PlayerCosmeticColorEdit[player_index] = 0;
					else
						PlayerCosmeticColorEdit[player_index]++;
				}
				else if(ButtonPressed == BUTTON_MOUSE2)
				{
					PlayerCosmeticSubMenuActive[player_index] = false;
					PlayerCosmeticColorEdit[player_index] = 0;
				}
				else if(ButtonPressed == BUTTON_RELOAD)
				{
					if(PlayerCosmeticEquipped[player_index] - 1 == CosmeticSelection[player_index])
						PlayerCosmeticEquipped[player_index] = 0;
					else
					{
						PlayerCosmeticEquipped[player_index] = CosmeticSelection[player_index] + 1;
						bEquipped = true;
					}
				}
			}

			if(bEquipped && RandomInt(1, 100) <= 50)
				EntFireByHandle(client, "RunScriptCode", "PlayVO(" + player_index + ",ScoutVO_CosmeticEquip);", 0.1, null, null);

			UpdateCosmeticEquipText(client);
			break;
		}
		case eSettingQuerys.ResetProfile:
		{
			return;

			if(ResetProfileProgress[player_index] == -1 || ResetProfileProgress[player_index] == -2 || ButtonPressed == BUTTON_RELOAD)
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
					PlayerCachedLeaderboardPosition[player_index] = null;
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
			if(ButtonPressed == BUTTON_MOUSE1)
			{
				if(!leaderboard_loaded || leaderboard_max_page == 1)
					return;

				SetLeaderboardPage(current_leaderboard_page + 1);
			}
			else if(ButtonPressed == BUTTON_MOUSE2)
			{
				if(!leaderboard_loaded || leaderboard_max_page == 1)
					return;

				SetLeaderboardPage(current_leaderboard_page - 1);
			}
			else if(ButtonPressed == BUTTON_RELOAD)
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

	if((current_setting == eSettingQuerys.MultiSetting && ButtonPressed == BUTTON_RELOAD) ||
	current_setting == eSettingQuerys.Profile ||
	current_setting == eSettingQuerys.Achievement ||
	(current_setting == eSettingQuerys.Cosmetic && ButtonPressed != BUTTON_RELOAD) ||
	(current_setting == eSettingQuerys.Leaderboard && ButtonPressed != BUTTON_RELOAD))
		EmitSoundOnClient(SND_MENU_MOVE, client);
	else
		EmitSoundOnClient(SND_MENU_SELECT, client);
}

::UpdateMultiSettingsText <- function(player_index)
{
	local SettingName = null;
	local SettingDesc = null;
	local SettingOption = null;

	local current_multisetting = PlayerCurrentMultiSettingQuery[player_index];

	SettingName = TranslateString(MULTISETTING_TITLE, player_index) + " - " + TranslateString(MULTISETTING_NAME[current_multisetting], player_index);
	SettingDesc = TranslateString(MULTISETTING_DESC[current_multisetting], player_index);

	switch(current_multisetting)
	{
		case eMultiSettings.DisplayTime:
		{
			SettingOption = TranslateString(SETTING_OPTION[PlayerSettingDisplayTime[player_index].tointeger()], player_index);
			break;
		}
		case eMultiSettings.DisplayCheckpoint:
		{
			SettingOption = TranslateString(SETTING_CHECKPOINTTIME_OPTION[PlayerSettingDisplayCheckpoint[player_index].tointeger()], player_index);
			break;
		}
		case eMultiSettings.PlayCharSound:
		{
			SettingOption = TranslateString(SETTING_OPTION[PlayerSettingPlayCharSounds[player_index].tointeger()], player_index);
			break;
		}
		case eMultiSettings.Soundtrack:
		{
			SettingOption = TranslateString(SETTING_SOUNDTRACK_OPTION[PlayerSoundtrackList[player_index]], player_index);
			break;
		}
		case eMultiSettings.Encore:
		{
			SettingOption = TranslateString(SETTING_OPTION[PlayerEncoreStatus[player_index].tointeger()], player_index);
			break;
		}
	}

	if(SettingName == null || SettingDesc == null || SettingOption == null)
		return;

	local SettingsText = SettingName + "\n" + SettingDesc + "\n\n";

	SettingsText += (current_multisetting == eMultiSettings.Soundtrack ? TranslateString(SOUNDTRACK_AUTHOR, player_index) + SoundtrackAuthors[PlayerSoundtrackList[player_index]] : "") + "\n";

	SettingsText += TranslateString(SETTING_CURRENT, player_index) + SettingOption + "\n";

	if(current_multisetting == eMultiSettings.Encore)
		SettingsText += TranslateString(SETTING_COMINGSOON, player_index) + "\n";
	else
		SettingsText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_TOGGLE, player_index) + "\n";

	local next_setting = (current_multisetting != eMultiSettings.MAX - 1 ? current_multisetting + 1 : 0);

	SettingsText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString(SETTING_NEXTPAGE, player_index) + " (" + TranslateString(MULTISETTING_NAME[next_setting], player_index) + ")";

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

	StatsText += TranslateString(PROFILE_TITLE, player_index) + (!!PlayerHasPlaytesterBonus[player_index] ? " ★" : "") + " (" + (ProfileSelection[player_index] + 1) + " / 8) - ";

	if(ProfileSelection[player_index] == 0)
	{
		StatsText += TranslateString(STATS_SUBTITLE_STATS, player_index);
		StatsText += "\n" + TranslateString(STATS_TIMEPLAYED, player_index) + FormatTimeHours(PlayerSecondsPlayed[player_index]) + "\n";

		local achievement_count = 0;
		for (local i = 0; i < eAchievements.MAX; i++)
			achievement_count += (HasAchievement(i, player_index)).tointeger()

		StatsText += TranslateString(STATS_ACHIEVEMENTS, player_index) + achievement_count + " / " + eAchievements.MAX + "\n";
		StatsText += TranslateString(STATS_TIMESHURT, player_index) + PlayerTimesHurt[player_index] + "\n";
		StatsText += TranslateString(STATS_RUNSRAN, player_index) + PlayerRunsRan[player_index] + "\n"

		if(IsPlayerEncorable(player_index))
		{
			StatsText += "\n";
			//StatsText += TranslateString(STATS_LAPSRAN, player_index) + PlayerLapsRan[player_index] + "\n";

			local total_time = 0;
			foreach(time in PlayerBestTimeArray[player_index])
				total_time += time;

			StatsText += TranslateString(STATS_TOTALTIME, player_index) + FormatTime(round(total_time, 2)) + "\n";
		}
		else
			StatsText += "\n\n";

		StatsText += "\n";
	}
	else
	{
		local iZone = ProfileSelection[player_index] - 1;
		StatsText += TranslateString(STATS_SUBTITLE_TIMES, player_index) + "\n";
		StatsText += "[" + ZoneNames[iZone] + "] ~ " + (iZone == 0 ? TranslateString(STATS_TIMES_MAINSTAGE, player_index) : TranslateString(STATS_TIMES_BONUS, player_index) + iZone) + "\n";
		StatsText += TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(TIMER_NONE, player_index) : GetPlayerBestMedal(player_index, iZone, false) == -1 ? TranslateString(TIMER_MEDAL_NOMEDAL, player_index) : TranslateString(TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, false)], player_index)) + "\n";
		StatsText += TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_TIME, player_index) + (PlayerBestTimeArray[player_index][iZone].tointeger() == 5000 ? TranslateString(TIMER_NONE, player_index) : FormatTime(PlayerBestTimeArray[player_index][iZone])) + "\n";

		local checktime = [
			PlayerBestCheckpointTimeArrayOne[player_index][iZone]
			PlayerBestCheckpointTimeArrayTwo[player_index][iZone]
		]

		for(local i = 0; i < 2; i++)
		{
			StatsText += format(TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT, player_index), i + 1);
			if(PlayerBestTimeArray[player_index][iZone] == 5000)
				StatsText += TranslateString(TIMER_NONE, player_index);
			else
				StatsText += checktime[i] == 5000 ? TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT_SKIPPED, player_index) : FormatTime(checktime[i]);

			StatsText += "\n";
		}

		if(IsPlayerEncorable(player_index))
		{
			StatsText += "\n\n";
			//StatsText += TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL_ENCORE, player_index) + (GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(TIMER_NONE, player_index) : TranslateString(TIMER_MEDAL[GetPlayerBestMedal(player_index, iZone, true)], player_index));
			//StatsText += (iZone != 6 ? ("\n" + TranslateString(TIMER_MEDAL_DISPLAY_SERVERBEST_LAP, player_index)) + (GetPlayerBestMedal(player_index, iZone, true) == -1 ? TranslateString(TIMER_NONE, player_index) : PlayerBestLapCountEncoreArray[player_index][iZone]) : "\n") + "\n";
		}
		else
			StatsText += "\n\n";
	}

	StatsText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_NEXTPAGE, player_index) + "\n";
	StatsText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_PREVPAGE, player_index) + "\n";

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateAchievementStatsText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local StatsText = "";

	StatsText += TranslateString(ACHIEVEMENT_TITLE, player_index) + " ";
	StatsText += "(" + (AchievementSelection[player_index] + 1) + " / " + eAchievements.MAX + ")\n";

	if((!IsPlayerEncorable(player_index) && AchievementSelection[player_index] > eAchievements.NormalIri) ||
	(AchievementSelection[player_index] == eAchievements.SecretClimb && !HasAchievement(eAchievements.SecretClimb, player_index)) ||
	(AchievementSelection[player_index] == eAchievements.SecretSmokey && !HasAchievement(eAchievements.SecretSmokey, player_index)))
	{
		StatsText += "???\n???\n\n\n"
	}
	else
	{
		StatsText += "[" + TranslateString(ACHIEVEMENT_NAME[AchievementSelection[player_index]], player_index) + "]\n";
		StatsText += TranslateString(ACHIEVEMENT_DESC[AchievementSelection[player_index]], player_index) + "\n";
	}

	StatsText += HasAchievement(AchievementSelection[player_index], player_index) ? "[O]" : "[X]\n";

	if(HasAchievement(AchievementSelection[player_index], player_index))
	{
		local achievementdate = PlayerAchievements[player_index][AchievementSelection[player_index]].tostring();
		StatsText += TranslateString(ACHIEVEMENT_UNLOCKDATE, player_index) + achievementdate.slice(0,2) + "/" + achievementdate.slice(2,4) + "/" + achievementdate.slice(4,8) + "\n";
	}

	StatsText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_NEXTPAGE, player_index) + "\n";
	StatsText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_PREVPAGE, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateCosmeticEquipText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local EquipText = "";

	EquipText += TranslateString(COSMETIC_TITLE, player_index);

	if(!PlayerCosmeticSubMenuActive[player_index])
	{
		EquipText += " (" + (CosmeticSelection[player_index] + 1) + " / " + (eCosmetics.MAX - 1) + ")\n";

		EquipText += "[" + TranslateString(COSMETIC_NAME[CosmeticSelection[player_index]], player_index) + "]\n";
		EquipText += TranslateString(COSMETIC_DESC[CosmeticSelection[player_index]], player_index) + "\n\n";

		EquipText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_NEXTPAGE, player_index) + "\n";
		EquipText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_PREVPAGE, player_index) + "\n";

		//if our cosmetic achievement isnt met, display the not unlocked message
		if(!HasAchievement(Cosmetic_Requirement[CosmeticSelection[player_index]], player_index) && !!!PlayerHasPlaytesterBonus[player_index])
			EquipText += format(TranslateString(COSMETIC_REQUIREMENT, player_index), TranslateString(ACHIEVEMENT_NAME[Cosmetic_Requirement[CosmeticSelection[player_index]]], player_index));
		else if(CosmeticSelection[player_index] == eCosmetics.MachTrail - 1)
			EquipText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString(SETTING_EDIT, player_index) + " / " + TranslateString((CosmeticSelection[player_index] + 1 == PlayerCosmeticEquipped[player_index] ? SETTING_UNEQUIP : SETTING_EQUIP), player_index);
		else
			EquipText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString((CosmeticSelection[player_index] + 1 == PlayerCosmeticEquipped[player_index] ? SETTING_UNEQUIP : SETTING_EQUIP), player_index);
	}
	else
	{
		EquipText += TranslateString(COSMETIC_EDIT, player_index) + TranslateString(COSMETIC_NAME[CosmeticSelection[player_index]], player_index) + "\n";
		EquipText += format(TranslateString(COSMETIC_EDIT_COLOR, player_index), 1) + PlayerMachTrailColor1[player_index] + (PlayerCosmeticColorEdit[player_index] == 1 ? TranslateString(COSMETIC_EDIT_CURRENT, player_index) : "") + "\n";
		EquipText += format(TranslateString(COSMETIC_EDIT_COLOR, player_index), 2) + PlayerMachTrailColor2[player_index] + (PlayerCosmeticColorEdit[player_index] == 2 ? TranslateString(COSMETIC_EDIT_CURRENT, player_index) : "") + "\n";
		EquipText += format(TranslateString(COSMETIC_EDIT_COLOR, player_index), 3) + PlayerMachTrailColor3[player_index] + (PlayerCosmeticColorEdit[player_index] == 3 ? TranslateString(COSMETIC_EDIT_CURRENT, player_index) : "") + "\n";
		EquipText += (PlayerCosmeticColorEdit[player_index] == 0 ? TranslateString(COSMETIC_EDIT_COLORHINT, player_index) : TranslateString(COSMETIC_EDIT_COLORHOWTO, player_index)) + "\n";
		EquipText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + (PlayerCosmeticColorEdit[player_index] == 3 ? TranslateString(SETTING_EDITSTOP, player_index) : format(TranslateString(SETTING_EDITCOLOR, player_index), (PlayerCosmeticColorEdit[player_index] + 1))) + "\n";
		EquipText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_RETURN, player_index) + "\n";
		EquipText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString((CosmeticSelection[player_index] + 1 == PlayerCosmeticEquipped[player_index] ? SETTING_UNEQUIP : SETTING_EQUIP), player_index);
	}

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", EquipText);
}

::UpdateResetProfileText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local ResetText = "";

	ResetText += TranslateString(RESET_PROFILE_TITLE, player_index) + "\n";

	if(ResetProfileProgress[player_index] == -1)
		ResetText += TranslateString(RESET_PROFILE_NORESET, player_index);
	else if(ResetProfileProgress[player_index] == -2)
		ResetText += TranslateString(RESET_PROFILE_RESET, player_index);
	else
	{
		ResetText += TranslateString(RESET_PROFILE_QUESTIONS[ResetProfileProgress[player_index]], player_index) + "\n";
		ResetText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_YES, player_index) + "\n";
		ResetText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_NO, player_index) + "\n";
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
		LeaderText = TranslateString(LEADERBOARD_TITLE, player_index) + "\n\n" + TranslateString(LEADERBOARD_NOENTRIES, player_index)
		LeaderText += "\n\n\n\n\n";

		if(LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME > Time())
			LeaderText += format(TranslateString(LEADERBOARD_BUTTON_REFRESHWAIT, player_index), FormatTime((LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME - Time()).tointeger()));
		else
			LeaderText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString(SETTING_REFRESHLEADERBOARD, player_index);

		local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
		NetProps.SetPropString(text, "m_iszMessage", LeaderText);

		return;
	}

	LeaderText += TranslateString(LEADERBOARD_TITLE, player_index) + " (" + TranslateString(LEADERBOARD_PAGE, player_index) + current_leaderboard_page + " / " + leaderboard_max_page + ")\n";

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

		DebugPrint("cached player " + player_index + " leaderboard rank: " + player_rank);
	}

	LeaderText += (TranslateString(LEADERBOARD_RANK, player_index) + (player_rank != -1 ? ("#" + player_rank + " / " + leaderboard_array.len()) : TranslateString(TIMER_NONE, player_index))) + "\n\n\n\n";

	LeaderText += TranslateString(SETTING_BUTTON_ATTACK, player_index) + TranslateString(SETTING_NEXTPAGE, player_index) + "\n";
	LeaderText += TranslateString(SETTING_BUTTON_ALTATTACK, player_index) + TranslateString(SETTING_PREVPAGE, player_index) + "\n";

	if(LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME > Time())
		LeaderText += format(TranslateString(LEADERBOARD_BUTTON_REFRESHWAIT, player_index), FormatTime((LastUpdatedLeaderboard + LEADERBOARD_RESET_TIME - Time()).tointeger()));
	else
		LeaderText += TranslateString(SETTING_BUTTON_RELOAD, player_index) + TranslateString(SETTING_REFRESHLEADERBOARD, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", LeaderText);
}