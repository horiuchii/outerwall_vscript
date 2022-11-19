IncludeScript("outerwall_utils.nut", this)

::OuterwallMain <- function()
{
	const SND_QUOTE_WALK = "outerwall/snd_quote_walk.mp3";
	const SND_PURPLECOIN_COLLECT = "outerwall/snd_purplecometcoin_collect.mp3";
	const MAT_PURPLECOINHUD = "outerwall/purplecoinhud.vmt"

	PrecacheSound(SND_QUOTE_WALK);
	PrecacheSound(SND_PURPLECOIN_COLLECT);
	
	CheckSoldierHoliday();
	
	EntFire("logic_relay_enablebonus6", "Trigger");
	
	DebugPrint("OUTERWALL INIT ENDED");
}

function CheckSoldierHoliday()
{
	const TF_SOLDIER_HOLIDAY = 12;

	if (!IsHolidayActive(TF_SOLDIER_HOLIDAY))
		EntFire("soldier_statue", "kill");
}

::PlayerZoneList <- array(33, 0)

::GameEventPlayerSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	
	if (!client.IsPlayer() || client.GetTeam() <= 1) //spec & unassigned
		return;
	
	local player_index = client.GetEntityIndex();
	
	switch(PlayerZoneList[player_index])
	{		
		case 1: //last cave
			client.SetOrigin(Vector(7024,-3504,10740));
			client.SetAngles(0,90,0);
			break;
		
		case 2: //balcony
			client.SetOrigin(Vector(4616,-2208,12020));
			client.SetAngles(0,90,0);
			break;
		
		case 3: //inner wall
			client.SetOrigin(Vector(-1392,7904,-13788));
			client.SetAngles(0,270,0);
			break;
		
		case 4: //hell
			client.SetOrigin(Vector(-704,-10368,13284));
			client.SetAngles(0,90,0);
			break;
		
		case 5: //wind fortress
			client.SetOrigin(Vector(-1824,7616,13412));
			client.SetAngles(0,0,0);
			break;
			
		case 6: //purple coin
			client.SetOrigin(Vector(5072,6944,-13436));
			client.SetAngles(0,180,0);
			break;
		
		default: //oside
			client.SetOrigin(Vector(3328,-1344,-14044));
			client.SetAngles(0,180,0);
			break;
	}
	
	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

::SetPlayerZone <- function(zone)
{
	if (!activator.IsPlayer())
		return;

	local player_index = activator.GetEntityIndex();
	
	PlayerZoneList[player_index] = zone;
	DebugPrint("Player " + player_index + "'s zone index is: " + zone);
}





const PURPLECOIN_COUNT = 120;
const PURPLECOIN_TRIGGERPATH = "purplecoin_trigger-InstanceAuto";
const PURPLECOIN_COINPATH = "purplecoin_coin-InstanceAuto";

const PURPLECOIN_PLAYERHUDTEXT = "outerwall_bonus6_gametext_";

::PlayerCoinStatusTable <- {}
::PlayerCoinCount <- array(33)

::ResetArena <- function()
{
	local player_index = activator.GetEntityIndex();

	PlayerCoinCount[player_index] = 0;
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
	
	//Set Player Targetname for map logic to send the correct game_text
	NetProps.SetPropString(activator, "m_iName", "outerwall_bonus6_" + player_index);

	//Reset Player HUD Count
	EntFire(PURPLECOIN_PLAYERHUDTEXT + player_index, "addoutput", "message 000");
	
	DebugPrint("Reset Arena for player " + player_index);
}

::CoinTouch <- function()
{	
	local player_index = activator.GetEntityIndex();
	
	//FIXME: Array index will not exist and throw an error if the player doesn't touch ::ResetArena() first
	local PlayerCoinStatusArray = null;
	PlayerCoinStatusArray = PlayerCoinStatusTable[player_index];

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
	
	DispatchParticleEffect("purplecoin_collect", caller.GetOrigin(), Vector(0,90,0));
	caller.EmitSound(SND_PURPLECOIN_COLLECT);
	//DOESN'T WORK: RE-ADD LATER
	//EmitSoundOnClient(SND_PURPLECOIN_COLLECT, activator);
	
	//Collected all coins
	if (PlayerCoinCount[player_index] >= PURPLECOIN_COUNT)
	{
		DebugPrint("All Coins Collected for player " + player_index);
		activator.SetOrigin(Vector(3920,6992,-11724));
		activator.SetAngles(0,180,0);
	}
}

::SetPurpleCoinHUDOverlay <- function(bSetHUD)
{
	if(bSetHUD)
		activator.SetScriptOverlayMaterial(MAT_PURPLECOINHUD);
	else
		activator.SetScriptOverlayMaterial(null);
	
}