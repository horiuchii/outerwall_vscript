::PlayerAccountID <- array(MAX_PLAYERS, null)

enum PlayerLeaderboardDataTypes
{
	steam_name
	total_time
	MAX
}

//16,384 is the max size a file can be.
//11 bytes per entry (10 for the account_id + 1 for the comma)
//16,384 / 11 = 1,489.45
const MAX_LEADERBOARD_ENTRIES = 1489;

::leaderboard_array <- array(MAX_LEADERBOARD_ENTRIES, null)
::current_leaderboard_page <- 1;
::leaderboard_max_page <- 1;
::PlayerCachedLeaderboardPosition <- array(MAX_PLAYERS, null)
::leaderboard_loaded <- false;

::ZONE_COUNT <- 7;
::ZONE_COUNT_ENCORE <- 6;
::CHECKPOINT_COUNT <- 2;

::PluginSaveActive <- false;

::PlayerPreventSaving <- array(MAX_PLAYERS, false)

::PlayerHasPlaytesterBonus <- array(MAX_PLAYERS, 0)

::PlayerBestTimeArray <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestCheckpointTimeArrayOne <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestCheckpointTimeArrayTwo <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestLapCountEncoreArray <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT_ENCORE, 0)
::PlayerBestSandPitTimeEncoreArray <- array(MAX_PLAYERS, 5000)

::PlayerAchievements <- ConstructTwoDimArray(MAX_PLAYERS, eAchievements.MAX, "00000000")

::PlayerSecondsPlayed <- array(MAX_PLAYERS, 0)
::PlayerTimesHurt <- array(MAX_PLAYERS, 0)
::PlayerTipsRecieved <- array(MAX_PLAYERS, 0)
::PlayerRunsRan <- array(MAX_PLAYERS, 0)
::PlayerLapsRan <- array(MAX_PLAYERS, 0)

::PlayerSettingDisplayTime <- array(MAX_PLAYERS, 0)
::PlayerSettingDisplayCheckpoint <- array(MAX_PLAYERS, 0)
::PlayerSettingPlayCharSounds <- array(MAX_PLAYERS, 1)
::PlayerSoundtrackList <- array(MAX_PLAYERS, 0)
::PlayerEncoreStatus <- array(MAX_PLAYERS, 0)
::PlayerCosmeticEquipped <- array(MAX_PLAYERS, 0)
::MachTrailColors <- [
	::PlayerMachTrailColor1 <- array(MAX_PLAYERS, "255 000 000")
	::PlayerMachTrailColor2 <- array(MAX_PLAYERS, "000 255 000")
	::PlayerMachTrailColor3 <- array(MAX_PLAYERS, "127 000 127")
]

