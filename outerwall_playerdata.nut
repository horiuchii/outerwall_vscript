const OUTERWALL_SAVEPATH = "pf_outerwall/"
const OUTERWALL_SAVETYPE = ".sav"
const OUTERWALL_SAVELEADERBOARDSUFFIX = "_leaderboarddata"
const OUTERWALL_SAVELEADERBOARD = "leaderboard_entries"

const OUTERWALL_KEYPATH = "server/"
const OUTERWALL_KEYFILE = "key"
const OUTERWALL_SERVERNAMEFILE = "transfer_server"

const OUTERWALL_MAPNAME = "pf_outerwall_"

::PlayerAccountID <- array(MAX_PLAYERS, null)

::SpecialPlayerAccountID <-
[
	"283216923" //Horiuchi
	"123928992" //Bradasparky
]

enum PlayerLeaderboardDataTypes
{
	steam_name
	total_time
	MAX
}

//16,384 is the max size a file can be.
//10 bytes per entry (9 for the account_id + 1 for the comma)
//16,384 / 10 = 1,638.4
const MAX_LEADERBOARD_ENTRIES = 1638

const ZONE_COUNT = 7;
const CHECKPOINT_COUNT = 2;

::PlayerPreventSaving <- array(MAX_PLAYERS, false);

::PlayerBestMedalArray <- array(MAX_PLAYERS, array(ZONE_COUNT, -1))
::PlayerBestTimeArray <- array(MAX_PLAYERS, array(ZONE_COUNT, 5000))
::PlayerBestCheckpointTimeArray <- array(MAX_PLAYERS, array(ZONE_COUNT, array(CHECKPOINT_COUNT, 5000)))
::PlayerBestMedalEncoreArray <- array(MAX_PLAYERS, array(ZONE_COUNT, -1))
::PlayerBestTimeEncoreArray <- array(MAX_PLAYERS, array(ZONE_COUNT, 5000))
::PlayerBestLapCountEncoreArray <- array(MAX_PLAYERS, array(ZONE_COUNT, 0))

::PlayerAchievements <-
[
	::NormalHellNoDmg <- array(MAX_PLAYERS, false)
	::NormalSecretClimb <- array(MAX_PLAYERS, false)
	::NormalGold <- array(MAX_PLAYERS, false)
	::NormalIri <- array(MAX_PLAYERS, false)
	::EncoreUnlock <- array(MAX_PLAYERS, false)
	::EncoreOsideNoDmg <- array(MAX_PLAYERS, false)
	::EncoreHellTime <- array(MAX_PLAYERS, false)
	::EncoreManyLaps <- array(MAX_PLAYERS, false)
	::EncoreGold <- array(MAX_PLAYERS, false)
	::EncoreIri <- array(MAX_PLAYERS, false)
	::AllGold <- array(MAX_PLAYERS, false)
	::AllIri <- array(MAX_PLAYERS, false)
]

::PlayerMiscStats <-
[
	::PlayerSecondsPlayed <- array(MAX_PLAYERS, 0)
	::PlayerSpikeHits <- array(MAX_PLAYERS, 0)
	::PlayerLavaHits <- array(MAX_PLAYERS, 0)
]

::PlayerSettings <-
[
	::PlayerSettingDisplayTime <- array(MAX_PLAYERS, 0)
	::PlayerSettingDisplayCheckpoint <- array(MAX_PLAYERS, 0)
	::PlayerSoundtrackList <- array(MAX_PLAYERS, 0)
	::PlayerEncoreStatus <- array(MAX_PLAYERS, 0)
	::PlayerCosmeticEquipped <- array(MAX_PLAYERS, 0)
]

enum PlayerDataTypes
{
	best_medal
	best_time
	best_checkpoint_time
	best_medal_encore
	best_time_encore
	best_lapcount_encore
	achievements
	misc_stats
	settings
	MAX
}

::IsPlayerSpecial <- function(player_index)
{
	return SpecialPlayerAccountID.find(PlayerAccountID[player_index]) != null;
}

