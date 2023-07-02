::PyroIdleSounds <-
[
    "Pyro.GoodJob01"
	"Pyro.Taunts03"
	"Pyro.HighFive02"
	"Pyro.LaughEvil02"
	"Pyro.LaughEvil03"
	"Pyro.LaughEvil04"
	"Pyro.NeedTeleporter01"
	"pyro_taunt_conga_random_fun1"
	"pyro_taunt_headbutt_success_windup"
	"pyro_taunt_headbutt_success_exert"
    "pyro_taunt_partytrick_4_laugh"
    "pyro_taunt_spring_rider_pyro_taunt_head_pain_04"
    "pyro_taunt_flip_random_waiting2"
    "pyro_taunt_flip_random_waiting1"
]

::PyroSoundsPrecache <-
[
    "vo/taunts/pyro/pyro_taunt_head_pain_04.mp3"
    "vo/taunts/pyro/pyro_taunt_ballon_11.mp3"
    "vo/taunts/pyro_highfive02.mp3"
    "vo/taunts/pyro/pyro_taunt_head_pain_22.mp3"
    "vo/taunts/pyro/pyro_taunt_head_pain_21.mp3"
    "vo/taunts/pyro/pyro_taunt_int_22.mp3"
    "vo/taunts/pyro/pyro_taunt_int_15.mp3"
    "vo/taunts/pyro/pyro_taunt_int_13.mp3"
    "vo/taunts/pyro/pyro_taunt_int_12.mp3"
    "vo/taunts/pyro/pyro_taunt_int_11.mp3"
    "vo/taunts/pyro/pyro_taunt_int_07.mp3"
    "vo/taunts/pyro/pyro_taunt_exert_12.mp3"
    "vo/taunts/pyro/pyro_taunt_cong_fun_10.mp3"
    "vo/taunts/pyro/pyro_taunt_cong_fun_09.mp3"
    "vo/taunts/pyro/pyro_taunt_flip_admire_06.mp3"
    "vo/taunts/pyro/pyro_taunt_flip_admire_05.mp3"
    "vo/taunts/pyro/pyro_taunt_flip_admire_03.mp3"
    "vo/taunts/pyro/pyro_taunt_flip_admire_02.mp3"
    "vo/taunts/pyro/pyro_taunt_flip_admire_01.mp3"

    "weapons/flame_thrower_airblast.wav"
]

::PyroPlayRandomSound <- function()
{
    Entities.FindByName(null, "fuck_you_pyro").EmitSound(PyroIdleSounds[RandomInt(0, PyroIdleSounds.len() - 1)]);
}

::PyroPlayFuckYouSounds <- function()
{
    local pyro = Entities.FindByName(null, "fuck_you_pyro");
    pyro.EmitSound("weapons/flame_thrower_airblast.wav");
    pyro.EmitSound("Pyro.LaughEvil01");
}

::GoalParticleName <-
[
    "goal_confetti_oside"
    "goal_confetti_lastcave"
    "goal_confetti_balcony"
    "goal_confetti_innerwall"
    "goal_confetti_hell"
    "goal_confetti_finalcave"
    "goal_confetti_windfortress"
]

::GoalParticle1Position <-
[
    Vector(2218, 827, -11976)
    Vector(5354, -4805, 12008)
    Vector(4822, -6347, 14008)
    Vector(-4709, -8234, -12776)
    Vector(-5814, -1316, 12409)
    Vector(2011, 4822, 14808)
    Vector(5003, 6826, -13448)
]

::GoalParticle1Rotation <-
[
    Vector(0, 0, 30)
    Vector(0, 30, 0)
    Vector(0, 210, 0)
    Vector(0, 300, 0)
    Vector(0, 30, 0)
    Vector(0, 300, 0)
    Vector(0, 60, 0)
]

::GoalParticle2Position <-
[
    Vector(2454, 827, -11976)
    Vector(5590, -4805, 12008)
    Vector(4586, -6347, 14008)
    Vector(-4709, -8470, -12776)
    Vector(-5578, -1316, 12409)
    Vector(2011, 4586, 14808)
    Vector(5003, 7062, -13448)
]

::GoalParticle2Rotation <-
[
    Vector(0, 0, 150)
    Vector(0, 150, 0)
    Vector(0, 330, 0)
    Vector(0, 60, 0)
    Vector(0, 150, 0)
    Vector(0, 60, 0)
    Vector(0, 300, 0)
]

::SpawnGoalParticle <- function(iZone)
{
    DispatchParticleEffect(GoalParticleName[iZone], GoalParticle1Position[iZone], GoalParticle1Rotation[iZone] + Vector(0, 90, 0));
    DispatchParticleEffect(GoalParticleName[iZone], GoalParticle2Position[iZone], GoalParticle2Rotation[iZone] + Vector(0, 90, 0));

    local sound_data_1 = {
        sound_name = "outerwall/goal.mp3",
        origin = GoalParticle1Position[iZone]
    };

    local sound_data_2 = {
        sound_name = "outerwall/goal.mp3",
        origin = GoalParticle2Position[iZone]
    };

    EmitSoundEx(sound_data_1);
    EmitSoundEx(sound_data_2);
}