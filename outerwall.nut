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

::PreviousButtons <- array(MAX_PLAYERS, 0)

::bRoundOver <- false
::bGlobalCheated <- false

IncludeScript("outerwall_achievements.nut", this);
IncludeScript("outerwall_timer.nut", this);
IncludeScript("outerwall_settings.nut", this);
IncludeScript("outerwall_purplecoin.nut", this);
IncludeScript("outerwall_timetrial.nut", this);
IncludeScript("outerwall_entity_io.nut", this);
IncludeScript("outerwall_gameevents.nut", this);

::Soundtracks <-
[
	".Remastered",
	".Ridiculon",
	".Organya",
	".Plus",
	".Remixed",
	".Keromix"
]

//TODO: ENUM THIS BITCH, FUCK
::Tracks <-
[
	"White", //0
	"Pulse", //1
	"Moonsong.Inside","Moonsong.Outside", //2,3
	"LastCave", //4
	"Balcony","Balcony.Lava", //5,6
	"Geothermal", //7
	"RunningHell.Inside","RunningHell.Outside", //8,9
	"WindFortress.Inside","WindFortress.Outside","WindFortress.Lava", //10,11,12
	"Meltdown" //13
]

::SoundTestTracks <-
[
	"White", //0
	"Pulse", //1
	"Moonsong", //2
	"LastCave", //3
	"Balcony", //4
	"Geothermal", //5
	"RunningHell", //6
	"WindFortress", //7
	"Meltdown", //8
	"Gravity", //9
	"EyesOfFlame", //10
	"LastBattle" //11
]

::PrecacheSoundtrackNames <-
[
	"remastered"
	"ridic"
	"organya"
	"plus"
	"remixed"
	"kero"
]

::PrecacheTrackNames <-
[
	"white",
	"kodou",
	"oside",
	"lastcave",
	"balcony",
	"grand",
	"hell",
	"kaze",
	"mdown2",
	"gravity",
	"fireeye",
	"lastbt3"
]

::OuterwallMain <- function()
{
	DebugPrint("OUTERWALL INIT STARTED");

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

	PrecacheSound("outerwall/snd_purplecometcoin_collect.mp3");
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

	if (!IsHolidayActive(HOLIDAY_SOLDIER))
		EntFire("soldier_statue", "kill");

	CreateGameText();
	SetLeaderboardMedalTimes();
	PopulateLeaderboard();

	Convars.SetValue("mp_forceautoteam", 1);
	Convars.SetValue("mp_teams_unbalance_limit", 0);

	DebugPrint("OUTERWALL INIT ENDED");
}

::CreateGameText <- function()
{
	for(local iArrayIndex = 1; iArrayIndex < MAX_PLAYERS; iArrayIndex++)
	{
		local gametext_menu = SpawnEntityFromTable("game_text",
		{
			targetname = TIMER_PLAYERHUDTEXT + iArrayIndex,
			message = "You're not supposed to see this.\nHow'd you do it?",
			channel = 5,
			color = "240 255 0 155",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.025,
			y = 0.375
		})

		local gametext_bonus = SpawnEntityFromTable("game_text",
		{
			targetname = BONUS_PLAYERHUDTEXT + iArrayIndex,
			channel = 4,
			color = "115 95 255 155",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.44,
			y = 0.720
		})

		local gametext_encore = SpawnEntityFromTable("game_text",
		{
			targetname = ENCORE_PLAYERHUDTEXT + iArrayIndex,
			channel = 3,
			color = "115 95 255 155",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.475,
			y = 0.895
		})

		Entities.DispatchSpawn(gametext_menu);
		Entities.DispatchSpawn(gametext_bonus);
		Entities.DispatchSpawn(gametext_encore);
	}
}

::OuterwallServerThink <- function()
{
	return 10000.0;
}

::OuterwallClientThink <- function()
{
	//CheckForCheating(self);

	PlaySpectatorTrackThink(self);

	PlayerHUDThink(self);

	CheckPurpleCoinAnnotateButton(self);

	PlayerTimeTrialThink(self);

	PurpleCoinHudThink(self);

	CheckSettingButton(self);

	PlayJumpSound(self);

	UpdatePlayerLastButtons(self);

	PlayerCosmeticThink(self);

	return 0.0;
}

