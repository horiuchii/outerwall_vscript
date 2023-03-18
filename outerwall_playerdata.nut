const ZONE_COUNT = 8;

::PlayerBestMedalArray <- array(MAX_PLAYERS, array(ZONE_COUNT, -1))
::PlayerBestTimeArray <- array(MAX_PLAYERS, array(ZONE_COUNT, 5000))
::PlayerSoundtrackList <- array(MAX_PLAYERS, 0)

::PlayerSettings <-
[
	::PlayerSettingDisplayTime <- array(MAX_PLAYERS, false)
]

enum PlayerDataTypes
{
	best_medal
	best_time
	soundtrack
	settings
	MAX
}

const OUTERWALL_SAVEPATH = "pf_outerwall/"
const OUTERWALL_SAVETYPE = ".sav"

::PlayerAccountID <- array(MAX_PLAYERS, null);

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

::PlayerSaveGame <- function(client)
{
	local player_index = client.GetEntityIndex();
	
	if(PlayerAccountID[player_index] == null)
	{
		CalculatePlayerAccountID(client);
		
		if(PlayerAccountID[player_index] == null)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "ERORR: Unable to save your game. AccountID is null even after attempting to grab again!");
			return;		
		}
	}
	
	local save = "";
	
	foreach(playerdata in PlayerBestMedalArray[player_index])
	{
		save += playerdata + ",";
	}
	
	save += ";,"
	
	foreach(playerdata in PlayerBestTimeArray[player_index])
	{
		save += playerdata + ",";
	}
	
	save += ";,"
	
	save += PlayerSoundtrackList[player_index] + ",";
	
	save += ";,"
	
	foreach(setting in PlayerSettings)
	{
		save += setting[player_index] + ",";
	}
	
	save += ";"
	
	StringToFile(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE, save);
	printl("GAME SAVED")
}

::PlayerLoadGame <- function(player_index)
{
	local load_data = 0
	
	local i = 0;
	
	local savetype = PlayerDataTypes.best_medal;
	
	local savebuffer = "";
	
	local save = FileToString(OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);
	
	if(save == null)
		return;
	
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
					case PlayerDataTypes.soundtrack:
					{
						PlayerSoundtrackList[player_index] = savebuffer.tointeger();
						break;
					}
					case PlayerDataTypes.soundtrack:
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
		
		printl("Save Loaded for player " + player_index);
	}
	catch(exception)
	{
		local client = PlayerInstanceFromIndex(player_index);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Your save failed to load. If you didn't edit your save, alert someone with server access and post an issue on the GitHub with the text below and your save file.");
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Save File: " + "scriptdata/" + OUTERWALL_SAVEPATH + PlayerAccountID[player_index] + OUTERWALL_SAVETYPE);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FFA500" + "Error: " + exception + "\nSave Type: " + savetype + "\nLoad Data: " + load_data + "\nIndex Location: " + i + "\nSave Buffer: " + savebuffer);
	}
}