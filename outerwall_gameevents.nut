ClearGameEventCallbacks();

function OnGameEvent_teamplay_round_win(eventdata)
{
	bRoundOver = true;
	PerformAutosave();
    for (local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
    {
        local player = PlayerInstanceFromIndex(player_index);
        if (player == null) continue;
		DoEntFire("trigger_soundscape_empty", "StartTouch", "", -1, player, player);
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

	if(PlayerCosmeticColorEdit[player_index] == 0)
		return;

	if(eventdata.text.len() != 11)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07FF0000" + TranslateString(COSMETIC_EDIT_ERROR_CHARCOUNT, player_index));
		return;
	}

	try
	{
		local message_array = split(eventdata.text, " ");

		if(message_array.len() != 3)
		{
			ClientPrint(client, HUD_PRINTTALK, "\x07FF0000" + TranslateString(COSMETIC_EDIT_ERROR_SPACECOUNT, player_index));
			return;
		}

		local color1 = FormatChatColor(message_array[0]);
		local color2 = FormatChatColor(message_array[1]);
		local color3 = FormatChatColor(message_array[2]);

		MachTrailColors[PlayerCosmeticColorEdit[player_index] - 1][player_index] = color1 + " " + color2 + " " + color3;
		UpdateCosmeticEquipText(client);
		EmitSoundOnClient(SND_MENU_SELECT, client);
		ClientPrint(client, HUD_PRINTTALK, "\x0700FF00" + format(TranslateString(COSMETIC_EDIT_SUCCESS, player_index), PlayerCosmeticColorEdit[player_index]) + "\"" + MachTrailColors[PlayerCosmeticColorEdit[player_index] - 1][player_index] + "\".");
		PlayerSaveGame(client);
	}
	catch (exception)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07FF0000" + TranslateString(COSMETIC_EDIT_ERROR_COLOR, player_index) + "(" + exception + ")");
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
		GetPlayerLanguage(client);
		CreateGameTextForPlayer(player_index);
		PrecachePlayerSounds(client);
		ResetPlayerGlobalArrays(player_index);
		CalculatePlayerAccountID(client);
		PlayerLoadGame(player_index);
		EncoreTeamCheck(client);
		PlayerUpdateLeaderboardTimes(player_index);
		AddThinkToEnt(client, "OuterwallClientThink");
		DebugPrint("Player " + player_index + " had their first spawn\n");
		PlayTrack(2, client, true);
		return;
	}

	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
	EncoreTeamCheck(client);

	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false, false);

	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

__CollectGameEventCallbacks(this);