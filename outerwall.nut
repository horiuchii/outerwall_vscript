IncludeScript("outerwall_utils.nut", this);
IncludeScript("outerwall_language.nut", this);

::PlayerZoneList <- array(MAX_PLAYERS, null)
::PlayerSoundtrackList <- array(MAX_PLAYERS, 0)
::PlayerTrackList <- array(MAX_PLAYERS, 2)
::PlayerCheckpointStatus <- array(MAX_PLAYERS, 0)
::PlayerLastHurt <- array(MAX_PLAYERS, null)

::PlayerSettingDisplayTime <- array(MAX_PLAYERS, false)

IncludeScript("outerwall_timer.nut", this);
IncludeScript("outerwall_tips.nut", this);
IncludeScript("outerwall_purplecoin.nut", this);
IncludeScript("outerwall_timetrial.nut", this);

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
	"breakdown", "scorchingback_outside", "scorchingback_lava", "lastbattle_lava", "lastbattle_outside" //14,15,16,17,18,
]

::SoundTestTracks <-
[
	"white", //0
	"pulse", //1
	"moonsong", //2
	"lastcave", //3
	"balcony", //4
	"geothermal", //5
	"hell", //6
	"windfortress", //7
	"meltdown" //8
	//"breakdown", //9
	//"scorchingback", //10
	//"lastbattle" //11
]

::ZoneLocations <-
[
	Vector(3328,-1344,-14044), //oside
	Vector(7024,-4256,12036), //lastcave
	Vector(4616,-2208,12020), //balcony
	Vector(-1392,7904,-13788), //inner wall
	Vector(-704,-10368,13284), //hell
	Vector(-5408,7616,13412), //wind fortress
	Vector(3328,-1344,-14044), //Vector(5072,6944,-13436) //sand pit DO NOT SHIP
	Vector(3328,-1344,-14044) //final cave
]

::ZoneAngles <-
[
	QAngle(0,180,0), //oside
	QAngle(0,90,0), //lastcave
	QAngle(0,90,0), //balcony
	QAngle(0,270,0), //inner wall
	QAngle(0,90,0), //hell
	QAngle(0,0,0), //wind fortress
	QAngle(0,180,0), //sand pit
	QAngle(0,180,0) //final cave
]

::OuterwallMain <- function()
{
	const MAT_PURPLECOINHUD = "outerwall/purplecoinhud.vmt";
	const MAT_TIMETRIALHUD = "outerwall/timetrialhud.vmt";
	const MAT_TIMETRIALHUD_LAPTWO = "outerwall/timetrialhud_laptwo.vmt";
	const MAT_MEDALTIMEHUD = "outerwall/medaltimehud.vmt";
	const MAT_PURPLECOINANDMEDALTIMEHUD = "outerwall/purplecoinandmedaltimehud.vmt";
	const MAT_TIMETRIALANDMEDALTIMEHUD = "outerwall/purplecoinandmedaltimehud.vmt";

	//Precache soundscript sounds
	
	PrecacheSound("outerwall/snd_quote_walk.mp3");
	
	PrecacheSound("outerwall/snd_quote_hurt.mp3");
	const SND_QUOTE_HURT = "Outerwall.QuoteHurt";
	
	PrecacheSound("outerwall/snd_quote_hurt_lava.mp3");
	const SND_QUOTE_HURT_LAVA = "Outerwall.QuoteHurtLava";
	
	PrecacheSound("outerwall/checkpoint.mp3");
	const SND_CHECKPOINT = "Outerwall.Checkpoint";
	
	PrecacheSound("outerwall/snd_purplecometcoin_collect.mp3");
	const SND_PURPLECOIN_COLLECT = "Outerwall.PurpleCometCoinCollect";
	
	PrecacheSound("outerwall/wartimer.mp3");
	const SND_WARTIMER = "Outerwall.WarTimer";
	
	PrecacheSound("outerwall/wartimerup.mp3");
	const SND_WARTIMER_UP = "Outerwall.WarTimerUp";
	
	PrecacheSound("ui/mm_medal_none.wav");
	const SND_MEDAL_NONE = "Outerwall.MedalNone";
	
	PrecacheSound("ui/mm_medal_bronze.wav");
	const SND_MEDAL_BRONZE = "Outerwall.MedalBronze";
	
	PrecacheSound("ui/mm_medal_silver.wav");
	const SND_MEDAL_SILVER = "Outerwall.MedalSilver";
	
	PrecacheSound("ui/mm_medal_gold.wav");
	const SND_MEDAL_GOLD = "Outerwall.MedalGold";
	
	//PrecacheSound("ui/itemcrate_smash_ultrarare_short.wav");
	const SND_MEDAL_IRIDESCENT = "Outerwall.MedalIridescent";
	
	if (!IsHolidayActive(kHoliday_Soldier))
		EntFire("soldier_statue", "kill");
	
	CreateMedalTimeText();
	CreateBonus6GameText();
	CreateBonus7GameText();
	
	DebugPrint("OUTERWALL INIT ENDED");
}

