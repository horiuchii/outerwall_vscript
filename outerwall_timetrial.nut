const START_TIME = 15.0;
const PICKUP_ADD_TIME = 15.0;
const LAP_ADD_TIME = 30.0;
const TIME_REDUCE_THINK = 0.1;
const TIMEPICKUP_COUNT = 15;
const TIMETRIAL_TRIGGERPATH = "timetrial_trigger_";

::PlayerTimeTrialTime <- array(MAX_PLAYERS, START_TIME)
::PlayerTimeTrialTimeDisplay <- array(MAX_PLAYERS, START_TIME)
::PlayerTimePickupStatus <- array(MAX_PLAYERS, array(TIMEPICKUP_COUNT, false))
::PlayerTimeTrialActive <- array(MAX_PLAYERS, false)
::PlayerLastTimeTrialThink <- array(MAX_PLAYERS, 0)
::PlayerCurrentLapCount <- array(MAX_PLAYERS, 1)

::IsTimeLerping <- function(player_index)
{
	return PlayerTimeTrialTimeDisplay[player_index] + 0.05 < PlayerTimeTrialTime[player_index];
}

::PlayerTimeTrialThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(PlayerTimeTrialActive[player_index] != true)
		return;

	if(PlayerLastTimeTrialThink[player_index] + TIME_REDUCE_THINK > Time())
		return;

	PlayerLastTimeTrialThink[player_index] = Time();

	if(PlayerTimeTrialTime[player_index] <= 0)
		client.TakeDamageEx(null, client, null, Vector(0,0,0), Vector(0,0,0), 2.5, DMG_BURN);
	else
	{
		PlayerTimeTrialTime[player_index] -= TIME_REDUCE_THINK;
		if(!IsTimeLerping(player_index))
			PlayerTimeTrialTimeDisplay[player_index] -= TIME_REDUCE_THINK;
	}

	if(IsTimeLerping(player_index))
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "color 0 255 0");
	else
	{
		local time = remap(-0.1, 15.0, 0.0, 1.0, clamp(0.0, 15.0, PlayerTimeTrialTimeDisplay[player_index]));
		local color = lerpRGB(time, Vector(255, 0, 0), Vector(240, 255, 0));
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "color " + color.x + " " + color.y + " " + color.z);
	}

	PlayerTimeTrialTimeDisplay[player_index] = SmoothDamp(PlayerTimeTrialTimeDisplay[player_index], PlayerTimeTrialTime[player_index], 0, 0.03, 999999, DeltaTime());

	UpdatePlayerTimeDisplay(player_index);
}

::ResetTimeTrialArena <- function(player_index)
{
	ResetPlayerTimeTrialArenaArray(player_index);
	UpdatePlayerTimeDisplay(player_index);

	DebugPrint("Reset Time Trial Arena for player " + player_index);
}

::UpdatePlayerTimeDisplay <- function(player_index)
{
	local time = round(PlayerTimeTrialTimeDisplay[player_index], 1);
	local pretime = time < 10 ? "0" : "";
	local posttime = time == time.tointeger() ? ".0" : "";
	local lapcount = PlayerCurrentLapCount[player_index] > 1? "\n" + TranslateString(OUTERWALL_TIMETRIAL_LAP, player_index) + PlayerCurrentLapCount[player_index] : "";
	EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "message " + " " + pretime + time.tostring() + posttime + lapcount);

	if(round(time - time.tointeger(), 1) == 0.9 && !IsTimeLerping(player_index))
		EmitSoundOnClient(SND_WARTIMER, PlayerInstanceFromIndex(player_index));
}

::ResetPlayerTimeTrialArenaArray <- function(player_index)
{
	PlayerTimeTrialTime[player_index] = START_TIME;
	PlayerTimeTrialTimeDisplay[player_index] = START_TIME;
	EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "color 240 255 0");
	PlayerCurrentLapCount[player_index] = 1;
	PlayerLastTimeTrialThink[player_index] = 0;

	for(local iArrayIndex = 0; iArrayIndex < PlayerTimePickupStatus[player_index].len(); iArrayIndex++)
	{
		PlayerTimePickupStatus[player_index][iArrayIndex] = true;
		DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerTimePickupStatus[player_index][iArrayIndex]);
	}
}

::PlayerActivateTimeTrial <- function(client, bSetTimeTrial)
{
	local player_index = client.GetEntityIndex();

	if(PlayerEncoreStatus[player_index] != 1)
		return;

	PlayerTimeTrialActive[player_index] = bSetTimeTrial;
}

::PlayerEnterLapTeleporter <- function()
{
	local player_index = activator.GetEntityIndex();

	if(PlayerTimeTrialActive[player_index] == false || PlayerEncoreStatus[player_index] != 1)
		return;

	local TeleportDest = Entities.FindByName(null, "teleport_encore_" + PlayerZoneList[player_index].tostring());

	if(TeleportDest == null)
		return;

	for(local iArrayIndex = 0; iArrayIndex < PlayerTimePickupStatus[player_index].len(); iArrayIndex++)
	{
		PlayerTimePickupStatus[player_index][iArrayIndex] = true;
		DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerTimePickupStatus[player_index][iArrayIndex]);
	}

	PlayerCurrentLapCount[player_index]++;
	PlayerTimeTrialTime[player_index] += LAP_ADD_TIME;
	activator.SetOrigin(TeleportDest.GetOrigin());
	EmitSoundOnClient(SND_WARTIMER_UP, activator);
}

::TimePickupTouch <- function()
{
	local player_index = activator.GetEntityIndex();

	if(PlayerTimeTrialActive[player_index] == false || PlayerEncoreStatus[player_index] != 1)
		return;

	local strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(TIMETRIAL_TRIGGERPATH.len()).tointeger() - 1;

	if(PlayerCurrentLapCount[player_index] >= 6)
		return;

	if (PlayerTimePickupStatus[player_index][TriggerID] == false)
		return;

	PlayerTimePickupStatus[player_index][TriggerID] = false;

	local time = PICKUP_ADD_TIME;
	for (local i = 0; i < PlayerCurrentLapCount[player_index] - 1; i++)
		time = time / 2;

	PlayerTimeTrialTime[player_index] += time
	printl(time)

	EmitSoundOnClient(SND_WARTIMER_UP, activator);
}