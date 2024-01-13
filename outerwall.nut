IncludeScript("outerwall_const.nut", this);
IncludeScript("outerwall_utils.nut", this);

if(FileToString(OUTERWALL_SERVERPATH + OUTERWALL_SERVER_LANGUAGEOVERRIDE_ENABLE) == "true")
	IncludeScript(OUTERWALL_SERVERPATH + OUTERWALL_SERVER_LANGUAGEOVERRIDE, this);
else
	IncludeScript("outerwall_language.nut", this);

IncludeScript("outerwall_playerdata.nut", this);

::PlayerZoneList <- array(MAX_PLAYERS, null)
::PlayerTrackList <- array(MAX_PLAYERS, 2)
::PlayerCheckpointStatus <- array(MAX_PLAYERS, 0)
::PlayerLastHurt <- array(MAX_PLAYERS, 0)
::PlayerLastPosition <- array(MAX_PLAYERS, Vector(0,0,0))
::PlayerLastSpectateTrack <- array(MAX_PLAYERS, -1)
::PlayerLastSpectateSoundtrack <- array(MAX_PLAYERS, -1)

::PreviousButtons <- array(MAX_PLAYERS, 0)

::bRoundOver <- false

IncludeScript("outerwall_achievements.nut", this);
IncludeScript("outerwall_timer.nut", this);
IncludeScript("outerwall_settings.nut", this);
IncludeScript("outerwall_purplecoin.nut", this);
IncludeScript("outerwall_timetrial.nut", this);
IncludeScript("outerwall_entity_io.nut", this);
IncludeScript("outerwall_gameevents.nut", this);

::OuterwallMain <- function()
{
	DebugPrint("OUTERWALL INIT STARTED");

	const MDL_SCOUT_TRAIL = "models/outerwall/player/scout.mdl";
	//const MDL_SCOUT_TRAIL_WHIMSICALSTAR = "models/outerwall/player/scout_whimsicalstar.mdl";

	//Precache soundscript sounds
	PrecacheSound("outerwall/snd_quote_walk.mp3");

	PrecacheSound("outerwall/snd_quote_jump.mp3");
	const SND_QUOTE_JUMP = "Outerwall.Jump";

	PrecacheSound("outerwall/snd_quote_thud.mp3");
	const SND_QUOTE_THUD = "Outerwall.Thud";

	PrecacheSound("outerwall/snd_booster.mp3")
	const SND_BOOSTER = "Outerwall.Booster";

	PrecacheSound("outerwall/snd_quote_hurt.mp3");
	const SND_QUOTE_HURT = "Outerwall.QuoteHurt";

	PrecacheSound("outerwall/snd_quote_hurt_lava.mp3");
	const SND_QUOTE_HURT_LAVA = "Outerwall.QuoteHurtLava";

	PrecacheSound("outerwall/checkpoint.mp3");
	const SND_CHECKPOINT = "Outerwall.Checkpoint";

	PrecacheSound("outerwall/snd_cion_collect.mp3");
	const SND_PURPLECOIN_COLLECT = "Outerwall.PurpleCometCoinCollect";

	PrecacheSound("outerwall/radar_ping.mp3");
	const SND_PURPLECOIN_RADAR = "Outerwall.PurpleCoinRadar";

	PrecacheSound("outerwall/radar_ready.mp3");
	const SND_PURPLECOIN_RADAR_READY = "Outerwall.PurpleCoinRadarReady";

	PrecacheSound("outerwall/snd_menu_select.mp3");
	const SND_MENU_SELECT = "Outerwall.MenuSelect";

	PrecacheSound("outerwall/snd_menu_prompt.mp3");
	const SND_MENU_PROMPT = "Outerwall.MenuPrompt";

	PrecacheSound("outerwall/snd_menu_move.mp3");
	const SND_MENU_MOVE = "Outerwall.MenuMove";

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

	PrecacheSound("misc/achievement_earned.wav");
	PrecacheSound("player/pl_impact_airblast1.wav");

	foreach(sound in PyroSoundsPrecache)
		PrecacheSound(sound);

	if (!IsHolidayActive(kHoliday_Soldier))
		EntFire("soldier_statue", "kill");

	SetLeaderboardMedalTimes();
	PopulateWorldRecordTimesFromFile();
	PopulateLeaderboard();
	PrecacheCoinPositions();

	Convars.SetValue("mp_forceautoteam", 1);
	Convars.SetValue("mp_teams_unbalance_limit", 0);

	DebugPrint("OUTERWALL INIT ENDED");
}

::FADE_OUT <- 0.05
::HOLD_TIME <- 0.3

