//shorten constants for sanity
::MAX_PLAYERS <- Constants.Server.MAX_PLAYERS
::TEAM_UNASSIGNED <- Constants.ETFTeam.TEAM_UNASSIGNED
::TF_TEAM_RED <- Constants.ETFTeam.TF_TEAM_RED
::TF_TEAM_BLUE <- Constants.ETFTeam.TF_TEAM_BLUE
::TEAM_SPECTATOR <- Constants.ETFTeam.TEAM_SPECTATOR
::kHoliday_Soldier <- Constants.EHoliday.kHoliday_Soldier
::OBS_MODE_IN_EYE <- Constants.ESpectatorMode.OBS_MODE_IN_EYE
::OBS_MODE_CHASE <- Constants.ESpectatorMode.OBS_MODE_CHASE
::DMG_BURN <- Constants.FDmgType.DMG_BURN
::HUD_PRINTTALK <- Constants.EHudNotify.HUD_PRINTTALK
::IN_ATTACK <- Constants.FButtons.IN_ATTACK
::IN_ATTACK2 <- Constants.FButtons.IN_ATTACK2

::DEBUG_OUTPUT <- true

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
	if(DEBUG_OUTPUT)
	{
		DEBUG_OUTPUT = false;
		printl("Debug Output: OFF");
	}
	else
	{
		DEBUG_OUTPUT = true;
		printl("Debug Output: ON");
	}
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
	foreach(iZone, medal in PlayerBestMedalArray[player_index])
	{
		// no medal exists, not encorable
		if(medal == -1)
		{
			return;
		}
	}
}

::IsPlayerAlive <- function(client)
{
    return NetProps.GetPropInt(client, "m_lifeState") == 0;
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

	if(client.GetTeam() == TF_TEAM_RED && PlayerEncoreStatus[player_index] == true)
		SwapTeam(client);
	else if(client.GetTeam() == TF_TEAM_BLUE && PlayerEncoreStatus[player_index] == false)
		SwapTeam(client);
}

::RainbowTrail <- function()
{
	//int color[3];
	//color[0] = round(Cosine((GetGameTime() * 1.5) + 6) * 127.5 + 127.5, 0);
	//color[1] = round(Cosine((GetGameTime() * 1.5) + 4) * 127.5 + 127.5, 0);
	//color[2] = round(Cosine((GetGameTime() * 1.5) + 2) * 127.5 + 127.5, 0);
}