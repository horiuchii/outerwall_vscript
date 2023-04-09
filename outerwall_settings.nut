::PlayerCurrentSettingQuery <- array(MAX_PLAYERS, null)

::SetPlayerSettingQuery <- function(iSetting)
{
	local player_index = activator.GetEntityIndex();
	PlayerCurrentSettingQuery[player_index] = iSetting;
	UpdateSettingsText(player_index);
}

::PreviousButtons <- array(MAX_PLAYERS, 0)
::AchievementSelection <- array(MAX_PLAYERS, 0)
::CosmeticSelection <- array(MAX_PLAYERS, 0)

::CheckSettingButton <- function(client)
{
	local player_index = client.GetEntityIndex();

	local buttons = NetProps.GetPropInt(client, "m_nButtons");

	if(PlayerCurrentSettingQuery[player_index] == null)
	{
		PreviousButtons[player_index] = buttons;
		NetProps.SetPropFloat(client, "m_flNextAttack", 0);
		return;
	}

	local ButtonPressed = null;
	NetProps.SetPropFloat(client, "m_flNextAttack", 9999999);

	//If our previous key capture doesn't contain attack key && new one does.
	if(!(PreviousButtons[player_index] & IN_ATTACK) && buttons & IN_ATTACK)
		ButtonPressed = 1;
	else if(!(PreviousButtons[player_index] & IN_ATTACK2) && buttons & IN_ATTACK2)
		ButtonPressed = 2;

	if(ButtonPressed == null)
	{
		PreviousButtons[player_index] = buttons;
		return;
	}

	switch(PlayerCurrentSettingQuery[player_index])
	{
		case eSettingQuerys.DisplayTime:
		{
			if(ButtonPressed != 1)
				return;

			PlayerSettingDisplayTime[player_index] = (!!!PlayerSettingDisplayTime[player_index]).tointeger();
			printl(IsPlayerSpecial(player_index))
			break;
		}
		case eSettingQuerys.DisplayCheckpoint:
		{
			if(ButtonPressed != 1)
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
			if(ButtonPressed != 1)
				return;

			local current_track = PlayerSoundtrackList[player_index];
			if(current_track == 0)
				SetPlayerSoundtrack(1, client);
			else if(current_track == 1)
				SetPlayerSoundtrack(2, client);
			else if(current_track == 2)
				SetPlayerSoundtrack(0, client);

			break;
		}
		case eSettingQuerys.Encore:
		{
			if(ButtonPressed != 1)
				return;

			if(IsPlayerEncorable(player_index) || IsPlayerSpecial(player_index))
				PlayerEncoreStatus[player_index] = (!!!PlayerEncoreStatus[player_index]).tointeger();
			else
				return;

			EncoreTeamCheck(client);

			break;
		}
		case eSettingQuerys.Achievement:
		{
			if(ButtonPressed == 1)
			{
				if(AchievementSelection[player_index] == OUTERWALL_ACHIEVEMENT_NAME.len() - 1)
					AchievementSelection[player_index] = 0;
				else
					AchievementSelection[player_index]++;
			}
			else if(ButtonPressed == 2)
			{
				if(AchievementSelection[player_index] == 0)
					AchievementSelection[player_index] = OUTERWALL_ACHIEVEMENT_NAME.len() - 1;
				else
					AchievementSelection[player_index]--;
			}

			UpdateAchievementStatsText(client);

			break;
		}
		case eSettingQuerys.Cosmetic:
		{
			if(ButtonPressed == 1)
			{
				if(CosmeticSelection[player_index] == OUTERWALL_COSMETIC_NAME.len() - 1)
					CosmeticSelection[player_index] = 0;
				else
					CosmeticSelection[player_index]++;
			}
			else if(ButtonPressed == 2)
			{
				if(CosmeticSelection[player_index] == 0)
					CosmeticSelection[player_index] = OUTERWALL_COSMETIC_NAME.len() - 1;
				else
					CosmeticSelection[player_index]--;
			}

			UpdateCosmeticEquipText(client);

			break;
		}
		case eSettingQuerys.SaveSync:
		{
			if(!IsSaveSyncEnabled())
				return;

			break;
		}
		default: break;
	}
	if(PlayerCurrentSettingQuery[player_index] <= eSettingQuerys.Encore)
		UpdateSettingsText(player_index);

	EmitSoundOnClient(SND_MENU_SELECT, client);

	PreviousButtons[player_index] = buttons;
}

