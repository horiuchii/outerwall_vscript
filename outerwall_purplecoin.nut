const PURPLECOIN_COUNT = 120;
const PURPLECOIN_TRIGGERPATH = "purplecoin_trigger-InstanceAuto";
const PURPLECOIN_COINPATH = "purplecoin_coin-InstanceAuto";

const PURPLECOIN_PLAYERHUDTEXT = "outerwall_bonus6_gametext_";

//TODO: Refactor this to not use a dipshit table and just use a 2D array
::PlayerCoinStatusTable <- {}
::PlayerCoinCount <- array(MAX_PLAYERS, 0)
::PurpleCoinPlayerHUDStatusArray <- array(MAX_PLAYERS, false)

::ResetArena <- function()
{
	local player_index = activator.GetEntityIndex();
	
	ResetPlayerArenaArray(player_index);
	
	EntFire(PURPLECOIN_COINPATH + "*", "Enable"); //TEMPORARY - SETTRANSMIT DOESN'T EXIST - DO NOT SHIP
	//transmit all coins to player
	/*
	local CoinModel = null;
	for(local iArrayIndex = 0 ; iArrayIndex < PURPLECOIN_COUNT + 1 ; iArrayIndex++)
	{
		CoinModel = Entities.FindByName(CoinModel, PURPLECOIN_COINPATH + (iArrayIndex + 1));
		activator.SetTransmit(CoinModel, true);
	}
	*/

	//Reset Player HUD Count
	EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", "message 000");
	
	DebugPrint("Reset Arena for player " + player_index);
}

::ResetPlayerArenaArray <- function(player_index)
{
	PlayerCoinCount[player_index] = 0;
	// +1 because name increments for every func_instance and the 3d sky is an instance
	PlayerCoinStatusTable[player_index] <- array(PURPLECOIN_COUNT + 1)
	
	local PlayerCoinStatusArray = PlayerCoinStatusTable[player_index];
	
	for(local iArrayIndex = 0 ; iArrayIndex < PlayerCoinStatusArray.len() ; iArrayIndex++)
	{
		PlayerCoinStatusArray[iArrayIndex] = true;
		//DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerCoinStatusArray[iArrayIndex]);
	}
	
	PlayerCoinStatusTable[player_index] = PlayerCoinStatusArray;
}

::CoinTouch <- function()
{	
	local player_index = activator.GetEntityIndex();
	
	local PlayerCoinStatusArray = PlayerCoinStatusTable[player_index];

	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
		return;
	
	local strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(PURPLECOIN_TRIGGERPATH.len()).tointeger() - 1;
	
	if (PlayerCoinStatusArray[TriggerID] == false)
		return;
	
	PlayerCoinStatusArray[TriggerID] = false;
	DebugPrint("Set Trigger ID " + (TriggerID + 1) + " to " + PlayerCoinStatusArray[TriggerID]);
	PlayerCoinStatusTable[player_index] = PlayerCoinStatusArray;
	
	PlayerCoinCount[player_index] += 1;
	DebugPrint("Coins Collected for player " + player_index + ": " + PlayerCoinCount[player_index]);
	
	EntFire(PURPLECOIN_COINPATH + (TriggerID + 1), "Disable"); //TEMPORARY - SETTRANSMIT DOESN'T EXIST - DO NOT SHIP
	//local CoinModel = Entities.FindByName(null, PURPLECOIN_COINPATH + (TriggerID + 1));
	//activator.SetTransmit(CoinModel, false);
	
	//update player HUD
	if (PlayerCoinCount[player_index] < 10)
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message 00" + PlayerCoinCount[player_index]));
	else if (PlayerCoinCount[player_index] < 100)
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message 0" + PlayerCoinCount[player_index]));
	else
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message " + PlayerCoinCount[player_index]));
	
	//show particle and play sound
	DispatchParticleEffect("purplecoin_collect", caller.GetOrigin(), Vector(0,90,0));
	activator.EmitSound(SND_PURPLECOIN_COLLECT);
	
	//Collected all coins
	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
	{
		DebugPrint("All Coins Collected for player " + player_index);
		activator.SetOrigin(Vector(3920,6992,-11724));
		activator.SetAngles(0,180,0);
	}
}

::PurpleCoinHUDThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");
	local GameTextEntity = null;
	
	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget");
		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS && PurpleCoinPlayerHUDStatusArray[spectator_target.GetEntityIndex()] == true)
			GameTextEntity = ("outerwall_bonus6_gametext_" + spectator_target.GetEntityIndex());
	}
	else if(PurpleCoinPlayerHUDStatusArray[player_index] == true)
		GameTextEntity = ("outerwall_bonus6_gametext_" + player_index);
		
	if(GameTextEntity != null)
	{
		EntFire(GameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_PURPLECOINHUD);
	}
	else
		client.SetScriptOverlayMaterial(null);
}

::SetPurpleCoinHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	PurpleCoinPlayerHUDStatusArray[player_index] = bSetHUD;
}