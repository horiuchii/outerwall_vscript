::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT)) // make sure folding is only done once
{
	foreach (a,b in Constants)
		foreach (k,v in b)
			if (v == null)
				ROOT[k] <- 0;
			else
				ROOT[k] <- v;
}

foreach (k, v in getclass())
    if (k != "IsValid")
		ROOT[k] <- NetProps[k].bindenv(NetProps);

const BUTTON_MOUSE1 = 1
const BUTTON_MOUSE2 = 2
const BUTTON_RELOAD = 3

::DEBUG_OUTPUT <- !IsDedicatedServer()

::OUTERWALL_SKYCAMERA_LOCATION <- Vector(1024, -5120, 140)
::OUTERWALL_SKYCAMERA_LOCATION_INNERWALL_HELL <- Vector(1568, 0, 0) + OUTERWALL_SKYCAMERA_LOCATION
::OUTERWALL_SKYCAMERA_LOCATION_WINDFORTRESS_SANDPIT <- Vector(784, 0, 0) + OUTERWALL_SKYCAMERA_LOCATION
::OUTERWALL_SKYCAMERA_OFFSET_LAPPING <- Vector(0, 0, 340)

const OUTERWALL_MEDAL_BRONZE = 0
const OUTERWALL_MEDAL_SILVER = 1
const OUTERWALL_MEDAL_GOLD = 2
const OUTERWALL_MEDAL_IRI = 3

::SMOKEY_TRIGGER_ZONES <- [
	1 //outerwall
	2 //lastcave
	4 //balcony
	8 //innerwall
	16 //hell
	32 //windfortress
	64 //sandpit
]

const SMOKEY_TRIGGER_ALL = 127

const MAT_MENU_MEDALTIMES = "outerwall/hud/hud_menu1.vmt"
//const MAT_MENU_SETTINGS = "outerwall/hud/hud_menu2.vmt"
const MAT_MENU_SETTINGS_LONGER = "outerwall/hud/hud_menu3.vmt"

const MAT_ENCOREHUD = "outerwall/hud/hud_encore.vmt"
const MAT_ENCOREHUD_RADAR = "outerwall/hud/hud_encore_radar.vmt"
const MAT_ENCOREHUD_MENU_MEDALTIMES_ENCORE = "outerwall/hud/hud_encore_menu1.vmt"
const MAT_ENCOREHUD_MENU_SETTINGS_ENCORE = "outerwall/hud/hud_encore_menu2.vmt"
const MAT_ENCOREHUD_MENU_SETTINGS_LONGER_ENCORE = "outerwall/hud/hud_encore_menu3.vmt"
const MAT_ENCOREHUD_ACTIVE_TIMELERPING = "outerwall/hud/hud_encore_timelerping.vmt"
const MAT_ENCOREHUD_ACTIVE_TIMELERPING_LAPUP = "outerwall/hud/hud_encore_timelerping_lapup.vmt"

const MAT_ENCOREHUD_ACTIVE_NOMEDAL_RADAR = "outerwall/hud/hud_encore_active_radar.vmt"
const MAT_ENCOREHUD_ACTIVE_NOMEDAL = "outerwall/hud/hud_encore_active.vmt"
const MAT_ENCOREHUD_ACTIVE_BRONZE = "outerwall/hud/hud_encore_active_bronze.vmt"
const MAT_ENCOREHUD_ACTIVE_SILVER = "outerwall/hud/hud_encore_active_silver.vmt"
const MAT_ENCOREHUD_ACTIVE_GOLD = "outerwall/hud/hud_encore_active_gold.vmt"
const MAT_ENCOREHUD_ACTIVE_IRI = "outerwall/hud/hud_encore_active_iri.vmt"

//stupid fucking const isnt registred fast enough???? having this const throws an exception on map start, SHUT THE FUCK UP
::TIMER_PLAYERHUDTEXT <- "outerwall_timer_gametext_"
::BONUS_PLAYERHUDTEXT <- "outerwall_bonus_gametext_"
::ENCORE_PLAYERHUDTEXT <- "outerwall_encore_gametext_"

const OUTERWALL_SAVEPATH = "pf_outerwall/"
const OUTERWALL_SAVETYPE = ".sav"
const OUTERWALL_SAVELEADERBOARDSUFFIX = "_leaderboarddata"
const OUTERWALL_SAVELEADERBOARD = "leaderboard_entries"
const OUTERWALL_SAVEWORLDRECORD = "world_records"

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
	RunsAlot
	NormalOuterWallNoParkour
	NormalInnerWallNoBoost
	NormalKazeNoDmg
	SecretSmokey
	SecretClimb
	EncoreUnlock
	NormalGold
	NormalIri
	// LapsAlot
	// EncoreOsideNoDmg
	// EncoreBalconyClock
	// EncoreHellTime
	// EncoreFinish
	// EncoreGold
	// EncoreIri
	// AllGold
	// AllIri
	MAX
}