::CreateGameTextForPlayer <- function(player_index)
{
	DestroyGameTextForPlayer(player_index);

	local gametext_menu = SpawnEntityFromTable("game_text",
	{
		targetname = TIMER_PLAYERHUDTEXT + player_index,
		channel = 5,
		color = "240 255 0 155",
		fadein = 0,
		fadeout = FADE_OUT,
		holdtime = HOLD_TIME,
		x = 0.025,
		y = 0.375
	})

	local gametext_bonus = SpawnEntityFromTable("game_text",
	{
		targetname = BONUS_PLAYERHUDTEXT + player_index,
		channel = 4,
		color = "115 95 255 155",
		fadein = 0,
		fadeout = FADE_OUT,
		holdtime = HOLD_TIME,
		x = 0.44,
		y = 0.720
	})

	local gametext_encore = SpawnEntityFromTable("game_text",
	{
		targetname = ENCORE_PLAYERHUDTEXT + player_index,
		channel = 3,
		color = "115 95 255 155",
		fadein = 0,
		fadeout = FADE_OUT,
		holdtime = HOLD_TIME,
		x = 0.475,
		y = 0.895
	})

	Entities.DispatchSpawn(gametext_menu);
	Entities.DispatchSpawn(gametext_bonus);
	Entities.DispatchSpawn(gametext_encore);
	SetPropBool(gametext_menu, "m_bForcePurgeFixedupStrings", true);
	SetPropBool(gametext_bonus, "m_bForcePurgeFixedupStrings", true);
	SetPropBool(gametext_encore, "m_bForcePurgeFixedupStrings", true);
}

::DestroyGameTextForPlayer <- function(player_index)
{
	local entity = null;
	if(entity = Entities.FindByName(null, TIMER_PLAYERHUDTEXT + player_index)) entity.Destroy();
	if(entity = Entities.FindByName(null, BONUS_PLAYERHUDTEXT + player_index)) entity.Destroy();
	if(entity = Entities.FindByName(null, ENCORE_PLAYERHUDTEXT + player_index)) entity.Destroy();
}

::OuterwallServerThink <- function()
{
	return 1000000000.0;
}

::OuterwallClientThink <- function()
{
	CheckForCheating(self);

	PlaySpectatorTrackThink(self);

	PlayerHUDThink(self);

	CheckPurpleCoinAnnotateButton(self);

	//PlayerTimeTrialThink(self);

	PurpleCoinHudThink(self);

	CheckSettingButton(self);

	PlayJumpSound(self);

	UpdatePlayerLastButtons(self);

	PlayerCosmeticThink(self);

	return -1;
}

::ResetPlayerGlobalArrays <- function(player_index)
{
	//reset all global arrays to default
	PlayerZoneList[player_index] = null;
	PlayerTrackList[player_index] = 2;
	PlayerCheckpointStatus[player_index] = 0;
	PlayerLanguage[player_index] = 0;
	PlayerCachedLeaderboardPosition[player_index] = null;
	PlayerSmokeyProgress[player_index] = 0;
	//reset arena array
	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
	//reset medal times
	ResetPlayerDataArrays(player_index);
	//make sure menus dont persist
	ResetPlayerMenuArrays(player_index);

	DebugPrint("Reset global arrays for player " + player_index);
}

::PrecachePlayerSounds <- function(client)
{
	//precache soundscripts
	client.PrecacheSoundScript(SND_QUOTE_JUMP);
	client.PrecacheSoundScript(SND_BOOSTER);
	client.PrecacheSoundScript(SND_QUOTE_HURT);
	client.PrecacheSoundScript(SND_QUOTE_HURT_LAVA);
	client.PrecacheSoundScript(SND_CHECKPOINT);
	client.PrecacheSoundScript(SND_PURPLECOIN_COLLECT);
	client.PrecacheSoundScript(SND_PURPLECOIN_RADAR);
	client.PrecacheSoundScript(SND_WARTIMER);
	client.PrecacheSoundScript(SND_WARTIMER_UP);
	client.PrecacheSoundScript(SND_MEDAL_NONE);
	client.PrecacheSoundScript(SND_MEDAL_BRONZE);
	client.PrecacheSoundScript(SND_MEDAL_SILVER);
	client.PrecacheSoundScript(SND_MEDAL_GOLD);
	client.PrecacheSoundScript(SND_MEDAL_IRIDESCENT);
	client.PrecacheSoundScript(SND_MENU_SELECT);
	client.PrecacheSoundScript(SND_MENU_PROMPT);
	client.PrecacheSoundScript(SND_MENU_MOVE);
	client.PrecacheSoundScript("Achievement.Earned");
	client.PrecacheSoundScript("Player.DenyWeaponSelection");
	client.PrecacheSoundScript("Halloween.spell_blastjump");
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

	foreach(soundtrack in PrecacheSoundtrackNames)
	{
		foreach(song in PrecacheTrackNames)
		{
			if(soundtrack == "plus" && (song == "white" || song == "kaze"))
				continue;

			if(soundtrack == "remixed" && song == "white")
				continue;

			client.PrecacheScriptSound("outerwall/music/ost_" + soundtrack + "/" + song + ".wav");
		}
	}
}

