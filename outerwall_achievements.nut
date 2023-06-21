::PlayerUseInnerWallBoosterDuringRun <- array(MAX_PLAYERS, 0)
::PlayerDamagedDuringRun <- array(MAX_PLAYERS, false)
::PlayerClocksCollectedDuringRun <- array(MAX_PLAYERS, 0)
::PlayerUseRadarDuringRun <- array(MAX_PLAYERS, false)
::PlayerTouchedForbiddenZoneDuringRun <- array(MAX_PLAYERS, false)
::PlayerDoubleJumpDuringRun <- array(MAX_PLAYERS, false)
::PlayerSmokeyProgress <- array(MAX_PLAYERS, 0)

::ResetPlayerAchievementArrays <- function(player_index)
{
    PlayerUseInnerWallBoosterDuringRun[player_index] = 0;
    PlayerDamagedDuringRun[player_index] = false;
    PlayerClocksCollectedDuringRun[player_index] = 0;
    PlayerUseRadarDuringRun[player_index] = false;
    PlayerTouchedForbiddenZoneDuringRun[player_index] = false;
    PlayerDoubleJumpDuringRun[player_index] = false;
}

::PlayerTouchForbiddenZone <- function()
{
    PlayerTouchedForbiddenZoneDuringRun[activator.GetEntityIndex()] = true;
}

::PlayerTouchSmokeyZone <- function()
{
    local player_index = activator.GetEntityIndex();

    if(HasAchievement(eAchievements.SecretSmokey, player_index) || PlayerCheatedCurrentRun[player_index])
    {
        DebugPrint("SmokeyTrigger Returned Early State 1: Already own Achievement or Cheated");
        return;
    }

    local iZone = PlayerZoneList[player_index];

    if(iZone == null)
    {
        DebugPrint("SmokeyTrigger Returned Early State 2: Null Zone");
        return;
    }

    local iSmokeyFlag = SMOKEY_TRIGGER_ZONES[iZone];
    DebugPrint("SmokeyTrigger Player " + player_index + " tried to collect flag " + iSmokeyFlag);

    if(PlayerSmokeyProgress[player_index] & iSmokeyFlag)
    {
        DebugPrint("SmokeyTrigger Returned Early State 3: Already have zone " + iZone + "'s progress");
        return;
    }

    PlayerSmokeyProgress[player_index] += iSmokeyFlag;
    DebugPrint("SmokeyTrigger Added flag " + PlayerSmokeyProgress[player_index] + " to player " + player_index + "'s progress");

    if(PlayerSmokeyProgress[player_index] == SMOKEY_TRIGGER_ALL)
        UnlockPlayerAchievement(eAchievements.SecretSmokey, player_index);
}

::DebugUnlockAllAchievements <- function(player_index)
{
    for (local i = 0; i < eAchievements.MAX; i++)
    {
        UnlockPlayerAchievement(i, player_index, true);
    }
    PlayerSaveGame(PlayerInstanceFromIndex(player_index));
}

::UnlockPlayerAchievement <- function(achievement_index, client_index, bHidden = false)
{
    //foreach client on the server, display message
    local client = PlayerInstanceFromIndex(client_index);
    local playername = NetProps.GetPropString(client, "m_szNetname");

    if(HasAchievement(achievement_index, client_index))
        return;

    PlayerAchievements[client_index][achievement_index] = FormatAchievementDataTime();

    if(!bHidden)
    {
        client.EmitSound("Achievement.Earned");
        DispatchParticleEffect("achieved", client.GetOrigin() + Vector(0,0,84), Vector(0,90,0));
        PlayerSaveGame(client);
    }

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
    // CheckAchievement_EncoreAllGold(player_index);
    // CheckAchievement_EncoreAllIri(player_index);
    // CheckAchievement_AllGold(player_index);
    // CheckAchievement_AllIri(player_index);
}

::CheckAchievementBatch_PostRun <- function(player_index)
{
    CheckAchievement_RunsAlot(player_index);
    CheckAchievement_NormalOuterWallNoParkour(player_index);
    CheckAchievement_NormalInnerWallNoBoost(player_index);
    CheckAchievement_NormalHellNoDmg(player_index);
    CheckAchievement_NormalWindFortressNoDoubleJumpNoDmg(player_index);
    CheckAchievement_NormalPurpleCoinNoRadar(player_index);
    CheckAchievement_EncoreUnlock(player_index);
    // CheckAchievement_EncoreOsideNoDmg(player_index);
    // CheckAchievement_EncoreBalconyClock(player_index);
    // CheckAchievement_EncoreHellTime(player_index);
    // CheckAchievement_EncorePurpleCoinNoRadar(player_index);
    // CheckAchievement_EncoreFinish(player_index);
}

::CheckAchievement_HitAlot <- function(player_index)
{
    if(HasAchievement(eAchievements.HurtAlot, player_index))
        return;

    if(PlayerTimesHurt[player_index] >= 5000)
        UnlockPlayerAchievement(eAchievements.HurtAlot, player_index);
}

::CheckAchievement_RunsAlot <- function(player_index)
{
    if(HasAchievement(eAchievements.RunsAlot, player_index))
        return;

    if(PlayerRunsRan[player_index] >= 100)
        UnlockPlayerAchievement(eAchievements.RunsAlot, player_index);
}