::ResetPlayerGlobalArrays <- function(player_index)
{
	//reset all global arrays to default
	PlayerZoneList[player_index] = null;
	PlayerTrackList[player_index] = 2;
	PlayerCheckpointStatus[player_index] = 0;
	PlayerLanguage[player_index] = 0;
	PlayerCachedLeaderboardPosition[player_index] = null;
	//reset arena array
	ResetPlayerPurpleCoinArenaArray(player_index);
	ResetPlayerTimeTrialArenaArray(player_index);
	//reset medal times
	ResetPlayerDataArrays(player_index);

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
	PlayTrack(PlayerTrackList[player_index], client);

	DebugPrint("Player " + player_index + "'s soundtrack is: " + Soundtracks[PlayerSoundtrackList[player_index]]);
}

::PlaySoundscape <- function(strSoundscape, client)
{
	local player_index = client.GetEntityIndex().tointeger().tostring();

	local soundscape = SpawnEntityFromTable("env_soundscape_triggerable",
	{
		targetname = player_index,
		origin = OUTERWALL_SKYCAMERA_LOCATION,
		soundscape = strSoundscape
	})

	local trigger = SpawnEntityFromTable("trigger_soundscape",
	{
		targetname = player_index + player_index,
		origin = OUTERWALL_SKYCAMERA_LOCATION,
		soundscape = player_index
	})

	Entities.DispatchSpawn(soundscape);
	Entities.DispatchSpawn(trigger);
	EntFireByHandle(trigger, "StartTouch", "", 0.0, client, client);
	EntFireByHandle(soundscape, "Kill", "", 0.01, client, client);
	EntFireByHandle(trigger, "Kill", "", 0.01, client, client);
	EntFire(player_index, "Kill", "", 0.5, client);
	EntFire(player_index + player_index, "Kill", "", 0.5, client);

	DebugPrint("Player " + player_index + " is now listening to: " + strSoundscape);
}

::PlayTrack <- function(iTrack, client)
{
	if(bRoundOver)
		return;

	local player_index = client.GetEntityIndex();

	if(PlayerTimeTrialActive[player_index])
	{
		local song = null

		if(PlayerCurrentLapCount[player_index] > 1)
		{
			song = "outerwall."

			if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[PlayerZoneList[player_index]][OUTERWALL_MEDAL_GOLD]) // gold medal active
				song += "LastBattle"

			else if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[PlayerZoneList[player_index]][OUTERWALL_MEDAL_SILVER]) // silver medal active
			{
				if(PlayerSoundtrackList[player_index] == 4) // Remixed Soundtrack
				{
					if(PlayerZoneList[player_index] == eCourses.Balcony)
						song += "EyesOfFlameThroneRoom"
					else if(PlayerZoneList[player_index] == eCourses.WindFortress)
						song += "EyesOfFlameGCLONE"
				}
				else
					song += "EyesOfFlame"
			}

			else // bronze medal active
				song += "Gravity"

			switch(iTrack)
			{
				case 3: case 5: case 7: case 9: case 11:
				{
					song += ".Outside"
					break;
				}
				case 4:	case 8: case 12:
				{
					song += ".Lava"
					break;
				}
				case 2: case 10: default:
				{
					song += ".Inside"
					break;
				}
			}
		}

		if(song != null)
		{
			printl(song)
			//PlaySoundscape(song, client);
			return;
		}
	}

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

	local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");

	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget");

		if(spectator_target && spectator_target.GetEntityIndex() <= MAX_PLAYERS)
		{
			if(PlayerTrackList[spectator_target.GetEntityIndex()] != -1)
				PlaySoundscape("outerwall." + Tracks[PlayerTrackList[spectator_target.GetEntityIndex()]] + Soundtracks[PlayerSoundtrackList[spectator_target.GetEntityIndex()]], client);
			else
				PlaySoundscape("outerwall.XXXX", client);
		}
		else //we're likely spectating the credits camera, play our pulse
			PlaySoundscape("outerwall.Pulse." + Soundtracks[PlayerSoundtrackList[client.GetEntityIndex()]], client);
	}
}