::GetPlayerLanguage <- function(client)
{
	local player_index = client.GetEntityIndex();
	local language = Convars.GetClientConvarValue("cl_language", player_index);
	local player_language = Languages.find(language);

	if(player_language == null)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Warning: A translation for the " + language + " language does not exist for Outer Wall, defaulting to English!")
		PlayerLanguage[player_index] = 0;
	}
	else
		PlayerLanguage[player_index] = player_language;

	if(LanguagesPoorWarning.find(language) != null)
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "Warning: The " + language + " translation for Outer Wall as of right now is either incomplete or translated poorly.")
	}
}

::IncrementTimePlayed <- function()
{
	foreach(i, time in PlayerSecondsPlayed)
	{
		PlayerSecondsPlayed[i] += 1;
	}
}

::SetPlayerSoundtrack <- function(iTrack, client = null)
{
	if(!client)
		client = activator;

	local player_index = client.GetEntityIndex();

	if(PlayerSoundtrackList[player_index] == iTrack)
		return;

	PlayerSoundtrackList[player_index] = iTrack;
	PlaySoundscape("outerwall." + Tracks[PlayerTrackList[player_index]] + Soundtracks[PlayerSoundtrackList[player_index]], client);

	DebugPrint("Player " + player_index + "'s soundtrack is: " + Soundtracks[PlayerSoundtrackList[player_index]]);
}

::PlayTrack <- function(iTrack, client, bForce = false)
{
	if(bRoundOver)
		return;

	local player_index = client.GetEntityIndex();

	if(iTrack == PlayerTrackList[player_index] && !bForce)
		return;

	PlayerTrackList[player_index] = iTrack;

	PlaySoundscape("outerwall." + (iTrack == -1 ? "XXXX" : Tracks[iTrack] + Soundtracks[PlayerSoundtrackList[player_index]]), client);
}

::PlaySoundTestTrack <- function(iTrack, client)
{
	if(bRoundOver)
		return;

	local player_index = client.GetEntityIndex();

	PlayerTrackList[player_index] = -1;

	PlaySoundscape("soundtest.outerwall." + SoundTestTracks[iTrack] + Soundtracks[PlayerSoundtrackList[player_index]], client);
}

::PlaySpectatorTrackThink <- function(client)
{
	if(bRoundOver)
		return;

	local obsmode = GetPropInt(client, "m_iObserverMode");
	local player_index = client.GetEntityIndex();

	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = GetPropEntity(client, "m_hObserverTarget");

		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS)
		{
			local spectarget_index = spectator_target.GetEntityIndex();

			if(PlayerTrackList[spectarget_index] != -1)
			{
				if(PlayerTrackList[player_index] == PlayerTrackList[spectarget_index])
					return;

				PlayerTrackList[player_index] = PlayerTrackList[spectarget_index];
				PlaySoundscape("outerwall." + Tracks[PlayerTrackList[spectarget_index]] + Soundtracks[PlayerSoundtrackList[spectarget_index]], client);
			}
			else
			{
				if(PlayerTrackList[player_index] == -1)
					return;

				PlayerTrackList[player_index] = -1;
				PlaySoundscape("outerwall.XXXX", client);
			}
		}
		else //we're likely spectating the credits camera, play our pulse
		{
			if(PlayerTrackList[player_index] == 1)
				return;

			PlayerTrackList[player_index] = 1;
			PlaySoundscape("outerwall.Pulse" + Soundtracks[PlayerSoundtrackList[player_index]], client);
		}
	}
}

