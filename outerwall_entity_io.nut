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

/*
::GoalParticleZone1 <-
[

]

::GoalParticleZone2 <-
[

]

::SpawnGoalParticle <- function(iZone)
{

}
*/