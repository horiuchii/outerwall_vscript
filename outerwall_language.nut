::PlayerLanguage <- array(MAX_PLAYERS, 0)

::TranslateString <- function(message, player_index = null)
{
	if(message.len() != Languages.len())
		return format("ERROR: BAD TRANSLATION STRING %s", message.tostring());

	if(player_index)
		return message[PlayerLanguage[player_index]];
		
	return message[0];
}

::Languages <- [
	"english"
	"pirate"
	"spanish"
]

::OUTERWALL_SETTING_ON <- [
	"ON"
	"ON"
	"ENCENDIDA"
]
::OUTERWALL_SETTING_OFF <- [
	"OFF"
	"OFF"
	"APAGADA"
]
::OUTERWALL_SETTING_FINALTIME <- [
	"Final time display is now: "
	"Final time display be now: "
	"La visualización de la hora final ahora está: "
]

::OUTERWALL_TIMETRIAL_LAP <- [
	"Lap"
	"Lap"
	"Vuelta"
]
::OUTERWALL_TIMER_CHEATED <- [
	"You seem to have cheated, your time has been invalidated."
	"Ye seem t' 'ave hornswaggled, yer time has been invalidated."
	"Parece que has hecho trampa, tu tiempo ha sido invalidado."
]
::OUTERWALL_TIMER_LAPTIME <- [
	"Lap Time: "
	"Lap Time: "
	"Tiempo de vuelta: "
]
::OUTERWALL_TIMER_FINALTIME <- [
	"Final Time: "
	"Final Time: "
	"Tiempo final: "
]

::OUTERWALL_TIMER_MEDAL <- [
	::BRONZE <- [
		"Bronze"
		"Bronze"
		"Bronce"
	]
	::SILVER <- [
		"Silver"
		"Silver"
		"Plata"
	]
	::GOLD <- [
		"Gold"
		"Gold"
		"Oro"
	]
	::IRIDESCENT <- [
		"Iridescent"
		"Iridescent"
		"Iridiscente"
	]
]

::OUTERWALL_TIMER_ACHIEVED <- [
	" achieved "
	" achieved "
	" lograda "
]
::OUTERWALL_TIMER_FAILEDTOQUALIFY <- [
	" failed to qualify for any of %s medals."
	" failed to qualify for any of %s medals."
	" failed to qualify for any of %s medals."
]
::OUTERWALL_TIMER_MEDAL_ACHIEVED <- [
	::BRONZE <- [
		"Bronze medal."
		"Bronze medal."
		"Medalla de bronce."
	]
	::SILVER <- [
		"Silver medal!"
		"Silver medal!"
		"¡Medalla de plata!"
	]
	::GOLD <- [
		"Gold medal!"
		"Gold medal!"
		"¡Medalla de oro!"
	]
	::IRIDESCENT <- [
		"Iridescent medal!"
		"Iridescent medal!"
		"¡Medalla de iridiscente!"
	]
]