::PlayerHUDThink <- function(client)
{
	local target_index = client.GetEntityIndex();

	if(PreviousButtons[target_index] & IN_SCORE)
	{
		client.SetScriptOverlayMaterial(null);
		return;
	}

	local obsmode = GetPropInt(client, "m_iObserverMode");
	local TimeTrialHUDGameTextEntity = null;
	local PurpleCoinHUDGameTextEntity = null;
	local MedalTimeHUDGameTextEntity = null;

	// if we're spectating, get our spec target index
	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = GetPropEntity(client, "m_hObserverTarget");
		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS)
		{
			target_index = spectator_target.GetEntityIndex();
		}
	}

	if(!!PlayerEncoreStatus[target_index] == true)
	{
		TimeTrialHUDGameTextEntity = (ENCORE_PLAYERHUDTEXT + target_index);
		PurpleCoinHUDGameTextEntity = (BONUS_PLAYERHUDTEXT + target_index);
	}
	else if(PlayerZoneList[target_index] == eCourses.SandPit)
		PurpleCoinHUDGameTextEntity = (BONUS_PLAYERHUDTEXT + target_index);

	if(PlayerMedalTimeHUDStatusArray[target_index] == true)
		MedalTimeHUDGameTextEntity = (TIMER_PLAYERHUDTEXT + target_index);

	// alright, we got the info, lets display to us
	if(TimeTrialHUDGameTextEntity)
		EntFire(TimeTrialHUDGameTextEntity, "Display", "", -1, client);

	if(MedalTimeHUDGameTextEntity)
		EntFire(MedalTimeHUDGameTextEntity, "Display", "", -1, client);

	if(PurpleCoinHUDGameTextEntity)
		EntFire(PurpleCoinHUDGameTextEntity, "Display", "", -1, client);

	local encore_hud_active = (TimeTrialHUDGameTextEntity || PurpleCoinHUDGameTextEntity)

	// display overlay hud
	if(encore_hud_active) // encore / normal bonus6
	{
		/*
		if(PlayerTimeTrialActive[target_index]) // blinking timer
		{
			if(IsTimeLerping(target_index)) // time going up
			{
				if(PlayerJustEnteredNewLap[target_index])
				{
					client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_TIMELERPING_LAPUP);
					return;
				}
				else
				{
					client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_TIMELERPING);
					return;
				}
			}

			local lap_count = PlayerCurrentLapCount[target_index];
			local current_zone = PlayerZoneList[target_index];

			if(lap_count >= ZoneLaps_Encore[current_zone][OUTERWALL_MEDAL_IRI]) // iri medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_IRI);
				return;
			}
			if(lap_count >= ZoneLaps_Encore[current_zone][OUTERWALL_MEDAL_GOLD]) // gold medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_GOLD);
				return;
			}
			if(lap_count >= ZoneLaps_Encore[current_zone][OUTERWALL_MEDAL_SILVER]) // silver medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_SILVER);
				return;
			}
			if(lap_count >= ZoneLaps_Encore[current_zone][OUTERWALL_MEDAL_BRONZE]) // bronze medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_BRONZE);
				return;
			}
			else // no medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_NOMEDAL);
				return;
			}
		}
		*/
		if(MedalTimeHUDGameTextEntity) // encore medal times / settings menu
		{
			local setting = PlayerCurrentSettingQuery[target_index];

			if(setting == null || setting == eSettingQuerys.Profile)
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_MENU_MEDALTIMES_ENCORE);
				return;
			}
			else
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_MENU_SETTINGS_LONGER_ENCORE);
				return;
			}
		}
		else // regular encore
		{
			client.SetScriptOverlayMaterial(MAT_ENCOREHUD);
			return;
		}
	}
	if(MedalTimeHUDGameTextEntity) // regular medal times / settings menu
	{
		local setting = PlayerCurrentSettingQuery[target_index];

		if(setting == null || setting == eSettingQuerys.Profile)
		{
			client.SetScriptOverlayMaterial(MAT_MENU_MEDALTIMES);
			return;
		}
		else
		{
			client.SetScriptOverlayMaterial(MAT_MENU_SETTINGS_LONGER);
			return;
		}
	}

	client.SetScriptOverlayMaterial(null);
}

::UpdatePlayerLastButtons <- function(client)
{
	local player_index = client.GetEntityIndex();
	local buttons = GetPropInt(client, "m_nButtons");
	PreviousButtons[player_index] = buttons;
}

::DispenseTip <- function(client)
{
	local chance = RandomInt(1, 100);
	local message = "\x07" + "FF0000";

	local player_index = client.GetEntityIndex();

	message += TranslateString(TIP_PREFIX[RandomInt(0, TIP_PREFIX.len() - 1)], player_index) + "\x01" + " ";

	if(chance <= 1) //Crude Text 1%
		message += TranslateString(TIP_CRUDE[RandomInt(0, TIP_CRUDE.len() - 1)], player_index);
	else if(chance <= 11) //ParkourText 10%
		message += TranslateString(TIP_PARKOUR[RandomInt(0, TIP_PARKOUR.len() - 1)], player_index);
	else if(chance <= 21) //CrapText 10%
		message += format(TranslateString(TIP_CRAP[RandomInt(0, TIP_CRAP.len() - 1)], player_index), PlayerTipsRecieved[player_index]);
	else
		message += TranslateString(TIP_REGULAR[RandomInt(0, TIP_REGULAR.len() - 1)], player_index);

	ClientPrint(client, HUD_PRINTTALK, message);
	PlayerTipsRecieved[player_index]++;
	PlayerTouchTipZone(player_index);
}