::OuterwallServerThink <- function()
{
	//CheckForCheating();
	
	return 1.0;
}

::OuterwallClientThink <- function()
{
	PlaySpectatorTrackThink(self);
	
	PlayerHUDThink(self);
	
	PlayerTimeTrialThink(self);
	
	return 0.1;
}

::GameEventPlayerConnect <- function(eventdata)
{
	local player_index = eventdata.index + 1;
	ResetPlayerGlobalArrays(player_index);
}

::ResetPlayerGlobalArrays <- function(player_index)
{
	//reset all global arrays to default
	PlayerZoneList[player_index] = null;
	PlayerSoundtrackList[player_index] = 0;
	PlayerTrackList[player_index] = 2;
	PlayerCheckpointStatus[player_index] = 0;
	PurpleCoinPlayerHUDStatusArray[player_index] = false;
	PlayerLastHurt[player_index] = null;
	PlayerLanguage[player_index] = 0;
	//reset arena array
	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
	//reset medal times
	ResetMedalTimes(player_index);
	
	DebugPrint("Reset global arrays for player " + player_index);
}

::GameEventPlayerSpawn <- function(eventdata)
{
	local client = GetPlayerFromUserID(eventdata.userid);
	
	if(!client || !client.IsPlayer() || client.GetTeam() == (TEAM_UNASSIGNED || TEAM_SPECTATOR))
		return;
	
	local player_index = client.GetEntityIndex();
	
	ResetPlayerPurpleCoinArenaArray(player_index);
	
	if(PlayerZoneList[player_index] == null) //player's first spawn
	{
		PrecachePlayerSounds(client);
		
		GetPlayerLanguage(client);
		
		AddThinkToEnt(client, "OuterwallClientThink");
		DebugPrint("Player " + player_index + " had their first spawn");
		return;
	}
	
	TeleportPlayerToZone(PlayerZoneList[player_index], client, null, false, false);
	
	DebugPrint("Player " + player_index + " was respawned at " + PlayerZoneList[player_index]);
}

::PrecachePlayerSounds <- function(client)
{
	//precache soundscripts
	client.PrecacheSoundScript(SND_QUOTE_HURT);
	client.PrecacheSoundScript(SND_QUOTE_HURT_LAVA);
	client.PrecacheSoundScript(SND_CHECKPOINT);
	client.PrecacheSoundScript(SND_PURPLECOIN_COLLECT);
	client.PrecacheSoundScript(SND_WARTIMER);
	client.PrecacheSoundScript(SND_WARTIMER_UP);
	client.PrecacheSoundScript(SND_MEDAL_NONE);
	client.PrecacheSoundScript(SND_MEDAL_BRONZE);
	client.PrecacheSoundScript(SND_MEDAL_SILVER);
	client.PrecacheSoundScript(SND_MEDAL_GOLD);
	client.PrecacheSoundScript(SND_MEDAL_IRIDESCENT);
	//precache soundscapes
	client.PrecacheScriptSound("ambient/windwinter.wav");
	client.PrecacheScriptSound("outerwall/wind/wind_hit1.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_hit2.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_hit3.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_med1.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_med2.mp3");
	client.PrecacheScriptSound("ambient/windwinterinside.wav");
	client.PrecacheScriptSound("ambient/underground.wav");
	client.PrecacheScriptSound("outerwall/wind/wind_inside1.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_inside2.mp3");
	client.PrecacheScriptSound("outerwall/wind/wind_inside3.mp3");
	client.PrecacheScriptSound("ambient/water/distant_drip1.wav");
	client.PrecacheScriptSound("ambient/water/distant_drip2.wav");
	client.PrecacheScriptSound("ambient/water/distant_drip3.wav");
	client.PrecacheScriptSound("ambient/water/distant_drip4.wav");
	client.PrecacheScriptSound("ambient/volcano_rumble.wav");
	client.PrecacheScriptSound("ambient/indoors.wav");
	client.PrecacheScriptSound("ambient/lighthum.wav");
	client.PrecacheScriptSound("ambient/drips1.wav");
	
	client.PrecacheScriptSound("outerwall/music/ladder.mp3");
	
	foreach(soundtrack in Soundtracks)
	{
		foreach(song in SoundTestTracks)
		{
			client.PrecacheScriptSound("outerwall/music/ost_" + soundtrack + "/" + song + ".wav");
		}	
	}
}

