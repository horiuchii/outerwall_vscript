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
::IN_ATTACK3 <- Constants.FButtons.IN_ATTACK3
::TF_CLASS_SCOUT <- Constants.ETFClass.TF_CLASS_SCOUT
::FL_ONGROUND <- Constants.FPlayer.FL_ONGROUND

const BUTTON_MOUSE1 = 1
const BUTTON_MOUSE2 = 2
const BUTTON_MOUSE3 = 3

::DEBUG_OUTPUT <- true

::OUTERWALL_SKYCAMERA_LOCATION <- Vector(1024, -5120, 140)
::OUTERWALL_SKYCAMERA_OFFSET <- Vector(0, 0, 340)
::OUTERWALL_SKYCAMERA_LOCATION_TIER1LAPPING <- OUTERWALL_SKYCAMERA_LOCATION + OUTERWALL_SKYCAMERA_OFFSET
::OUTERWALL_SKYCAMERA_LOCATION_TIER2LAPPING <- OUTERWALL_SKYCAMERA_LOCATION + (OUTERWALL_SKYCAMERA_OFFSET * 2)

const OUTERWALL_MEDAL_BRONZE = 0
const OUTERWALL_MEDAL_SILVER = 1
const OUTERWALL_MEDAL_GOLD = 2
const OUTERWALL_MEDAL_IRI = 3

const MAT_MENU_MEDALTIMES = "outerwall/hud/hud_menu1.vmt"
const MAT_MENU_SETTINGS = "outerwall/hud/hud_menu2.vmt"

const MAT_ENCOREHUD = "outerwall/hud/hud_encore.vmt"
const MAT_ENCOREHUD_RADAR = "outerwall/hud/hud_encore_radar.vmt"
const MAT_ENCOREHUD_MENU_MEDALTIMES_ENCORE = "outerwall/hud/hud_encore_menu1.vmt"
const MAT_ENCOREHUD_MENU_SETTINGS_ENCORE = "outerwall/hud/hud_encore_menu2.vmt"
const MAT_ENCOREHUD_ACTIVE_TIMELERPING = "outerwall/hud/hud_encore_timelerping.vmt"
const MAT_ENCOREHUD_ACTIVE_TIMELERPING_LAPUP = "outerwall/hud/hud_encore_timelerping_lapup.vmt"

const MAT_ENCOREHUD_ACTIVE_NOMEDAL_RADAR = "outerwall/hud/hud_encore_active_radar.vmt"
const MAT_ENCOREHUD_ACTIVE_NOMEDAL = "outerwall/hud/hud_encore_active.vmt"
const MAT_ENCOREHUD_ACTIVE_BRONZE = "outerwall/hud/hud_encore_active_bronze.vmt"
const MAT_ENCOREHUD_ACTIVE_SILVER = "outerwall/hud/hud_encore_active_silver.vmt"
const MAT_ENCOREHUD_ACTIVE_GOLD = "outerwall/hud/hud_encore_active_gold.vmt"
const MAT_ENCOREHUD_ACTIVE_IRI = "outerwall/hud/hud_encore_active_iri.vmt"

const TIMER_PLAYERHUDTEXT = "outerwall_timer_gametext_"
const BONUS_PLAYERHUDTEXT = "outerwall_bonus_gametext_"
const ENCORE_PLAYERHUDTEXT = "outerwall_encore_gametext_"

const OUTERWALL_SAVEPATH = "pf_outerwall/"
const OUTERWALL_SAVETYPE = ".sav"
const OUTERWALL_SAVELEADERBOARDSUFFIX = "_leaderboarddata"
const OUTERWALL_SAVELEADERBOARD = "leaderboard_entries"

::OUTERWALL_SERVERPATH <- "pf_outerwall/server/"
::OUTERWALL_SERVER_LANGUAGEOVERRIDE_ENABLE <- "language_override_enable"
::OUTERWALL_SERVER_LANGUAGEOVERRIDE <- "language_override.nut"

const OUTERWALL_MAPNAME = "pf_outerwall_"

enum eCourses{
	OuterWall
	LastCave
	Balcony
	InnerWall
	Hell
	WindFortress
	SandPit
}

enum eAchievements{
	HurtAlot
	//NormalOuterWallNoParkour
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
	Profile
	Achievement
	Cosmetic
	ResetProfile
	Leaderboard
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

enum eCosmetics{
	None
	Booster
	PurpleCoin
	MachTrail
	RainbowTrail
	RaveStory
	WhimsicalStar
}

::Cosmetic_Requirement <-
[
	eAchievements.NormalInnerWallNoBoost //booster spritetrail
    eAchievements.NormalPurpleCoinNoRadar //purple shine
	eAchievements.EncoreUnlock //mach trail
	eAchievements.EncoreOsideNoDmg //rainbow trail
    eAchievements.EncoreBalconyClock //rave story
	eAchievements.AllGold //whimsical star
]

::ResetProfile_Answers <-
[
	BUTTON_MOUSE1
	BUTTON_MOUSE1
	BUTTON_MOUSE2
	BUTTON_MOUSE1
	BUTTON_MOUSE1
	BUTTON_MOUSE2
	BUTTON_MOUSE1
	BUTTON_MOUSE1
]