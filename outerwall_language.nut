::PlayerLanguage <- array(MAX_PLAYERS, 0)

::TranslateString <- function(message, player_index = null)
{
	if(type(message) != "array")
		return "[ERROR:1]"

	if(message.len() != Languages.len())
		return "[ERROR:2]";

	if(player_index)
		return message[PlayerLanguage[player_index]];

	return message[0];
}

::Languages <- [
	"english"
	"spanish"
]

::LanguagesPoorWarning <- [
	"spanish"
]

::RESET_PROFILE_TITLE <- [
	"Reset Profile"
	"Reset Profile"
]
::RESET_PROFILE_QUESTIONS <- [
	::QUESTION_1 <- [
		"You got some business with me?\n\n"
		"You got some business with me?\n\n"
	]
	::QUESTION_2 <- [
		"Well, then.\nDo you want to reset your save?\n"
		"Well, then.\nDo you want to reset your save?\n"
	]
	::QUESTION_3 <- [
		"But in reality, you don't\nreally want to, right?\n"
		"But in reality, you don't\nreally want to, right?\n"
	]
	::QUESTION_4 <- [
		"You really want to that much?\n\n"
		"You really want to that much?\n\n"
	]
	::QUESTION_5 <- [
		"You want to absolutely positively\nreset your save no matter what?\n"
		"You want to absolutely positively\nreset your save no matter what?\n"
	]
	::QUESTION_6 <- [
		"But really you don't want to, right?\n\n"
		"But really you don't want to, right?\n\n"
	]
	::QUESTION_7 <- [
		"Are you absolutely sure you're sure?\nSave data doesn't grow like\nred flowers, you know!"
		"Are you absolutely sure you're sure?\nSave data doesn't grow like\nred flowers, you know!"
	]
	::QUESTION_8 <- [
		"Pressing yes will irreversably\ndelete all your save data!\nThis is your final warning!"
		"Pressing yes will irreversably\ndelete all your save data!\nThis is your final warning!"
	]
]
::RESET_PROFILE_NORESET <- [
	"Then scram!"
	"Then scram!"
]
::RESET_PROFILE_RESET <- [
	"The deed has been done."
	"The deed has been done."
]

::SETTING_OPTION <- [
	::SETTING_OFF <- [
		"OFF"
		"APAGADA"
	]
	::SETTING_ON <- [
		"ON"
		"ENCENDIDA"
	]
]
::SETTING_BUTTON_ATTACK <- [
	"[ATTACK] "
	"[ATTACK] "
]
::SETTING_BUTTON_ALTATTACK <- [
	"[ALT-ATTACK] "
	"[ALT-ATTACK] "
]
::SETTING_BUTTON_RELOAD <- [
	"[RELOAD] "
	"[RELOAD] "
]
::SETTING_TOGGLE <- [
	"Toggle"
	"Toggle"
]
::SETTING_ENCORE_NOQUALIFY <- [
	"[LOCKED] Requires a rank on each course"
	"[LOCKED] Requires a rank on each course"
]
::SETTING_NEXTPAGE <- [
	"Next"
	"Next"
]
::SETTING_PREVPAGE <- [
	"Previous"
	"Previous"
]
::SETTING_RETURN <- [
	"Return"
	"Return"
]
::SETTING_EDIT <- [
	"Edit"
	"Edit"
]
::SETTING_EDITSTOP <- [
	"Stop Editing"
	"Stop Editing"
]
::SETTING_EDITCOLOR <- [
	"Edit Color %i"
	"Edit Color %i"
]
::SETTING_EQUIP <- [
	"Equip"
	"Equip"
]
::SETTING_UNEQUIP <- [
	"Unequip"
	"Unequip"
]
::COSMETIC_REQUIREMENT <- [
	"[LOCKED] REQ: [%s]"
	"[LOCKED] REQ: [%s]"
]
::SETTING_COMINGSOON<- [
	"[LOCKED] Coming Soon!"
	"[LOCKED] Coming Soon!"
]
::SETTING_YES <- [
	"Yes"
	"Yes"
]
::SETTING_NO <- [
	"No"
	"No"
]
::SETTING_ENCORETUTORIAL <- [
	"Tutorial"
	"Tutorial"
]
::SETTING_REFRESHLEADERBOARD <- [
	"Refresh"
	"Refresh"
]
::LEADERBOARD_BUTTON_REFRESHWAIT <- [
	"[LOCKED] Refresh (Cooldown %s)"
	"[LOCKED] Refresh (Cooldown %s)"
]
::SETTING_CURRENT <- [
	"Current Setting: "
	"Current Setting: "
]
::LEADERBOARD_NOENTRIES <- [
	"[NO ENTRIES]"
	"[NO ENTRIES]"
]