::OUTERWALL_TIMER_MEDAL_DISPLAY_MEDALTIMES <- [
	"%s Medal Times"
	"%s Medal Times"
	"Tiempos de la medalla %s"
]
::OUTERWALL_TIMER_MEDAL_DISPLAY_LAPTWO <- [
	" + Lap 2"
	" + Lap 2"
	" + Vuelta 2"
]
::OUTERWALL_TIMER_MEDAL_DISPLAY <- [
	::BRONZE <- [
		"Bronze time: "
		"Bronze time: "
		"Tiempo de bronce: "
	]
	::SILVER <- [
		"Silver time: "
		"Silver time: "
		"Tiempo de plata: "
	]
	::GOLD <- [
		"Gold time: "
		"Gold time: "
		"Tiempo de oro: "
	]
	::IRIDESCENT <- [
		"Iridescent time: "
		"Iridescent time: "
		"Tiempo de iridiscente: "
	]
]
::OUTERWALL_TIMER_MESSAGE <- [
	::OUTERWALL_TIMER_MESSAGE_BRONZE <- [
		::MESSAGE_1 <- [
			"Not bad, but not great either, you"
			"Not bad, but not great either, you"
			"Not bad, but not great either, you"
		]
		::MESSAGE_2 <- [
			"Not very fast... You"
			"Not very fast... You"
			"Not very fast... You"
		]
		::MESSAGE_3 <- [
			"That could've gone better, you"
			"That could've gone better, you"
			"That could've gone better, you"
		]
		::MESSAGE_4 <- [
			"Atleast you got something, you"
			"Atleast you got something, you"
			"Atleast you got something, you"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_SILVER <- [
		::MESSAGE_1 <- [
			"Now you're getting somewhere! You"
			"Now you're getting somewhere! You"
			"Now you're getting somewhere! You"
		]
		::MESSAGE_2 <- [
			"Not bad, you"
			"Not bad, you"
			"Not bad, you"
		]
		::MESSAGE_3 <- [
			"Not too shabby, you"
			"Not too shabby, you"
			"Not too shabby, you"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_GOLD <- [
		::MESSAGE_1 <- [
			"Sweet! You"
			"Sweet! You"
			"Sweet! You"
		]
		::MESSAGE_2 <- [
			"Great Job! You"
			"Great Job! You"
			"Great Job! You"
		]
		::MESSAGE_3 <- [
			"Alright! You"
			"Alright! You"
			"Alright! You"
		]
		::MESSAGE_4 <- [
			"Excellent! You"
			"Excellent! You"
			"Excellent! You"
		]
		::MESSAGE_5 <- [
			"That was fast! You"
			"That was fast! You"
			"That was fast! You"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_IRIDESCENT <- [
		::MESSAGE_1 <- [
			"Faster than fast! You"
			"Faster than fast! You"
			"Faster than fast! You"
		]
		::MESSAGE_2 <- [
			"I don't believe it! You"
			"I don't believe it! You"
			"I don't believe it! You"
		]
		::MESSAGE_3 <- [
			"There's no way! You"
			"There's no way! You"
			"There's no way! You"
		]
		::MESSAGE_4 <- [
			"Did you cheat? That was TOO fast! You"
			"Did you cheat? That was TOO fast! You"
			"Did you cheat? That was TOO fast! You"
		]
		::MESSAGE_5 <- [
			"You've gotta be the best of the best! You"
			"You've gotta be the best of the best! You"
			"You've gotta be the best of the best! You"
		]
	]
	::OUTERWALL_TIMER_MESSAGE_NOMEDAL <- [
		::MESSAGE_1 <- [
			"That was REALLY slow, you"
			"That was REALLY slow, you"
			"That was REALLY slow, you"
		]
		::MESSAGE_2 <- [
			"WOW, could you have gone any slower? You"
			"WOW, could you have gone any slower? You"
			"WOW, could you have gone any slower? You"
		]
		::MESSAGE_3 <- [
			"That was pretty bad, you"
			"That was pretty bad, you"
			"That was pretty bad, you"
		]
		::MESSAGE_4 <- [
			"Tough luck pal, you"
			"Tough luck pal, you"
			"Tough luck pal, you"
		]
		::MESSAGE_5 <- [
			"Lame, you"
			"Lame, you"
			"Lame, you"
		]
		::MESSAGE_6 <- [
			"Too bad! You"
			"Too bad! You"
			"Too bad! You"
		]
		::MESSAGE_7 <- [
			"You can do better than that, right? You"
			"You can do better than that, right? You"
			"You can do better than that, right? You"
		]
	]
]

::OUTERWALL_TIP_REGULAR <- [
	::TIP_1 <- [
		"Touching a spike can grant a vertical boost! Combine it with a long jump to reach new heights!"
		"Touchin' a spike can grant a vertical boost! Combine it wit' a long jump t' reach new heights!"
		"¡Tocar un pico puede otorgar un impulso vertical! ¡Combínalo con un salto de longitud para alcanzar nuevas alturas!"
	]
	::TIP_2 <- [
		"Obtaining the glorious iridescent medal requires you to prove mastery over a course by getting a time even faster than gold. Only for those zealous challengers out there!"
		"Obtainin' the glorious iridescent medal requires ye t' prove mastery o'er a course by gettin' a time even faster than gold. Only fer those zealous challengers out thar!"
		"Obtener la gloriosa medalla iridiscente requiere que demuestres el dominio de un curso al obtener un tiempo incluso más rápido que el oro. ¡Solo para esos entusiastas retadores por ahí!"
	]
	::TIP_3 <- [
		"Keep an eye out for alternative routes through a course, they can help you achieve better times!"
		"Keep an eye out fer alternative routes through a course, they can help ye achieve better times!"
		"Esté atento a las rutas alternativas a través de un curso, ¡pueden ayudarlo a lograr mejores tiempos!"
	]
	::TIP_4 <- [
		"The computer at the start of each course can tell you what the Gold, Silver and Bronze times for that course are."
		"The computer at the start o' each course can tell ye wha' the Gold, Silver 'n Bronze times fer that course are."
		"La computadora al comienzo de cada curso puede decirle cuáles son los tiempos de oro, plata y bronce para ese curso."
	]
	::TIP_5 <- [
		"Dying or falling off on a couse will have you conveniently respawn at the start to keep the momentum of the runs going!"
		"Dying or fallin' off the plank will 'ave ye conveniently respawn at the start t' keep the momentum o' the runs goin'!"
		"¡Morir o caerte en un campo te hará reaparecer convenientemente al comienzo para mantener el impulso de las carreras!"
	]
	::TIP_6 <- [
		"Shortly after taking damage you will start to regenerate health, use this power to keep spike jumping!"
		"Shortly aft takin' damage ye will start t' regenerate health, use this power t' keep spike jumpin'!"
		"Poco después de recibir daño comenzarás a regenerar salud, ¡usa este poder para seguir saltando con picos!"
	]
	::TIP_7 <- [
		"Want a change in tunes? Walk into the teleporter room and take a left!"
		"Wants a change in shanties? Walk into the teleporter cabin 'n turn t' port!"
		"¿Quieres un cambio de melodía? ¡Entra en la sala del teletransportador y gira a la izquierda!"
	]
	::TIP_8 <- [
		"You can adjust the volume of Outer Wall's tunes by typing snd_musicvolume in console."
		"Ye can adjust the volume o' Outer Wall's shanties by typing snd_musicvolume in console."
		"Puedes ajustar el volumen de las melodías de Outer Wall escribiendo snd_musicvolume en la consola."
	]
	::TIP_9 <- [
		"You can easily view all courses by walking into the teleporter room and taking a right!"
		"Ye can easily view all courses by walkin' into the teleporter cabin 'n takin' a right!"
		"¡Puedes ver fácilmente todos los cursos entrando en la sala del teletransportador y girando a la derecha!"
	]
	::TIP_10 <- [
		"Touching lava will actually send you twice as high as a spike does, while only dealing half the damage!"
		"Touchin' lava will actually send ye twice as high as a spike does, while only dealin' half the damage!"
		"¡Tocar lava en realidad te enviará el doble de alto que un pico, mientras que solo inflige la mitad del daño!"
	]
]
::OUTERWALL_TIP_CRAP <- [
	::TIP_1 <- [
		"You don't need any of these tips, do you?"
		"Ye don't needs any o' these tips, do ye?"
		"No necesitas ninguno de estos consejos, ¿verdad?"
	]
	::TIP_2 <- [
		"Those eyes in the stone have seen everything you've done."
		"Those eyes in the stone 'ave seen everythin' ye've done."
		"Esos ojos en la piedra han visto todo lo que has hecho."
	]
	::TIP_3 <- [
		"I would watch my back if I were you."
		"I would watch me back if I we be ye."
		"Cuidaría mi espalda si fuera tú."
	]
	::TIP_4 <- [
		"Don't you have anything better to do?"
		"Don't ye 'ave anythin' better t' do?"
		"¿No tienes nada mejor que hacer?"
	]
	::TIP_5 <- [
		"You're getting on my nerves!"
		"Ye're gettin' on me nerves, ye filthy cretin!"
		"¡Me estás poniendo de los nervios!"
	]
	::TIP_6 <- [
		"That timer isn't going to stop for your dillydallying."
		"That timer ain't goin' t' stop fer yer dillydallyin'."
		"Ese cronómetro no va a parar por tu dildo."
	]
	::TIP_7 <- [
		"If you see any red flowers, you should eat them!"
		"If ye see any red flowers, ye shall eat 'em!"
		"¡Si ves flores rojas, debes comerlas!"
	]
	::TIP_8 <- [
		"Looking to get a better time? Lose some weight! That fat ass of yours must be whats slowing you down."
		"Lookin' t' get a better time? Lose some weight! That fat arse o' yers must be whats slowin' ye down."
		"¿Buscas pasarlo mejor? ¡Pierde algo de peso! Ese culo gordo tuyo debe ser lo que te está frenando."
	]
	::TIP_9 <- [
		"Looking for a quick way to heal after taking damage? Too bad! The damage you deal to yourself is permanent."
		"Lookin' fer a quick way t' heal aft takin' damage? Too bad! The damage ye deal t' yourself be permanent."
		"¿Estás buscando una forma rápida de curarte después de recibir daño? ¡Lástima! El daño que te haces a ti mismo es permanente."
	]
	::TIP_10 <- [
		"You are not supposed to be here."
		"Ye be nah supposed t' be here."
		"Se supone que no deberías estar aquí."
	]
	::TIP_11 <- [
		"You are going to die on this island."
		"Ye be goin' t' Davey Jones locker on this island."
		"Vas a morir en esta isla."
	]
	::TIP_12 <- [
		"You are running out of time."
		"Yer doom be at hand."
		"Te estás quedando sin tiempo."
	]
	::TIP_13 <- [
		"TIP SERVER UNAVAILABLE TRY AGAIN LATER"
		"TIP SERVER UNAVAILABLE TRY AGAIN LATER"
		"SERVIDOR DE CONSEJOS NO DISPONIBLE INTÉNTELO DE NUEVO MÁS TARDE"
	]
]
::OUTERWALL_TIP_PARKOUR <- [
	::TIP_1 <- [
		"helloserverplugintogglethirdpresononmeplease"
		"helloserverplugintogglethirdpresononmeplease"
		"helloserverplugintogglethirdpresononmeplease"
	]
	::TIP_2 <- [
		"Porting Parkour Fortress to VScript [462 of 133,308 bytes translated] [Estimated 6 Years Remaining]"
		"Portin' Parkour Fortress t' VScript [462 o' 133,308 bytes translated] [Estimated 6 Years Remaining]"
		"Portar Parkour Fortress a VScript [462 de 133,308 bytes traducidos] [Estimación de 6 años restantes]"
	]
	::TIP_3 <- [
		"Questionable."
		"Questionable."
		"Cuestionable."
	]
	::TIP_4 <- [
		"Animations and Chat Features are coming very soon!"
		"Animations 'n Chat Features are comin' mighty soon!"
		"¡Las funciones de animación y chat llegarán muy pronto!"
	]
	::TIP_5 <- [
		"By playing Outer Wall, you hereby agree to a personal haunting on pf_thunderstorms."
		"By playin' Outer Wall, ye hereby agree t' a personal hauntin' on pf_thunderstorms."
		"Al jugar Outer Wall, aceptas una persecución personal en pf_thunderstorms."
	]
	::TIP_6 <- [
		"By playing Outer Wall, you hereby agree to not post images of any of these high effort and extremly whitty tips."
		"By playin' Outer Wall, ye hereby agree t' nah post images o' any o' these high effort 'n extremly whitty tips."
		"Al jugar Outer Wall, por la presente aceptas no publicar imágenes de ninguno de estos consejos de gran esfuerzo y extremadamente ingeniosos."
	]
	::TIP_7 <- [
		"By playing Outer Wall, you hereby agree to post bnuuy photos in #off-topic every day for the next 16 years."
		"By playin' Outer Wall, ye hereby agree t' post bnuuy photos in #off-topic every day fer the next 16 years."
		"Al jugar a Outer Wall, aceptas publicar bnuuy fotos en #off-topic todos los días durante los próximos 16 años."
	]
	::TIP_8 <- [
		"Using the reset command has a 1 in 4,800,000,000 chance to ban you and wipe all your times. Don't believe me? You will soon enough."
		"Usin' the reset command has a 1 in 4,800,000,000 chance t' ban ye 'n wipe all yer times. Don't believe me? Ye will soon enough."
		"Usar el comando de reinicio tiene una probabilidad de 1 en 4,800,000,000 de prohibirte y borrar todos tus tiempos. ¿No me crees? Lo harás muy pronto."
	]
	::TIP_9 <- [
		"Outer Wall+ is now available on WiiWare for 1,200 Wii Points! Buy now or forever feel the guilt of missing out!"
		"Outer Wall+ be now available on WiiWare fer 1,200 Wii Points! Buy now or forever feel the guilt o' missin' out!"
		"¡Outer Wall+ ya está disponible en WiiWare por 1,200 Wii Points! ¡Cómpralo ahora o siéntete culpable para siempre por perdértelo!"
	]
]
::OUTERWALL_TIP_CRUDE <- [
	::TIP_1 <- [
		"Fuck you!"
		"Walk the plank!"
		"Vete a la mierda!"
	]
]
::OUTERWALL_TIP_PREFIX <- [
	::PREFIX_1 <- [
		"Tip:"
		"Tip:"
		"Consejo:"
	]
	::PREFIX_2 <- [
		"Helpful Tip:"
		"Helpful Tip:"
		"Consejo útil:"
	]
	::PREFIX_3 <- [
		"Here's some advice:"
		"Here be some advice:"
		"Aquí hay algunos consejos:"
	]
	::PREFIX_4 <- [
		"Read this:"
		"Read this:"
		"Lee esto:"
	]
	::PREFIX_5 <- [
		"Look here:"
		"Look 'ere:"
		"Mira aquí:"
	]
	::PREFIX_6 <- [
		"Listen to this:"
		"Listen t' this:"
		"Escucha esto:"
	]
	::PREFIX_7 <- [
		"I'll tip you off:"
		"I'll tip ye off:"
		"Te aviso:"
	]
	::PREFIX_8 <- [
		"Sponsored Tip:"
		"Sponsored Tip:"
		"Consejo patrocinado:"
	]
]