::PlayerHUDThink <- function(client)
{
	local target_index = client.GetEntityIndex();

	local obsmode = NetProps.GetPropInt(client, "m_iObserverMode");
	local TimeTrialHUDGameTextEntity = null;
	local PurpleCoinHUDGameTextEntity = null;
	local MedalTimeHUDGameTextEntity = null;

	// if we're spectating, get our spec target index
	if(client.GetTeam() == TEAM_SPECTATOR && obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE)
	{
		local spectator_target = NetProps.GetPropEntity(client, "m_hObserverTarget");
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
		EntFire(TimeTrialHUDGameTextEntity, "Display", "", 0.0, client);

	if(MedalTimeHUDGameTextEntity)
		EntFire(MedalTimeHUDGameTextEntity, "Display", "", 0.0, client);

	if(PurpleCoinHUDGameTextEntity)
		EntFire(PurpleCoinHUDGameTextEntity, "Display", "", 0.0, client);

	local encore_hud_active = (TimeTrialHUDGameTextEntity || PurpleCoinHUDGameTextEntity)

	// display overlay hud
	if(encore_hud_active) // encore / normal bonus6
	{
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
			else if(PlayerCurrentLapCount[target_index] >= ZoneLaps_Encore[PlayerZoneList[target_index]][OUTERWALL_MEDAL_IRI]) // iri medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_IRI);
				return;
			}
			else if(PlayerCurrentLapCount[target_index] >= ZoneLaps_Encore[PlayerZoneList[target_index]][OUTERWALL_MEDAL_GOLD]) // gold medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_GOLD);
				return;
			}
			else if(PlayerCurrentLapCount[target_index] >= ZoneLaps_Encore[PlayerZoneList[target_index]][OUTERWALL_MEDAL_SILVER]) // silver medal active
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_ACTIVE_SILVER);
				return;
			}
			else if(PlayerCurrentLapCount[target_index] >= ZoneLaps_Encore[PlayerZoneList[target_index]][OUTERWALL_MEDAL_BRONZE]) // bronze medal active
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
		else if(MedalTimeHUDGameTextEntity) // encore medal times / settings menu
		{
			if(PlayerCurrentSettingQuery[target_index] != null)
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_MENU_SETTINGS_ENCORE);
				return;
			}
			else
			{
				client.SetScriptOverlayMaterial(MAT_ENCOREHUD_MENU_MEDALTIMES_ENCORE);
				return;
			}
		}
		else // regular encore
		{
			client.SetScriptOverlayMaterial(MAT_ENCOREHUD);
			return;
		}
	}
	else if(MedalTimeHUDGameTextEntity) // regular medal times / settings menu
	{
		if(PlayerCurrentSettingQuery[target_index] == null || PlayerCurrentSettingQuery[target_index] == eSettingQuerys.Profile)
		{
			client.SetScriptOverlayMaterial(MAT_MENU_MEDALTIMES);
			return;
		}
		else
		{
			client.SetScriptOverlayMaterial(MAT_MENU_SETTINGS);
			return;
		}
	}

	client.SetScriptOverlayMaterial(null);
}

::UpdatePlayerLastButtons <- function(client)
{
	local player_index = client.GetEntityIndex();
	local buttons = NetProps.GetPropInt(client, "m_nButtons");
	PreviousButtons[player_index] = buttons;
}

::DispenseTip <- function(client)
{
	local chance = RandomInt(1, 100);
	local message = "\x07" + "FF0000";

	local player_index = client.GetEntityIndex();

	message += TranslateString(OUTERWALL_TIP_PREFIX[RandomInt(0, OUTERWALL_TIP_PREFIX.len() - 1)], player_index) + "\x01" + " ";

	if(chance <= 1) //Crude Text 1%
		message += TranslateString(OUTERWALL_TIP_CRUDE[RandomInt(0, OUTERWALL_TIP_CRUDE.len() - 1)], player_index);
	else if(chance <= 11) //ParkourText 10%
		message += TranslateString(OUTERWALL_TIP_PARKOUR[RandomInt(0, OUTERWALL_TIP_PARKOUR.len() - 1)], player_index);
	else if(chance <= 21) //CrapText 10%
		message += TranslateString(OUTERWALL_TIP_CRAP[RandomInt(0, OUTERWALL_TIP_CRAP.len() - 1)], player_index);
	else
		message += TranslateString(OUTERWALL_TIP_REGULAR[RandomInt(0, OUTERWALL_TIP_REGULAR.len() - 1)], player_index);

	ClientPrint(client, HUD_PRINTTALK, message);
}