::MULTISETTING_TITLE <- [
	"Settings"
	"Settings"
]
::MULTISETTING_NAME <- [
	::SETTING_FINALTIME_NAME <- [
		"Final Time"
		"Final Time"
	]
	::SETTING_CHECKPOINTTIME_NAME <- [
		"Checkpoint Time"
		"Checkpoint Time"
	]
	::SETTING_PLAYCHARSOUND_NAME <- [
		"Jump & Land Sound"
		"Jump & Land Sound"
	]
	::SETTING_SOUNDTRACK_NAME <- [
		"Soundtrack"
		"Soundtrack"
	]
	::SETTING_ENCORE_NAME <- [
		"Encore Mode"
		"Encore Mode"
	]
]
::MULTISETTING_DESC <- [
	::SETTING_FINALTIME_DESC <- [
		"Shows a run's final time\nwhen completing one."
		"Shows a run's final time\nwhen completing one."
	]
	::SETTING_CHECKPOINTTIME_DESC <- [
		"Display's your checkpoint time\nwhen you reach one."
		"Display's your checkpoint time\nwhen you reach one."
	]
	::SETTING_PLAYCHARSOUND_DESC <- [
		"Plays a special sound\nwhen jumping & landing."
		"Plays a special sound\nwhen jumping & landing."
	]
	::SETTING_SOUNDTRACK_DESC <- [
		"The soundtrack variant that\nis currently playing."
		"The soundtrack variant that\nis currently playing."
	]
	::SETTING_ENCORE_DESC <- [
		"Encore Mode remixes every course into\na time trial! Not for the feint of heart!"
		"Encore Mode remixes every course into\na time trial! Not for the feint of heart!"
	]
]
::SETTING_CHECKPOINTTIME_OPTION <- [
	BONUS <- [
		"BONUSES ONLY"
		"BONUSES ONLY"
	]
	ALWAYS <- [
		"ALL COURSES"
		"ALL COURSES"
	]
	NEVER <- [
		"NEVER"
		"NEVER"
	]
]
::SETTING_FINALTIME_OPTION <- [
	ENCORE <- [
		"ENCORE ONLY"
		"ENCORE ONLY"
	]
	ALWAYS <- [
		"ALWAYS"
		"ALWAYS"
	]
	NEVER <- [
		"NEVER"
		"NEVER"
	]
]
::SETTING_SOUNDTRACK_OPTION <- [
	::REMASTERED <- [
		"REMASTERED (2011)"
		"REMASTERED (2011)"
	]
	::RIDICULON <- [
		"RIDICULON (2017)"
		"RIDICULON (2017)"
	]
	::ORGANYA <- [
		"ORGANYA (2004)"
		"ORGANYA (2004)"
	]
	::PLUS <- [
		"PLUS (2010)"
		"PLUS (2010)"
	]
	::REMIXED <- [
	 	"REMIXED (2023)"
	 	"REMIXED (2023)"
	]
	::KEROMIX <- [
		"KERO-MIX (2015)"
		"KERO-MIX (2015)"
	]
]

::SOUNDTRACK_AUTHOR <- [
	"Author: "
	"Author: "
]

::LEADERBOARD_TITLE <- [
	"Leaderboard"
	"Leaderboard"
]
::LEADERBOARD_PAGE <- [
	"Page "
	"Page "
]
::LEADERBOARD_RANK <- [
	"Your Rank: "
	"Your Rank: "
]