::CheckAchievement_NormalOuterWallNoParkour <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalOuterWallNoParkour, player_index))
        return;

    if(!PlayerTouchedForbiddenZoneDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.OuterWall && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalOuterWallNoParkour, player_index);
}

::CheckAchievement_NormalInnerWallNoBoost <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalInnerWallNoBoost, player_index))
        return;

    if(PlayerUseInnerWallBoosterDuringRun[player_index] <= 3 && PlayerZoneList[player_index] == eCourses.InnerWall && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalInnerWallNoBoost, player_index);
}

::CheckAchievement_NormalHellNoDmg <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalHellNoDmg, player_index))
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.Hell && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalHellNoDmg, player_index);
}

::CheckAchievement_NormalWindFortressNoDoubleJumpNoDmg <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalWindFortressNoDoubleJumpDmg, player_index))
        return;

    if(!PlayerDamagedDuringRun[player_index] && !PlayerDoubleJumpDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.WindFortress && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalWindFortressNoDoubleJumpDmg, player_index);
}

::CheckAchievement_NormalPurpleCoinNoRadar <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalPurpleCoinNoRadar, player_index))
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.SandPit && !!!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.NormalPurpleCoinNoRadar, player_index);
}

::AwardAchievement_SecretClimb <- function()
{
    local player_index = activator.GetEntityIndex();

    if(HasAchievement(eAchievements.SecretClimb, player_index))
        return;

    if(PlayerCheatedCurrentRun[player_index])
        return;

    UnlockPlayerAchievement(eAchievements.SecretClimb, player_index);
}

::CheckAchievement_EncoreUnlock <- function(player_index)
{
    if(HasAchievement(eAchievements.EncoreUnlock, player_index))
        return;

    if(IsPlayerEncorable(player_index))
    {
        UnlockPlayerAchievement(eAchievements.EncoreUnlock, player_index);
        //TODO: REENABLE FOR ENCORE UPDATE
        //ClientPrint(PlayerInstanceFromIndex(player_index), HUD_PRINTTALK, "\x01" + "\x07FFD700" + TranslateString(OUTERWALL_ENCORE_UNLOCK, player_index));
    }
}

::CheckAchievement_NormalAllGold <- function(player_index)
{
    if(HasAchievement(eAchievements.NormalGold, player_index))
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
    if(HasAchievement(eAchievements.NormalIri, player_index))
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
/*
::CheckAchievement_LapsAlot <- function(player_index)
{
    if(HasAchievement(eAchievements.LapsAlot, player_index))
        return;

    if(PlayerLapsRan[player_index] >= 100)
        UnlockPlayerAchievement(eAchievements.LapsAlot, player_index);
}

::CheckAchievement_EncoreOsideNoDmg <- function(player_index)
{
    if(HasAchievement(eAchievements.EncoreOsideNoDmg, player_index))
        return;

    if(!PlayerDamagedDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.OuterWall && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreOsideNoDmg, player_index);
}

::CheckAchievement_EncoreBalconyClock <- function(player_index)
{
    if(HasAchievement(eAchievements.EncoreBalconyClock, player_index))
        return;

    if(PlayerClocksCollectedDuringRun[player_index] <= 4 && PlayerZoneList[player_index] == eCourses.Balcony && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreBalconyClock, player_index);
}

::CheckAchievement_EncoreHellTime <- function(player_index)
{
    if(HasAchievement(eAchievements.EncoreHellTime, player_index))
        return;

    if(PlayerTimeTrialTime[player_index] >= 200 && PlayerZoneList[player_index] == eCourses.Hell && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncoreHellTime, player_index);
}

::CheckAchievement_EncorePurpleCoinNoRadar <- function(player_index)
{
    if(HasAchievement(eAchievements.EncorePurpleCoinNoRadar, player_index))
        return;

    if(!PlayerUseRadarDuringRun[player_index] && PlayerZoneList[player_index] == eCourses.SandPit && !!PlayerEncoreStatus[player_index])
        UnlockPlayerAchievement(eAchievements.EncorePurpleCoinNoRadar, player_index);
}

::CheckAchievement_EncoreFinish <- function(player_index)
{
    if(HasAchievement(eAchievements.EncoreFinish, player_index))
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
    if(HasAchievement(eAchievements.EncoreGold, player_index))
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
    if(HasAchievement(eAchievements.EncoreIri, player_index))
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
    if(HasAchievement(eAchievements.AllGold, player_index))
        return;

    if(!HasAchievement(eAchievements.NormalGold, player_index) || !HasAchievement(eAchievements.EncoreGold, player_index))
        return;

    UnlockPlayerAchievement(eAchievements.AllGold, player_index);
}

::CheckAchievement_AllIri <- function(player_index)
{
    if(HasAchievement(eAchievements.AllIri, player_index))
        return;

    if(!HasAchievement(eAchievements.NormalIri, player_index) || !HasAchievement(eAchievements.EncoreIri, player_index))
        return;

    UnlockPlayerAchievement(eAchievements.AllIri, player_index);
}
*/