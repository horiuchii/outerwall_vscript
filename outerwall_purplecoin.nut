const PURPLECOIN_COUNT = 120;
const PURPLECOIN_TRIGGERPATH = "purplecoin_trigger-InstanceAuto";
const PURPLECOIN_COINPATH = "purplecoin_coin-InstanceAuto";

const PURPLECOIN_PLAYERHUDTEXT = "outerwall_bonus6_gametext_";

::PlayerCoinStatusTable <- {}
::PlayerCoinCount <- array(33, 0)
::PurpleCoinPlayerHUDStatusArray <- array(33, false)

::ResetArena <- function()
{
	local player_index = activator.GetEntityIndex();

	PlayerCoinCount[player_index] = 0;
	// +1 because name increments for every func_instance and the 3d sky is an instance
	PlayerCoinStatusTable[player_index] <- array(PURPLECOIN_COUNT + 1)
	
	local PlayerCoinStatusArray = null;
	PlayerCoinStatusArray = PlayerCoinStatusTable[player_index];
	
	local iArrayIndex = 0;
	while(iArrayIndex < PlayerCoinStatusArray.len())
	{
		PlayerCoinStatusArray[iArrayIndex] = true;
		//DebugPrint("Array Index: " + iArrayIndex + " = " + PlayerCoinStatusArray[iArrayIndex]);
		iArrayIndex++;
	}
	
	PlayerCoinStatusTable[player_index] = PlayerCoinStatusArray;
	
	EntFire(PURPLECOIN_COINPATH + "*", "Enable"); //TEMPORARY
	//transmit all coins to player

	//Reset Player HUD Count
	EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", "message 000");
	
	DebugPrint("Reset Arena for player " + player_index);
}

::CoinTouch <- function()
{	
	local player_index = activator.GetEntityIndex();
	
	//FIXME: Array index will not exist and throw an error if the player doesn't touch ::ResetArena() first	
	local PlayerCoinStatusArray = PlayerCoinStatusTable[player_index];

	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
		return;
	
	local strTriggerName = null;
	strTriggerName = NetProps.GetPropString(caller, "m_iName");
	local TriggerID = strTriggerName.slice(PURPLECOIN_TRIGGERPATH.len()).tointeger() - 1;
	
	if (PlayerCoinStatusArray[TriggerID] == false)
		return;
	
	PlayerCoinStatusArray[TriggerID] = false;
	DebugPrint("Set Trigger ID " + (TriggerID + 1) + " to " + PlayerCoinStatusArray[TriggerID]);
	PlayerCoinStatusTable[player_index] = PlayerCoinStatusArray;
	
	PlayerCoinCount[player_index] += 1;
	DebugPrint("Coins Collected for player " + player_index + ": " + PlayerCoinCount[player_index]);
	
	EntFire(PURPLECOIN_COINPATH + (TriggerID + 1), "Disable"); //TEMPORARY
	//transmit the dissapearing of coin
	
	//update player HUD
	if (PlayerCoinCount[player_index] < 10)
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message 00" + PlayerCoinCount[player_index]));
	else if (PlayerCoinCount[player_index] < 100)
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message 0" + PlayerCoinCount[player_index]));
	else
		EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", ("message " + PlayerCoinCount[player_index]));
	
	//show particle and play sound
	DispatchParticleEffect("purplecoin_collect", caller.GetOrigin(), Vector(0,90,0));
	caller.EmitSound(SND_PURPLECOIN_COLLECT);
	//EmitSoundOnClient(SND_PURPLECOIN_COLLECT, activator);
	
	//Collected all coins
	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
	{
		DebugPrint("All Coins Collected for player " + player_index);
		activator.SetOrigin(Vector(3920,6992,-11724));
		activator.SetAngles(0,180,0);
	}
}

::PurpleCoinHUDThink <- function()
{
	local iArrayIndex = 0;
	while(iArrayIndex < PurpleCoinPlayerHUDStatusArray.len())
	{
		if(PurpleCoinPlayerHUDStatusArray[iArrayIndex] == true)
		{
			local GameTextEntity = ("outerwall_bonus6_gametext_" + iArrayIndex);
			EntFire(GameTextEntity, "Display", "", 0.0, PlayerInstanceFromIndex(iArrayIndex));
		}
		iArrayIndex++;
	}
}

::SetPurpleCoinHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	if(bSetHUD)
	{
		PurpleCoinPlayerHUDStatusArray[player_index] = true;
		activator.SetScriptOverlayMaterial(MAT_PURPLECOINHUD);
	}
	else
	{
		PurpleCoinPlayerHUDStatusArray[player_index] = false;
		activator.SetScriptOverlayMaterial(null);
	}
}