::ACHIEVEMENT_TITLE <- [
	"Achievements"
	"Achievements"
]
::ACHIEVEMENT_UNLOCKDATE <- [
	" Achieved: "
	" Achieved: "
]
::ACHIEVEMENT_NAME <- [
	::ACHIEVEMENT_HURT_ALOT_NAME <- [
		"1001 Spikes"
		"1001 Spikes"
	]
	::ACHIEVEMENT_RUNS_ALOT_NAME <- [
		"Moonside Marathonist"
		"Moonside Marathonist"
	]
	::ACHIEVEMENT_NOPARKOUR_NAME <- [
		"Climber's Clamber"
		"Climber's Clamber"
	]
	::ACHIEVEMENT_INNERWALL_NOBOOSTER_NAME <- [
		"No Booster Required"
		"No Booster Required"
	]
	::ACHIEVEMENT_KAZE_NODMG_NAME <- [
		"All Salt, No Wound"
		"All Salt, No Wound"
	]
	::ACHIEVEMENT_SECRETSMOKEY_NAME <- [
		"Secret Smokester"
		"Secret Smokester"
	]
	::ACHIEVEMENT_SECRETCLIMB_NAME <- [
		"Fuck You, Pyro!"
		"Fuck You, Pyro!"
	]
	::ACHIEVEMENT_ENCORE_UNLOCK_NAME <- [
		"Outer World Tour"
		"Outer World Tour"
	]
	::ACHIEVEMENT_NORMAL_ALLGOLD_NAME <- [
		"Outer Ace"
		"Outer Ace"
	]
	::ACHIEVEMENT_NORMAL_ALLIRI_NAME <- [
		"Outer God"
		"Outer God"
	]
	::ACHIEVEMENT_ENCORE_LAPS_ALOT_NAME <- [
		"Island Collapse Ad Infinitum"
		"Island Collapse Ad Infinitum"
	]
	::ACHIEVEMENT_ENCORE_OSIDE_NODMG_NAME <- [
		"Moonside Madness"
		"Moonside Madness"
	]
	::ACHIEVEMENT_ENCORE_BALCONY_CLOCKPICKUP_NAME <- [
		"Clock Block"
		"Clock Block"
	]
	::ACHIEVEMENT_ENCORE_HELL_TIME_NAME <- [
		"Nikumaru Masta"
		"Nikumaru Masta"
	]
	::ACHIEVEMENT_ENCORE_ALL_NAME <- [
		"Mimiga Death March"
		"Mimiga Death March"
	]
	::ACHIEVEMENT_ENCORE_ALLGOLD_NAME <- [
		"Lapping Hell"
		"Lapping Hell"
	]
	::ACHIEVEMENT_ENCORE_ALLIRI_NAME <- [
		"Hedonistic Lapping"
		"Hedonistic Lapping"
	]
	::ACHIEVEMENT_ALLGOLD_NAME <- [
		"Whimsical Superstar"
		"Whimsical Superstar"
	]
	::ACHIEVEMENT_ALLIRI_NAME <- [
		"End All Be All Of Outer Wall"
		"End All Be All Of Outer Wall"
	]
]
::ACHIEVEMENT_DESC <- [
	::ACHIEVEMENT_HURT_ALOT_DESC <- [
		"Take damage from the\nenvironment 1001 times.\n"
		"Take damage from the\nenvironment 1001 times.\n"
	]
	::ACHIEVEMENT_RUNS_ALOT_DESC <- [
		"Complete 50 Runs.\n\n"
		"Complete 50 Runs.\n\n"
	]
	::ACHIEVEMENT_NOPARKOUR_DESC <- [
	 	"Don't touch any rails, ziplines\nor climbable pipes at the Outer Wall.\n"
	 	"Don't touch any rails, ziplines\nor climbable pipes at the Outer Wall.\n"
	]
	::ACHIEVEMENT_INNERWALL_NOBOOSTER_DESC <- [
		"Don't touch any of the air currents\nmore than 2 times at the Inner Wall.\n"
		"Don't touch any of the air currents\nmore than 2 times at the Inner Wall.\n"
	]
	::ACHIEVEMENT_KAZE_NODMG_DESC <- [
		"Don't take any environment\ndamage at the Wind Fortress.\n"
		"Don't take any environment\ndamage at the Wind Fortress.\n"
	]
	::ACHIEVEMENT_SECRETSMOKEY_DESC <- [
		"Find Smokey.\n\n"
		"Find Smokey.\n\n"
	]
	::ACHIEVEMENT_SECRETCLIMB_DESC <- [
		"Meet the Pyro.\n\n"
		"Meet the Pyro.\n\n"
	]
	::ACHIEVEMENT_ENCORE_UNLOCK_DESC <- [
		"Earn a rank in every course.\n\n"
		"Earn a rank in every course.\n\n"
	]
	// ::ACHIEVEMENT_ENCORE_UNLOCK_DESC <- [
	// 	"Unlock Encore mode by earning a rank in every course.\n\n"
	// 	"Unlock Encore mode by earning a rank in every course.\n\n"
	// ]
	::ACHIEVEMENT_NORMAL_ALLGOLD_DESC <- [
		"Earn an A Rank on each course.\n\n"
		"Earn an A Rank on each course.\n\n"
	]
	::ACHIEVEMENT_NORMAL_ALLIRI_DESC <- [
		"Earn an S Rank on each course.\n\n"
		"Earn an S Rank on each course.\n\n"
	]
	::ACHIEVEMENT_ENCORE_LAPS_ALOT_DESC <- [
		"Complete 100 extra laps.\n"
		"Complete 100 extra laps.\n"
	]
	::ACHIEVEMENT_ENCORE_OSIDE_NODMG_DESC <- [
		"Don't take any environment damage at Encore Outer Wall.\n"
		"Don't take any environment damage at Encore Outer Wall.\n"
	]
	::ACHIEVEMENT_ENCORE_BALCONY_CLOCKPICKUP_DESC <- [
		"Don't collect any more than 4 time clocks in a 3 lap run of Encore Balcony.\n"
		"Don't collect any more than 4 time clocks in a 3 lap run of Encore Balcony.\n"
	]
	::ACHIEVEMENT_ENCORE_HELL_TIME_DESC <- [
		"Finish with atleast 200 or more seconds remaining at Encore Sacred Grounds.\n"
		"Finish with atleast 200 or more seconds remaining at Encore Sacred Grounds.\n"
	]
	::ACHIEVEMENT_ENCORE_ALL_DESC <- [
		"Earn a rank in every Encore course.\n"
		"Earn a rank in every Encore course.\n"
	]
	::ACHIEVEMENT_ENCORE_ALLGOLD_DESC <- [
		"Earn an A Rank in each Encore course.\n"
		"Earn an A Rank in each Encore course.\n"
	]
	::ACHIEVEMENT_ENCORE_ALLIRI_DESC <- [
		"Earn an S Rank in each Encore course.\n"
		"Earn an S Rank in each Encore course.\n"
	]
	::ACHIEVEMENT_ALLGOLD_DESC <- [
		"Earn an A Rank in every Regular and Encore course.\n"
		"Earn an A Rank in every Regular and Encore course.\n"
	]
	::ACHIEVEMENT_ALLIRI_DESC <- [
		"Earn an S Rank in every Regular and Encore course.\n"
		"Earn an S Rank in every Regular and Encore course.\n"
	]
]
::ACHIEVEMENT_ACHIEVED <- [
	" has achieved: "
	" has achieved: "
]

