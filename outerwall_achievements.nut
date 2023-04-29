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

::UnlockPlayerAchievementMessage <- function(achievement_index, client_index)
{
    //foreach client on the server, display message
    local client = PlayerInstanceFromIndex(client_index);
    local playername = NetProps.GetPropString(client, "m_szNetname");
    PlayerAchievements[player_index][achievement_index] = 1;
    client.EmitSound("Achievement.Earned");
    DispatchParticleEffect("achieved", client.GetOrigin() + Vector(0,0,84), Vector(0,90,0));

    for(local player_index = 1; player_index <= MAX_PLAYERS; player_index++)
    {
        local player = PlayerInstanceFromIndex(player_index);
        if (!player) continue;
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
        UnlockPlayerAchievementMessage(eAchievements.HurtAlot, player_index);
}

::CheckAchievement_NormalInnerWallNoBoost <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost])
        return;

    if(!PlayerUseInnerWallBoosterDuringRun[player_index] && PlayerZoneList[player_index] == 3 && !!!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.NormalInnerWallNoBoost, player_index);
}

::CheckAchievement_NormalHellNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalHellNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 4 && !!!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.NormalHellNoDmg, player_index);
}

::CheckAchievement_NormalPurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalPurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.NormalPurpleCoinNoRadar, player_index);
}

::AwardAchievement_SecretClimb <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.SecretClimb])
        return;

    if(PlayerCheatedCurrentRun[player_index])
        return;

    DisplayAchievementMessage(eAchievements.SecretClimb, player_index);
}

::CheckAchievement_EncoreUnlock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreUnlock])
        return;

    if(IsPlayerEncorable(player_index))
        DisplayAchievementMessage(eAchievements.EncoreUnlock, player_index);
}

::CheckAchievement_NormalAllGold <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalGold])
        return;

    for (local i = 0; i < ZONE_COUNT; i++)
	{
		// we have a medal thats less than gold
		if(GetPlayerBestMedal(player_index, i, false) < OUTERWALL_MEDAL_GOLD)
		{
			return;
		}
	}

    DisplayAchievementMessage(eAchievements.NormalGold, player_index);
}

::CheckAchievement_NormalAllIri <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalIri])
        return;

    for (local i = 0; i < ZONE_COUNT; i++)
    {
        // we have a medal thats less than iri
        if(GetPlayerBestMedal(player_index, i, false) < OUTERWALL_MEDAL_IRI)
        {
            return;
        }
    }

    DisplayAchievementMessage(eAchievements.NormalIri, player_index);
}

::CheckAchievement_LapsAlot <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.LapsAlot])
        return;

    if(PlayerLapsRan[player_index] >= 100)
        DisplayAchievementMessage(eAchievements.LapsAlot, player_index);
}

::CheckAchievement_EncoreOsideNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreOsideNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 0 && !!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.EncoreOsideNoDmg, player_index);
}

::CheckAchievement_EncoreBalconyClock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreBalconyClock])
        return;

    if(PlayerClocksCollectedDuringRun[player_index] <= 4 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.EncoreBalconyClock, player_index);
}

::CheckAchievement_EncoreHellTime <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreHellTime])
        return;

    if(PlayerTimeTrialTime[player_index] >= 200 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.EncoreHellTime, player_index);
}

::CheckAchievement_EncorePurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncorePurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!PlayerEncoreStatus[player_index])
        DisplayAchievementMessage(eAchievements.EncorePurpleCoinNoRadar, player_index);
}

//todo: EncoreManyLaps

//todo: EncoreFinish

::CheckAchievement_EncoreAllGold <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreGold])
        return;

    for (local i = 0; i < ZONE_COUNT_ENCORE; i++)
    {
        // we have a medal thats less than gold
        if(GetPlayerBestMedal(player_index, i, true) < OUTERWALL_MEDAL_GOLD)
        {
            return;
        }
    }

    DisplayAchievementMessage(eAchievements.EncoreGold, player_index);
}

::CheckAchievement_EncoreAllIri <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreIri])
        return;

    for (local i = 0; i < ZONE_COUNT_ENCORE; i++)
    {
        // we have a medal thats less than iri
        if(GetPlayerBestMedal(player_index, i, true) < OUTERWALL_MEDAL_IRI)
        {
            return;
        }
    }

    DisplayAchievementMessage(eAchievements.EncoreIri, player_index);
}

//todo: AllGold

//todo: AllIri