::CheckForCheating <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(!client || PlayerCheatedCurrentRun[player_index] == true)
		return;

	if(bGlobalCheated)
	{
		PlayerCheatedCurrentRun[player_index] = true;
		return;
	}

	if(Convars.GetBool("sv_cheats"))
	{
		PlayerCheatedCurrentRun[player_index] = true;
		return;
	}

	if(client.IsNoclipping())
	{
		PlayerCheatedCurrentRun[player_index] = true;
		return;
	}

	local Distance = (client.GetOrigin() - PlayerLastPosition[player_index]).Length()

	if(Distance > 96)
	{
		PlayerCheatedCurrentRun[player_index] = true;
		return;
	}

	PlayerLastPosition[player_index] = client.GetOrigin()

	if(NetProps.GetPropInt(client, "m_PlayerClass.m_iClass") != TF_CLASS_SCOUT)
	{
		PlayerCheatedCurrentRun[player_index] = true;
		return;
	}

	//todo: block sm_goto
}

::PlayerLastIsJumpingState <- array(MAX_PLAYERS, false)
::PlayerLastGroundedState <- array(MAX_PLAYERS, false)
::PlayerLastAirDashCount <- array(MAX_PLAYERS, 0)

::PlayJumpSound <- function(client)
{
	local player_index = client.GetEntityIndex();

	local jump_state = NetProps.GetPropBool(client, "m_Shared.m_bJumping");
	local grounded_state = !!(NetProps.GetPropInt(client, "m_fFlags") & FL_ONGROUND);
	local airdash_count = NetProps.GetPropInt(client, "m_Shared.m_iAirDash");

	//If our previous state check is false && new one is true.
	if(PlayerLastIsJumpingState[player_index] == false && jump_state == true)
		client.EmitSound(SND_QUOTE_JUMP);

	else if(PlayerLastGroundedState[player_index] == false && grounded_state == true)
		client.EmitSound(SND_QUOTE_THUD);

	else if(PlayerLastAirDashCount[player_index] != airdash_count && PlayerLastAirDashCount[player_index] != 1)
		client.EmitSound(SND_BOOSTER);

	PlayerLastIsJumpingState[player_index] = jump_state;
	PlayerLastGroundedState[player_index] = grounded_state;
	PlayerLastAirDashCount[player_index] = airdash_count;
}

::PlayerUpdateSkyboxState <- function(client)
{
	local player_index = client.GetEntityIndex();
	local SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION;

	if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[PlayerZoneList[player_index]][OUTERWALL_MEDAL_GOLD])
		SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION_TIER2LAPPING;
	else if(PlayerCurrentLapCount[player_index] >= ZoneLaps_Encore[PlayerZoneList[player_index]][OUTERWALL_MEDAL_BRONZE])
		SkyCameraLocation = OUTERWALL_SKYCAMERA_LOCATION_TIER1LAPPING;

	NetProps.SetPropVector(client, "m_Local.m_skybox3d.origin", SkyCameraLocation);
}
::PlayerLastCosmeticSpawn <-
[
	::PlayerLastSpawnCosmeticA <- array(MAX_PLAYERS, 0)
	::PlayerLastSpawnCosmeticB <- array(MAX_PLAYERS, 0)
]

::PlayerCosmeticThink <- function(client)
{
	local player_index = client.GetEntityIndex();

	if(!IsPlayerAlive(client) || client.IsNoclipping())
		return;

	switch(PlayerCosmeticEquipped[player_index])
	{
		case eCosmetics.Booster:
		{
			PlayerDispatchCosmeticParticle(client, 0, 249, 0.05, "outerwall_cosmetic_booster", client.GetOrigin() + Vector(0,0,42), Vector(0,0,0));
			break;
		}
		case eCosmetics.PurpleCoin:
		{
			PlayerDispatchCosmeticParticle(client, 0, 0, 0.25, "outerwall_cosmetic_purplecoin", client.GetOrigin() + Vector(0,0,42), Vector(0,90,0));
			PlayerDispatchCosmeticParticle(client, 1, 249, 0.0, "outerwall_cosmetic_purplecoin_dash_" + (PlayerEncoreStatus[player_index] ? "blue" : "red"), client.GetOrigin(), Vector(0,90,0));
			break;
		}
		case eCosmetics.MachTrail:
		{
			PlayerSpawnCosmeticModelTrail(client, 0, 249, false);
			break;
		}
		case eCosmetics.RainbowTrail:
		{
			PlayerSpawnCosmeticModelTrail(client, 0, 249, true);
			break;
		}
		default: break;
	}
}