::PROFILE_TITLE <- [
	"Player Profile"
	"Player Profile"
]
::STATS_SUBTITLE_STATS <- [
	"Stats"
	"Stats"
]
::STATS_TIMEPLAYED <- [
	"Time Played: "
	"Time Played: "
]
::STATS_ACHIEVEMENTS <- [
	"Achievements: "
	"Achievements: "
]
::STATS_TIMESHURT <- [
	"Times hurt by environment: "
	"Times hurt by environment: "
]
::STATS_RUNSRAN <- [
	"Completed runs: "
	"Completed runs: "
]
::STATS_LAPSRAN <- [
	"Extra laps ran: "
	"Extra laps ran: "
]
::STATS_TOTALTIME <- [
	"Cumulative regular time: "
	"Cumulative regular time: "
]
::STATS_SUBTITLE_TIMES <- [
	"Times"
	"Times"
]
::STATS_TIMES_MAINSTAGE <- [
	"Main Stage"
	"Main Stage"
]
::STATS_TIMES_BONUS <- [
	"Bonus "
	"Bonus "
]

::COSMETIC_TITLE <- [
	"Cosmetics"
	"Cosmetics"
]
::COSMETIC_EDIT <- [
	" - Edit "
	" - Edit "
]
::COSMETIC_EDIT_COLOR <- [
	"Color %i: "
	"Color %i: "
]
::COSMETIC_EDIT_CURRENT <- [
	" < EDITING"
	" < EDITING"
]
::COSMETIC_EDIT_COLORHOWTO <- [
	"Type color in chat as \"RRR GGG BBB\""
	"Type color in chat as \"RRR GGG BBB\""
]
::COSMETIC_EDIT_COLORHINT <- [
	"Colors as \"000 000 000\" get skipped"
	"Colors as \"000 000 000\" get skipped"
]
::COSMETIC_EDIT_SUCCESS <- [
	"Successfully set color %i to "
	"Successfully set color %i to "
]
::COSMETIC_EDIT_ERROR_CHARCOUNT <- [
	"ERROR: Color contains incorrect number of characters."
	"ERROR: Color contains incorrect number of characters."
]
::COSMETIC_EDIT_ERROR_SPACECOUNT <- [
	"ERROR: Color contains incorrect number of spaces."
	"ERROR: Color contains incorrect number of spaces."
]
::COSMETIC_EDIT_ERROR_COLOR <- [
	"ERROR: Failed to parse color. "
	"ERROR: Failed to parse color. "
]
::COSMETIC_NAME <- [
	::COSMETIC_BOOSTER_NAME <- [
		"Booster Trail"
		"Booster Trail"
	]
	::COSMETIC_PURPLESHINE_NAME <- [
		"Purple Shine"
		"Purple Shine"
	]
	::COSMETIC_VICTORY_NAME <- [
		"Victory Lap"
		"Victory Lap"
	]
	::COSMETIC_MACHTRAIL_NAME <- [
		"Mach Trail"
		"Mach Trail"
	]
	::COSMETIC_RAINBOWTRAIL_NAME <- [
		"Rainbow Trail"
		"Rainbow Trail"
	]
	::COSMETIC_RAVESTORY_NAME <- [
		"Raving Lyrics"
		"Raving Lyrics"
	]
	::COSMETIC_WHIMSICALSTAR_NAME <- [
		"Whimsical Star"
		"Whimsical Star"
	]
]
::COSMETIC_DESC <- [
	::COSMETIC_BOOSTER_DESC <- [
		"This rocket powered jetpack can\ncross any perilous gap you need."
		"This rocket powered jetpack can\ncross any perilous gap you need."
	]
	::COSMETIC_PURPLESHINE_DESC <- [
		"Nobody knows where these cion\ncame from, but they sure are shiny."
		"Nobody knows where these cion\ncame from, but they sure are shiny."
	]
	::COSMETIC_VICTORY_DESC <- [
		"Why only be a winner at the goal when\nyou can be a winner wherever you go!"
		"Why only be a winner at the goal when\nyou can be a winner wherever you go!"
	]
	::COSMETIC_MACHTRAIL_DESC <- [
		"Nothing compares!\n"
		"Nothing compares!\n"
	]
	::COSMETIC_RAINBOWTRAIL_DESC <- [
		"Perfect for the aftermath\nof a stormy night."
		"Perfect for the aftermath\nof a stormy night."
	]
	::COSMETIC_RAVESTORY_DESC <- [
		"Who wrote these, anyway?\nSounds like they belong in a rave."
		"Who wrote these, anyway?\nSounds like they belong in a rave."
	]
	::COSMETIC_WHIMSICALSTAR_DESC <- [
		"A special reward for\nzealous challengers."
		"A special reward for\nzealous challengers."
	]
]

