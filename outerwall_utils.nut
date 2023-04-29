//shorten constants for sanity
::MAX_PLAYERS <- Constants.Server.MAX_PLAYERS
::TEAM_UNASSIGNED <- Constants.ETFTeam.TEAM_UNASSIGNED
::TF_TEAM_RED <- Constants.ETFTeam.TF_TEAM_RED
::TF_TEAM_BLUE <- Constants.ETFTeam.TF_TEAM_BLUE
::TEAM_SPECTATOR <- Constants.ETFTeam.TEAM_SPECTATOR
::HOLIDAY_SOLDIER <- Constants.EHoliday.kHoliday_Soldier
::OBS_MODE_IN_EYE <- Constants.ESpectatorMode.OBS_MODE_IN_EYE
::OBS_MODE_CHASE <- Constants.ESpectatorMode.OBS_MODE_CHASE
::DMG_BURN <- Constants.FDmgType.DMG_BURN
::HUD_PRINTTALK <- Constants.EHudNotify.HUD_PRINTTALK
::IN_ATTACK <- Constants.FButtons.IN_ATTACK
::IN_ATTACK2 <- Constants.FButtons.IN_ATTACK2
::TF_CLASS_SCOUT <- Constants.ETFClass.TF_CLASS_SCOUT

::DEBUG_OUTPUT <- false

::OUTERWALL_MEDAL_BRONZE <- 0
::OUTERWALL_MEDAL_SILVER <- 1
::OUTERWALL_MEDAL_GOLD <- 2
::OUTERWALL_MEDAL_IRI <- 3

::MAT_MENU_MEDALTIMES <- "outerwall/hud/hud_menu1.vmt"
::MAT_MENU_SETTINGS <- "outerwall/hud/hud_menu2.vmt"

::MAT_ENCOREHUD <- "outerwall/hud/hud_encore.vmt"
::MAT_ENCOREHUD_MENU_MEDALTIMES_ENCORE <- "outerwall/hud/hud_encore_menu1.vmt"
::MAT_ENCOREHUD_MENU_SETTINGS_ENCORE <- "outerwall/hud/hud_encore_menu2.vmt"
::MAT_ENCOREHUD_ACTIVE_TIMELERPING <- "outerwall/hud/hud_encore_timelerping.vmt"

::MAT_ENCOREHUD_ACTIVE_NOMEDAL <- "outerwall/hud/hud_encore_active.vmt"
::MAT_ENCOREHUD_ACTIVE_BRONZE <- "outerwall/hud/hud_encore_active_bronze.vmt"
::MAT_ENCOREHUD_ACTIVE_SILVER <- "outerwall/hud/hud_encore_active_silver.vmt"
::MAT_ENCOREHUD_ACTIVE_GOLD <- "outerwall/hud/hud_encore_active_gold.vmt"
::MAT_ENCOREHUD_ACTIVE_IRI <- "outerwall/hud/hud_encore_active_iri.vmt"

::TIMER_PLAYERHUDTEXT <- "outerwall_timer_gametext_"
::BONUS_PLAYERHUDTEXT <- "outerwall_bonus_gametext_"
::ENCORE_PLAYERHUDTEXT <- "outerwall_encore_gametext_"

::OUTERWALL_SAVEPATH <- "pf_outerwall/"
::OUTERWALL_SAVETYPE <- ".sav"
::OUTERWALL_SAVELEADERBOARDSUFFIX <- "_leaderboarddata"
::OUTERWALL_SAVELEADERBOARD <- "leaderboard_entries"

::OUTERWALL_SERVERPATH <- "server/"
::OUTERWALL_BANNEDACCOUNTS <- "account_bans"

::OUTERWALL_MAPNAME <- "pf_outerwall_"

enum eAchievements{
	HurtAlot
	NormalInnerWallNoBoost
	NormalHellNoDmg
	NormalPurpleCoinNoRadar
	SecretClimb
	EncoreUnlock
	NormalGold
	NormalIri
	LapsAlot
	EncoreOsideNoDmg
	EncoreBalconyClock
	EncoreHellTime
	EncorePurpleCoinNoRadar
	EncoreManyLaps
	EncoreFinish
	EncoreGold
	EncoreIri
	AllGold
	AllIri
	MAX
}

enum eSettingQuerys{
	DisplayTime
	DisplayCheckpoint
	Soundtrack
	Encore
	Achievement
	Cosmetic
	MAX
}

