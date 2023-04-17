const PURPLECOIN_COUNT = 120;
const PURPLECOIN_TRIGGERPATH = "purplecoin_trigger-InstanceAuto";
const PURPLECOIN_COINPATH = "purplecoin_coin-InstanceAuto";

const PURPLECOIN_ANNOTATE_RADAR_COOLDOWN = 25;

// +1 because name increments for every func_instance and the 3d sky is an instance
::PlayerLastUseRadar <- array(MAX_PLAYERS, 0)
::PlayerRadarReady <- array(MAX_PLAYERS, false)
::PlayerCoinStatus <- array(MAX_PLAYERS, array(PURPLECOIN_COUNT + 1, false))
::PlayerCoinCount <- array(MAX_PLAYERS, 0)
::PurpleCoinPlayerHUDStatusArray <- array(MAX_PLAYERS, false)

::ResetPurpleCoinArena <- function()
{
	local player_index = activator.GetEntityIndex();

	ResetPlayerPurpleCoinArenaArray(player_index);

	//Reset Player HUD Count
	EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "message 000");

	DebugPrint("Reset Purple Coin Arena for player " + player_index);
}

::ResetPlayerPurpleCoinArenaArray <- function(player_index)
{
	PlayerCoinCount[player_index] = 0;

	for(local iArrayIndex = 0; iArrayIndex < PURPLECOIN_COUNT; iArrayIndex++)
	{
		PlayerCoinStatus[player_index][iArrayIndex] = true;
		//DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerCoinStatus[player_index][iArrayIndex]);
	}
}

::CheckPurpleCoinAnnotateButton <- function(client)
{
	local player_index = client.GetEntityIndex();

	local buttons = NetProps.GetPropInt(client, "m_nButtons");

	if(!PlayerRadarReady[player_index] && PlayerLastUseRadar[player_index] + PURPLECOIN_ANNOTATE_RADAR_COOLDOWN <= Time())
	{
		PlayerRadarReady[player_index] = true;
		EmitSoundOnClient(SND_PURPLECOIN_RADAR_READY, client);
		return;
	}

	//If our previous key capture doesn't contain attack key && new one does.
	if(PlayerZoneList[player_index] != 6 || !(!(PreviousButtons[player_index] & IN_ATTACK) && buttons & IN_ATTACK))
		return;

	if(PlayerLastUseRadar[player_index] + PURPLECOIN_ANNOTATE_RADAR_COOLDOWN > Time())
	{
		EmitSoundOnClient("Player.DenyWeaponSelection", client);
		return;
	}


	local bitfield = GenerateVisibilityBitfield(player_index);

	foreach(i, coin in PlayerCoinStatus[player_index])
	{
		if(!coin)
			continue;

		local trigger = Entities.FindByName(null, PURPLECOIN_TRIGGERPATH + (i + 1));

		local trigger_position = trigger.GetOrigin();

		local annotate_data = {
			worldPosX = trigger_position.x
			worldPosY = trigger_position.y
			worldPosZ = trigger_position.z + 16
			id = (player_index.tostring() + i.tostring()).tointeger()
			text = "!"
			lifetime = 6.5
			visibilityBitfield = bitfield
			play_sound = "/misc/null.wav"
		};
		SendGlobalGameEvent("show_annotation", annotate_data);
	}

	PlayerLastUseRadar[player_index] = Time();
	EmitSoundOnClient(SND_PURPLECOIN_RADAR, client);
	PlayerClocksCollectedDuringRun[player_index] = true;
	PlayerRadarReady[player_index] = false;
}

::CoinTouch <- function(bEncoreCoin = false)
{
	local player_index = activator.GetEntityIndex();

	if(PlayerEncoreStatus[player_index] != bEncoreCoin.tointeger())
		return;

	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
		return;

	local strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(PURPLECOIN_TRIGGERPATH.len()).tointeger() - 1;

	if (PlayerCoinStatus[player_index][TriggerID] == false)
		return;

	PlayerCoinStatus[player_index][TriggerID] = false;
	DebugPrint("Set Trigger ID " + (TriggerID + 1) + " to " + PlayerCoinStatus[player_index][TriggerID]);

	PlayerCoinCount[player_index] += 1;
	DebugPrint("Coins Collected for player " + player_index + ": " + PlayerCoinCount[player_index]);

	//update player HUD
	if(PlayerCoinCount[player_index] < 10)
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message 00" + PlayerCoinCount[player_index]));
	else if(PlayerCoinCount[player_index] < 100)
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message 0" + PlayerCoinCount[player_index]));
	else
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message " + PlayerCoinCount[player_index]));

	//show particle and play sound
	DispatchParticleEffect("purplecoin_collect", caller.GetOrigin(), Vector(0,90,0));
	activator.EmitSound(SND_PURPLECOIN_COLLECT);

	//Collected all coins
	if(PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
	{
		DebugPrint("All Coins Collected for player " + player_index);
		DoGoal(6, activator);
	}
	else if(PlayerCoinCount[player_index] == 80)
	{
		SetPlayerCheckpoint(2);
	}
	else if(PlayerCoinCount[player_index] == 40)
	{
		SetPlayerCheckpoint(1);
	}

	local annotate_data = {
		id = (player_index.tostring() + TriggerID.tostring()).tointeger()
	};
	SendGlobalGameEvent("hide_annotation", annotate_data);
}

::SetPurpleCoinHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();

	PurpleCoinPlayerHUDStatusArray[player_index] = bSetHUD;
}