::ENCORE_UNLOCK <- [
	"You just unlocked Encore Mode! You can enable it in the teleporter room!"
	"You just unlocked Encore Mode! You can enable it in the teleporter room!"
]
::ENCORETUTORIAL_INTRO <- [
	"Welcome to Encore Mode. Encore Mode remixes every stage into a more difficult, timed version."
	"Welcome to Encore Mode. Encore Mode remixes every stage into a more difficult, timed version."
]
::ENCORETUTORIAL_TIMER_1 <- [
	"You will start with 15 seconds to complete the course. You can get more time by collecting the Time Clocks."
	"You will start with 15 seconds to complete the course. You can get more time by collecting the Time Clocks."
]
::ENCORETUTORIAL_TIMER_2 <- [
	"Running out of time will cause you to quickly bleed out. You won't lose your speed though, and gaining time by any means will stop the bleeding."
	"Running out of time will cause you to quickly bleed out. You won't lose your speed though, and gaining time by any means will stop the bleeding."
]
::ENCORETUTORIAL_LAP_1 <- [
	"At the end of each course lies a Lapping Teleporter. Lapping will cause Time Clocks to give 3/4 of what they were last lap and add an additional 30 seconds to your clock."
	"At the end of each course lies a Lapping Teleporter. Lapping will cause Time Clocks to give 3/4 of what they were last lap and add an additional 30 seconds to your clock."
]
::ENCORETUTORIAL_LAP_2 <- [
	"However, reaching the 4th lap will cause Time Clocks to stop giving time."
	"However, reaching the 4th lap will cause Time Clocks to stop giving time."
]
::ENCORETUTORIAL_LAP_3 <- [
	"Higher tiers of ranks require running multiple laps through a course. Good Luck!"
	"Higher tiers of ranks require running multiple laps through a course. Good Luck!"
]

