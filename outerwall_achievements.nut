::PlayerUseInnerWallBoosterDuringRun <- array(MAX_PLAYERS, false)
::PlayerDamagedDuringRun <- array(MAX_PLAYERS, false)
::PlayerClocksCollectedDuringRun <- array(MAX_PLAYERS, 0)
::PlayerUseRadarDuringRun <- array(MAX_PLAYERS, false)

::ResetPlayerAchievementArrays <- function(player_index)
{
    PlayerUseInnerWallBoosterDuringRun[player_index] = false;
    PlayerDamagedDuringRun[player_index] = false;
    PlayerClocksCollectedDuringRun[player_index] = 0;
    PlayerUseRadarDuringRun[player_index] = false;
}

::DisplayAchievementMessage <- function(achievement_index, client_index)
{
    //foreach client on the server, display message
    local client = PlayerInstanceFromIndex(client_index);
    local playername = NetProps.GetPropString(client, "m_szNetname");
    client.EmitSound("Achievement.Earned");
    DispatchParticleEffect("achieved", client.GetOrigin() + Vector(0,0,84), Vector(0,90,0));

    for(local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
    {
        local player = PlayerInstanceFromIndex(player_index);
        if (player == null) continue;
        local achieved_string = TranslateString(OUTERWALL_ACHIEVEMENT_ACHIEVED, player_index);
        local achievement_string = TranslateString(OUTERWALL_ACHIEVEMENT_NAME[achievement_index], player_index);

        ClientPrint(player, HUD_PRINTTALK, "\x01" + "\x07FFD700" + playername + "\x01" + achieved_string + "\x079EC34F" + achievement_string);
    }

}

::CheckAchievementBatch_Medals <- function(player_index)
{
    CheckAchievement_NormalAllGold(player_index);
    CheckAchievement_NormalAllIri(player_index);
    CheckAchievement_EncoreAllGold(player_index);
    CheckAchievement_EncoreAllIri(player_index);
}

::CheckAchievement_HitAlot <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.HurtAlot])
        return;

    if((PlayerSpikeHits[player_index] + PlayerLavaHits[player_index]) >= 5000)
    {
        PlayerAchievements[player_index][eAchievements.HurtAlot] = 1;
        DisplayAchievementMessage(eAchievements.HurtAlot, player_index);
    }
}

::CheckAchievement_NormalInnerWallNoBoost <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost])
        return;

    if(!PlayerUseInnerWallBoosterDuringRun[player_index] && PlayerZoneList[player_index] == 3 && !!!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost] = 1;
        DisplayAchievementMessage(eAchievements.NormalInnerWallNoBoost, player_index);
    }
}

::CheckAchievement_NormalHellNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalHellNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 4 && !!!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.NormalHellNoDmg] = 1;
        DisplayAchievementMessage(eAchievements.NormalHellNoDmg, player_index);
    }
}

::CheckAchievement_NormalPurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalPurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.NormalPurpleCoinNoRadar] = 1;
        DisplayAchievementMessage(eAchievements.NormalPurpleCoinNoRadar, player_index);
    }
}

::AwardAchievement_SecretClimb <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.SecretClimb])
        return;

    PlayerAchievements[player_index][eAchievements.SecretClimb] = 1;
    DisplayAchievementMessage(eAchievements.SecretClimb, player_index);
}

::CheckAchievement_EncoreUnlock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreUnlock])
        return;

    if(IsPlayerEncorable(player_index))
    {
        PlayerAchievements[player_index][eAchievements.EncoreUnlock] = 1;
        DisplayAchievementMessage(eAchievements.EncoreUnlock, player_index);
    }
}

::CheckAchievement_NormalAllGold <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalGold])
        return;

	foreach(iZone, medal in PlayerBestMedalArray[player_index])
	{
		// we have a medal thats less than gold
		if(medal < OUTERWALL_MEDAL_GOLD)
		{
            return;
		}
	}

    PlayerAchievements[player_index][eAchievements.NormalGold] = 1;
    DisplayAchievementMessage(eAchievements.NormalGold, player_index);
}

::CheckAchievement_NormalAllIri <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalIri])
        return;

    foreach(iZone, medal in PlayerBestMedalArray[player_index])
    {
        // we have a medal thats less than iri
        if(medal < OUTERWALL_MEDAL_IRI)
        {
            return;
        }
    }

    PlayerAchievements[player_index][eAchievements.NormalIri] = 1;
    DisplayAchievementMessage(eAchievements.NormalIri, player_index);
}

::CheckAchievement_LapsAlot <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.LapsAlot])
        return;

    if(PlayerLapsRan[player_index] >= 100)
    {
        PlayerAchievements[player_index][eAchievements.LapsAlot] = 1;
        DisplayAchievementMessage(eAchievements.LapsAlot, player_index);
    }
}

::CheckAchievement_EncoreOsideNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreOsideNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 0 && !!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.EncoreOsideNoDmg] = 1;
        DisplayAchievementMessage(eAchievements.EncoreOsideNoDmg, player_index);
    }
}

::CheckAchievement_EncoreBalconyClock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreBalconyClock])
        return;

    if(PlayerClocksCollectedDuringRun[player_index] <= 4 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.EncoreBalconyClock] = 1;
        DisplayAchievementMessage(eAchievements.EncoreBalconyClock, player_index);
    }
}

::CheckAchievement_EncoreHellTime <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreHellTime])
        return;

    if(PlayerTimeTrialTime[player_index] >= 200 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.EncoreHellTime] = 1;
        DisplayAchievementMessage(eAchievements.EncoreHellTime, player_index);
    }
}

::CheckAchievement_EncorePurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncorePurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!PlayerEncoreStatus[player_index])
    {
        PlayerAchievements[player_index][eAchievements.EncorePurpleCoinNoRadar] = 1;
        DisplayAchievementMessage(eAchievements.EncorePurpleCoinNoRadar, player_index);
    }
}

//todo: EncoreManyLaps

//todo: EncoreFinish

::CheckAchievement_EncoreAllGold <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreGold])
        return;

	foreach(iZone, medal in PlayerBestMedalEncoreArray[player_index])
	{
		// we have a medal thats less than gold
		if(medal < OUTERWALL_MEDAL_GOLD)
		{
            return;
		}
	}

    PlayerAchievements[player_index][eAchievements.EncoreGold] = 1;
    DisplayAchievementMessage(eAchievements.EncoreGold, player_index);
}

::CheckAchievement_EncoreAllIri <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreIri])
        return;

    foreach(iZone, medal in PlayerBestMedalEncoreArray[player_index])
    {
        // we have a medal thats less than iri
        if(medal < OUTERWALL_MEDAL_IRI)
        {
            return;
        }
    }

    PlayerAchievements[player_index][eAchievements.EncoreIri] = 1;
    DisplayAchievementMessage(eAchievements.EncoreIri, player_index);
}

//todo: AllGold

//todo: AllIri