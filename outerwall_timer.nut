const PF_MEDAL_MODEL = "models/beepin/pf_medal/pf_medal.mdl"
const PF_MEDAL_SKIN_IRIDECENT = 1;
const PF_MEDAL_SKIN_GOLD = 2;
const PF_MEDAL_SKIN_SILVER = 3;
const PF_MEDAL_SKIN_BRONZE = 4;
const ZONE_COUNT = 8;

::Medals <-
[
	"Bronze",
	"Silver",
	"Gold",
	"Iridecent"
]

::MedalColors <-
[
	"D2691E", //bronze
	"C0C0C0", //silver
	"FFD700", //gold
	"B71111" //iridecence
]

::ZoneTimes <-
[
	// bronze, silver, gold, iridecence
	
	[85, 70, 50, 35], //oside
	[60, 45, 35, 30], //last cave
	[70, 55, 45, 30], //balcony
	[65, 45, 35, 25], //inner wall
	[135, 100, 70, 60], //hell
	[145, 110, 80, 75], //wind fortress
	[155, 135, 115, 100], //sand pit
	[155, 135, 115, 100] //final cave
]

::MedalLocations <-
[
	Vector(2328,896,-11928), //oside
	Vector(5472,-2688,12056), //lastcave
	Vector(4704,-4368,14056), //balcony
	Vector(-4736,-4456,-12728), //inner wall
	Vector(-5696,-1247,12457), //hell
	Vector(5663,4704,14856), //wind fortress
	Vector(4928,6944,-13392) //sand pit
	Vector(4928,6944,-13392) //final cave
]

::ZoneNames <-
[
	"Outer Wall's",
	"Last Cave's",
	"Balcony's",
	"Inner Wall's",
	"Sacred Grounds'",
	"Wind Fortress'",
	"Sand Pit's",
	"Final Cave's"
]

::MessagePrefixesIridecence <-
[
	"Faster than fast! You",
	"I don't believe it! You",
	"There's no way! You",
	"Did you cheat? That was TOO fast! You",
	"You're a damn legend! You",
	"You're the best of the best! You"
]

::MessagePrefixesGold <-
[
	"Sweet! You",
	"Amazing Job! You",
	"Alright! You",
	"Excellent! You",
	"That was fast! You",
]

::MessagePrefixesSilver <-
[
	"You're getting somewhere! You",
	"Good job, you",
	"Neat, you",
	"Not too shabby, you",
	"Decently fast, you"
]

::MessagePrefixesBronze <-
[
	"Not bad, but not great either, you",
	"Eh, you",
	"Not very fast... You",
	"That could've gone better, you"
]

::MessagePostfixesSilver <-
[
	", now go for Gold!",
	", now can you reach Gold?",
	"... Now beat the Gold time!",
	"... Now grab that Gold!",
	", though the Gold is still up for grabs!",
	", but y'know the real treasure is Gold, right?"
]

::MessagePostfixesBronze <-
[
	", atleast try to get Silver, yeah?",
	", I know you can do better than that...",
	"... C'mon now, atleast go for Silver!",
	"... Now bump that time up to a Silver!",
	"... Don't leave me hanging at just a Bronze now...",
	"... Atleast you can only go up from here!"
]

::PlayerStartTime <- array(MAX_PLAYERS, 0)
::PlayerBestMedalArray <- array(MAX_PLAYERS, array(ZoneNames.len(), -1))
::PlayerMedalTimeHUDStatusArray <- array(MAX_PLAYERS, false)

::CreateMedalTimeText <- function()
{
	for(local iArrayIndex = 0 ; iArrayIndex < ZoneNames.len() ; iArrayIndex++)
	{
		local MedalTimesText = ZoneNames[iArrayIndex] + " Medal Times" + "\n" + "------------------------" + "\n";
		for(local medal_index = 2 ; medal_index > -1 ; medal_index--)
		{
			local Milestone = ZoneTimes[iArrayIndex][medal_index];
			local Min = Milestone / 60;
			local Sec = Milestone - (Min * 60);
			local SecString = format("%s%i", Sec < 10 ? "0" : "", Sec);
			MedalTimesText += Medals[medal_index] + " time: " + Min + ":" + SecString + "\n";
		}
		
		local gametext = SpawnEntityFromTable("game_text",
		{
			targetname = "medaltimes_zone" + iArrayIndex,
			message = MedalTimesText,
			channel = 5,
			color = "240 255 0",
			fadein = 0,
			fadeout = 0.05,
			holdtime = 0.3,
			x = 0.025,
			y = 0.375
		})
		
		Entities.DispatchSpawn(gametext);
	}
}