enum eMultiSettings{
	DisplayTime
	DisplayCheckpoint
	PlayCharSound
	Soundtrack
	Encore
	MAX
}

enum eSettingQuerys{
	MultiSetting
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

enum eCosmetics{
	None
	Booster
	PurpleCoin
	Victory
	MachTrail
	RainbowTrail
	// 	RaveStory
	// 	WhimsicalStar
	MAX
}

::Cosmetic_Requirement <-
[
	eAchievements.NormalInnerWallNoBoost //booster spritetrail
    eAchievements.NormalKazeNoDmg //purple shine
	eAchievements.EncoreUnlock //victory
	eAchievements.NormalGold //mach trail
	eAchievements.NormalIri //rainbow trail
    // eAchievements.EncoreBalconyClock //rave story
	// eAchievements.AllGold //whimsical star
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

::Soundtracks <-
[
	".Remastered",
	".Ridiculon",
	".Organya",
	".Plus"
	".Remixed",
	".Keromix"
]

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
	"Meltdown" //8
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
	"mdown2"
]

::SoundtrackAuthors <-
[
	"Danny Baranowsky"
	"Matthias Bossi & Jon Evans"
	"Daisuke Amaya (Pixel)"
	"Yann van der Cruyssen"
	"iFlicky & Cornetto"
	"Daisuke Amaya (Pixel)"
]

::ScoutVO_Medal <-
[
	"cm_scout_gamewon_01"
	"cm_scout_gamewon_02"
	"cm_scout_gamewon_03"
	"cm_scout_gamewon_04"
	"cm_scout_gamewon_05"
	"cm_scout_gamewon_06"
	"cm_scout_gamewon_07"
	"cm_scout_gamewon_09"
	"cm_scout_gamewon_10"
	"cm_scout_gamewon_11"
	"cm_scout_gamewon_12"
	"cm_scout_gamewon_13"
	"cm_scout_gamewon_14"
	"cm_scout_gamewon_15"
	"cm_scout_matchwon_01"
	"cm_scout_matchwon_03"
	"cm_scout_matchwon_04"
	"cm_scout_matchwon_09"
	"Scout.PositiveVocalization01"
	"Scout.PositiveVocalization02"
	"Scout.PositiveVocalization03"
	"Scout.PositiveVocalization04"
	"Scout.PositiveVocalization05"
	"scout_mvm_loot_rare02"
	"scout_mvm_loot_rare03"
	"scout_mvm_loot_rare05"
	"scout_sf12_goodmagic03"
	"scout_sf12_goodmagic04"
]

::ScoutVO_MedalNone <-
[
	"Scout.Jeers04"
	"Scout.Jeers09"
	"Scout.Jeers10"
	"cm_scout_pregamelostlast_03"
	"Scout.AutoDejectedTie01"
	"Scout.AutoDejectedTie02"
	"Scout.AutoDejectedTie03"
	"scout_sf13_magic_reac03"
]

::ScoutVO_MedalIri <-
[
	"scout_mvm_loot_rare07"
	"scout_mvm_loot_rare08"
	"scout_mvm_loot_godlike01"
	"scout_mvm_loot_godlike02"
	"scout_sf12_goodmagic05"
	"cm_scout_gamewon_rare_02"
	"cm_scout_pregamewonlast_rare_04"
]

::ScoutVO_Achievement <-
[
	"Scout.Award01"
	"Scout.Award02"
	"Scout.Award03"
	"Scout.Award04"
	"Scout.Award05"
	"Scout.Award07"
	"Scout.Award08"
	"Scout.Award09"
	"Scout.Award10"
	"Scout.Award11"
	"Scout.Award12"
]

::ScoutVO_CosmeticEquip <-
[
	"scout_mvm_loot_common01"
	"scout_mvm_loot_common02"
	"scout_mvm_loot_common03"
	"scout_mvm_loot_common04"
	"scout_mvm_loot_common05"
	"scout_mvm_loot_common06"
]

::ScoutVO_JumpPad <-
[
	"Scout.TripleJump01"
	"Scout.TripleJump02"
	"Scout.TripleJump03"
	"Scout.TripleJump04"
]

::ScoutVO_Respawn <-
[
	"scout_mvm_resurrect01"
	"scout_mvm_resurrect02"
	"scout_mvm_resurrect03"
	"scout_mvm_resurrect04"
	"scout_mvm_resurrect05"
	"scout_mvm_resurrect06"
	"scout_mvm_resurrect07"
	"scout_mvm_resurrect08"
]

::ScoutVO_LavaTouch <-
[
	"Scout.AutoOnFire01"
	"Scout.AutoOnFire02"
]