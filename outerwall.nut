IncludeScript("outerwall_utils.nut", this);
IncludeScript("outerwall_purplecoin.nut", this);

::PlayerZoneList <- array(33, 0)
::PlayerSoundtrackList <- array(33, 0)
::PlayerCheckpointStatus <- array(33, 0)

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
	const SND_QUOTE_WALK = "outerwall/snd_quote_walk.mp3";
	const SND_QUOTE_HURT = "outerwall/snd_quote_hurt.mp3";
	const SND_CHECKPOINT = "outerwall/checkpoint.mp3";
	const SND_PURPLECOIN_COLLECT = "outerwall/snd_purplecometcoin_collect.mp3";
	
	const MAT_PURPLECOINHUD = "outerwall/purplecoinhud.vmt";

	PrecacheSound(SND_QUOTE_WALK);
	PrecacheSound(SND_QUOTE_HURT);
	PrecacheSound(SND_CHECKPOINT);
	PrecacheSound(SND_PURPLECOIN_COLLECT);
	
	if (!IsHolidayActive(12)) //soldier holiday
		EntFire("soldier_statue", "kill");
	
	DebugPrint("OUTERWALL INIT ENDED");
}

function OuterwallThink()
{
	PurpleCoinHUDThink();
}

::GameEventPlayerSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	
	if (client == null || client.GetTeam() <= 1) //spec & unassigned
		return;
	
	local player_index = client.GetEntityIndex();
	
	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false);
	
	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

::SetPlayerSoundtrack <- function(iTrack)
{
	local Soundtracks = ["remastered","ridiculon","organya"]
	local player_index = activator.GetEntityIndex();
	
	PlayerSoundtrackList[player_index] = iTrack;
	DebugPrint("Player " + player_index + "'s soundtrack is: " + Soundtracks[PlayerSoundtrackList[player_index]]);
}

::PlayTrack <- function(iTrack)
{
	local Soundtracks = ["remastered","ridiculon","organya"]
	local Tracks = ["white","pulse","moonsong_inside","moonsong_outside","lastcave","balcony","balcony_lava","geothermal","hell_inside","hell_outside","windfortress_inside","windfortress_outside","windfortress_lava","meltdown"]
	local player_index = activator.GetEntityIndex();
	
	DoEntFire("trigger_soundscape_" + Tracks[iTrack] + "_" + Soundtracks[PlayerSoundtrackList[player_index]], "StartTouch", "", 0.0, activator, activator);
	DebugPrint("Player " + player_index + " is now listening to: " + Soundtracks[PlayerSoundtrackList[player_index]] + " " + Tracks[iTrack]);
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

::TeleportPlayerToZone <- function(iZone = null, client = null, iCheckpointFilter = null, bAllowOnlyInFilter = false)
{
	if(client == null)
		return;

	//TODO: Add a case for the checkpoints in bonus 4 and 5
	local player_index = client.GetEntityIndex();
	
	if(iZone == null) //Player is Out Of Bounds
	{
		EmitSoundOnClient(SND_QUOTE_HURT, client);
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

::HurtTouch <- function(iSpikeType)
{
	const DMG_BURN = 8;

	switch(iSpikeType)
	{
		case 0: //Normal Spike
			ApplyAbsVelocityImpulse(Vector(0,0,350));
		case 1: //No Launch Spike
			activator.TakeDamage(100.0, DMG_BURN, null);
			EmitSoundOnClient(Outerwall.SpikeHurt, activator);
			break;
		case 2: //Lava
			activator.TakeDamage(50.0, DMG_BURN, null);
			ApplyAbsVelocityImpulse(Vector(0,0,650));
			EmitSoundOnClient(Outerwall.LavaHurt, activator);
			break;
		default: //Error
			printl("ERROR ERROR! ::HurtTouch() called with invalid iSpikeType!!!!");
			break;
	}
}