::SetMedalTimeHUD <- function(bSetHUD)
{
	local player_index = activator.GetEntityIndex();
	
	if(bSetHUD)
		EmitSoundOnClient(SND_CHECKPOINT, activator);
	
	PlayerMedalTimeHUDStatusArray[player_index] = bSetHUD;
}

::ResetMedalTimes <- function(player_index)
{
	for(local iArrayIndex = 0 ; iArrayIndex < ZoneNames.len() ; iArrayIndex++)
	{
		PlayerBestMedalArray[player_index][iArrayIndex] = -1;
	}
}

::MedalTextPrefix <- function(medal)
{
	switch(medal)
	{
		case 3: return MessagePrefixesIridecence[RandomInt(0, MessagePrefixesIridecence.len() - 1)];
		case 2: return MessagePrefixesGold[RandomInt(0, MessagePrefixesGold.len() - 1)];
		case 1: return MessagePrefixesSilver[RandomInt(0, MessagePrefixesSilver.len() - 1)];
		case 0: return MessagePrefixesBronze[RandomInt(0, MessagePrefixesBronze.len() - 1)];
		default: return "";
	}
}

::MedalTextPostfix <- function(medal)
{
	switch(medal)
	{
		case 3: return "!";
		case 2: return "!";
		case 1: return MessagePostfixesSilver[RandomInt(0, MessagePostfixesSilver.len() - 1)];
		case 0: return MessagePostfixesBronze[RandomInt(0, MessagePostfixesBronze.len() - 1)];
		default: return ".";
	}
}

::StartPlayerTimer <- function(client)
{
	local player_index = client.GetEntityIndex();
	PlayerStartTime[player_index] = Time();
}

::CheckPlayerMedal <- function(iZone, client)
{
	local player_index = client.GetEntityIndex();
	
	local player_best_medal = PlayerBestMedalArray[player_index][iZone];
	DebugPrint("Player " + player_index + "'s best medal for stage " + iZone + " is " + player_best_medal);
	
	local total_time = Time() - PlayerStartTime[player_index];
	DebugPrint("Player " + player_index + "'s time for stage " + iZone + " is " + total_time);
	
	local medal = null;
	local medal_times = ZoneTimes[iZone];
	
	for(local medal_index = 3 ; medal_index > -1 ; medal_index--)
	{
		if(total_time < medal_times[medal_index])
		{
			if(player_best_medal >= medal_index)
			{
				DebugPrint(player_best_medal + " is better than " + medal_index);
				return;
			}
			
			medal = medal_index;
			break;
		}
	}
	
	if(medal != null)
	{
		PlayerBestMedalArray[player_index][iZone] = medal;
		DebugPrint("Setting player " + player_index + "'s best medal for stage " + iZone + " to " + Medals[medal]);
		ClientPrint(client, HUD_PRINTTALK, "\x07" + MedalColors[medal] + MedalTextPrefix(medal) + " achieved " + ZoneNames[iZone] + " " + Medals[medal] + " medal" + MedalTextPostfix(medal));
		SpawnPropMedal(medal, iZone, client);
	}
}

::SpawnPropMedal <- function(medal_type, iZone, client)
{
	local prop_skin = null;
	local medal_sound = null;
	local prop_origin = MedalLocations[iZone];

	switch(medal_type)
	{
		case 3: prop_skin = PF_MEDAL_SKIN_IRIDECENT; medal_sound = SND_MEDAL_GOLD; break;
		case 2: prop_skin = PF_MEDAL_SKIN_GOLD; medal_sound = SND_MEDAL_GOLD; break;
		case 1: prop_skin = PF_MEDAL_SKIN_SILVER; medal_sound = SND_MEDAL_SILVER; break;
		case 0: prop_skin = PF_MEDAL_SKIN_BRONZE; medal_sound = SND_MEDAL_BRONZE; break;
		default: prop_skin = 5; medal_sound = null;
	}
	
	local medal = SpawnEntityFromTable("prop_dynamic",
	{
		model = PF_MEDAL_MODEL,
		skin = prop_skin,
		origin = prop_origin,
		modelscale = 1.0,
		DefaultAnim = "spin",
		playbackrate = 0.50,
		solid = 0
	})
	
	Entities.DispatchSpawn(medal);
	client.EmitSound(medal_sound);
	local particle_origin = prop_origin;
	particle_origin.z += 20;
	DispatchParticleEffect("outerwall_medal_" + Medals[medal_type], particle_origin, Vector(0,90,0));
	EntFireByHandle(medal, "Kill", "", 10.0, client, null);
}