::PerformAutosave <- function()
{
	for (local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
	{
		local player = PlayerInstanceFromIndex(player_index);
		if(player == null || player.GetTeam() == TEAM_UNASSIGNED || PlayerZoneList[player_index] == null) continue;
		PlayerSaveGame(player);
	}
}

::ResetPlayerDataArrays <- function(player_index)
{
	PlayerPreventSaving[player_index] = false;
	PlayerAccountID[player_index] = null;

	PlayerHasPlaytesterBonus[player_index] = 0;

	for(local i = 0; i < ZONE_COUNT; i++)
	{
		PlayerBestTimeArray[player_index][i] = 5000;
		PlayerBestCheckpointTimeArrayOne[player_index][i] = 5000;
		PlayerBestCheckpointTimeArrayTwo[player_index][i] = 5000;
	}

	for(local i = 0; i < ZONE_COUNT_ENCORE; i++)
		PlayerBestLapCountEncoreArray[player_index][i] = 0;

	PlayerBestSandPitTimeEncoreArray[player_index] = 5000;

	for(local i = 0; i < eAchievements.MAX; i++)
	{
		PlayerAchievements[player_index][i] = "00000000";
	}

	PlayerSecondsPlayed[player_index] = 0;
	PlayerTimesHurt[player_index] = 0;
	PlayerRunsRan[player_index] = 0;
	PlayerLapsRan[player_index] = 0;

	PlayerSettingDisplayTime[player_index] = 0;
	PlayerSettingDisplayCheckpoint[player_index] = 0;
	PlayerSettingPlayCharSounds[player_index] = 1;
	PlayerEncoreStatus[player_index] = 0;
	PlayerSoundtrackList[player_index] = 0;
	PlayerCosmeticEquipped[player_index] = 0;

	PlayerMachTrailColor1[player_index] = "255 000 000";
	PlayerMachTrailColor2[player_index] = "000 255 000";
	PlayerMachTrailColor3[player_index] = "127 000 127";

	DebugPrint("Reset Data Arrays for player " + player_index);
}

::CalculatePlayerAccountID <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerPreventSaving[player_index] == true)
	{
		DebugPrint("Refusing to grab player " + player_index + "'s NetworkIDString. PlayerPreventSaving is true for this person.");
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Refusing to grab your SteamID due to a previous error.");
		return;
	}

	local player_networkid = NetProps.GetPropString(client, "m_szNetworkIDString");

	if(player_networkid == null || type(player_networkid) != "string" || player_networkid == "" || player_networkid == "\0" || player_networkid == "null" || player_networkid == "BOT" || player_networkid == "STEAM_ID_LAN" || player_networkid == "STEAM_ID_PENDING" || player_networkid == "HLTV" || player_networkid == "REPLAY" || player_networkid == "UNKNOWN")
	{
		PlayerAccountID[player_index] = null;
		PlayerPreventSaving[player_index] = true;
		DebugPrint("Player " + player_index + "'s SteamID was invalid. We got: " + player_networkid);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Failed to grab your SteamID. Steam may be down.");
		return;
	}

	local id_split = split(player_networkid, ":");

	if(id_split.len() != 3)
	{
		PlayerAccountID[player_index] = null;
		PlayerPreventSaving[player_index] = true;
		DebugPrint("Player " + player_index + "'s SteamID was impossible to parse. We got: " + player_networkid);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Failed to parse your SteamID. This shouldn't ever happen!");
		return;
	}

	local z = id_split[2].tointeger();
	local y = id_split[1].tointeger();
	local player_accountid = (z + y).tostring();

	PlayerAccountID[player_index] = player_accountid;

	DebugPrint("Player " + player_index + "'s AccountID is " + PlayerAccountID[player_index]);
}

