IncludeScript("outerwall_utils.nut", this);
IncludeScript("outerwall_purplecoin.nut", this);

::PlayerZoneList <- array(MAX_PLAYERS, null)
::PlayerSoundtrackList <- array(MAX_PLAYERS, 0)
::PlayerTrackList <- array(MAX_PLAYERS, 2)
::PlayerCheckpointStatus <- array(MAX_PLAYERS, 0)
::PlayerLastHurt <- array(MAX_PLAYERS, null)

::Soundtracks <-
[
	"remastered",
	"ridiculon",
	"organya"
]

::Tracks <-
[
	"white", //0
	"pulse", //1
	"moonsong_inside","moonsong_outside", //2,3
	"lastcave", //4
	"balcony","balcony_lava", //5,6
	"geothermal", //7
	"hell_inside","hell_outside", //8,9
	"windfortress_inside","windfortress_outside","windfortress_lava", //10,11,12
	"meltdown" //13
]

::ZoneLocations <-
[
	Vector(3328,-1344,-14044), //oside
	Vector(7024,-3504,10740), //lastcave
	Vector(4616,-2208,12020), //balcony
	Vector(-1392,7904,-13788), //inner wall
	Vector(-704,-10368,13284), //hell
	Vector(-1824,7616,13412), //wind fortress
	Vector(5072,6944,-13436) //sand pit
]

::ZoneAngles <-
[
	QAngle(0,180,0), //oside
	QAngle(0,90,0), //lastcave
	QAngle(0,90,0), //balcony
	QAngle(0,270,0), //inner wall
	QAngle(0,90,0), //hell
	QAngle(0,0,0), //wind fortress
	QAngle(0,180,0) //sand pit
]

::OuterwallMain <- function()
{
	const MAT_PURPLECOINHUD = "outerwall/purplecoinhud.vmt";

	PrecacheSound("outerwall/snd_quote_walk.mp3");
	
	PrecacheSound("outerwall/snd_quote_hurt.mp3");
	const SND_QUOTE_HURT = "Outerwall.QuoteHurt";
	
	PrecacheSound("outerwall/snd_quote_hurt_lava.mp3");
	const SND_QUOTE_HURT_LAVA = "Outerwall.QuoteHurtLava";
	
	PrecacheSound("outerwall/checkpoint.mp3");
	const SND_CHECKPOINT = "Outerwall.Checkpoint";
	
	PrecacheSound("outerwall/snd_purplecometcoin_collect.mp3");
	const SND_PURPLECOIN_COLLECT = "Outerwall.PurpleCometCoinCollect";
	
	if (!IsHolidayActive(Constants.EHoliday.kHoliday_Soldier))
		EntFire("soldier_statue", "kill");
	
	DebugPrint("OUTERWALL INIT ENDED");
}

function OuterwallThink()
{
	PurpleCoinHUDThink();
	
	PlaySpectatorTrackThink();
}

::GameEventPlayerInitialSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	local player_index = client.GetEntityIndex();
	//reset all global arrays to default
	PlayerZoneList[player_index] = null;
	PlayerSoundtrackList[player_index] = 0;
	PlayerTrackList[player_index] = 2;
	PlayerCheckpointStatus[player_index] = 0;
	PurpleCoinPlayerHUDStatusArray[player_index] = false;
	PlayerLastHurt[player_index] = null;
	//precache soundscripts
	client.PrecacheSoundScript(SND_QUOTE_HURT);
	client.PrecacheSoundScript(SND_QUOTE_HURT_LAVA);
	client.PrecacheSoundScript(SND_CHECKPOINT);
	client.PrecacheSoundScript(SND_PURPLECOIN_COLLECT);
}

::GameEventPlayerSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	
	if(!client.IsPlayer() || client.GetTeam() == (TEAM_UNASSIGNED || TEAM_SPECTATOR))
		return;
	
	local player_index = client.GetEntityIndex();
	
	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false, false);
	
	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

::SetPlayerSoundtrack <- function(iTrack)
{
	local player_index = activator.GetEntityIndex();
	
	if(PlayerSoundtrackList[player_index] == iTrack)
		return;
	
	PlayerSoundtrackList[player_index] = iTrack;
	PlayTrack(PlayerTrackList[player_index], activator);
	activator.EmitSound(SND_CHECKPOINT);
	
	DebugPrint("Player " + player_index + "'s soundtrack is: " + Soundtracks[PlayerSoundtrackList[player_index]]);
}