enum eCheckpointOptions{
	Bonuses
	Always
	Never
}

enum eMapVersions{
	v4a
}

::MapVersionArray <-
[
	"v4a"
]

::CURRENT_VERSION <- eMapVersions.v4a;

::DeltaTime <- function()
{
	return clamp(FrameTime(), 0.0, 1.0);
}

::DebugPrint <- function(Text)
{
	if(DEBUG_OUTPUT)
		printl(Text);
}

::ToggleDebug <- function()
{
	DEBUG_OUTPUT = !DEBUG_OUTPUT;
	printl("Debug Output: " + DEBUG_OUTPUT ? "ON" : "OFF");
}

::max <- function(a, b)
{
	if (a > b)
		return a;
	return b;
}

::round <- function(val, decimalPoints)
{
	local f = pow(10, decimalPoints) * 1.0;
	local newVal = val * f;
	newVal = floor(newVal + 0.5)
	newVal = (newVal * 1.0) / f;

	return newVal;
}

::clamp <- function(val, min, max)
{
	if (max < min)
		return max;
	if (val < min)
		return min;
	if (val > max)
		return max;
	return val;
}

::lerp <- function(f, A, B)
{
	return A + f * (B - A);
}

::invlerp <- function(f, A, B)
{
	return (f - A) / (B - A);
}

::remap <- function(imin, imax, omin, omax, v)
{
	return omin + (v - imin) * (omax - omin) / (imax - imin);
}

::lerpRGB <- function(f, color1, color2)
{
    local color = Vector(0, 0, 0);
    color.x = color1.x + ((color2.x - color1.x) * f);
    color.y = color1.y + ((color2.y - color1.y) * f);
    color.z = color1.z + ((color2.z - color1.z) * f);
    return color;
}

// Gradually changes a value towards a desired goal over time.
::SmoothDamp <- function(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
{
	// Based on Game Programming Gems 4 Chapter 1.10
	smoothTime = max(0.0001, smoothTime);
	local omega = 2.0 / smoothTime;

	local x = omega * deltaTime;
	local expo = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);
	local change = current - target;
	local originalTo = target;

	// Clamp maximum speed
	local maxChange = maxSpeed * smoothTime;
	change = clamp(change, -maxChange, maxChange);
	target = current - change;

	local temp = (currentVelocity + omega * change) * deltaTime;
	currentVelocity = (currentVelocity - omega * temp) * expo;
	local output = target + (change + temp) * expo;

	// Prevent overshooting
	if (originalTo - current > 0.0 == output > originalTo)
	{
		output = originalTo;
		currentVelocity = (output - originalTo) / deltaTime;
	}

	return output;
}

::GetPlayerBestMedal <- function(player_index, iZone, bEncore)
{
	local medal_times = ZoneTimes[iZone];
	local medal_laps = ZoneLaps_Encore[iZone];

	local total_time = PlayerBestTimeArray[player_index][iZone];
	local laps_ran = PlayerBestLapCountEncoreArray[player_index][iZone];

	for(local medal_index = 3; medal_index > -1; medal_index--)
	{
		if((!bEncore && total_time < medal_times[medal_index]) || (bEncore && laps_ran >= medal_laps[medal_index]))
		{
			return medal_index;
		}
	}

	return -1;
}

::SortTotalTime <- function(a,b)
{
	local first = a.total_time;
	local second = b.total_time;

	if(first>second) return 1
	else if(first<second) return -1
	return 0;
}

::AddEscapeChars <- function(str)
{
	local result_str = "";
	local str_len = str.len();
	local str_array = array(str_len, "");
	for(local i = 0; i < str_len; i++)
	{
		str_array[i] = str[i].tochar();
	}

	foreach(char in str_array)
	{
		if(char == "\\" || char == "," || char == ";")
		{
			result_str += "\\";
		}
		result_str += char;
	}

	return result_str;
}

::IsPlayerEncorable <- function(player_index)
{
	for (local i = 0; i < ZONE_COUNT; i++)
	{
		// no medal exists, not encorable
		if(GetPlayerBestMedal(player_index, i, false) == -1)
		{
			return false;
		}
	}

	return true;
}

::IsPlayerAlive <- function(client)
{
    return NetProps.GetPropInt(client, "m_lifeState") == 0; //thank u ficool
}