::PlayerSaveGame <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerPreventSaving[player_index] == true)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to save your game due to a previous error.");
		return;
	}

	if(PlayerAccountID[player_index] == null)
	{
		CalculatePlayerAccountID(client);

		if(PlayerAccountID[player_index] == null)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to save your game. PlayerAccountID is null even after attempting to grab again. Steam may be down.");
			return;
		}
	}

	local save = "";

	save += "playtester_bonus," + PlayerHasPlaytesterBonus[player_index] + ";"

	save += "time_stage0," + PlayerBestTimeArray[player_index][0] + ";";
	save += "time_bonus1," + PlayerBestTimeArray[player_index][1] + ";";
	save += "time_bonus2," + PlayerBestTimeArray[player_index][2] + ";";
	save += "time_bonus3," + PlayerBestTimeArray[player_index][3] + ";";
	save += "time_bonus4," + PlayerBestTimeArray[player_index][4] + ";";
	save += "time_bonus5," + PlayerBestTimeArray[player_index][5] + ";";
	save += "time_bonus6," + PlayerBestTimeArray[player_index][6] + ";";

	save += "cp1_stage0," + PlayerBestCheckpointTimeArrayOne[player_index][0] + ";";
	save += "cp1_bonus1," + PlayerBestCheckpointTimeArrayOne[player_index][1] + ";";
	save += "cp1_bonus2," + PlayerBestCheckpointTimeArrayOne[player_index][2] + ";";
	save += "cp1_bonus3," + PlayerBestCheckpointTimeArrayOne[player_index][3] + ";";
	save += "cp1_bonus4," + PlayerBestCheckpointTimeArrayOne[player_index][4] + ";";
	save += "cp1_bonus5," + PlayerBestCheckpointTimeArrayOne[player_index][5] + ";";
	save += "cp1_bonus6," + PlayerBestCheckpointTimeArrayOne[player_index][6] + ";";

	save += "cp2_stage0," + PlayerBestCheckpointTimeArrayTwo[player_index][0] + ";";
	save += "cp2_bonus1," + PlayerBestCheckpointTimeArrayTwo[player_index][1] + ";";
	save += "cp2_bonus2," + PlayerBestCheckpointTimeArrayTwo[player_index][2] + ";";
	save += "cp2_bonus3," + PlayerBestCheckpointTimeArrayTwo[player_index][3] + ";";
	save += "cp2_bonus4," + PlayerBestCheckpointTimeArrayTwo[player_index][4] + ";";
	save += "cp2_bonus5," + PlayerBestCheckpointTimeArrayTwo[player_index][5] + ";";
	save += "cp2_bonus6," + PlayerBestCheckpointTimeArrayTwo[player_index][6] + ";";

	save += "lap_stage0," + PlayerBestLapCountEncoreArray[player_index][0] + ";";
	save += "lap_bonus1," + PlayerBestLapCountEncoreArray[player_index][1] + ";";
	save += "lap_bonus2," + PlayerBestLapCountEncoreArray[player_index][2] + ";";
	save += "lap_bonus3," + PlayerBestLapCountEncoreArray[player_index][3] + ";";
	save += "lap_bonus4," + PlayerBestLapCountEncoreArray[player_index][4] + ";";
	save += "lap_bonus5," + PlayerBestLapCountEncoreArray[player_index][5] + ";";

	save += "encoretime_bonus6," + PlayerBestSandPitTimeEncoreArray[player_index] + ";";

	save += "ach_hurtalot," + PlayerAchievements[player_index][eAchievements.HurtAlot] + ";";
	save += "ach_runsalot," + PlayerAchievements[player_index][eAchievements.RunsAlot] + ";";
	save += "ach_osidenoparkour," + PlayerAchievements[player_index][eAchievements.NormalOuterWallNoParkour] + ";";
	save += "ach_airboost," + PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost] + ";";
	save += "ach_kazenodmg," + PlayerAchievements[player_index][eAchievements.NormalKazeNoDmg] + ";";
	save += "ach_smokey," + PlayerAchievements[player_index][eAchievements.SecretSmokey] + ";";
	save += "ach_pyro," + PlayerAchievements[player_index][eAchievements.SecretClimb] + ";";
	save += "ach_normalall," + PlayerAchievements[player_index][eAchievements.EncoreUnlock] + ";";
	save += "ach_normalgold," + PlayerAchievements[player_index][eAchievements.NormalGold] + ";";
	save += "ach_normaliri," + PlayerAchievements[player_index][eAchievements.NormalIri] + ";";

	save += "stat_time," + PlayerSecondsPlayed[player_index] + ";";
	save += "stat_hurt," + PlayerTimesHurt[player_index] + ";";
	save += "stat_tips," + PlayerTipsRecieved[player_index] + ";";
	save += "stat_runs," + PlayerRunsRan[player_index] + ";";
	save += "stat_laps," + PlayerLapsRan[player_index] + ";";

	save += "setting_finaltime," + PlayerSettingDisplayTime[player_index] + ";";
	save += "setting_checkpoint," + PlayerSettingDisplayCheckpoint[player_index] + ";";
	save += "setting_charsound," + PlayerSettingPlayCharSounds[player_index] + ";";
	save += "setting_soundtrack," + PlayerSoundtrackList[player_index] + ";";
	save += "setting_encore," + PlayerEncoreStatus[player_index] + ";";
	save += "setting_cosmetic," + PlayerCosmeticEquipped[player_index] + ";";
	save += "setting_machcolor1," + PlayerMachTrailColor1[player_index] + ";";
	save += "setting_machcolor2," + PlayerMachTrailColor2[player_index] + ";";
	save += "setting_machcolor3," + PlayerMachTrailColor3[player_index] + ";";

	StringToFile(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE, save);

	if(PluginSaveActive)
		PluginSavePlayerProfile(player_index);

	DebugPrint("GAME SAVED FOR " + player_index);
}

