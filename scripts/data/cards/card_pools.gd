# Card pools for each pantheon for easy filtering and deck generation

const GREEK_PANTHEON = [
	# Divine Soldiers
	preload("res://scripts/data/cards/divine_pantheons/greek/acropolis_guardian.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/olympian_strategist.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/voice_of_prophecy.tres"),
	# Levy
	preload("res://scripts/data/cards/divine_pantheons/greek/olympian_guard.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/athenian_skirmisher.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/centaur_archer.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/spartan_vanguard.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/hoplite_phalanx.tres"),
	# Spell
	preload("res://scripts/data/cards/divine_pantheons/greek/bolt_of_the_skyfather.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/oracle_insight.tres"),
	preload("res://scripts/data/cards/divine_pantheons/greek/ambrosial_blessing.tres")
]

const NORSE_PANTHEON = [
	# Divine Soldiers
	preload("res://scripts/data/cards/divine_pantheons/norse/berserker_herald.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/einherjar_champion.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/seer_of_frost.tres"),
	# Levy
	preload("res://scripts/data/cards/divine_pantheons/norse/draugr_warrior.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/fylgja_guide.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/jotunn_brute.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/shieldmaiden_corps.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/thrall_raider.tres"),
	# Spells
	preload("res://scripts/data/cards/divine_pantheons/norse/rune_of_warding.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/gungnir_strike.tres"),
	preload("res://scripts/data/cards/divine_pantheons/norse/skuld_weave.tres")
]

const EGYPTIAN_PANTHEON = [
	# Divine Soldiers
	preload("res://scripts/data/cards/divine_pantheons/egyptian/eye_of_ra.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/scribe_of_thoth.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/holder_of_the_scale.tres"),
	# Levy
	preload("res://scripts/data/cards/divine_pantheons/egyptian/ankh_bearer_guard.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/crocodile_hunter.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/hieroglyph_engraver.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/scorpion_warrior.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/temple_aspirant.tres"),
	# Spells
	preload("res://scripts/data/cards/divine_pantheons/egyptian/shifting_sands.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/afterlife_glimpse.tres"),
	preload("res://scripts/data/cards/divine_pantheons/egyptian/scarab_swarm.tres")	
]

const DREAMING_MAW = [
	# Divine Soldiers
	preload("res://scripts/data/cards/void_pantheons/dreaming_maw/abyssal_watcher.tres"),
	preload("res://scripts/data/cards/void_pantheons/dreaming_maw/priest_of_sunken_stars.tres"),
	preload("res://scripts/data/cards/void_pantheons/dreaming_maw/sleeper_eldest_scion.tres"),
	# Levy
	preload("res://scripts/data/cards/void_pantheons/levies/amorphous_thrall.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/mindless_drone.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/sanity_devourer.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/shoggoth_spawn.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/veiled_acolyte.tres"),
	# Spells
	preload("res://scripts/data/cards/void_pantheons/spells/chaotic_burst.tres"),
	preload("res://scripts/data/cards/void_pantheons/dreaming_maw/deep_heartbeat.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/echoing_madness.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/mind_flaying_scream.tres")	
]

const INFINITE_MESSENGER = [
	# Divine Soldiers
	preload("res://scripts/data/cards/void_pantheons/infinite_messenger/avatar_of_secrecy.tres"),
	preload("res://scripts/data/cards/void_pantheons/infinite_messenger/faceless_deceiver.tres"),
	preload("res://scripts/data/cards/void_pantheons/infinite_messenger/herald_of_chaos.tres"),
	# Levy
	preload("res://scripts/data/cards/void_pantheons/levies/amorphous_thrall.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/mindless_drone.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/sanity_devourer.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/shoggoth_spawn.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/veiled_acolyte.tres"),
	# Spells
	preload("res://scripts/data/cards/void_pantheons/infinite_messenger/illusionary_veil.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/chaotic_burst.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/echoing_madness.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/mind_flaying_scream.tres")	
]

const PRIMAL_ROIL = [
	# Divine Soldiers
	preload("res://scripts/data/cards/void_pantheons/primal_roil/blind_spawn.tres"),
	preload("res://scripts/data/cards/void_pantheons/primal_roil/chaos_engine.tres"),
	preload("res://scripts/data/cards/void_pantheons/primal_roil/idiot_god_fragment.tres"),
	# Levy
	preload("res://scripts/data/cards/void_pantheons/levies/amorphous_thrall.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/mindless_drone.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/sanity_devourer.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/shoggoth_spawn.tres"),
	preload("res://scripts/data/cards/void_pantheons/levies/veiled_acolyte.tres"),
	# Spells
	preload("res://scripts/data/cards/void_pantheons/spells/chaotic_burst.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/echoing_madness.tres"),
	preload("res://scripts/data/cards/void_pantheons/spells/mind_flaying_scream.tres")	
]


# ...repeat for each pantheon