::PerformAutosave <- function()
{
	for (local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
	{
		local player = PlayerInstanceFromIndex(player_index);
		if (player == null) continue;
		PlayerSaveGame(player);
	}
}

::ResetPlayerDataArrays <- function(player_index)
{
	PlayerPreventSaving[player_index] = false;

	foreach(medal in PlayerBestMedalArray[player_index])
		medal = -1;

	foreach(time in PlayerBestTimeArray[player_index])
		time = 5000;

	foreach(zone in PlayerBestCheckpointTimeArray[player_index])
		foreach(time in zone)
			time = 5000;

	foreach(medal in PlayerBestMedalEncoreArray[player_index])
		medal = -1;

	foreach(time in PlayerBestTimeEncoreArray[player_index])
		time = 5000;

	foreach(laps in PlayerBestLapCountEncoreArray[player_index])
		laps = 0;

	foreach(achievement in PlayerAchievements)
		achievement[player_index] = false;

	foreach(stats in PlayerMiscStats)
		stats[player_index] = 0;

	foreach(i, setting in PlayerSettings)
		setting[player_index] = 0;
}

::CalculatePlayerAccountID <- function(client)
{
	local player_index = client.GetEntityIndex();
	local player_networkid = NetProps.GetPropString(client, "m_szNetworkIDString");

	local id_split = split(player_networkid, ":");
	local z = id_split[2].tointeger();
	local y = id_split[1].tointeger();
	local player_accountid = (z + y).tostring();

	PlayerAccountID[player_index] = player_accountid;

	DebugPrint("Player " + player_index + "'s AccountID is " + PlayerAccountID[player_index]);
}

::GenerateSaveTransferKey <- function(player_index)
{
	local key = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_KEYPATH + OUTERWALL_KEYFILE + OUTERWALL_SAVETYPE);
	if(key == null)
	{
		ClientPrint(PlayerInstanceFromIndex(player_index), HUD_PRINTTALK, "\x07" + "FF0000" + "Key cannot be generated.");
		return;
	}

	PlayerSaveGame(PlayerInstanceFromIndex(player_index));

	local hash = EncryptString(FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE), key);
	printl(hash)
	ClientPrint(PlayerInstanceFromIndex(player_index), HUD_PRINTTALK, "\x07" + "FF0000" + "key");
	//have it so user cannot generate a key for 24h
}

::ProcessSaveTransferKey <- function()
{
	ClientPrint(null, HUD_PRINTTALK, "\x07" + "FF0000" + "type key please");
	local key = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_KEYPATH + OUTERWALL_KEYFILE + OUTERWALL_SAVETYPE);
	local save = FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[1] + OUTERWALL_SAVETYPE);
	printl(save)
	local hash = EncryptString(save, key);
	printl(hash)
	local resulting_save = DecryptString(hash, key);
	printl(resulting_save)
	//set bool to grab player key from chat event
	//grab three messages with key and combine? them
	//load them into player arrays and then save and load the game, respawn the player if needed
	//have it so user cannot load a key for 24h
}

::PlayerSaveGame <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerPreventSaving[player_index] == true)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERORR: Unable to save your game. Not allowing overwrite of improper save.");
		return;
	}

	if(PlayerAccountID[player_index] == null)
	{
		CalculatePlayerAccountID(client);

		if(PlayerAccountID[player_index] == null)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERORR: Unable to save your game. AccountID is null even after attempting to grab again. Steam may be down.");
			return;
		}
	}

	local save = "";

	foreach(playerdata in PlayerBestMedalArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestTimeArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(zone_count, zone in PlayerBestCheckpointTimeArray[player_index])
	{
		printl("Zone " + zone_count + ": " + zone)
		foreach(check_count, time in zone)
		{
			save += time + ",";
			printl("Time " + check_count + ": " + time)
		}
	}

	save += ";,";

	foreach(playerdata in PlayerBestMedalEncoreArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestTimeEncoreArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestLapCountEncoreArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerAchievements)
		save += playerdata[player_index].tointeger() + ",";

	save += ";,";

	foreach(playerdata in PlayerMiscStats)
		save += playerdata[player_index] + ",";

	save += ";,";

	foreach(i, setting in PlayerSettings)
		save += setting[player_index].tointeger() + ",";

	save += ";";

	StringToFile(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE, save);
	DebugPrint("GAME SAVED FOR " + player_index)
}

