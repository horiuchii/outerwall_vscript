::PlayerAccountID <- array(MAX_PLAYERS, null)

::SpecialPlayerAccountID <-
[
	"283216923" //Horiuchi
	"123928992" //Bradasparky
	"40068780" //Lucas
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
const MAX_LEADERBOARD_ENTRIES = 1638;

::leaderboard_array <- array(MAX_LEADERBOARD_ENTRIES, null)
::current_leaderboard_page <- 1;
::leaderboard_max_page <- 1;

const ZONE_COUNT = 7;
const ZONE_COUNT_ENCORE = 7;
const CHECKPOINT_COUNT = 2;

::PlayerPreventSaving <- array(MAX_PLAYERS, false)

::PlayerBestTimeArray <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestCheckpointTimeArrayOne <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestCheckpointTimeArrayTwo <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT, 5000)
::PlayerBestLapCountEncoreArray <- ConstructTwoDimArray(MAX_PLAYERS, ZONE_COUNT_ENCORE, 0)
::PlayerBestSandPitTimeEncoreArray <- array(MAX_PLAYERS, 5000)

::PlayerAchievements <- ConstructTwoDimArray(MAX_PLAYERS, eAchievements.MAX, 0)

::PlayerMiscStats <-
[
	::PlayerSecondsPlayed <- array(MAX_PLAYERS, 0)
	::PlayerSpikeHits <- array(MAX_PLAYERS, 0)
	::PlayerLavaHits <- array(MAX_PLAYERS, 0)
	::PlayerLapsRan <- array(MAX_PLAYERS, 0)
	::PlayerPVPKills <- array(MAX_PLAYERS, 0)
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
	map_version
	best_time
	best_checkpoint_time_one
	best_checkpoint_time_two
	best_lapcount_encore
	best_sandpit_time_encore
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
	PlayerAccountID[player_index] = null;

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
		PlayerAchievements[player_index][i] = 0;

	foreach(i, stats in PlayerMiscStats)
		PlayerMiscStats[i][player_index] = 0;

	foreach(i, setting in PlayerSettings)
		PlayerSettings[i][player_index] = 0;

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

	if(player_networkid == null || player_networkid == 0 || type(player_networkid) != "string" || player_networkid == "" || player_networkid == "null" || player_networkid == "BOT" || player_networkid == "STEAM_ID_LAN" || player_networkid == "STEAM_ID_PENDING" || player_networkid == "HLTV" || player_networkid == "REPLAY" || player_networkid == "UNKNOWN")
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
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to save your game due to a previous error. Please rejoin the server.");
		return;
	}

	if(PlayerAccountID[player_index] == null)
	{
		CalculatePlayerAccountID(client);

		if(PlayerAccountID[player_index] == null)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to save your game. AccountID is null even after attempting to grab again. Steam may be down.");
			return;
		}
	}

	local mapversion = split(GetMapName(), "_");

	if(mapversion.len() != 3)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to save your game. Map name is invalid.");
		return;
	}

	local save = "";

	save += mapversion[2] + ",;,";

	foreach(playerdata in PlayerBestTimeArray[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestCheckpointTimeArrayOne[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestCheckpointTimeArrayTwo[player_index])
		save += playerdata + ",";

	save += ";,";

	foreach(playerdata in PlayerBestLapCountEncoreArray[player_index])
		save += playerdata + ",";

	save += ";,";

	save += PlayerBestSandPitTimeEncoreArray[player_index] + ",;,";

	foreach(playerdata in PlayerAchievements[player_index])
		save += playerdata.tointeger() + ",";

	save += ";,";

	foreach(playerdata in PlayerMiscStats)
		save += playerdata[player_index] + ",";

	save += ";,";

	foreach(i, setting in PlayerSettings)
		save += setting[player_index].tointeger() + ",";

	save += ";,;";

	StringToFile(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE, save);
	DebugPrint("GAME SAVED FOR " + player_index)
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

	local load_data = 0;

	local i = 0;

	local savetype = PlayerDataTypes.map_version;

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
					case PlayerDataTypes.map_version:
					{
						break;
					}
					case PlayerDataTypes.best_time:
					{
						PlayerBestTimeArray[player_index][load_data] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.best_checkpoint_time_one:
					{
						PlayerBestCheckpointTimeArrayOne[player_index][load_data] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.best_checkpoint_time_two:
					{
						PlayerBestCheckpointTimeArrayTwo[player_index][load_data] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.best_lapcount_encore:
					{
						PlayerBestLapCountEncoreArray[player_index][load_data] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.best_sandpit_time_encore:
					{
						PlayerBestSandPitTimeEncoreArray[player_index] = savebuffer.tofloat();
						break;
					}
					case PlayerDataTypes.achievements:
					{
						PlayerAchievements[player_index][load_data] = !!savebuffer.tointeger();
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

				load_data += 1;
				savebuffer = "";
				i += 1;
				continue;
			}

			savebuffer += save[i].tochar();
			i += 1;
		}

		DebugPrint("Save Loaded for player " + player_index);
	}
	catch(exception)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Your save failed to load. If you didn't manually edit your save, alert someone with server access and post an issue on the \"horiuchii/outerwall_vscript\" GitHub with the text below and your save file.");
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Save File: " + "tf/scriptdata/" + OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Error: " + exception + "\nSave Type: " + savetype + "\nLoad Data: " + load_data + "\nIndex Location: " + i + "\nSave Buffer: " + savebuffer);
		ResetPlayerDataArrays(player_index);
		PlayerPreventSaving[player_index] = true;
	}
}

::PlayerUpdateLeaderboardTimes <- function(player_index)
{
	if(PlayerPreventSaving[player_index] == true)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Unable to update your leaderboard times due to a previous error.");
		return;
	}

	local player = PlayerInstanceFromIndex(player_index);
	if(FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVELEADERBOARDSUFFIX + OUTERWALL_SAVETYPE) == null)
	{
		if(!IsPlayerEncorable(player_index))
			return;
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

	// for(local i = 0; i < 1600; i++)
	// {
	// 	dummy_entry_data <- {
	// 		account_id = null,
	// 		steam_name = "DUMMYDUMMYDUMMY(" + i + ")",
	// 		total_time = RandomFloat(120, 1000)
	// 	}

	// 	entry_data_array.append(dummy_entry_data);
	// }

	//sort array based on total_time
	if(entry_data_array.len() > 1)
	{
		entry_data_array.sort(SortTotalTime)
	}

	leaderboard_array = entry_data_array;
	SetLeaderboardPage(1);
}

const LEADERBOARD_PAGE_SIZE = 22;

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

	foreach(i, ranking in leaderboard_page)
	{
		if(!ranking)
			break;

		if(i <= 5)
			EntFire("leaderboard_" + i, "SetRainbow", iPage == 1 ? "1" : "0");

		//DebugPrint((i + 1 + start_len) + ": " + ranking.steam_name + " - " + FormatTime(ranking.total_time));
		EntFire("leaderboard_" + (i + 1), "SetText", (i + 1 + start_len) + ": " + ranking.steam_name + " - " + FormatTime(round(ranking.total_time, 2)))
	}
}