::PlayTrack <- function(iTrack, client)
{
	local player_index = client.GetEntityIndex();
	
	PlayerTrackList[player_index] = iTrack;
		
	DoEntFire("trigger_soundscape_" + Tracks[iTrack] + "_" + Soundtracks[PlayerSoundtrackList[player_index]], "StartTouch", "", 0.0, client, client);
	DebugPrint("Player " + player_index + " is now listening to: " + Soundtracks[PlayerSoundtrackList[player_index]] + " " + Tracks[iTrack]);
}

::PlaySpectatorTrackThink <- function()
{
	local player_index = 0;
	while(player_index < MAX_PLAYERS)
	{
		local client = PlayerInstanceFromIndex(player_index);
		
		if(client != null)
		{
			local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");
			
			if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
			{
				local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget").GetEntityIndex();
				
				if(spectator_target <= MAX_PLAYERS)
					DoEntFire("trigger_soundscape_" + Tracks[PlayerTrackList[spectator_target]] + "_" + Soundtracks[PlayerSoundtrackList[spectator_target]], "StartTouch", "", 0.0, client, client);
			}
		}
		player_index++;
	}
}

::SetPlayerZone <- function(iZone)
{
	local player_index = activator.GetEntityIndex();
	
	PlayerZoneList[player_index] = iZone;
	DebugPrint("Player " + player_index + "'s zone index is: " + iZone);
}

::SetPlayerCheckpoint <- function(iNewCheckpoint)
{
	local player_index = activator.GetEntityIndex();
	local current_checkpoint = PlayerCheckpointStatus[player_index];
	
	if(iNewCheckpoint != current_checkpoint + 1 && iNewCheckpoint != 0)
		return;
	
	PlayerCheckpointStatus[player_index] = iNewCheckpoint;
	
	if(iNewCheckpoint > 0)
		EmitSoundOnClient(SND_CHECKPOINT, activator);
	
	DebugPrint("Player " + player_index + "'s new checkpoint is: " + iNewCheckpoint);
}

::TeleportPlayerToZone <- function(iZone = null, client = null, iCheckpointFilter = null, bAllowOnlyInFilter = false, bPlayHurtSound = true)
{
	//TODO: Add a case for the checkpoints in bonus 4 and 5
	if(client == null)
		return;

	local player_index = client.GetEntityIndex();

	if(PlayerZoneList[player_index] == null) //player's first spawn
		return;
	
	if(iZone == null) //Player is Out Of Bounds
	{
		iZone = PlayerZoneList[player_index];
	}
	
	if(iCheckpointFilter != null)
	{
		if(bAllowOnlyInFilter && PlayerCheckpointStatus[player_index] != iCheckpointFilter)
		{
			DebugPrint("Player " + player_index + " does not match teleport filter: Only allowed those in checkpoint " + iCheckpointFilter);
			return;
		}
		else if(!bAllowOnlyInFilter && PlayerCheckpointStatus[player_index] == iCheckpointFilter)
		{
			DebugPrint("Player " + player_index + " does not match teleport filter: Only allowed those not in checkpoint " + iCheckpointFilter);
			return;
		}
	}
	
	DebugPrint("Player " + player_index + " teleported via ::TeleportPlayerToZone()");
	
	if(bPlayHurtSound)
		client.EmitSound(SND_QUOTE_HURT);
	
	client.SetOrigin(ZoneLocations[PlayerZoneList[player_index]]);
	client.SnapEyeAngles(ZoneAngles[PlayerZoneList[player_index]]);
}

::DoGoal <- function(iZoneGoal, iRequiredCheckpoint)
{
	local player_index = activator.GetEntityIndex();

	if(PlayerCheckpointStatus[player_index] == iRequiredCheckpoint)
	{
		if(iZoneGoal == 0)
			EntFire("logic_relay_goal", "Trigger");
		
		else
			EntFire("logic_relay_goal_bonus" + iZoneGoal, "Trigger");
	}
}

::HurtTouch <- function(iSpikeType, client)
{
	local player_index = client.GetEntityIndex();
	
	if(PlayerLastHurt[player_index] != null && PlayerLastHurt[player_index] + 0.5 > Time())
		return;

	switch(iSpikeType)
	{
		case 0: //Normal Spike
			NetProps.SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,350));
		case 1: //No Launch Spike
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 50.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT);
			break;
		case 2: //Lava
			NetProps.SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,650));
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 25.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT_LAVA);
			break;
		default: //Error
			printl("ERROR ERROR! ::HurtTouch() called with invalid iSpikeType!!!!");
			break;
	}
	
	PlayerLastHurt[player_index] = Time();
}