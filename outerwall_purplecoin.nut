const PURPLECOIN_COUNT = 120;
const PURPLECOIN_COINPATH = "purplecoin_coin_";
const PURPLECOIN_COINPATH_ENCORE = "encore_purplecoin_coin_";

const PURPLECOIN_ANNOTATE_RADAR_COOLDOWN = 25;
const COINTOUCHRADIUS = 64;

::PlayerLastUseRadar <- array(MAX_PLAYERS, 0)
::PlayerRadarReady <- array(MAX_PLAYERS, false)
::PlayerCoinStatus <- ConstructTwoDimArray(MAX_PLAYERS, PURPLECOIN_COUNT, false)
::PlayerCoinCount <- array(MAX_PLAYERS, PURPLECOIN_COUNT)

const PURPLECOIN_READY_MESSAGE_LENGTH = 2;

::PlayerLastRadarReadyMessageSet <- array(MAX_PLAYERS, 0)
::PlayerCurrentRadarMessage <- array(MAX_PLAYERS, 0)

::ResetPurpleCoinArena <- function()
{
	local player_index = activator.GetEntityIndex();

	ResetPlayerPurpleCoinArenaArray(player_index);

	DebugPrint("Reset Purple Coin Arena for player " + player_index);
}

::ResetPlayerPurpleCoinArenaArray <- function(player_index)
{
	PlayerCoinCount[player_index] = PURPLECOIN_COUNT;

	for(local iArrayIndex = 0; iArrayIndex < PURPLECOIN_COUNT; iArrayIndex++)
	{
		PlayerCoinStatus[player_index][iArrayIndex] = true;
		//DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerCoinStatus[player_index][iArrayIndex]);
	}
}

::PurpleCoinHudThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerZoneList[player_index] != eCourses.SandPit)
		return;

	local count_prefix = "";

	if(PlayerCoinCount[player_index] < 10)
		count_prefix = "00";
	else if(PlayerCoinCount[player_index] < 100)
		count_prefix = "0";

	local radar_message = "";

	if(PlayerRadarReady[player_index])
	{
		if(PlayerLastRadarReadyMessageSet[player_index] + PURPLECOIN_READY_MESSAGE_LENGTH <= Time())
		{
			PlayerLastRadarReadyMessageSet[player_index] = Time();
			PlayerCurrentRadarMessage[player_index] = PlayerCurrentRadarMessage[player_index] == 0 ? 1 : 0;
		}

		radar_message = TranslateString(OUTERWALL_HUD_COINRADAR_READY[PlayerCurrentRadarMessage[player_index]], player_index);
	}
	else
	{
		local time = round((PlayerLastUseRadar[player_index] - Time()) + PURPLECOIN_ANNOTATE_RADAR_COOLDOWN, 1);
		local pretime = time < 10 ? "0" : "";
		local posttime = time == time.tointeger() ? ".0" : "";
		radar_message = format(TranslateString(OUTERWALL_HUD_COINRADAR_NOTREADY, player_index), (pretime + time.tostring() + posttime).tostring());
	}


	EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message " + radar_message + "\n\n" + TranslateString(OUTERWALL_HUD_COIN, player_index) + count_prefix + PlayerCoinCount[player_index]));
}

