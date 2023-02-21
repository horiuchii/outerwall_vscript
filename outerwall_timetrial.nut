const START_TIME = 10.0;
const PICKUP_ADD_TIME = 15.0;
const SUPERPICKUP_ADD_TIME = 45.0;
const TIME_REDUCE_THINK = 0.1;
const TIMEPICKUP_COUNT = 6;
const TIMETRIAL_TRIGGERPATH = "timetrial_trigger_";
const TIMETRIAL_PLAYERHUDTEXT = "outerwall_bonus7_gametext_";

::PlayerTimeTrialTime <- array(MAX_PLAYERS, START_TIME)
::PlayerTimeTrialTimeDisplay <- array(MAX_PLAYERS, START_TIME)
::PlayerTimeTrialTimeDisplayVelocity <- array(MAX_PLAYERS, 0.0)
::PlayerTimePickupStatus <- array(MAX_PLAYERS, array(TIMEPICKUP_COUNT, false))
::PlayerTimeTrialActive <- array(MAX_PLAYERS, false)
::PlayerLapTwoStatus <- array(MAX_PLAYERS, false)
::TimeTrialPlayerHUDStatusArray <- array(MAX_PLAYERS, false)

::CreateBonus7GameText <- function()
{
	for(local iArrayIndex = 1 ; iArrayIndex < MAX_PLAYERS ; iArrayIndex++)
	{
		local gametext = SpawnEntityFromTable("game_text",
		{
			targetname = TIMETRIAL_PLAYERHUDTEXT + iArrayIndex,
			message = "10.0",
			channel = 4,
			color = "240 255 0",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.5015,
			y = 0.905
		})
		
		Entities.DispatchSpawn(gametext);
	}
}

::IsTimeLerping <- function(player_index)
{
	return PlayerTimeTrialTimeDisplay[player_index] + 0.05 < PlayerTimeTrialTime[player_index];
}

::PlayerTimeTrialThink <- function(client)
{
	local player_index = client.GetEntityIndex();
	
	if(PlayerTimeTrialActive[player_index] != true)
		return;
	
	if(PlayerTimeTrialTime[player_index] <= 0)
		client.TakeDamageEx(null, client, null, Vector(0,0,0), Vector(0,0,0), 2.5, DMG_BURN);
	else
	{
		PlayerTimeTrialTime[player_index] -= TIME_REDUCE_THINK;
		if(!IsTimeLerping(player_index))
			PlayerTimeTrialTimeDisplay[player_index] -= TIME_REDUCE_THINK;
	}
	
	if(IsTimeLerping(player_index))
		EntFire(TIMETRIAL_PLAYERHUDTEXT + player_index, "addoutput", "color 0 255 0");
	else
	{
		local time = remap(-0.1, 15.0, 0.0, 1.0, clamp(0.0, 15.0, PlayerTimeTrialTimeDisplay[player_index]));
		local color = lerpRGB(time, Vector(255, 0, 0), Vector(240, 255, 0));
		EntFire(TIMETRIAL_PLAYERHUDTEXT + player_index, "addoutput", "color " + color.x + " " + color.y + " " + color.z);
	}
	
	PlayerTimeTrialTimeDisplay[player_index] = SmoothDamp(PlayerTimeTrialTimeDisplay[player_index], PlayerTimeTrialTime[player_index], 0, 0.03, 999999, DeltaTime());
	
	UpdatePlayerTimeDisplay(player_index);
}

::ResetTimeTrialArena <- function()
{
	local player_index = activator.GetEntityIndex();
	
	ResetPlayerTimeTrialArenaArray(player_index);
	UpdatePlayerTimeDisplay(player_index);
	
	DebugPrint("Reset Time Trial Arena for player " + player_index);
}

::UpdatePlayerTimeDisplay <- function(player_index)
{
	local time = round(PlayerTimeTrialTimeDisplay[player_index], 1);
	local pretime = time < 10 ? "0" : "";
	local posttime = time == time.tointeger() ? ".0" : "";
	local lapcount = PlayerLapTwoStatus[player_index] ? "\n" + TranslateString(OUTERWALL_TIMETRIAL_LAP, player_index) + " 2" : "";
	EntFire(TIMETRIAL_PLAYERHUDTEXT + player_index, "addoutput", "message " + " " + pretime + time.tostring() + posttime + lapcount);
	
	if(round(time - time.tointeger(), 1) == 0.9 && !IsTimeLerping(player_index))
		EmitSoundOnClient(SND_WARTIMER, PlayerInstanceFromIndex(player_index));
}

::ResetPlayerTimeTrialArenaArray <- function(player_index)
{
	PlayerTimeTrialTime[player_index] = START_TIME;
	PlayerTimeTrialTimeDisplay[player_index] = START_TIME;
	EntFire(TIMETRIAL_PLAYERHUDTEXT + player_index, "addoutput", "color 240 255 0");
	PlayerLapTwoStatus[player_index] = false;
	
	for(local iArrayIndex = 0 ; iArrayIndex < PlayerTimePickupStatus[player_index].len() ; iArrayIndex++)
	{
		PlayerTimePickupStatus[player_index][iArrayIndex] = true;
		DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerTimePickupStatus[player_index][iArrayIndex]);
	}
}

::PlayerActivateTimeTrial <- function(bSetTimeTrial)
{
	local player_index = activator.GetEntityIndex();
	
	PlayerTimeTrialActive[player_index] = bSetTimeTrial;
}

::PlayerEnterLapTwo <- function()
{
	local player_index = activator.GetEntityIndex();
	if(PlayerLapTwoStatus[player_index] == false)
	{
		PlayerLapTwoStatus[player_index] = true;
		//teleport back to start
		DisplayTime(activator, true);
		DebugPrint("Player " + player_index + " entering lap 2");
	}
}

::TimePickupTouch <- function(iType)
{
	local player_index = activator.GetEntityIndex();
	
	if(PlayerTimeTrialActive[player_index] == false)
		return;
	
	local strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(TIMETRIAL_TRIGGERPATH.len()).tointeger() - 1;
	
	if (PlayerTimePickupStatus[player_index][TriggerID] == false)
		return;
		
	PlayerTimePickupStatus[player_index][TriggerID] = false;
	
	if(iType == 1)
	{
		PlayerTimeTrialTime[player_index] += PICKUP_ADD_TIME;	
	}
	else if(iType == 2 && PlayerLapTwoStatus[player_index] == true)
	{
		PlayerTimeTrialTime[player_index] += SUPERPICKUP_ADD_TIME;
	}
	
	EmitSoundOnClient(SND_WARTIMER_UP, activator);
}

::SetTimeTrialHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	TimeTrialPlayerHUDStatusArray[player_index] = bSetHUD;
}