::CheckForCheating <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(client.IsNoclipping())
	{
		PlayerCheatedCurrentRun[player_index] = true;

		if(!PlayerCheatedCurrentRun[player_index])
		{
			DebugPrint("PLAYER " + player_index + " MARKED FOR CHEATING - NOCLIP");
		}
	}

	/*
	if(PlayerHasCheatImmunity[player_index] == false && (client.GetOrigin() - PlayerLastPosition[player_index]).Length() > 250)
	{
		PlayerCheatedCurrentRun[player_index] = true;
		DebugPrint("PLAYER " + player_index + " MARKED FOR CHEATING - POSITION (" + (client.GetOrigin() - PlayerLastPosition[player_index]).Length() + ")");
	}

	PlayerLastPosition[player_index] = client.GetOrigin();
	*/
}

::PluginMarkPlayerAsCheater <- function(player_index)
{
	if(PlayerCheatedCurrentRun[player_index] == true)
		return;

	PlayerCheatedCurrentRun[player_index] = true;
	ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + "You've executed a command that has invalidated your in-map Outer Wall time. This will NOT effect your parkour.tf time.");
}

::PlayerLastIsJumpingState <- array(MAX_PLAYERS, false)
::PlayerLastGroundedState <- array(MAX_PLAYERS, false)
::PlayerLastAirDashCount <- array(MAX_PLAYERS, 0)

::PlayJumpSound <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(!!!PlayerSettingPlayCharSounds[player_index])
		return;

	local jump_state = GetPropBool(client, "m_Shared.m_bJumping");
	local grounded_state = !!(GetPropInt(client, "m_fFlags") & FL_ONGROUND);
	local airdash_count = GetPropInt(client, "m_Shared.m_iAirDash");

	//If our previous state check is false && new one is true.
	if(PlayerLastIsJumpingState[player_index] == false && jump_state == true)
		client.EmitSound(SND_QUOTE_JUMP);

	else if(PlayerLastGroundedState[player_index] == false && grounded_state == true)
		client.EmitSound(SND_QUOTE_THUD);

	//todo: this plays on wallrun and similar actions, fix me!
	//else if(PlayerLastAirDashCount[player_index] != airdash_count && PlayerLastAirDashCount[player_index] != 1 && !client.IsNoclipping())
	//	client.EmitSound(SND_BOOSTER);

	PlayerLastIsJumpingState[player_index] = jump_state;
	PlayerLastGroundedState[player_index] = grounded_state;
	PlayerLastAirDashCount[player_index] = airdash_count;
}

::PlayerUpdateSkyboxState <- function(player_index)
{
	local SkyCameraLocation = Vector(0, 0, 0);
	local curr_zone = PlayerZoneList[player_index];

	if(curr_zone == eCourses.OuterWall || curr_zone == eCourses.LastCave || curr_zone == eCourses.Balcony)
		SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION;
	else if(curr_zone == eCourses.InnerWall || curr_zone == eCourses.Hell)
		SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION_INNERWALL_HELL;
	else if(curr_zone == eCourses.WindFortress || curr_zone == eCourses.SandPit)
		SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION_WINDFORTRESS_SANDPIT;

	if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[curr_zone][OUTERWALL_MEDAL_GOLD])
		SkyCameraLocation += OUTERWALL_SKYCAMERA_OFFSET_LAPPING * 2;
	else if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[curr_zone][OUTERWALL_MEDAL_BRONZE])
		SkyCameraLocation += OUTERWALL_SKYCAMERA_OFFSET_LAPPING;

	SetPropVector(PlayerInstanceFromIndex(player_index), "m_Local.m_skybox3d.origin", SkyCameraLocation);
}

::PlayerLastCosmeticSpawn <-
[
	::PlayerLastSpawnCosmeticA <- array(MAX_PLAYERS, 0)
	::PlayerLastSpawnCosmeticB <- array(MAX_PLAYERS, 0)
]

::PlayerCosmeticLastMachColor <- array(MAX_PLAYERS, 0)

::PlayerCosmeticThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(!IsPlayerAlive(client))
		return;

	switch(PlayerCosmeticEquipped[player_index])
	{
		case eCosmetics.Booster:
		{
			PlayerDispatchCosmeticParticle(client, 0, 419, 0.05, "outerwall_cosmetic_booster", client.GetOrigin() + Vector(0,0,42), Vector(0,0,0));
			break;
		}
		case eCosmetics.PurpleCoin:
		{
			PlayerDispatchCosmeticParticle(client, 0, 0, 0.25, "outerwall_cosmetic_purplecoin", client.GetOrigin() + Vector(0,0,42), Vector(0,90,0));
			PlayerDispatchCosmeticParticle(client, 1, 419, 0.0, "outerwall_cosmetic_purplecoin_dash_" + (PlayerEncoreStatus[player_index] ? "blue" : "red"), client.GetOrigin(), Vector(0,90,0));
			break;
		}
		case eCosmetics.Victory:
		{
			PlayerDispatchCosmeticParticle(client, 1, 419, 0.1, "outerwall_cosmetic_victory_" + PlayerZoneList[player_index], client.GetOrigin() + Vector(0,0,6), Vector(0,180,0));
			break;
		}
		case eCosmetics.MachTrail:
		{
			if(MachTrailColors[PlayerCosmeticLastMachColor[player_index]][player_index] == "000 000 000")
				PlayerCosmeticLastMachColor[player_index] = (PlayerCosmeticLastMachColor[player_index] + 1) % MachTrailColors.len();

			if(PlayerSpawnCosmeticModelTrail(client, 0, 419, 0.125, MDL_SCOUT_TRAIL, MachTrailColors[PlayerCosmeticLastMachColor[player_index]][player_index]))
			{
				PlayerCosmeticLastMachColor[player_index]++;
				if(PlayerCosmeticLastMachColor[player_index] > MachTrailColors.len() - 1)
					PlayerCosmeticLastMachColor[player_index] = 0;
			}
			break;
		}
		case eCosmetics.RainbowTrail:
		{
			PlayerSpawnCosmeticModelTrail(client, 0, 419, 0.125, MDL_SCOUT_TRAIL, RainbowTrail());
			break;
		}
		// case eCosmetics.WhimsicalStar:
		// {
		// 	PlayerSpawnAttachedCosmeticParticle(client, 0, 0, 1, "outerwall_cosmetic_whimsicalstar_0", client.GetOrigin() + Vector(0,0,42), Vector(0,0,0));
		// 	break;
		// }
	}
}

::PlayerDispatchCosmeticParticle <- function(client, cosmeticindex, speedrequired, delay, particle, position, rotation)
{
	local player_index = client.GetEntityIndex();

	if(PlayerLastCosmeticSpawn[cosmeticindex][player_index] + delay > Time())
		return false;

	//only do speed check if we are not in a movement
	if(client.GetMoveType() == MOVETYPE_WALK)
	{
		if(GetPropFloat(client, "m_flMaxspeed") < speedrequired)
		{
			return false;
		}
	}

	local string_pos = "Vector(" + position.x + "," + position.y + "," + position.z + ")"
	local string_rot = "Vector(" + rotation.x + "," + rotation.y + "," + rotation.z + ")"

	EntFireByHandle(client, "RunScriptCode", "DispatchParticleEffect(\"" + particle + "\", " + string_pos + ", " + string_rot + ");", -1, null, null);
	PlayerLastCosmeticSpawn[cosmeticindex][player_index] = Time();
	return true;
}

//todo: this doesnt work, fix this for v5 / whimsical star
::PlayerSpawnAttachedCosmeticParticle <- function(client, cosmeticindex, speedrequired, delay, particle, position, rotation)
{
	local player_index = client.GetEntityIndex();

	if(PlayerLastCosmeticSpawn[cosmeticindex][player_index] + delay > Time())
		return false;

	//only do speed check if we are not in a movement
	if(client.GetMoveType() == MOVETYPE_WALK)
	{
		if(GetPropFloat(client, "m_flMaxspeed") < speedrequired)
		{
			return false;
		}
	}

	local trail = SpawnEntityFromTable("info_particle_system",
	{
		parentname = "outerwall_player_" + player_index,
		cpoint1 = "outerwall_player_" + player_index,
		effect_name = particle,
		origin = position,
		angles = rotation,
		start_active = true
	})
	Entities.DispatchSpawn(trail);
	EntFireByHandle(trail, "Kill", "", 15, client, null);
	PlayerLastCosmeticSpawn[cosmeticindex][player_index] = Time();
	return true;
}

::PlayerSpawnCosmeticModelTrail <- function(client, cosmeticindex, speedrequired, delay, modelname, color)
{
	local player_index = client.GetEntityIndex();

	if(PlayerLastCosmeticSpawn[cosmeticindex][player_index] + delay > Time())
		return false;

	//only do speed check if we are not in a movement
	if(client.GetMoveType() == MOVETYPE_WALK)
	{
		if(GetPropFloat(client, "m_flMaxspeed") < speedrequired)
		{
			return false;
		}
	}

	local trail = SpawnEntityFromTable("prop_dynamic",
	{
		model = modelname,
		origin = client.GetOrigin(),
		angles = client.GetLocalAngles(),
		solid = 0,
		DisableBoneFollowers = true,
		disableshadows = true,
		disablereceiveshadows = true,
		playbackrate = 0,
		rendermode = 5,
		renderamt = 30,
		rendercolor = color,
		DefaultAnim = client.GetSequenceName(client.GetSequence())
	})
	Entities.DispatchSpawn(trail);

	EntFireByHandle(trail, "Kill", "", 0.75, client, null);
	PlayerLastCosmeticSpawn[cosmeticindex][player_index] = Time();
	return true;
}