::PlayerLoadGame <- function(player_index)
{
	local save = FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);

	if(save == null)
		return;

	local load_data = 0;

	local i = 0;

	local savetype = PlayerDataTypes.best_medal;

	local bCheckpointIndex = false;

	local savebuffer = "";

	local save_length = save.len();

	try
	{
		while(i < save_length)
		{
			if(savetype == PlayerDataTypes.MAX)
				break;

			if(save[i] == ',' || i == save_length) //we've gotten to the end
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
					case PlayerDataTypes.best_medal:
					{
						PlayerBestMedalArray[player_index][load_data] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.best_time:
					{
						PlayerBestTimeArray[player_index][load_data] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.best_checkpoint_time:
					{
						PlayerBestCheckpointTimeArray[player_index][load_data][bCheckpointIndex.tointeger()] = savebuffer.tofloat();
						bCheckpointIndex = !bCheckpointIndex;
						break;
					}
					case PlayerDataTypes.best_medal_encore:
					{
						PlayerBestMedalEncoreArray[player_index][load_data] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.best_time_encore:
					{
						PlayerBestTimeEncoreArray[player_index][load_data] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.best_lapcount_encore:
					{
						PlayerBestLapCountEncoreArray[player_index][load_data] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.achievements:
					{
						PlayerAchievements[load_data][player_index] = !!savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.misc_stats:
					{
						PlayerMiscStats[load_data][player_index] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.settings:
					{
						PlayerSettings[load_data][player_index] = savebuffer.tointeger();
						break;
					}
				}

				if(!bCheckpointIndex)
					load_data += 1;

				savebuffer = "";
				i += 1;
				continue;
			}

			savebuffer += save[i].tochar();
			i += 1;
		}

		printl("Save Loaded for player " + player_index);
	}
	catch(exception)
	{
		local client = PlayerInstanceFromIndex(player_index);
		PlayerPreventSaving[player_index] = true;
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Your save failed to load. If you didn't edit your save, alert someone with server access and post an issue on the GitHub with the text below and your save file.");
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Save File: " + "tf/scriptdata/" + OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Error: " + exception + "\nSave Type: " + savetype + "\nLoad Data: " + load_data + "\nIndex Location: " + i + "\nSave Buffer: " + savebuffer);
	}
}

::PlayerUpdateLeaderboardTimes <- function(player_index)
{
	local player = PlayerInstanceFromIndex(player_index);
	if(FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVELEADERBOARDSUFFIX + OUTERWALL_SAVETYPE) == null)
	{
		foreach(iZone, medal in PlayerBestMedalArray[player_index])
		{
			// no medal exists, dont make leaderboard entry
			if(medal == -1)
			{
				return;
			}

			// TODO: reimplement for encore
			// if bonus 7 and we have bronze, dont make leaderboard entry
			//if(iZone == 7 && medal == 0)
			//{
			//	return;
			//}
		}
	}

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
	if(entry_list_string != null)
	{
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
			local array_index = entry_list_array.find(-1);

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

::PopulateLeaderboard <- function()
{
	local entry_list_string = FileToString(OUTERWALL_SAVEPATH + OUTERWALL_SAVELEADERBOARD + OUTERWALL_SAVETYPE);

	if(entry_list_string == null)
		return;

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

	//sort array based on total_time
	if(entry_data_array.len() != 1)
	{
		entry_data_array.sort(SortTotalTime)
	}

	EntFire("leaderboard_*", "SetText", "");

	foreach(i, ranking in entry_data_array)
	{
		if(i == 15)
			break;

		printl(i + 1 + ": " + ranking.steam_name + " - " + ranking.total_time);
		EntFire("leaderboard_" + (i + 1), "SetText", (i + 1) + ": " + ranking.steam_name + " - " + ranking.total_time)
		//NetProps.SetPropString(text, "m_iszMessage", i + 1 + ": " + ranking.steam_name + " - " + ranking.total_time);
	}
}