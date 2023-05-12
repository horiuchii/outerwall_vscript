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

::UnlockPlayerAchievement <- function(achievement_index, client_index)
{
    //foreach client on the server, display message
    local client = PlayerInstanceFromIndex(client_index);
    local playername = NetProps.GetPropString(client, "m_szNetname");

    if(!!PlayerAchievements[client_index][achievement_index])
        return;

    PlayerAchievements[client_index][achievement_index] = 1;
    client.EmitSound("Achievement.Earned");
    DispatchParticleEffect("achieved", client.GetOrigin() + Vector(0,0,84), Vector(0,90,0));
    PlayerSaveGame(client);

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
    CheckAchievement_AllGold(player_index);
    CheckAchievement_AllIri(player_index);
}

::CheckAchievementBatch_PostRun <- function(player_index)
{
    CheckAchievement_NormalInnerWallNoBoost(player_index);
    CheckAchievement_NormalHellNoDmg(player_index);
    CheckAchievement_NormalPurpleCoinNoRadar(player_index);
    CheckAchievement_EncoreUnlock(player_index);
    CheckAchievement_EncoreOsideNoDmg(player_index);
    CheckAchievement_EncoreBalconyClock(player_index);
    CheckAchievement_EncoreHellTime(player_index);
    CheckAchievement_EncorePurpleCoinNoRadar(player_index);
    CheckAchievement_EncoreManyLapsRun(player_index);
    CheckAchievement_EncoreFinish(player_index);
}

::CheckAchievement_HitAlot <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.HurtAlot])
        return;

    if((PlayerSpikeHits[player_index] + PlayerLavaHits[player_index]) >= 5000)
        UnlockPlayerAchievement(eAchievements.HurtAlot, player_index);
}

::CheckAchievement_NormalInnerWallNoBoost <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalInnerWallNoBoost])
        return;

    if(!PlayerUseInnerWallBoosterDuringRun[player_index] && PlayerZoneList[player_index] == 3 && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalInnerWallNoBoost, player_index);
}

::CheckAchievement_NormalHellNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalHellNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 4 && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalHellNoDmg, player_index);
}

::CheckAchievement_NormalPurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.NormalPurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalPurpleCoinNoRadar, player_index);
}

::AwardAchievement_SecretClimb <- function()
{
    local player_index = activator.GetEntityIndex();

    if(!!PlayerAchievements[player_index][eAchievements.SecretClimb])
        return;

    if(PlayerCheatedCurrentRun[player_index])
        return;

    UnlockPlayerAchievement(eAchievements.SecretClimb, player_index);
}

::CheckAchievement_EncoreUnlock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreUnlock])
        return;

    if(IsPlayerEncorable(player_index))
        UnlockPlayerAchievement(eAchievements.EncoreUnlock, player_index);
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

    UnlockPlayerAchievement(eAchievements.NormalGold, player_index);
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

    UnlockPlayerAchievement(eAchievements.NormalIri, player_index);
}

::CheckAchievement_LapsAlot <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.LapsAlot])
        return;

    if(PlayerLapsRan[player_index] >= 100)
        UnlockPlayerAchievement(eAchievements.LapsAlot, player_index);
}

::CheckAchievement_EncoreOsideNoDmg <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreOsideNoDmg])
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == 0 && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreOsideNoDmg, player_index);
}

::CheckAchievement_EncoreBalconyClock <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreBalconyClock])
        return;

    if(PlayerClocksCollectedDuringRun[player_index] <= 4 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreBalconyClock, player_index);
}

::CheckAchievement_EncoreHellTime <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreHellTime])
        return;

    if(PlayerTimeTrialTime[player_index] >= 200 && PlayerZoneList[player_index] == 2 && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreHellTime, player_index);
}

::CheckAchievement_EncorePurpleCoinNoRadar <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncorePurpleCoinNoRadar])
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == 6 && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncorePurpleCoinNoRadar, player_index);
}

::CheckAchievement_EncoreManyLapsRun <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreManyLaps])
        return;

    if(!!PlayerEncoreStatus[player_index] && PlayerCurrentLapCount[player_index] >= 10)
        UnlockPlayerAchievement(eAchievements.EncoreManyLaps, player_index);
}

::CheckAchievement_EncoreFinish <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.EncoreFinish])
        return;

    for (local i = 0; i < ZONE_COUNT_ENCORE; i++)
	{
		// no medal exists
		if(GetPlayerBestMedal(player_index, i, true) == -1)
		{
			return;
		}
	}

    UnlockPlayerAchievement(eAchievements.EncoreFinish, player_index);
}

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

    UnlockPlayerAchievement(eAchievements.EncoreGold, player_index);
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

    UnlockPlayerAchievement(eAchievements.EncoreIri, player_index);
}

::CheckAchievement_AllGold <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.AllGold])
        return;

    if(!!!PlayerAchievements[player_index][eAchievements.NormalGold] || !!!PlayerAchievements[player_index][eAchievements.EncoreGold])
        return;

    UnlockPlayerAchievement(eAchievements.AllGold, player_index);
}

::CheckAchievement_AllIri <- function(player_index)
{
    if(!!PlayerAchievements[player_index][eAchievements.AllIri])
        return;

    if(!!!PlayerAchievements[player_index][eAchievements.NormalIri] || !!!PlayerAchievements[player_index][eAchievements.EncoreIri])
        return;

    UnlockPlayerAchievement(eAchievements.AllIri, player_index);
}