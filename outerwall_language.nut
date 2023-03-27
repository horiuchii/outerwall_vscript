::PlayerLanguage <- array(MAX_PLAYERS, 0)

::TranslateString <- function(message, player_index = null)
{
	if(message.len() != Languages.len())
		return "ERROR";

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

::OUTERWALL_COLLECTABLE_WARNING <- [
	"Due to technical limitations, the collectables will not disapear as of right now. You will still collect them however. Sorry!"
	"Due to technical limitations, the collectables will not disapear as of right now. You will still collect them however. Sorry!"
]

::OUTERWALL_SETTING_OPTION <- [
	::OUTERWALL_SETTING_OFF <- [
		"OFF"
		"APAGADA"
	]
	::OUTERWALL_SETTING_ON <- [
		"ON"
		"ENCENDIDA"
	]
]
::OUTERWALL_SETTING_BUTTON <- [
	"Press [ATTACK] to toggle"
	"Press [ATTACK] to toggle"
]
::OUTERWALL_SETTING_BUTTON_ALT <- [
	"Press [ALT-ATTACK] to toggle"
	"Press [ALT-ATTACK] to toggle"
]
::OUTERWALL_SETTING_BUTTON_NEXTPAGE <- [
	"Press [ATTACK] to go to the next item"
	"Press [ATTACK] to go to the next item"
]
::OUTERWALL_SETTING_BUTTON_NEXTPAGE_ALT <- [
	"Press [ALT-ATTACK] to go to the next item"
	"Press [ALT-ATTACK] to go to the next item"
]
::OUTERWALL_SETTING_BUTTON_PREVPAGE <- [
	"Press [ALT-ATTACK] to go to the previous item"
	"Press [ALT-ATTACK] to go to the previous item"
]
::OUTERWALL_SETTING_BUTTON_ENCORETUTORIAL <- [
	"Press [ALT-ATTACK] to play Encore's tutorial"
	"Press [ALT-ATTACK] to play Encore's tutorial"
]
::OUTERWALL_SETTING_CURRENT <- [
	"Current Setting: "
	"Current Setting: "
]
::OUTERWALL_SETTING_FINALTIME_NAME <- [
	"Final Time Display"
	"Final Time Display"
]
::OUTERWALL_SETTING_FINALTIME_DESC <- [
	"Shows a run's final time,\ncolor representing the medal."
	"Shows a run's final time,\ncolor representing the medal."
]
::OUTERWALL_SETTING_SOUNDTRACK <- [
	"Soundtrack"
	"Soundtrack"
]
::OUTERWALL_SETTING_SOUNDTRACK_DESC <- [
	"The soundtrack variant that\nis currently playing."
	"The soundtrack variant that\nis currently playing."
]
::OUTERWALL_SETTING_SOUNDTRACK_OPTION <- [
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
]
::OUTERWALL_SETTING_ENCORE <- [
	"Encore Mode"
	"Encore Mode"
]
::OUTERWALL_SETTING_ENCORE_DESC <- [
	"Encore Mode remixes every course and adds a time limit for an extra challenge!"
	"Encore Mode remixes every course and adds a time limit for an extra challenge!"
]
::OUTERWALL_SETTING_ENCORE_NOQUALIFY <- [
	"You do not qualify for Encore Mode yet."
	"You do not qualify for Encore Mode yet."
]

::OUTERWALL_LEADERBOARD_PAGE <- [
	"Page: "
	"Page: "
]

::OUTERWALL_ACHIEVEMENT_TITLE <- [
	"Achievements"
	"Achievements"
]
::OUTERWALL_ACHIEVEMENT_NAME <- [
	::OUTERWALL_ACHIEVEMENT_HELL_NODMG_NAME <- [
		"No Booster Required"
		"No Booster Required"
	]
	::OUTERWALL_ACHIEVEMENT_SECRET_01_NAME <- [
		"Secret Snake"
		"Secret Snake"
	]
	::OUTERWALL_ACHIEVEMENT_NORMAL_ALLGOLD_NAME <- [
		"Golden Bond"
		"Golden Bond"
	]
	::OUTERWALL_ACHIEVEMENT_NORMAL_ALLIRI_NAME <- [
		"Iridescent Bond"
		"Iridescent Bond"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_UNLOCK_NAME <- [
		"Encore, Encore!"
		"Encore, Encore!"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_OSIDE_NODMG_NAME <- [
		"Moonside Madness"
		"Moonside Madness"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_HELL_TIME_NAME <- [
		"Ain't Got No Time To Dance"
		"Ain't Got No Time To Dance"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_LAP_COUNT_NAME <- [
		"Overstaying Your Welcome"
		"Overstaying Your Welcome"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_ALLGOLD_NAME <- [
		"Lapping Hell"
		"Lapping Hell"
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_ALLIRI_NAME <- [
		"Hedonistic Lapping"
		"Hedonistic Lapping"
	]
	::OUTERWALL_ACHIEVEMENT_ALLGOLD_NAME <- [
		"Superstar"
		"Superstar"
	]
	::OUTERWALL_ACHIEVEMENT_ALLIRI_NAME <- [
		"Whimsical Superstar"
		"Whimsical Superstar"
	]
]
::OUTERWALL_ACHIEVEMENT_DESC <- [
	::OUTERWALL_ACHIEVEMENT_HELL_NODMG_DESC <- [
		"Complete the Sacred Grounds without taking damage."
		"Complete the Sacred Grounds without taking damage."
	]
	::OUTERWALL_ACHIEVEMENT_SECRET_01_DESC <- [
		"An absolute thrill to feel."
		"An absolute thrill to feel."
	]
	::OUTERWALL_ACHIEVEMENT_NORMAL_ALLGOLD_DESC <- [
		"Achieve a Gold medal on each course."
		"Achieve a Gold medal on each course."
	]
	::OUTERWALL_ACHIEVEMENT_NORMAL_ALLIRI_DESC <- [
		"Achieve a Iridescent medal on each course."
		"Achieve a Iridescent medal on each course."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_UNLOCK_DESC <- [
		"Unlock Encore mode."
		"Unlock Encore mode."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_OSIDE_NODMG_DESC <- [
		"Complete Encore Outer Wall without taking damage."
		"Complete Encore Outer Wall without taking damage."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_HELL_TIME_DESC <- [
		"Complete Encore Sacred Grounds with 1:30 on the clock."
		"Complete Encore Sacred Grounds with 1:30 on the clock."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_LAP_COUNT_DESC <- [
		"Complete 5 Laps on any Encore course."
		"Complete 5 Laps on any Encore course."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_ALLGOLD_DESC <- [
		"Achieve a Gold medal on each Encore course."
		"Achieve a Gold medal on each Encore course."
	]
	::OUTERWALL_ACHIEVEMENT_ENCORE_ALLIRI_DESC <- [
		"Achieve a Iridescent medal on each Encore course."
		"Achieve a Iridescent medal on each Encore course."
	]
	::OUTERWALL_ACHIEVEMENT_ALLGOLD_DESC <- [
		"Achieve an Gold medal on EVERY course."
		"Achieve an Gold medal on EVERY course."
	]
	::OUTERWALL_ACHIEVEMENT_ALLIRI_DESC <- [
		"Achieve an Iridescent medal on EVERY course."
		"Achieve an Iridescent medal on EVERY course."
	]
]

::OUTERWALL_STATS_TITLE <- [
	"Player Stats"
	"Player Stats"
]
::OUTERWALL_STATS_TIMEPLAYED <- [
	"Time Played: "
	"Time Played: "	
]
::OUTERWALL_STATS_ACHIEVEMENTS <- [
	"Achievements: "
	"Achievements: "
]
::OUTERWALL_STATS_SPIKEHITS <- [
	"Times hurt by spike: "
	"Times hurt by spike: "
]
::OUTERWALL_STATS_SPIKEJUMPS <- [
	"Times spikejumped: "
	"Times spikejumped: "
]
::OUTERWALL_STATS_LAVAHITS <- [
	"Times burned by lava: "
	"Times burned by lava: "
]

::OUTERWALL_COSMETIC_TITLE <- [
	"Cosmetics"
	"Cosmetics"
]
::OUTERWALL_COSMETIC_EQUIPPED <- [
	"Equipped:"
	"Equipped:"
]
::OUTERWALL_COSMETIC_NAME <- [
	::OUTERWALL_COSMETIC_NONEEQUIPPED_NAME <- [
		"None"
		"None"
	]
	::OUTERWALL_COSMETIC_MACHTRAIL_NAME <- [
		"Mach 3 Trail"
		"Mach 3 Trail"
	]
	::OUTERWALL_COSMETIC_RAINBOWTRAIL_NAME <- [
		"Rainbow Trail"
		"Rainbow Trail"
	]
]
::OUTERWALL_COSMETIC_DESC <- [
	::OUTERWALL_COSMETIC_NONEEQUIPPED_DESC <- [
		""
		""
	]
	::OUTERWALL_COSMETIC_MACHTRAIL_DESC <- [
		"Who knew breaking the sound barrier was this easy?"
		"Who knew breaking the sound barrier was this easy?"
	]
	::OUTERWALL_COSMETIC_RAINBOWTRAIL_DESC <- [
		"Rainbow Trail DESC"
		"Rainbow Trail DESC"
	]
]
::OUTERWALL_COSMETIC_REQUIREMENT <- [
	"[LOCKED]\nRequires "
	"[LOCKED]\nRequires "
]

::OUTERWALL_ENCORETUTORIAL_INTRO <- [
	"Welcome to Encore Mode. Encore Mode remixes every stage into a more difficult, timed version."
]
::OUTERWALL_ENCORETUTORIAL_TIMER_1 <- [
	"You will start with 15 seconds to complete the course. You can get more time by collecting the Time Clocks."
]
::OUTERWALL_ENCORETUTORIAL_TIMER_2 <- [
	"Running out of time will cause you to quickly bleed out. You won't lose your speed though, and gaining time by any means will stop the bleeding."
]
::OUTERWALL_ENCORETUTORIAL_LAP_1 <- [
	"At the end of each course lies a Lapping Teleporter. Lapping will cause Time Clocks to give 1/2 of what they were last lap."
]
::OUTERWALL_ENCORETUTORIAL_LAP_2 <- [
	"Higher tiers of medals may require running multiple laps through a course. Good Luck!"
]

::OUTERWALL_TIMETRIAL_LAP <- [
	"Lap"
	"Vuelta"
]
::OUTERWALL_TIMER_CHEATED <- [
	"You seem to have cheated, your time has been invalidated."
	"Parece que has hecho trampa, tu tiempo ha sido invalidado."
]
::OUTERWALL_TIMER_LAPTIME <- [
	"Lap Time: "
	"Tiempo de vuelta: "
]
::OUTERWALL_TIMER_FINALTIME <- [
	"Final Time: "
	"Tiempo final: "
]
::OUTERWALL_TIMER_NONE <- [
	"N/A"
	"N/A"
]
::OUTERWALL_TIMER_MEDAL <- [
	::BRONZE <- [
		"Bronze"
		"Bronce"
	]
	::SILVER <- [
		"Silver"
		"Plata"
	]
	::GOLD <- [
		"Gold"
		"Oro"
	]
	::IRIDESCENT <- [
		"Iridescent"
		"Iridiscente"
	]
]

::OUTERWALL_TIMER_MEDAL_DISPLAY_MEDALTIMES <- [
	"%s%s Medal Times"
	"Tiempos de medalla de %s"
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_MEDALTIMES_ENCORE <- [
	"%s%s Encore Medal Times"
	"Tiempos de medalla Encore de %s"
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_LAP <- [
	" + Lap %i"
	" + Vuelta %i"
]
::OUTERWALL_TIMER_MEDAL_DISPLAY <- [
	::BRONZE <- [
		"Bronze time: "
		"Tiempo de bronce: "
	]
	::SILVER <- [
		"Silver time: "
		"Tiempo de plata: "
	]
	::GOLD <- [
		"Gold time: "
		"Tiempo de oro: "
	]
	::IRIDESCENT <- [
		"Iridescent time: "
		"Tiempo de iridiscente: "
	]
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_MEDAL <- [
	"Best medal: "
	"Best medal: "
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_TIME <- [
	"Best time: "
	"Best time: "
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_SERVERBEST_LAP <- [
	"Most laps: "
	"Most laps: "
]

::OUTERWALL_TIMER_ACHIEVED <- [
	" achieved %s%s "
	" lograda &s "
]
::OUTERWALL_TIMER_FAILEDTOQUALIFY <- [
	" failed to qualify for any of %s%s medals."
	" failed to qualify for any of %s%s medals."
]
::OUTERWALL_TIMER_MEDAL_ACHIEVED <- [
	::BRONZE <- [
		"Bronze medal."
		"Medalla de bronce."
	]
	::SILVER <- [
		"Silver medal!"
		"¡Medalla de plata!"
	]
	::GOLD <- [
		"Gold medal!"
		"¡Medalla de oro!"
	]
	::IRIDESCENT <- [
		"Iridescent medal!"
		"¡Medalla de iridiscente!"
	]
]
::OUTERWALL_TIMER_MESSAGE <- [
	::OUTERWALL_TIMER_MESSAGE_BRONZE <- [
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
			"Atleast you got something, you"
			"Atleast you got something, you"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_SILVER <- [
		::MESSAGE_1 <- [
			"Now you're getting somewhere! You"
			"Now you're getting somewhere! You"
		]
		::MESSAGE_2 <- [
			"Not bad, you"
			"Not bad, you"
		]
		::MESSAGE_3 <- [
			"Not too shabby, you"
			"Not too shabby, you"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_GOLD <- [
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
	::OUTERWALL_TIMER_MESSAGE_IRIDESCENT <- [
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
	::OUTERWALL_TIMER_MESSAGE_NOMEDAL <- [
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

::OUTERWALL_TIP_REGULAR <- [
	::TIP_1 <- [
		"Touching a spike can grant a vertical boost! Combine it with a long jump to reach new heights!"
		"¡Tocar un pico puede otorgar un impulso vertical! ¡Combínalo con un salto de longitud para alcanzar nuevas alturas!"
	]
	::TIP_2 <- [
		"Obtaining the glorious iridescent medal requires you to prove mastery over a course by getting a time even faster than gold. Only for those zealous challengers out there!"
		"Obtener la gloriosa medalla iridiscente requiere que demuestres el dominio de un curso al obtener un tiempo incluso más rápido que el oro. ¡Solo para esos entusiastas retadores por ahí!"
	]
	::TIP_3 <- [
		"Keep an eye out for alternative routes through a course, they can help you achieve better times!"
		"Esté atento a las rutas alternativas a través de un curso, ¡pueden ayudarlo a lograr mejores tiempos!"
	]
	::TIP_4 <- [
		"The computer at the start of each course can tell you what the Gold, Silver and Bronze times for that course are."
		"La computadora al comienzo de cada curso puede decirle cuáles son los tiempos de oro, plata y bronce para ese curso."
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
]
::OUTERWALL_TIP_CRAP <- [
	::TIP_1 <- [
		"You don't need any of these tips, do you?"
		"No necesitas ninguno de estos consejos, ¿verdad?"
	]
	::TIP_2 <- [
		"Those eyes in the stone have seen everything you've done."
		"Esos ojos en la piedra han visto todo lo que has hecho."
	]
	::TIP_3 <- [
		"I would watch my back if I were you."
		"Cuidaría mi espalda si fuera tú."
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
		"Go to hell!"
		"Go to hell!"
	]
	::TIP_11 <- [
		"TIP SERVER UNAVAILABLE TRY AGAIN LATER"
		"SERVIDOR DE CONSEJOS NO DISPONIBLE INTÉNTELO DE NUEVO MÁS TARDE"
	]
]
::OUTERWALL_TIP_PARKOUR <- [
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
::OUTERWALL_TIP_CRUDE <- [
	::TIP_1 <- [
		"Fuck you!"
		"Vete a la mierda!"
	]
]
::OUTERWALL_TIP_PREFIX <- [
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
