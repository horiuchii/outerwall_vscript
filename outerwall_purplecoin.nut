const PURPLECOIN_COUNT = 120;
const PURPLECOIN_TRIGGERPATH = "purplecoin_trigger-InstanceAuto";
const PURPLECOIN_COINPATH = "purplecoin_coin-InstanceAuto";

// +1 because name increments for every func_instance and the 3d sky is an instance
::PlayerCoinStatus <- array(MAX_PLAYERS, array(PURPLECOIN_COUNT + 1, false))
::PlayerCoinCount <- array(MAX_PLAYERS, 0)
::PurpleCoinPlayerHUDStatusArray <- array(MAX_PLAYERS, false)

::ResetPurpleCoinArena <- function()
{
	local player_index = activator.GetEntityIndex();
	
	ResetPlayerPurpleCoinArenaArray(player_index);
	
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
	EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", "message 000");
	
	DebugPrint("Reset Purple Coin Arena for player " + player_index);
}

::ResetPlayerPurpleCoinArenaArray <- function(player_index)
{
	PlayerCoinCount[player_index] = 0;
	
	for(local iArrayIndex = 0; iArrayIndex < PlayerCoinStatus[player_index].len(); iArrayIndex++)
	{
		PlayerCoinStatus[player_index][iArrayIndex] = true;
		DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerCoinStatus[player_index][iArrayIndex]);
	}
}

::CoinTouch <- function()
{	
	local player_index = activator.GetEntityIndex();

	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
		return;
	
	local strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(PURPLECOIN_TRIGGERPATH.len()).tointeger() - 1;
	
	if (PlayerCoinStatus[player_index][TriggerID] == false)
		return;
	
	PlayerCoinStatus[player_index][TriggerID] = false;
	DebugPrint("Set Trigger ID " + (TriggerID + 1) + " to " + PlayerCoinStatus[player_index][TriggerID]);
	
	PlayerCoinCount[player_index] += 1;
	DebugPrint("Coins Collected for player " + player_index + ": " + PlayerCoinStatus[player_index][TriggerID]);
	
	//EntFire(PURPLECOIN_COINPATH + (TriggerID + 1), "Disable"); //TEMPORARY - SETTRANSMIT DOESN'T EXIST - DO NOT SHIP
	//local CoinModel = Entities.FindByName(null, PURPLECOIN_COINPATH + (TriggerID + 1));
	//activator.SetTransmit(CoinModel, false);
	
	//update player HUD
	if (PlayerCoinCount[player_index] < 10)
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message 00" + PlayerCoinCount[player_index]));
	else if (PlayerCoinCount[player_index] < 100)
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message 0" + PlayerCoinCount[player_index]));
	else
		EntFire(BONUS_PLAYERHUDTEXT + player_index, "addoutput", ("message " + PlayerCoinCount[player_index]));
	
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

::SetPurpleCoinHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	PurpleCoinPlayerHUDStatusArray[player_index] = bSetHUD;
}