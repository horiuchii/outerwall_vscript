ClearGameEventCallbacks();

function OnGameEvent_teamplay_round_win(eventdata)
{
	bRoundOver = true;
	PerformAutosave();
    for (local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
    {
        local player = PlayerInstanceFromIndex(player_index);
        if (player == null) continue;
		DoEntFire("trigger_soundscape_empty", "StartTouch", "", 0.0, player, player);
    }
}

function OnGameEvent_player_death(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	EntFireByHandle(client, "RunScriptCode", "activator.ForceRespawn()", 1.0, client, client);
}

function OnGameEvent_player_connect(eventdata)
{
	ResetPlayerGlobalArrays(eventdata.index + 1);
}

function OnGameEvent_player_say(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	local player_index = client.GetEntityIndex();

	if(PlayerCosmeticColorEdit[player_index] > 0)
	{
		local message = eventdata.text;
		if(message.len() != 11)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07FF0000" + "ERROR: Color contains incorrect number of characters.");
			return;
		}

		try
		{
			local message_array = split(message, " ");
			local color1 = clamp(message_array[0].tointeger(), 0, 255);

			if(color1 == 0)
				color1 = "000";
			else if(color1 < 10)
				color1 = "00" + color1;
			else if(color1 < 100)
				color1 = "0" + color1;

			local color2 = clamp(message_array[1].tointeger(), 0, 255);

			if(color2 == 0)
				color2 = "000";
			else if(color2 < 10)
				color2 = "00" + color2;
			else if(color2 < 100)
				color2 = "0" + color2;

			local color3 = clamp(message_array[2].tointeger(), 0, 255);

			if(color3 == 0)
				color3 = "000";
			else if(color3 < 10)
				color3 = "00" + color3;
			else if(color3 < 100)
				color3 = "0" + color3;

			MachTrailColors[PlayerCosmeticColorEdit[player_index] - 1][player_index] = color1 + " " + color2 + " " + color3;
			UpdateCosmeticEquipText(client);
			PlayerSaveGame(client);
		}
		catch (exception)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07FF0000" + "ERROR: Failed to parse chat message: " + exception);
		}
	}
}

function OnGameEvent_player_spawn(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);

	DebugPrint("GameEventPlayerSpawn: Running function for player: " + eventdata.userid.tostring() + ", " + client.GetEntityIndex().tostring());

	if(!client || !client.IsPlayer() || client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR || !IsPlayerAlive(client))
		return;

	local player_index = client.GetEntityIndex();

	NetProps.SetPropString(client, "m_iName", "outerwall_player_" + player_index);

	if(PlayerZoneList[player_index] == null) //player's first spawn
	{
		PrecachePlayerSounds(client);
		ResetPlayerGlobalArrays(player_index);
		CalculatePlayerAccountID(client);
		PlayerLoadGame(player_index);
		EncoreTeamCheck(client);
		PlayerUpdateLeaderboardTimes(player_index);
		GetPlayerLanguage(client);
		AddThinkToEnt(client, "OuterwallClientThink");
		DebugPrint("Player " + player_index + " had their first spawn\n");
		return;
	}

	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
	EncoreTeamCheck(client);

	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false, false);

	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

__CollectGameEventCallbacks(this);