::SetPlayerZone <- function(iZone)
{
	local player_index = activator.GetEntityIndex();

	if(iZone == PlayerZoneList[player_index] && iZone != eCourses.OuterWall)
		return;

	PlayerZoneList[player_index] = iZone;
	UpdateMedalTimeText(player_index);

	DebugPrint("Player " + player_index + "'s zone index is: " + iZone);
}

::SetPlayerCheckpoint <- function(iNewCheckpoint)
{
	local player_index = activator.GetEntityIndex();

	if(PlayerEncoreStatus[player_index] == 1 && (iNewCheckpoint == 1 || iNewCheckpoint == 2))
		return;

	local current_checkpoint = PlayerCheckpointStatus[player_index];

	//todo: im lazy..... zzzzzzz
	if(PlayerZoneList[player_index] != eCourses.SandPit)
	{
		if(iNewCheckpoint != current_checkpoint + 1 && (iNewCheckpoint != 0 && iNewCheckpoint != 3) || activator.IsNoclipping())
			return;
	}

	PlayerCheckpointStatus[player_index] = iNewCheckpoint;

	if(iNewCheckpoint == 1 || iNewCheckpoint == 2)
	{
		PlayerSetCheckpointTime(player_index);

		if(PlayerZoneList[player_index] == eCourses.OuterWall)
			DoEntFire("checkpoint_" + iNewCheckpoint, "StartTouch", "", -1, activator, activator);
	}

	DebugPrint("Player " + player_index + "'s new checkpoint is: " + iNewCheckpoint);
}