::GetPlayerLanguage <- function(client)
{
	local player_index = client.GetEntityIndex();
	local language = Convars.GetClientConvarValue("cl_language", player_index)
	local player_language = Languages.find(language);
	
	if(player_language == null)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Warning: A translation for the " + language + " language does not exist for Outer Wall, defaulting to English!")
		PlayerLanguage[player_index] = 0;
	}
	else
		PlayerLanguage[player_index] = player_language;
}

::TogglePlayerSetting <- function()
{
	local player_index = activator.GetEntityIndex();
	
	local setting_toggle = "\x07" + "FF0000";
	
	if(PlayerSettingDisplayTime[player_index])
	{
		PlayerSettingDisplayTime[player_index] = false;
		setting_toggle += TranslateString(OUTERWALL_SETTING_OFF, player_index);
	}
	else
	{
		PlayerSettingDisplayTime[player_index] = true;
		setting_toggle += TranslateString(OUTERWALL_SETTING_ON, player_index);
	}
	
	EmitSoundOnClient(SND_CHECKPOINT, activator);
	ClientPrint(activator, HUD_PRINTTALK, "\x01" + TranslateString(OUTERWALL_SETTING_FINALTIME, player_index) + setting_toggle);
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
	
	if(iTrack != -1)
	{
		DoEntFire("trigger_soundscape_" + Tracks[iTrack] + "_" + Soundtracks[PlayerSoundtrackList[player_index]], "StartTouch", "", 0.0, client, client);
		DebugPrint("Player " + player_index + " is now listening to: " + Soundtracks[PlayerSoundtrackList[player_index]] + " " + Tracks[iTrack]);
	}
	else
		DoEntFire("trigger_soundscape_empty", "StartTouch", "", 0.0, client, client);
}

::PlaySoundTestTrack <- function(iTrack, client)
{
	local player_index = client.GetEntityIndex();
	
	PlayerTrackList[player_index] = -1;
	DoEntFire("soundtest_trigger_soundscape_" + SoundTestTracks[iTrack] + "_" + Soundtracks[PlayerSoundtrackList[player_index]], "StartTouch", "", 0.0, client, client);
}

::PlaySpectatorTrackThink <- function(client)
{
	local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");
	
	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget");
	
		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS)
		{
			if(PlayerTrackList[spectator_target.GetEntityIndex()] != -1)
				DoEntFire("trigger_soundscape_" + Tracks[PlayerTrackList[spectator_target.GetEntityIndex()]] + "_" + Soundtracks[PlayerSoundtrackList[spectator_target.GetEntityIndex()]], "StartTouch", "", 0.0, client, client);
			else
				DoEntFire("trigger_soundscape_empty", "StartTouch", "", 0.0, client, client);
		}
		else //we're likely spectating the credits camera, play our pulse
			DoEntFire("trigger_soundscape_pulse_" + Soundtracks[PlayerSoundtrackList[client.GetEntityIndex()]], "StartTouch", "", 0.0, client, client);
	}
}

::PlayerHUDThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");
	local TimeTrialHUDGameTextEntity = null;
	local PurpleCoinHUDGameTextEntity = null;
	local MedalTimeHUDGameTextEntity = null;
	
	// if we're spectating, get our spec target info
	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget");
		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS)
		{
			local spectator_target_index = spectator_target.GetEntityIndex();
			if(TimeTrialPlayerHUDStatusArray[spectator_target_index] == true)
				TimeTrialHUDGameTextEntity = ("outerwall_bonus7_gametext_" + spectator_target_index);
			if(PurpleCoinPlayerHUDStatusArray[spectator_target_index] == true)
				PurpleCoinHUDGameTextEntity = ("outerwall_bonus6_gametext_" + spectator_target_index);
			if(PlayerMedalTimeHUDStatusArray[spectator_target_index] == true)
				MedalTimeHUDGameTextEntity = (TIMER_PLAYERHUDTEXT + player_index);
		}
	}
	// we aren't spectating, get our own info
	else
	{
		if(TimeTrialPlayerHUDStatusArray[player_index] == true)
			TimeTrialHUDGameTextEntity = ("outerwall_bonus7_gametext_" + player_index);
		if(PurpleCoinPlayerHUDStatusArray[player_index] == true)
			PurpleCoinHUDGameTextEntity = ("outerwall_bonus6_gametext_" + player_index);
		if(PlayerMedalTimeHUDStatusArray[player_index] == true)
			MedalTimeHUDGameTextEntity = (TIMER_PLAYERHUDTEXT + player_index);
	}
	
	// alright, we got the info, lets display to us
	if(TimeTrialHUDGameTextEntity != null && MedalTimeHUDGameTextEntity != null) //bonus7 + medal
	{
		EntFire(TimeTrialHUDGameTextEntity, "Display", "", 0.0, client);
		EntFire(MedalTimeHUDGameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_TIMETRIALANDMEDALTIMEHUD);
		return;
	}
	else if(PurpleCoinHUDGameTextEntity != null && MedalTimeHUDGameTextEntity != null) //bonus6 + medal
	{
		EntFire(PurpleCoinHUDGameTextEntity, "Display", "", 0.0, client);
		EntFire(MedalTimeHUDGameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_PURPLECOINANDMEDALTIMEHUD);
		return;
	}
	else if(TimeTrialHUDGameTextEntity != null) //bonus7
	{
		EntFire(TimeTrialHUDGameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_TIMETRIALHUD);
		return;
	}
	else if(PurpleCoinHUDGameTextEntity != null) //bonus6
	{
		EntFire(PurpleCoinHUDGameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_PURPLECOINHUD);
		return;
	}
	else if(MedalTimeHUDGameTextEntity != null) //medal
	{
		EntFire(MedalTimeHUDGameTextEntity, "Display", "", 0.0, client);
		client.SetScriptOverlayMaterial(MAT_MEDALTIMEHUD);
		return;
	}
	
	client.SetScriptOverlayMaterial(null);
}

::CheckForCheating <- function()
{
	for (local i = 1; i <= MAX_PLAYERS; i++)
	{
		local player = PlayerInstanceFromIndex(i)
		if(player)
		{
			local player_index = player.GetEntityIndex();
			if(player.IsNoclipping())
			{
				PlayerCheatedCurrentRun[player_index] = true;
			}
		}
	}
}

::SetPlayerZone <- function(iZone)
{
	local player_index = activator.GetEntityIndex();
	
	PlayerZoneList[player_index] = iZone;
	
	UpdateMedalTimeText(player_index);
	
	DebugPrint("Player " + player_index + "'s zone index is: " + iZone);
}

::SetPlayerCheckpoint <- function(iNewCheckpoint)
{
	local player_index = activator.GetEntityIndex();
	local current_checkpoint = PlayerCheckpointStatus[player_index];
	
	if(iNewCheckpoint != current_checkpoint + 1 && iNewCheckpoint != 0 || activator.IsNoclipping())
		return;
	
	PlayerCheckpointStatus[player_index] = iNewCheckpoint;
	
	if(iNewCheckpoint > 0)
		EmitSoundOnClient(SND_CHECKPOINT, activator);
	
	DebugPrint("Player " + player_index + "'s new checkpoint is: " + iNewCheckpoint);
}

::TeleportPlayerToZone <- function(iZone = null, client = null, iCheckpointFilter = null, bAllowOnlyInFilter = false, bPlayHurtSound = true)
{
	//TODO: Add a case for the checkpoints in bonus 4 and 5
	if(!client || client.IsNoclipping())
		return;
	
	local player_index = client.GetEntityIndex();
	
	if(iZone == null) //Player is Out Of Bounds
		iZone = PlayerZoneList[player_index];
	
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

	if(activator.IsNoclipping() || PlayerCheckpointStatus[player_index] != iRequiredCheckpoint || PlayerZoneList[player_index] != iZoneGoal)
		return;
	
	if(PlayerCheatedCurrentRun[player_index])
	{
		ClientPrint(activator, HUD_PRINTTALK, "\x07" + "FF0000" + TranslateString(OUTERWALL_TIMER_CHEATED, player_index));
		EmitSoundOnClient(SND_MEDAL_NONE, activator);
		return;
	}

	if(iZoneGoal == 0)
		EntFire("logic_relay_goal", "Trigger");
		
	else
		EntFire("logic_relay_goal_bonus" + iZoneGoal, "Trigger");
		
	CheckPlayerMedal(iZoneGoal, activator);
}

::HurtTouch <- function(iSpikeType, client)
{
	local player_index = client.GetEntityIndex();
	
	if(client.IsNoclipping() || PlayerLastHurt[player_index] != null && PlayerLastHurt[player_index] + 0.5 > Time())
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
		case 3: //Instant Kill
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 9999999.0, DMG_BURN);
		default: //Error
			printl("ERROR ERROR! ::HurtTouch() called with invalid iSpikeType!!!!");
			break;
	}
	
	PlayerLastHurt[player_index] = Time();
}