::PlayerDispatchCosmeticParticle <- function(client, cosmeticindex, speedrequired, delay, particle, position, rotation)
{
	local player_index = client.GetEntityIndex();

	if(PlayerLastCosmeticSpawn[cosmeticindex][player_index] + delay > Time())
		return;

	if(NetProps.GetPropFloat(client, "m_flMaxspeed") < speedrequired)
		return;

	local string_pos = "Vector(" + position.x + "," + position.y + "," + position.z + ")"
	local string_rot = "Vector(" + rotation.x + "," + rotation.y + "," + rotation.z + ")"

	EntFireByHandle(client, "RunScriptCode", "DispatchParticleEffect(\"" + particle + "\", " + string_pos + ", " + string_rot + ");", 0.0, null, null);
	PlayerLastCosmeticSpawn[cosmeticindex][player_index] = Time();
}

::PlayerSpawnCosmeticModelTrail <- function(client, cosmeticindex, speedrequired, bRainbow)
{
	local player_index = client.GetEntityIndex();

	if(PlayerLastCosmeticSpawn[cosmeticindex][player_index] + 0.125 > Time())
		return;

	if(NetProps.GetPropFloat(client, "m_flMaxspeed") < speedrequired)
		return;

	local trail = SpawnEntityFromTable("prop_dynamic",
	{
		model = client.GetModelName(),
		skin = 0,
		origin = client.GetOrigin(),
		angles = client.GetLocalAngles(),
		solid = 0,
		DisableBoneFollowers = true,
		disableshadows = true,
		disablereceiveshadows = true,
		rendermode = 5,
		renderamt = 0,
		rendercolor = bRainbow ? RainbowTrail() : PlayerEncoreStatus[player_index] ? "0 0 255" : "255 0 0",
		DefaultAnim = client.GetSequenceName(client.GetSequence())
	})
	Entities.DispatchSpawn(trail);
	EntFireByHandle(trail, "SetCycle", round(client.GetCycle(), 1).tostring(), 0.0, client, null);
	EntFireByHandle(trail, "SetPlayBackRate", "0", 0.05, client, null);
	EntFireByHandle(trail, "Alpha", "50", 0.05, client, null);
	EntFireByHandle(trail, "Kill", "", 0.5, client, null);
	PlayerLastCosmeticSpawn[cosmeticindex][player_index] = Time();
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

	if(iNewCheckpoint != current_checkpoint + 1 && (iNewCheckpoint != 0 && iNewCheckpoint != 3) || activator.IsNoclipping())
		return;

	PlayerCheckpointStatus[player_index] = iNewCheckpoint;

	if(iNewCheckpoint == 1 || iNewCheckpoint == 2)
	{
		EmitSoundOnClient(SND_CHECKPOINT, activator);
		PlayerSetCheckpointTime(player_index);

		if(PlayerZoneList[player_index] == eCourses.OuterWall)
			DoEntFire("checkpoint_" + iNewCheckpoint, "StartTouch", "", 0.0, activator, activator);
	}

	DebugPrint("Player " + player_index + "'s new checkpoint is: " + iNewCheckpoint);
}

::TeleportPlayerToZone <- function(iZone = null, client = null, iCheckpointFilter = null, bAllowOnlyInFilter = false, bPlayHurtSound = true, bIgnoreNoclip = false)
{
	//TODO: Add a case for the checkpoints in bonus 4 and 5
	if(!client)
		return;

	if(!bIgnoreNoclip && client.IsNoclipping())
		return;

	local player_index = client.GetEntityIndex();

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

	if(bPlayHurtSound)
		client.EmitSound(SND_QUOTE_HURT);

	local TeleportDest = Entities.FindByName(null, "teleport_regular_" + PlayerZoneList[player_index].tostring());

	if(TeleportDest == null)
		return;

	client.SetOrigin(TeleportDest.GetOrigin());
	client.SnapEyeAngles(QAngle(TeleportDest.GetAngles().x, TeleportDest.GetAngles().y, TeleportDest.GetAngles().z));
}