::PlayerLoadGame <- function(player_index)
{
	local client = PlayerInstanceFromIndex(player_index);

	if(PlayerPreventSaving[player_index] == true)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to load your save due to a previous error.");
		return;
	}

	if(PlayerAccountID[player_index] == null)
	{
		CalculatePlayerAccountID(client);

		if(PlayerAccountID[player_index] == null)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to load your save. AccountID is null even after attempting to grab again. Steam may be down.");
			return;
		}
	}

	local save = FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);

	if(save == null)
		return;

	local save_length = save.len();

	local i = 0;
	local bReadingKey = true;
	local key_buffer = "";
	local value_buffer = "";

	try
	{
		while(i < save_length)
		{
			if(save[i] == ',') //we've got our key
			{
				bReadingKey = false;
				i += 1;
			}

			if(save[i] == ';') //we've gotten to the end of the value
			{
				switch(key_buffer)
				{
					case "playtester_bonus":
					{
						PlayerHasPlaytesterBonus[player_index] = value_buffer.tointeger();
						break;
					}
					case "time_stage0":
					{
						PlayerBestTimeArray[player_index][0] = value_buffer.tofloat();
						break;
					}
					case "time_bonus1":
					{
						PlayerBestTimeArray[player_index][1] = value_buffer.tofloat();
						break;
					}
					case "time_bonus2":
					{
						PlayerBestTimeArray[player_index][2] = value_buffer.tofloat();
						break;
					}
					case "time_bonus3":
					{
						PlayerBestTimeArray[player_index][3] = value_buffer.tofloat();
						break;
					}
					case "time_bonus4":
					{
						PlayerBestTimeArray[player_index][4] = value_buffer.tofloat();
						break;
					}
					case "time_bonus5":
					{
						PlayerBestTimeArray[player_index][5] = value_buffer.tofloat();
						break;
					}
					case "time_bonus6":
					{
						PlayerBestTimeArray[player_index][6] = value_buffer.tofloat();
						break;
					}
					case "cp1_stage0":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][0] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus1":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][1] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus2":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][2] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus3":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][3] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus4":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][4] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus5":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][5] = value_buffer.tofloat();
						break;
					}
					case "cp1_bonus6":
					{
						PlayerBestCheckpointTimeArrayOne[player_index][6] = value_buffer.tofloat();
						break;
					}
					case "cp2_stage0":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][0] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus1":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][1] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus2":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][2] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus3":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][3] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus4":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][4] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus5":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][5] = value_buffer.tofloat();
						break;
					}
					case "cp2_bonus6":
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][6] = value_buffer.tofloat();
						break;
					}
					case "lap_stage0":
					{
						PlayerBestLapCountEncoreArray[player_index][0] = value_buffer.tointeger();
						break;
					}
					case "lap_bonus1":
					{
						PlayerBestLapCountEncoreArray[player_index][1] = value_buffer.tointeger();
						break;
					}
					case "lap_bonus2":
					{
						PlayerBestLapCountEncoreArray[player_index][2] = value_buffer.tointeger();
						break;
					}
					case "lap_bonus3":
					{
						PlayerBestLapCountEncoreArray[player_index][3] = value_buffer.tointeger();
						break;
					}
					case "lap_bonus4":
					{
						PlayerBestLapCountEncoreArray[player_index][4] = value_buffer.tointeger();
						break;
					}
					case "lap_bonus5":
					{
						PlayerBestLapCountEncoreArray[player_index][5] = value_buffer.tointeger();
						break;
					}
					case "encoretime_bonus6":
					{
						PlayerBestSandPitTimeEncoreArray[player_index] = value_buffer.tofloat();
						break;
					}
					case "ach_hurtalot":
					{
						PlayerAchievements[player_index][eAchievements.HurtAlot] = value_buffer.tostring();
						break;
					}
					case "ach_runsalot":
					{
						PlayerAchievements[player_index][eAchievements.RunsAlot] = value_buffer.tostring();
						break;
					}
					case "ach_osidenoparkour":
					{
						PlayerAchievements[player_index][eAchievements.NormalOuterWallNoParkour] = value_buffer.tostring();
						break;
					}
					case "ach_airboost":
					{
						PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost] = value_buffer.tostring();
						break;
					}
					case "ach_kazenodmg":
					{
						PlayerAchievements[player_index][eAchievements.NormalKazeNoDmg] = value_buffer.tostring();
						break;
					}
					case "ach_smokey":
					{
						PlayerAchievements[player_index][eAchievements.SecretSmokey] = value_buffer.tostring();
						break;
					}
					case "ach_pyro":
					{
						PlayerAchievements[player_index][eAchievements.SecretClimb] = value_buffer.tostring();
						break;
					}
					case "ach_normalall":
					{
						PlayerAchievements[player_index][eAchievements.EncoreUnlock] = value_buffer.tostring();
						break;
					}
					case "ach_normalgold":
					{
						PlayerAchievements[player_index][eAchievements.NormalGold] = value_buffer.tostring();
						break;
					}
					case "ach_normaliri":
					{
						PlayerAchievements[player_index][eAchievements.NormalIri] = value_buffer.tostring();
						break;
					}
					case "stat_time":
					{
						PlayerSecondsPlayed[player_index] = value_buffer.tointeger();
						break;
					}
					case "stat_hurt":
					{
						PlayerTimesHurt[player_index] = value_buffer.tointeger();
						break;
					}
					case "stat_tips":
					{
						PlayerTipsRecieved[player_index] = value_buffer.tointeger();
						break;
					}
					case "stat_runs":
					{
						PlayerRunsRan[player_index] = value_buffer.tointeger();
						break;
					}
					case "stat_laps":
					{
						PlayerLapsRan[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_finaltime":
					{
						PlayerSettingDisplayTime[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_checkpoint":
					{
						PlayerSettingDisplayCheckpoint[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_soundtrack":
					{
						PlayerSoundtrackList[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_encore":
					{
						PlayerEncoreStatus[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_cosmetic":
					{
						PlayerCosmeticEquipped[player_index] = value_buffer.tointeger();
						break;
					}
					case "setting_machcolor1":
					{
						PlayerMachTrailColor1[player_index] = value_buffer.tostring();
						break;
					}
					case "setting_machcolor2":
					{
						PlayerMachTrailColor2[player_index] = value_buffer.tostring();
						break;
					}
					case "setting_machcolor3":
					{
						PlayerMachTrailColor3[player_index] = value_buffer.tostring();
						break;
					}
				}

				//clear everything and start reading the next key
				key_buffer = "";
				value_buffer = "";
				i += 1;
				bReadingKey = true;
				continue;
			}

			if(bReadingKey)
				key_buffer += save[i].tochar();
			else
				value_buffer += save[i].tochar();

			i += 1;
		}

		GatherWorldRecordTimes();
		DebugPrint("Save Loaded for player " + player_index);
	}
	catch(exception)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Your save failed to load. Please alert a server admin and have them post an issue on the \"horiuchii/outerwall_vscript\" GitHub with the text below and your save file.");
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Save: " + "tf/scriptdata/" + OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Error: " + exception + "\nIndex: " + i + "\nReading Key?: " + bReadingKey + "\nKey: " + key_buffer + "\nValue: " + value_buffer);
		ResetPlayerDataArrays(player_index);
		PlayerPreventSaving[player_index] = true;
	}
}

::PlayerUpdateLeaderboardTimes <- function(player_index)
{
	local player = PlayerInstanceFromIndex(player_index);

	if(PlayerPreventSaving[player_index] == true)
	{
		ClientPrint(player, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to update your leaderboard times due to a previous error.");
		return;
	}

	if(FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVELEADERBOARDSUFFIX + OUTERWALL_SAVETYPE) == null && !IsPlayerEncorable(player_index))
		return;

	local name = AddEscapeChars(NetProps.GetPropString(player, "m_szNetname"));

	local total_time = 0;

	foreach(time in PlayerBestTimeArray[player_index])
	{
		total_time += time;
	}

	local save = name + ",;," + total_time.tostring() + ",;";

	StringToFile(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVELEADERBOARDSUFFIX + OUTERWALL_SAVETYPE, save);
	AddPlayerToLeaderboardEntries(PlayerAccountID[player_index]);
}

::AddPlayerToLeaderboardEntries <- function(account_id)
{
	local entry_list_string = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE);

	local entry_list_array = array(MAX_LEADERBOARD_ENTRIES, -1);

	// get back list of entries
	if(entry_list_string != null && entry_list_string != "empty")
	{
		entry_list_array = split(entry_list_string, ",");
	}
	else
	{
		//we dont have an entry list, so lets make one
		entry_list_array[0] = account_id;
	}

	//if we just made one, dont run this
	if(entry_list_string != null)
	{
		//find account_id in entry_list_array. if account_id exists, dont add
		if(entry_list_array.find(account_id) == null)
		{
			//append account_id to the first empty slot
			local array_index = entry_list_array.find("-1");

			//TODO: add support for multiple leaderboard_entries files
			if(array_index == null)
			{
				ClientPrint(null, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Tried to update leaderboard_entries but it was full! Max size is " + MAX_LEADERBOARD_ENTRIES + ". Somebody PLEASE make it bigger!");
				return;
			}

			entry_list_array.insert(array_index, account_id);
		}
	}

	//save the file
	local save = "";

	foreach(leaderboard_entry in entry_list_array)
	{
		save += leaderboard_entry + ",";
	}

	StringToFile(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE, save);
}

::RemovePlayerFromLeaderboardEntries <- function(account_id)
{
	local entry_list_string = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE);

	if(entry_list_string == null || entry_list_string == "empty")
		return;

	local entry_list_array = array(MAX_LEADERBOARD_ENTRIES, -1);

	entry_list_array = split(entry_list_string, ",");

	local target_index = entry_list_array.find(account_id)

	if(target_index == null)
		return;

	//remove account_id from array and append -1 to end of array
	entry_list_array.remove(target_index);
	entry_list_array.append(-1);

	//save the file
	local save = "";

	if(entry_list_array[0] == "-1")
		save = "empty";
	else
	{
		foreach(leaderboard_entry in entry_list_array)
		{
			save += leaderboard_entry + ",";
		}
	}

	StringToFile(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE, save);
	PopulateLeaderboard();
}

::PopulateLeaderboard <- function()
{
	PlayerCachedLeaderboardPosition = array(MAX_PLAYERS, null);
	local entry_list_string = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE);

	if(entry_list_string == null || entry_list_string == "empty")
	{
		leaderboard_loaded = false;
		EntFire("leaderboard_*", "SetText", "");
		EntFire("leaderboard_*", "SetColor", "255 255 255");
		EntFire("leaderboard_*", "SetRainbow", "0");
		EntFire("leaderboard_" + round(LEADERBOARD_PAGE_SIZE / 2, 0), "SetText", "                                      [NO ENTRIES]");
		return;
	}

	//parse leaderboard_entries
	local entry_list_array = array(MAX_LEADERBOARD_ENTRIES, -1);

	local load_data = 0;

	local i = 0;

	local save_length = entry_list_string.len();

	local savebuffer = "";

	while(i < save_length)
	{
		if(entry_list_string[i] == ',' || i == save_length) //we've gotten to the end
		{
			if(savebuffer == "")
				continue;

			if(i > MAX_LEADERBOARD_ENTRIES)
				break;

			//parse entry list
			entry_list_array[load_data] = savebuffer.tostring() + "";

			load_data += 1;
			savebuffer = "";
			i += 1;
			continue;
		}

		savebuffer += entry_list_string[i].tochar();
		i += 1;
	}

	local entry_data_array = array(MAX_LEADERBOARD_ENTRIES, null)

	//for each entry, get the account_id_leaderboarddata and put it into a map and append it into an array
	foreach(entry_index, account in entry_list_array)
	{
		if(account == "-1")
		{
			entry_data_array = entry_data_array.slice(0, entry_index);
			break;
		}

		local entry_data_string = FileToString(OUTERWALL_SAVEPATH + account + OUTERWALL_SAVELEADERBOARDSUFFIX + OUTERWALL_SAVETYPE);

		if(entry_data_string == null)
		{
			ClientPrint(null, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Bad leaderboard_entry " + account + " found!");
			continue;
		}

		entry_data <- {
			account_id = null,
			steam_name = null,
			total_time = null
		}

		entry_data.account_id = account;

		local load_data = 0;

		i = 0;

		local savetype = PlayerLeaderboardDataTypes.steam_name;

		local savebuffer = "";

		local save_length = entry_data_string.len();

		while(i < save_length)
		{
			if(savetype == PlayerLeaderboardDataTypes.MAX)
				break;

			if(entry_data_string[i] == '\\') //we escapin this motherfucker
			{
				savebuffer += entry_data_string[i + 1].tochar();
				i += 2;
				continue;
			}

			if(entry_data_string[i] == ',' || i == save_length) //we've gotten to the end
			{
				if(savebuffer == "")
					continue;

				if(savebuffer == ";") //we've gotten to the end of the savetype
				{
					load_data = 0;
					savebuffer = "";
					i += 1;
					savetype += 1;
					continue;
				}

				switch(savetype)
				{
					case PlayerLeaderboardDataTypes.steam_name:
					{
						entry_data.steam_name = savebuffer.tostring();
						break;
					}
					case PlayerLeaderboardDataTypes.total_time:
					{
						entry_data.total_time = savebuffer.tofloat();
						break;
					}
				}

				load_data += 1;
				savebuffer = "";
				i += 1;
				continue;
			}

			savebuffer += entry_data_string[i].tochar();
			i += 1;
		}

		entry_data_array[entry_index] = entry_data;
	}

	if(false)
	{
		for(local i = 0; i < MAX_LEADERBOARD_ENTRIES; i++)
		{
			dummy_entry_data <- {
				account_id = null,
				steam_name = "dummy entry " + i,
				total_time = RandomFloat(LEADERBOARD_IRI - 30, LEADERBOARD_BRONZE + 250)
			}

			entry_data_array.append(dummy_entry_data);
		}
	}

	//sort array based on total_time
	if(entry_data_array.len() > 1)
	{
		entry_data_array.sort(SortTotalTime)
	}

	leaderboard_array = entry_data_array;
	SetLeaderboardPage(1);
	leaderboard_loaded = true;
}

const LEADERBOARD_PAGE_SIZE = 25;

::SetLeaderboardPage <- function(iPage)
{
	local start_len = LEADERBOARD_PAGE_SIZE * (iPage - 1);
	local end_len = LEADERBOARD_PAGE_SIZE + (LEADERBOARD_PAGE_SIZE * (iPage - 1));

	if(start_len > leaderboard_array.len() || start_len < 0)
	{
		iPage = start_len < 0 ? leaderboard_max_page : 1;

		start_len = LEADERBOARD_PAGE_SIZE * (iPage - 1);
		end_len = LEADERBOARD_PAGE_SIZE + (LEADERBOARD_PAGE_SIZE * (iPage - 1));

		if(start_len > leaderboard_array.len() || start_len < 0)
			return;
	}

	if(end_len > leaderboard_array.len())
		end_len = leaderboard_array.len();

	local leaderboard_page = leaderboard_array.slice(start_len, end_len);
	current_leaderboard_page = iPage;
	leaderboard_max_page = ceil(1.0 * leaderboard_array.len() / LEADERBOARD_PAGE_SIZE);

	EntFire("leaderboard_*", "SetText", "");
	EntFire("leaderboard_*", "SetColor", "0 128 128");
	EntFire("leaderboard_*", "SetRainbow", "0");

	foreach(i, ranking in leaderboard_page)
	{
		if(!ranking)
			break;

		if(i < 5 && iPage == 1)
			EntFire("leaderboard_" + (i + 1), "SetRainbow", "1");
		else if(ranking.total_time <= LEADERBOARD_IRI)
			EntFire("leaderboard_" + (i + 1), "SetColor", "255 36 54");
		else if(ranking.total_time <= LEADERBOARD_GOLD)
			EntFire("leaderboard_" + (i + 1), "SetColor", "255 215 0");
		else if(ranking.total_time <= LEADERBOARD_SILVER)
			EntFire("leaderboard_" + (i + 1), "SetColor", "192 192 192");
		else if(ranking.total_time <= LEADERBOARD_BRONZE)
			EntFire("leaderboard_" + (i + 1), "SetColor", "210 105 30");

		EntFire("leaderboard_" + (i + 1), "SetText", (i + 1 + start_len) + ": " + (ranking.steam_name).toupper() + " - " + FormatTime(round(ranking.total_time, 2)))
	}
}