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

function OnGameEvent_player_team(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);

	if(client == null)
        return;

	EncoreTeamCheck(client);
}

function OnGameEvent_server_cvar(eventdata)
{
	if(bGlobalCheated)
		return;

	if(eventdata.cvarname == "sv_cheats")
	{
		bGlobalCheated = true;
		ClientPrint(null, HUD_PRINTTALK, "\x07" + "FF0000" + "WARNING: Cvar \"" + eventdata.cvarname + "\" has been changed. Scoring has been disabled.")
	}
}

function OnGameEvent_player_spawn(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);

	DebugPrint("GameEventPlayerSpawn: Running function for player: " + eventdata.userid.tostring() + ", " + client.GetEntityIndex().tostring());

	if(!client || !client.IsPlayer() || client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR || !IsPlayerAlive(client))
		return;

	local player_index = client.GetEntityIndex();

	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
    EncoreTeamCheck(client);

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

	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false, false);

	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

__CollectGameEventCallbacks(this);