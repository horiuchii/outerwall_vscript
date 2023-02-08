::TipText <- //79%
[
	"Touching a spike can grant a verticle boost! Combine it with a long jump to reach new heights!"
	"Obtaining the glorious iridecent medal requires you to prove mastery over a course by getting a time even faster than gold. Only for those zealous challengers out there!"
	"Keep an eye out for alternative routes through a course, they can help you achieve better times!"
	"The computer at the start of each course can tell you what the Gold, Silver and Bronze times for that course are."
	"Dying or falling off on a couse will have you conveniently respawn at the start to keep the momentum of the runs going!"
	"Shortly after taking damage you will start to regenerate health, use this power to keep spike jumping!"
	"Want a change in tunes? Walk into the teleporter room and take a left!"
	"You can adjust the volume of Outer Wall's tunes by typing snd_musicvolume in console."
	"You can easily view all courses by walking into the teleporter room and taking a right!"
	"Touching lava will actually send you twice as high as a spike does, while only dealing half the damage!"
]

::CrapText <- //10%
[
	"You don't need any of these tips, do you?"
	"Those eyes in the stone have seen everything you've done."
	"I would watch my back if I were you."
	"Don't you have anything better to do?"
	"You're getting on my nerves!"
	"That timer isn't going to stop for your dillydallying."
	"If you see any red flowers, you should eat them!"
	"Looking to get a better time? Lose some weight! That fat ass of yours must be whats slowing you down."
	"Looking for a quick way to heal after taking damage? Too bad! The damage you deal to yourself is permanent."
	"You are not supposed to be here."
	"You are going to die on this island."
	"You are running out of time."
	"TIP SERVER UNAVAILABLE TRY AGAIN LATER"
]

::ParkourText <- //10%
[
	"helloserverplugintogglethirdpresononmeplease"
	"Porting Parkour Fortress to VScript [462 of 133,308 bytes translated] [Estimated 6 Years Remaining]"
	"Questionable."
	"Animations and Chat Features are coming very soon!"
	"By playing Outer Wall, you hereby agree to a personal haunting on pf_thunderstorms."
	"By playing Outer Wall, you hereby agree to not post images of any of these high effort and extremly whitty tips."
	"By playing Outer Wall, you hereby agree to post bnuuy photos in #off-topic every day for the next 16 years."
	"Using the reset command has a 1 in 4,800,000,000 chance to ban you and wipe all your times. Don't believe me? You will soon enough."
	"Outer Wall+ is now available on WiiWare for 1,200 Wii Points! Buy now or forever feel the guilt of missing out!"
]

::CrudeText <- //1%
[
	"Fuck you!"
]

::TipPrefix <-
[
	"Tip:"
	"Helpful Tip:"
	"Here's some advice:"
	"Read this:"
	"Look here:"
	"Listen to this:"
	"I'll tip you off:"
	"Sponsored Tip:"
]

::DispenseTip <- function(client)
{
	local chance = RandomInt(1, 100);
	local message = "\x07" + "FF0000";
	
	message += TipPrefix[RandomInt(0, TipPrefix.len() - 1)] + "\x01" + " ";
	
	if(chance <= 1) //Crude Text 1%
		message += CrudeText[RandomInt(0, CrudeText.len() - 1)];
	else if(chance <= 11) //ParkourText 10%
		message += ParkourText[RandomInt(0, ParkourText.len() - 1)];
	else if(chance <= 21) //CrapText 10%
		message += CrapText[RandomInt(0, CrapText.len() - 1)];
	else
		message += TipText[RandomInt(0, TipText.len() - 1)];
		
	ClientPrint(client, HUD_PRINTTALK, message);
}