::TeleportPlayerToZone <- function(iZone = null, client = null, iCheckpointFilter = null, bAllowOnlyInFilter = false, bPlayHurtSound = true, bIgnoreNoclip = false)
{
	//TODO: Add a case for the checkpoints in bonus 4 and 5
	if(!client)
		return;

	local player_index = client.GetEntityIndex();

	if(!bIgnoreNoclip && client.IsNoclipping())
		return;

	if(iZone == null) //Player is Out Of Bounds
		iZone = PlayerZoneList[player_index];

	if(iCheckpointFilter != null)
	{
		if(PlayerEncoreStatus[player_index] == 1)
			return;

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

	local TeleportDest = Entities.FindByName(null, "teleport_regular_" + PlayerZoneList[player_index].tostring());

	if(TeleportDest == null)
		return;

	client.SetOrigin(TeleportDest.GetOrigin());
	client.SnapEyeAngles(QAngle(TeleportDest.GetAngles().x, TeleportDest.GetAngles().y, TeleportDest.GetAngles().z));
	SetPropVector(client, "m_vecAbsVelocity", Vector(0,0,0));
	DoRespawnEffects(player_index);
}

::TeleportPlayerToCheckpoint <- function()
{
	if(activator.IsNoclipping())
		return;

	local player_index = activator.GetEntityIndex();

	PlayerHasCheatImmunity[player_index] = true;
	activator.EmitSound(SND_QUOTE_HURT);

	local TeleportDest = Entities.FindByName(null, "bonus" + PlayerZoneList[player_index].tostring() + "_teleport2");

	if(TeleportDest == null)
		return;

	activator.SetOrigin(TeleportDest.GetOrigin());
	activator.SnapEyeAngles(QAngle(TeleportDest.GetAngles().x, TeleportDest.GetAngles().y, TeleportDest.GetAngles().z));
	SetPropVector(activator, "m_vecAbsVelocity", Vector(0,0,0));
	DoRespawnEffects(player_index);
}

::PlayerRemoveCheatImmunity <- function()
{
	PlayerHasCheatImmunity[activator.GetEntityIndex()] = false;
}

::PlayerTouchTimerStartZone <- function(iZone, bTouch)
{
	local player_index = activator.GetEntityIndex();
	EntFireByHandle(activator, "RunScriptCode", "PlayerUpdateSkyboxState(" + activator.GetEntityIndex() + ");", -1, null, null);

	local Action = bTouch ? "StartTouch" : "EndTouch";

	if(iZone == 0)
		DoEntFire("start_zone", Action, "", -1, activator, activator);
	else
		DoEntFire("bonus" + iZone + "_start", Action, "", -1, activator, activator);

	if(bTouch)
	{
		ResetTimeTrialArena(player_index);
		PlayerActivateTimeTrial(activator, false);
		ResetPlayerAchievementArrays(player_index);
	}
}

::DoGoal <- function(iZoneGoal, client = null)
{
	if(client == null)
		client = activator;

	if(!!!PlayerEncoreStatus[client.GetEntityIndex()])
	{
		if(iZoneGoal == 0)
			DoEntFire("end_zone", "StartTouch", "", -1, client, client);
		else
			DoEntFire("bonus" + iZoneGoal + "_end", "StartTouch", "", -1, client, client);
	}

	//lets run this a little late to let the cheating check do its thing!
	EntFireByHandle(client, "RunScriptCode", "DoGoalPost(" + iZoneGoal + "," + client.GetEntityIndex() + ");", 0.05, null, null);
	EntFireByHandle(client, "RunScriptCode", "PlayerCheckpointStatus[" + client.GetEntityIndex() + "] = 3;", 0.1, null, null);
}

::DoGoalPost <- function(iZoneGoal, player_index)
{
	local client = PlayerInstanceFromIndex(player_index);

	if(client.IsNoclipping() || PlayerZoneList[player_index] != iZoneGoal || PlayerCheckpointStatus[player_index] == 3)
		return;

	if(PlayerEncoreStatus[player_index] == 1 && PlayerTimeTrialActive[player_index] == false)
		return;

	PlayerActivateTimeTrial(client, false);

	if(PlayerHasCheatImmunity[player_index] || PlayerCheatedCurrentRun[player_index] || (iZoneGoal == 0 && PlayerCheckpointStatus[player_index] != 2 && PlayerEncoreStatus[player_index] != 1))
	{
		ClientPrint(client, HUD_PRINTTALK, "\x07" + "FF0000" + TranslateString(TIMER_CHEATED, player_index));
		EmitSoundOnClient(SND_MEDAL_NONE, client);
		return;
	}

	if(iZoneGoal == 0)
		EntFire("logic_relay_goal", "Trigger");
	else
		EntFire("logic_relay_goal_bonus" + iZoneGoal, "Trigger");

	PlayerRunsRan[player_index]++;
	CheckPlayerMedal(iZoneGoal, client);
	CheckAchievementBatch_PostRun(player_index);
}

::PlayerLastLavaHurt <- array(MAX_PLAYERS, 0)

::HurtTouch <- function(iSpikeType, client, bEncoreSpike = false)
{
	local player_index = client.GetEntityIndex();

	if(client.IsNoclipping() || PlayerLastHurt[player_index] + 0.5 > Time())
		return;

	if(PlayerEncoreStatus[player_index] != bEncoreSpike.tointeger() && iSpikeType != 2)
		return;

	switch(iSpikeType)
	{
		case 0: //Normal Spike
		{
			SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,350));
		}
		case 1: //No Launch Spike
		{
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 50.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT);

			if(!PlayerCheatedCurrentRun[player_index])
				PlayerTimesHurt[player_index] += 1;

			break;
		}
		case 2: //Lava
		{
			SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,650));
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 25.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT_LAVA);

			if(!PlayerCheatedCurrentRun[player_index])
				PlayerTimesHurt[player_index] += 1;

			if(PlayerLastLavaHurt[player_index] + 2 < Time() && GetPropInt(client, "m_iHealth") > 25.0)
			{
				PlayVO(player_index, ScoutVO_LavaTouch);
				PlayerLastLavaHurt[player_index] = Time();
			}

			break;
		}
		case 3: //Instant Kill
		{
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 9999999.0, DMG_BURN);
		}
		default: //Error
		{
			printl("ERROR ERROR! ::HurtTouch() called with invalid iSpikeType!!!!");
			break;
		}
	}

	PlayerLastHurt[player_index] = Time();
	PlayerDamagedDuringRun[player_index] = true;
	CheckAchievement_HitAlot(player_index);
}

::BoosterTouch <- function(bEncoreBooster = false)
{
	local player_index = activator.GetEntityIndex();

	if(activator.IsNoclipping() || PlayerEncoreStatus[player_index] != bEncoreBooster.tointeger())
		return;

	local player_velocity = GetPropVector(activator, "m_vecAbsVelocity");

	player_velocity.z = 650;

	SetPropVector(activator, "m_vecAbsVelocity", player_velocity);
	SetPropInt(activator, "m_Shared.m_iAirDash", 0);
	activator.EmitSound("TFPlayer.AirBlastImpact");
	PlayerUseInnerWallBoosterDuringRun[player_index]++;

	if(RandomInt(1, 100) <= 25)
		PlayVO(player_index, ScoutVO_JumpPad);
}

try
{
	IncludeScript("outerwall_hotfix.nut", this);
	printl("[OUTERWALL PRINT] Included hotfix.");
}
catch (exception)
{
	printl("[OUTERWALL PRINT] No hotfix file found. Not running!");
}