::UpdateSettingsText <- function(player_index)
{
	local SettingName = null;
	local SettingDesc = null;
	local SettingOption = null;

	if(PlayerCurrentSettingQuery[player_index] > eSettingQuerys.Encore || PlayerCurrentSettingQuery[player_index] == null)
		return;

	SettingName = TranslateString(OUTERWALL_SETTING_NAME[PlayerCurrentSettingQuery[player_index]], player_index);
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
		SettingsText +=  TranslateString(OUTERWALL_SETTING_BUTTON, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", SettingsText);
}

::UpdatePlayerStatsText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = activator.GetEntityIndex();
	local StatsText = "";

	StatsText += TranslateString(OUTERWALL_STATS_TITLE, player_index) + (IsPlayerSpecial(player_index) ? " ★" : "") + "\n"

	StatsText += TranslateString(OUTERWALL_STATS_TIMEPLAYED, player_index) + FormatTimeHours(PlayerSecondsPlayed[player_index]) + "\n"

	local achievement_count = 0;
	foreach(playerdata in PlayerAchievements)
		achievement_count += playerdata[player_index].tointeger();

	StatsText += TranslateString(OUTERWALL_STATS_ACHIEVEMENTS, player_index) + achievement_count + " / " + OUTERWALL_ACHIEVEMENT_NAME.len() + "\n"
	StatsText += TranslateString(OUTERWALL_STATS_SPIKEHITS, player_index) + PlayerSpikeHits[player_index] + "\n"
	StatsText += TranslateString(OUTERWALL_STATS_LAVAHITS, player_index) + PlayerLavaHits[player_index] + "\n"
	StatsText += TranslateString(OUTERWALL_STATS_LAPSRAN, player_index) + 0 + "\n"

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateAchievementStatsText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local StatsText = "";

	StatsText += TranslateString(OUTERWALL_ACHIEVEMENT_TITLE, player_index) + "\n";

	StatsText += (PlayerAchievements[AchievementSelection[player_index]][player_index] ? TranslateString(OUTERWALL_ACHIEVEMENT_NAME[AchievementSelection[player_index]], player_index) : "???") + "\n";
	StatsText += (!IsPlayerEncorable(player_index) && AchievementSelection[player_index] > 4 ? "???" : TranslateString(OUTERWALL_ACHIEVEMENT_DESC[AchievementSelection[player_index]], player_index)) + "\n";
	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_NEXTPAGE, player_index) + "\n";
	StatsText += TranslateString(OUTERWALL_SETTING_BUTTON_PREVPAGE, player_index) + "\n";
	StatsText += (AchievementSelection[player_index] + 1) + " / " + OUTERWALL_ACHIEVEMENT_NAME.len();

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", StatsText);
}

::UpdateCosmeticEquipText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local EquipText = "";

	EquipText += TranslateString(OUTERWALL_COSMETIC_TITLE, player_index);

	EquipText += TranslateString(OUTERWALL_SETTING_BUTTON_NEXTPAGE, player_index) + "\n";
	EquipText += TranslateString(OUTERWALL_SETTING_BUTTON_PREVPAGE, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", EquipText);
}

::UpdateSaveSyncText <- function(client = null)
{
	if(client == null)
		client = activator;

	local player_index = client.GetEntityIndex();
	local DisplayText = "";

	DisplayText += TranslateString(OUTERWALL_SAVE_TRANSFER_TITLE, player_index) + "\n\n";

	if(IsSaveSyncEnabled())
	{
		DisplayText += TranslateString(OUTERWALL_SAVE_TRANSFER, player_index) + "\n";
		DisplayText += TranslateString(OUTERWALL_SAVE_TRANSFER_BUTTON, player_index) + "\n";
		DisplayText += TranslateString(OUTERWALL_SAVE_TRANSFER_BUTTON_ALT, player_index);
	}
	else
		DisplayText += TranslateString(OUTERWALL_SAVE_TRANSFER_UNAVAILABLE, player_index);

	local text = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index);
	NetProps.SetPropString(text, "m_iszMessage", DisplayText);
}