::HUD_COIN <- [
	"Cion\nx"
	"Cion\nx"
]
::HUD_COINRADAR_READY <- [
	::MSG1 <- [
		"RADAR READY"
		"RADAR READY"
	]
	::MSG2 <- [
		"[ATTACK] TO USE"
		"[ATTACK] TO USE"
	]
]
::HUD_COINRADAR_NOTREADY <- [
	"CHARGING RADAR [%s]"
	"CHARGING RADAR [%s]"
]
::TIMETRIAL_LAP <- [
	"Lap "
	"Vuelta "
]
::TIMETRIAL_FINALLAP <- [
	"Lap\nFINAL"
	"Lap\nFINAL"
]
::TIMETRIAL_MSG_TIME <- [
	"Time is starting to dilate..."
	"Time is starting to dilate..."
]
::TIMETRIAL_MSG_DEATH <- [
	"A sense of dread weighs down upon you..."
	"A sense of dread weighs down upon you..."
]
::TIMETRIAL_MSG_CRYSTAL <- [
	"You've found %i crystals out of 5!"
	"You've found %i crystals out of 5!"
]
::TIMER_ENCORE <- [
	"Encore "
	"Encore "
]
::TIMER_CHEATED <- [
	"You seem to have cheated, your time has been invalidated."
	"Parece que has hecho trampa, tu tiempo ha sido invalidado."
]
::TIMER_CHECKPOINT <- [
	"%s Checkpoint "
	"%s Checkpoint "
]
::TIMER_PERSONALBEST <- [
	" Per. "
	" Per. "
]
::TIMER_WORLDRECORD <- [
	" Rec. "
	" Rec. "
]
::TIMER_LAPTIME <- [
	"Lap Time: "
	"Tiempo de vuelta: "
]
::TIMER_FINALTIME <- [
	"Final Time: "
	"Tiempo final: "
]
::TIMER_FINALTIME_LAPCOUNT <- [
	::SINGULAR <- [
		" (%i Lap)"
		" (%i Lap)"
	]
	::PLURAL <- [
		" (%i Laps)"
		" (%i Laps)"
	]
]
::TIMER_NONE <- [
	"N/A"
	"N/A"
]
::TIMER_MEDAL_NOMEDAL <- [
	"D"
	"D"
]
::TIMER_MEDAL <- [
	::BRONZE <- [
		"C"
		"C"
	]
	::SILVER <- [
		"B"
		"B"
	]
	::GOLD <- [
		"A"
		"A"
	]
	::IRIDESCENT <- [
		"S"
		"S"
	]
]
::TIMER_MEDAL_DISPLAY_MEDALTIMES <- [
	"%s%s Ranks"
	"%s%s Ranks"
]
::TIMER_MEDAL_DISPLAY_MEDALTIMES_ENCORE <- [
	"%s%s Encore Ranks"
	"%s%s Encore Ranks"
]
::TIMER_MEDAL_DISPLAY_LAP <- [
	"Lap "
	"Vuelta "
]
::TIMER_MEDAL_DISPLAY <- [
	::BRONZE <- [
		"C Rank"
		"C Rank"
	]
	::SILVER <- [
		"B Rank"
		"B Rank"
	]
	::GOLD <- [
		"A Rank"
		"A Rank"
	]
	::IRIDESCENT <- [
		"S Rank"
		"S Rank"
	]
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL <- [
	"Best Rank: "
	"Best Rank: "
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL_ENCORE <- [
	"Best Encore Rank: "
	"Best Encore Rank: "
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_TIME <- [
	"Best Time: "
	"Best Time: "
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT <- [
	"Checkpoint %i: "
	"Checkpoint %i: "
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_CHECKPOINT_SKIPPED <- [
	"Gooched!"
	"Gooched!"
]
::TIMER_MEDAL_DISPLAY_SERVERBEST_LAP <- [
	"Most Laps: "
	"Most Laps: "
]

::TIMER_ACHIEVED <- [
	" achieved %s%s "
	" lograda %s "
]
::TIMER_FAILEDTOQUALIFY <- [
	"D Rank."
	"D Rank."
]
::TIMER_MEDAL_ACHIEVED <- [
	::BRONZE <- [
		"C Rank."
		"C Rank."
	]
	::SILVER <- [
		"B Rank."
		"B Rank."
	]
	::GOLD <- [
		"A Rank!"
		"A Rank!"
	]
	::IRIDESCENT <- [
		"S Rank!"
		"S Rank!"
	]
]
::TIMER_MESSAGE <- [
	::TIMER_MESSAGE_BRONZE <- [
		::MESSAGE_1 <- [
			"Not bad, but not great either, you"
			"Not bad, but not great either, you"
		]
		::MESSAGE_2 <- [
			"Not very fast... You"
			"Not very fast... You"
		]
		::MESSAGE_3 <- [
			"That could've gone better, you"
			"That could've gone better, you"
		]
		::MESSAGE_4 <- [
			"Atleast it's something, you"
			"Atleast it's something, you"
		]
		::MESSAGE_5 <- [
			"Better than nothing, you"
			"Better than nothing, you"
		]
	]
	::TIMER_MESSAGE_SILVER <- [
		::MESSAGE_1 <- [
			"Now you're getting somewhere! You"
			"Now you're getting somewhere! You"
		]
		::MESSAGE_2 <- [
			"Nice, you"
			"Nice, you"
		]
		::MESSAGE_3 <- [
			"Not too shabby, you"
			"Not too shabby, you"
		]
	]
	::TIMER_MESSAGE_GOLD <- [
		::MESSAGE_1 <- [
			"Sweet! You"
			"Sweet! You"
		]
		::MESSAGE_2 <- [
			"Great Job! You"
			"Great Job! You"
		]
		::MESSAGE_3 <- [
			"Alright! You"
			"Alright! You"
		]
		::MESSAGE_4 <- [
			"Excellent! You"
			"Excellent! You"
		]
		::MESSAGE_5 <- [
			"That was fast! You"
			"That was fast! You"
		]
	]
	::TIMER_MESSAGE_IRIDESCENT <- [
		::MESSAGE_1 <- [
			"Faster than fast! You"
			"Faster than fast! You"
		]
		::MESSAGE_2 <- [
			"I don't believe it! You"
			"I don't believe it! You"
		]
		::MESSAGE_3 <- [
			"There's no way! You"
			"There's no way! You"
		]
		::MESSAGE_4 <- [
			"Did you cheat? That was TOO fast! You"
			"Did you cheat? That was TOO fast! You"
		]
		::MESSAGE_5 <- [
			"You've gotta be the best of the best! You"
			"You've gotta be the best of the best! You"
		]
	]
	::TIMER_MESSAGE_NOMEDAL <- [
		::MESSAGE_1 <- [
			"That was REALLY slow, you"
			"That was REALLY slow, you"
		]
		::MESSAGE_2 <- [
			"WOW, could you have gone any slower? You"
			"WOW, could you have gone any slower? You"
		]
		::MESSAGE_3 <- [
			"That was pretty bad, you"
			"That was pretty bad, you"
		]
		::MESSAGE_4 <- [
			"Tough luck pal, you"
			"Tough luck pal, you"
		]
		::MESSAGE_5 <- [
			"Lame, you"
			"Lame, you"
		]
		::MESSAGE_6 <- [
			"Too bad! You"
			"Too bad! You"
		]
		::MESSAGE_7 <- [
			"You can do better than that, right? You"
			"You can do better than that, right? You"
		]
		::MESSAGE_8 <- [
			"Sucks to suck. You"
			"Sucks to suck. You"
		]
	]
]

::TIP_REGULAR <- [
	::TIP_1 <- [
		"Touching a spike can grant a vertical boost! Combine it with a long jump to reach new heights!"
		"¡Tocar un pico puede otorgar un impulso vertical! ¡Combínalo con un salto de longitud para alcanzar nuevas alturas!"
	]
	::TIP_2 <- [
		"Earning an S Rank isn't easy! It's for the best of the best, only obtainable for those zealous challengers out there!"
		"Earning an S Rank isn't easy! It's for the best of the best, only obtainable for those zealous challengers out there!"
	]
	::TIP_3 <- [
		"Keep an eye out for alternative routes through a course, they can help you achieve better times!"
		"Esté atento a las rutas alternativas a través de un curso, ¡pueden ayudarlo a lograr mejores tiempos!"
	]
	::TIP_4 <- [
		"The computer at the start of each course can tell you what the rank times for that course are, aim for the best!"
		"The computer at the start of each course can tell you what the rank times for that course are, aim for the best!"
	]
	::TIP_5 <- [
		"Dying or falling off on a couse will have you conveniently respawn at the start to keep the momentum of the runs going!"
		"¡Morir o caerte en un campo te hará reaparecer convenientemente al comienzo para mantener el impulso de las carreras!"
	]
	::TIP_6 <- [
		"Shortly after taking damage you will start to regenerate health, use this power to keep spike jumping!"
		"Poco después de recibir daño comenzarás a regenerar salud, ¡usa este poder para seguir saltando con picos!"
	]
	::TIP_7 <- [
		"Want a change in tunes? Walk into the teleporter room and take a left!"
		"¿Quieres un cambio de melodía? ¡Entra en la sala del teletransportador y gira a la izquierda!"
	]
	::TIP_8 <- [
		"You can adjust the volume of Outer Wall's tunes by typing snd_musicvolume in console."
		"Puedes ajustar el volumen de las melodías de Outer Wall escribiendo snd_musicvolume en la consola."
	]
	::TIP_9 <- [
		"You can easily view all courses by walking into the teleporter room and taking a right!"
		"¡Puedes ver fácilmente todos los cursos entrando en la sala del teletransportador y girando a la derecha!"
	]
	::TIP_10 <- [
		"Touching lava will actually send you twice as high as a spike does, while only dealing half the damage!"
		"¡Tocar lava en realidad te enviará el doble de alto que un pico, mientras que solo inflige la mitad del daño!"
	]
	// ::TIP_11 <- [
	// 	"Looking for a challenge? Try Encore Mode! You can unlock it by earning a rank on each course."
	// 	"Looking for a challenge? Try Encore Mode! You can unlock it by earning a rank on each course."
	// ]
	::TIP_11 <- [
		"The air currents at the Inner Wall will allow you to double jump after touching one. Use this to make extra distance you couldn't before!"
		"The air currents at the Inner Wall will allow you to double jump after touching one. Use this to make extra distance you couldn't before!"
	]
	::TIP_12 <- [
		"You can customize your Outer Wall expierence by heading to the teleporter room and taking a left!"
		"You can customize your Outer Wall expierence by heading to the teleporter room and taking a left!"
	]
]
::TIP_CRAP <- [
	::TIP_1 <- [
		"You don't need any of these tips, do you?"
		"No necesitas ninguno de estos consejos, ¿verdad?"
	]
	::TIP_2 <- [
		"You're going to die here, but don't fret! Once you do, its permanent!"
		"You're going to die here, but don't fret! Once you do, its permanent!"
	]
	::TIP_3 <- [
		"Those spikes littered everywhere weren't always red!"
		"Those spikes littered everywhere weren't always red!"
	]
	::TIP_4 <- [
		"Don't you have anything better to do?"
		"¿No tienes nada mejor que hacer?"
	]
	::TIP_5 <- [
		"You're getting on my nerves!"
		"¡Me estás poniendo de los nervios!"
	]
	::TIP_6 <- [
		"That timer isn't going to stop for your dillydallying!"
		"¡Ese cronómetro no va a parar por tu dildo!"
	]
	::TIP_7 <- [
		"If you see any red flowers, you should eat them!"
		"¡Si ves flores rojas, debes comerlas!"
	]
	::TIP_8 <- [
		"Looking to get a better time? Lose some weight! That fat ass of yours must be whats slowing you down."
		"¿Buscas pasarlo mejor? ¡Pierde algo de peso! Ese culo gordo tuyo debe ser lo que te está frenando."
	]
	::TIP_9 <- [
		"Looking for a quick way to heal after taking damage? Too bad! The damage you deal to yourself is permanent."
		"¿Estás buscando una forma rápida de curarte después de recibir daño? ¡Lástima! El daño que te haces a ti mismo es permanente."
	]
	::TIP_10 <- [
		"Ever wonder what happens when a teleporter turns off halfway during teleportation? Lets find out!"
		"Ever wonder what happens when a teleporter turns off halfway during teleportation? Lets find out!"
	]
	::TIP_12 <- [
		"TIP SERVER UNAVAILABLE TRY AGAIN LATER"
		"SERVIDOR DE CONSEJOS NO DISPONIBLE INTÉNTELO DE NUEVO MÁS TARDE"
	]
	::TIP_17 <- [
		"Take a big whiff of fresh air outside! Let me know how it smells!"
		"Take a big whiff of fresh air outside! Let me know how it smells!"
	]
	::TIP_18 <- [
		"Break some of those bones of yours! They'll grow back twice as stong!"
		"Break some of those bones of yours! They'll grow back twice as stong!"
	]
	::TIP_19 <- [
		"If you die enough, you may not respawn!"
		"If you die enough, you may not respawn!"
	]
	::TIP_20 <- [
		"I'm bored! Jump off that cliff and kill yourself for my amusement!"
		"I'm bored! Jump off that cliff and kill yourself for my amusement!"
	]
	::TIP_21 <- [
		"Do you smell it? I smell it. Go take a shower!"
		"Do you smell it? I smell it. Go take a shower!"
	]
	::TIP_22 <- [
		"You've bothered me %i times, go away now!"
		"You've bothered me %i times, go away now!"
	]
]
::TIP_PARKOUR <- [
	::TIP_1 <- [
		"helloserverplugintogglethirdpresononmeplease"
		"helloserverplugintogglethirdpresononmeplease"
	]
	::TIP_2 <- [
		"Porting Parkour Fortress to VScript [462 of 133,308 bytes translated] [Estimated 6 Years Remaining]"
		"Portar Parkour Fortress a VScript [462 de 133,308 bytes traducidos] [Estimación de 6 años restantes]"
	]
	::TIP_3 <- [
		"Questionable."
		"Cuestionable."
	]
	::TIP_4 <- [
		"Animations and Chat Features are coming very soon!"
		"¡Las funciones de animación y chat llegarán muy pronto!"
	]
	::TIP_5 <- [
		"By playing Outer Wall, you hereby agree to a personal haunting on pf_thunderstorms."
		"Al jugar Outer Wall, aceptas una persecución personal en pf_thunderstorms."
	]
	::TIP_6 <- [
		"By playing Outer Wall, you hereby agree to not post images of any of these high effort and extremly whitty tips."
		"Al jugar Outer Wall, por la presente aceptas no publicar imágenes de ninguno de estos consejos de gran esfuerzo y extremadamente ingeniosos."
	]
	::TIP_7 <- [
		"By playing Outer Wall, you hereby agree to post bnuuy photos in #off-topic every day for the next 16 years."
		"Al jugar a Outer Wall, aceptas publicar bnuuy fotos en #off-topic todos los días durante los próximos 16 años."
	]
	::TIP_8 <- [
		"Using the reset command has a 1 in 4,800,000,000 chance to ban you and wipe all your times. Don't believe me? You will soon enough."
		"Usar el comando de reinicio tiene una probabilidad de 1 en 4,800,000,000 de prohibirte y borrar todos tus tiempos. ¿No me crees? Lo harás muy pronto."
	]
	::TIP_9 <- [
		"Outer Wall+ is now available on WiiWare for 1,200 Wii Points! Buy now or forever feel the guilt of missing out!"
		"¡Outer Wall+ ya está disponible en WiiWare por 1,200 Wii Points! ¡Cómpralo ahora o siéntete culpable para siempre por perdértelo!"
	]
]
::TIP_CRUDE <- [
	::TIP_1 <- [
		"Fuck you!"
		"Vete a la mierda!"
	]
]
::TIP_PREFIX <- [
	::PREFIX_1 <- [
		"Tip:"
		"Consejo:"
	]
	::PREFIX_2 <- [
		"Helpful Tip:"
		"Consejo útil:"
	]
	::PREFIX_3 <- [
		"Here's some advice:"
		"Aquí hay algunos consejos:"
	]
	::PREFIX_4 <- [
		"Read this:"
		"Lee esto:"
	]
	::PREFIX_5 <- [
		"Look here:"
		"Mira aquí:"
	]
	::PREFIX_6 <- [
		"Listen to this:"
		"Escucha esto:"
	]
	::PREFIX_7 <- [
		"I'll tip you off:"
		"Te aviso:"
	]
	::PREFIX_8 <- [
		"Sponsored Tip:"
		"Consejo patrocinado:"
	]
	::PREFIX_8 <- [
		"Point of advice:"
		"Point of advice:"
	]
]