::CheckPurpleCoinAnnotateButton <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerZoneList[player_index] != eCourses.SandPit)
		return;

	local buttons = NetProps.GetPropInt(client, "m_nButtons");

	if(!PlayerRadarReady[player_index] && PlayerLastUseRadar[player_index] + PURPLECOIN_ANNOTATE_RADAR_COOLDOWN <= Time())
	{
		PlayerRadarReady[player_index] = true;
		EmitSoundOnClient(SND_PURPLECOIN_RADAR_READY, client);
		return;
	}

	//If our previous key capture doesn't contain attack key && new one does.
	if(!(!(PreviousButtons[player_index] & IN_ATTACK) && buttons & IN_ATTACK))
		return;

	if(PlayerLastUseRadar[player_index] + PURPLECOIN_ANNOTATE_RADAR_COOLDOWN > Time())
	{
		EmitSoundOnClient("Player.DenyWeaponSelection", client);
		return;
	}

	local bitfield = (1 << player_index);

	local coinpath = !!!PlayerEncoreStatus[player_index] ? PURPLECOIN_COINPATH : PURPLECOIN_COINPATH_ENCORE;

	foreach(i, coin in PlayerCoinStatus[player_index])
	{
		if(!coin)
			continue;

		local trigger = Entities.FindByName(null, coinpath + (i + 1));

		if(!trigger)
			continue;

		local trigger_position = trigger.GetOrigin();

		local annotate_data = {
			worldPosX = trigger_position.x
			worldPosY = trigger_position.y
			worldPosZ = trigger_position.z + 32
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

::CoinTouch <- function()
{
	local player_index = activator.GetEntityIndex();

	if(PlayerZoneList[player_index] != eCourses.SandPit || PlayerCoinCount[player_index] == 0)
		return;

	local coinpath = !!!PlayerEncoreStatus[player_index] ? PURPLECOIN_COINPATH : PURPLECOIN_COINPATH_ENCORE;

	//get closest purplecoin prop_dynamic and get its name
	local player_origin = activator.GetOrigin();
	local CoinHandle = Entities.FindByNameWithin(null, coinpath + "*", player_origin, COINTOUCHRADIUS);
	//DebugDrawBox(player_origin, Vector(-COINTOUCHRADIUS, -COINTOUCHRADIUS, -COINTOUCHRADIUS), Vector(COINTOUCHRADIUS, COINTOUCHRADIUS, COINTOUCHRADIUS), 255, 0, 0, 155, 10)

	if(!CoinHandle)
	{
		player_origin.z += 96;
		CoinHandle = Entities.FindByNameWithin(null, coinpath + "*", player_origin, COINTOUCHRADIUS);
		//DebugDrawBox(player_origin, Vector(-COINTOUCHRADIUS, -COINTOUCHRADIUS, -COINTOUCHRADIUS), Vector(COINTOUCHRADIUS, COINTOUCHRADIUS, COINTOUCHRADIUS), 0, 255, 0, 155, 10)
	}

	if(!CoinHandle)
		return;

	local strTriggerName = NetProps.GetPropString(CoinHandle, "m_iName");

	local TriggerID = strTriggerName.slice(PURPLECOIN_COINPATH.len()).tointeger() - 1;

	if(PlayerCoinStatus[player_index][TriggerID] == false)
		return;

	PlayerCoinStatus[player_index][TriggerID] = false;
	DebugPrint("Set Trigger ID " + (TriggerID + 1) + " to " + PlayerCoinStatus[player_index][TriggerID]);

	PlayerCoinCount[player_index] -= 1;
	DebugPrint("Coins Collected for player " + player_index + ": " + PlayerCoinCount[player_index]);

	//show particle and play sound
	local coin_location = CoinHandle.GetOrigin();
	coin_location.z += 16;
	DispatchParticleEffect("purplecoin_collect", coin_location, Vector(0,90,0));
	activator.EmitSound(SND_PURPLECOIN_COLLECT);

	//Collected all coins
	if(PlayerCoinCount[player_index] == 0)
	{
		DebugPrint("All Coins Collected for player " + player_index);
		DoGoal(6, activator);
		TeleportPlayerToZone(6, activator);
	}
	else if(PlayerCoinCount[player_index] == 80)
	{
		SetPlayerCheckpoint(1);
	}
	else if(PlayerCoinCount[player_index] == 40)
	{
		SetPlayerCheckpoint(2);
	}

	local annotate_data = {
		id = (player_index.tostring() + TriggerID.tostring()).tointeger()
	};
	SendGlobalGameEvent("hide_annotation", annotate_data);
}