::PlayerTouchTimerStartZone <- function(iZone, bTouch)
{
	local player_index = activator.GetEntityIndex();

	local Action = bTouch ? "StartTouch" : "EndTouch";

	if(iZone == 0)
		DoEntFire("start_zone", Action, "", 0.0, activator, activator);
	else
		DoEntFire("bonus" + iZone + "_start", Action, "", 0.0, activator, activator);

	if(bTouch)
	{
		ResetTimeTrialArena(player_index);
		PlayerActivateTimeTrial(activator, false);
		ResetPlayerAchievementArrays(player_index);
		PlayerUpdateSkyboxState(activator);
	}
}

::DoGoal <- function(iZoneGoal, client = null)
{
	if(!client)
		client = activator;

	local player_index = activator.GetEntityIndex();

	if(activator.IsNoclipping() || PlayerZoneList[player_index] != iZoneGoal || PlayerCheckpointStatus[player_index] == 3)
		return;

	if(PlayerEncoreStatus[player_index] == 1 && PlayerTimeTrialActive[player_index] == false)
		return;

	PlayerActivateTimeTrial(activator, false);

	if(PlayerCheatedCurrentRun[player_index] || (iZoneGoal == 0 && PlayerCheckpointStatus[player_index] != 2 && PlayerEncoreStatus[player_index] != 1))
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
	CheckAchievementBatch_PostRun(player_index);

	if(PlayerEncoreStatus[player_index] != 1)
	{
		if(iZoneGoal == 0)
			DoEntFire("end_zone", "StartTouch", "", 0.0, client, client);
		else
			DoEntFire("bonus" + iZoneGoal + "_end", "StartTouch", "", 0.0, client, client);
	}
}

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
			NetProps.SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,350));
		case 1: //No Launch Spike
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 50.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT);

			if(!PlayerCheatedCurrentRun[player_index])
				PlayerTimesHurt[player_index] += 1;

			break;
		case 2: //Lava
			NetProps.SetPropVector(client, "m_vecBaseVelocity", Vector(0,0,650));
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 25.0, DMG_BURN);
			client.EmitSound(SND_QUOTE_HURT_LAVA);

			if(!PlayerCheatedCurrentRun[player_index])
				PlayerTimesHurt[player_index] += 1;

			break;
		case 3: //Instant Kill
			client.TakeDamageEx(null, caller, null, Vector(0,0,0), Vector(0,0,0), 9999999.0, DMG_BURN);
		default: //Error
			printl("ERROR ERROR! ::HurtTouch() called with invalid iSpikeType!!!!");
			break;
	}

	PlayerLastHurt[player_index] = Time();
	PlayerDamagedDuringRun[player_index] = true;
	CheckAchievement_HitAlot(player_index);
}

::BoosterTouch <- function(bEncoreBooster = false, vCustomAngle = null)
{
	local player_index = activator.GetEntityIndex();

	if(activator.IsNoclipping() || PlayerEncoreStatus[player_index] != bEncoreBooster.tointeger())
		return;

	local player_velocity = NetProps.GetPropVector(activator, "m_vecAbsVelocity");

	if(vCustomAngle == null)
		player_velocity.z = 650;
	else if(type(vCustomAngle) == "vector")
	{
		if(vCustom.x != 0) player_velocity.x = vCustom.x;
		if(vCustom.y != 0) player_velocity.y = vCustom.y;
		if(vCustom.z != 0) player_velocity.z = vCustom.z;
	}

	NetProps.SetPropVector(activator, "m_vecAbsVelocity", player_velocity);
	NetProps.SetPropInt(activator, "m_Shared.m_iAirDash", 0);
	activator.EmitSound("TFPlayer.AirBlastImpact");
	PlayerUseInnerWallBoosterDuringRun[player_index] = 1;
}