::SwapTeam <- function(client)
{
	if (client == null || client.IsPlayer() == false)
		return;

	if (client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR)
		return;

	local newTeam = 0
	if (client.GetTeam() == TF_TEAM_RED)
		newTeam = TF_TEAM_BLUE;
	else
		newTeam = TF_TEAM_RED;

	client.ForceChangeTeam(newTeam, true);

	local cosmetic = null;
	while (cosmetic = Entities.FindByClassname(cosmetic, "tf_wearable"))
	{
		if (cosmetic.GetOwner() == client)
			cosmetic.SetTeam(newTeam);
	}
}

::EncoreTeamCheck <- function(client)
{
	local player_index = client.GetEntityIndex();

	if (client == null || client.IsPlayer() == false || !IsPlayerAlive(client))
		return;

	if (client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR)
		return;

	if(client.GetTeam() == TF_TEAM_RED && !!PlayerEncoreStatus[player_index] == false)
		return;

	if(client.GetTeam() == TF_TEAM_BLUE && !!PlayerEncoreStatus[player_index] == true)
		return;

	if(client.GetTeam() == TF_TEAM_RED && !!PlayerEncoreStatus[player_index] == true)
	{
		SwapTeam(client);
		return;
	}

	else if(client.GetTeam() == TF_TEAM_BLUE && !!PlayerEncoreStatus[player_index] == false)
	{
		SwapTeam(client);
		return;
	}

	ClientPrint(null, HUD_PRINTTALK, "\x07" + "FF0000" + "ERROR: Failed to enforce encore status on player " + player_index)
}

::PrintToPlayerAndSpectators <- function(main_player_index, message)
{
	local main_player = PlayerInstanceFromIndex(main_player_index);

	for (local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
	{
		if(player_index == main_player_index)
		{
			ClientPrint(main_player, HUD_PRINTTALK, message);
			continue;
		}

		local player = PlayerInstanceFromIndex(player_index);
		if (!player)
			continue;

		if(player.GetTeam() != TEAM_SPECTATOR)
			continue;

		local obsmode = NetProps.GetPropInt(main_player, "m_iObserverMode");
		local spectator_target = NetProps.GetPropEntity(main_player, "m_hObserverTarget");

		if((obsmode == OBS_MODE_IN_EYE || obsmode == OBS_MODE_CHASE) && spectator_target == main_player)
			ClientPrint(player, HUD_PRINTTALK, message);
	}
}

::FormatTime <- function(input_time)
{
	local input_time_type = type(input_time);

	if(input_time_type == "integer")
	{
		local Min = input_time / 60;
		local Sec = input_time - (Min * 60);
		local SecString = format("%s%i", Sec < 10 ? "0" : "", Sec);
		return (Min + ":" + SecString).tostring();
	}

	if(input_time_type == "float")
	{
		local timedecimal = split((round(input_time - input_time.tointeger(), 2)).tostring(), ".");
		local Min = input_time.tointeger() / 60;
		local Sec = input_time.tointeger() - (Min * 60);
		local SecString = format("%s%i", Sec < 10 ? "0" : "", Sec);
		return (Min + ":" + SecString + "." + (timedecimal.len() == 1 ? "00" : timedecimal[1].len() == 1 ? timedecimal[1].tostring() + "0" : timedecimal[1].tostring())).tostring();
	}

	return input_time.tostring();
}

::FormatTimeHours <- function(input_time)
{
	local input_time_type = type(input_time);

	if(input_time_type == "integer")
	{
		local Hrs = (input_time / 3600);
		local Min = ((input_time - (Hrs * 3600)) / 60).tointeger();
		local Sec = input_time - (Hrs * 3600) - (Min * 60).tointeger();

		if(Hrs < 10) {Hrs = "0" + Hrs;}
		if(Min < 10) {Min = "0" + Min;}
		if(Sec < 10) {Sec = "0" + Sec;}

		return (Hrs + ":" + Min + ":" + Sec).tostring();
	}

	return input_time.tostring();
}

::RainbowTrail <- function()
{
	//int color[3];
	//color[0] = round(Cosine((GetGameTime() * 1.5) + 6) * 127.5 + 127.5, 0);
	//color[1] = round(Cosine((GetGameTime() * 1.5) + 4) * 127.5 + 127.5, 0);
	//color[2] = round(Cosine((GetGameTime() * 1.5) + 2) * 127.5 + 127.5, 0);
}
