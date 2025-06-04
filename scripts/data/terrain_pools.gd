# Pantheon and Void terrain pools for random assignment

const PANTHEON_TERRAIN_POOLS = {
	"GREEK": [
		preload("res://scripts/data/terrains/mount_olympus.tres"),
		preload("res://scripts/data/terrains/parnassus.tres"),
		preload("res://scripts/data/terrains/asphodel_field.tres"),
		preload("res://scripts/data/terrains/river_styx.tres"),
		preload("res://scripts/data/terrains/gate_of_tartarus.tres")
	],
	"NORSE": [
		preload("res://scripts/data/terrains/hall_of_valhalla.tres"),
		preload("res://scripts/data/terrains/yggdrasil_roots.tres"),
		preload("res://scripts/data/terrains/bifrost.tres"),
		preload("res://scripts/data/terrains/jotunheim.tres"),
		preload("res://scripts/data/terrains/jormundgandr_nest.tres")
	],
	"EGYPTIAN": [
		preload("res://scripts/data/terrains/fertile_banks.tres"),
		preload("res://scripts/data/terrains/hall_of_maat.tres"),
		preload("res://scripts/data/terrains/karnak_hypostyle_hall.tres"),
		preload("res://scripts/data/terrains/duat_shifting_sands.tres"),
		preload("res://scripts/data/terrains/lake_of_fire.tres")
	],	
	"CELTIC": [
		preload("res://scripts/data/terrains/groves_of_avalon.tres"),
		preload("res://scripts/data/terrains/tir_na_nog.tres"),
		preload("res://scripts/data/terrains/caer_sidi.tres"),
		preload("res://scripts/data/terrains/ancient_dolmen.tres"),
		preload("res://scripts/data/terrains/dagda_cauldron.tres")
	],
	"SHINTO": [
		preload("res://scripts/data/terrains/mount_fuji_spirit_peak.tres"),
		preload("res://scripts/data/terrains/sanzu_river.tres"),
		preload("res://scripts/data/terrains/takamagahara.tres"),
		preload("res://scripts/data/terrains/onogoro_island.tres"),
		preload("res://scripts/data/terrains/ama-no-iwato.tres")
	],
	"HINDU": [
		preload("res://scripts/data/terrains/dvaita_forest.tres"),
		preload("res://scripts/data/terrains/svargaloka.tres"),
		preload("res://scripts/data/terrains/mystical_lotus_pond.tres"),
		preload("res://scripts/data/terrains/sumeru.tres"),
		preload("res://scripts/data/terrains/vishnuloka.tres")
	],
	"CHINESE": [
		preload("res://scripts/data/terrains/jade_court.tres"),
		preload("res://scripts/data/terrains/eight_pillars.tres"),
		preload("res://scripts/data/terrains/kunlun_summit.tres"),
		preload("res://scripts/data/terrains/youdu.tres"),
		preload("res://scripts/data/terrains/fusang.tres")
	],	
	"MESOPOTAMIAN": [
		preload("res://scripts/data/terrains/aratta.tres"),
		preload("res://scripts/data/terrains/ekur.tres"),
		preload("res://scripts/data/terrains/cedar_forest.tres"),
		preload("res://scripts/data/terrains/ghostly_hall_of_ur.tres"),
		preload("res://scripts/data/terrains/plains_of_the_two_rivers.tres")
	],	
	"AZTEC": [
		preload("res://scripts/data/terrains/omeyocan.tres"),
		preload("res://scripts/data/terrains/tlalocan.tres"),
		preload("res://scripts/data/terrains/tlillan-tlapallan.tres"),
		preload("res://scripts/data/terrains/mictlan_nine_layers.tres"),
		preload("res://scripts/data/terrains/warrior_garden.tres")
	],
	"MAYA": [
		preload("res://scripts/data/terrains/xibalba.tres"),
		preload("res://scripts/data/terrains/itzam_cab_ain_corpse.tres"),
		preload("res://scripts/data/terrains/original_maize_field.tres"),
		preload("res://scripts/data/terrains/lying-down-sky.tres"),
		preload("res://scripts/data/terrains/monkey_brothers_workshop.tres")
	],
	"YORUBA": [
		preload("res://scripts/data/terrains/ile-ife.tres"),
		preload("res://scripts/data/terrains/osun-osogbo_sacred_grove.tres"),
		preload("res://scripts/data/terrains/olukun_harbor.tres"),
		preload("res://scripts/data/terrains/oshun_flowing_river.tres"),
		preload("res://scripts/data/terrains/ara_orun.tres")
	],
	"ZOROASTRIAN": [
		preload("res://scripts/data/terrains/eternal_fire_temple.tres"),
		preload("res://scripts/data/terrains/temple_of_asha_vahishta.tres"),
		preload("res://scripts/data/terrains/paristan.tres"),
		preload("res://scripts/data/terrains/mount_qaf.tres"),
		preload("res://scripts/data/terrains/hara_berezaiti.tres")
	],
	"POLYNESIAN": [
		preload("res://scripts/data/terrains/halemaumau_crater.tres"),
		preload("res://scripts/data/terrains/sun-snaring_beach.tres"),
		preload("res://scripts/data/terrains/deepest_lagoon.tres"),
		preload("res://scripts/data/terrains/sacred_stone_platform.tres"),
		preload("res://scripts/data/terrains/puku-puhipuhi.tres")
	],
	"KALEVALA": [
		preload("res://scripts/data/terrains/vainamoinen_ancient_forge.tres"),
		preload("res://scripts/data/terrains/lintukoto.tres"),
		preload("res://scripts/data/terrains/tuonela.tres"),
		preload("res://scripts/data/terrains/linnunrata.tres"),
		preload("res://scripts/data/terrains/great_bear_celestial_path.tres")
	],
	"IROQUOIS": [
		preload("res://scripts/data/terrains/great_turtle_back.tres"),
		preload("res://scripts/data/terrains/cave_below_the_earth.tres"),
		preload("res://scripts/data/terrains/hah-gweh-di-yu_abode.tres"),
		preload("res://scripts/data/terrains/ha-qweh-da-et-gah_hall.tres"),
		preload("res://scripts/data/terrains/sky_world.tres")
	],
}

const VOID_TERRAIN_POOL = {
	# Cthulhu
	"THE DREAMING MAW": [
	preload("res://scripts/data/terrains/sunken_citadel.tres"),
	preload("res://scripts/data/terrains/dream_chamber.tres"),
	preload("res://scripts/data/terrains/drowned_halls_of_rlyeh.tres"),
	preload("res://scripts/data/terrains/whispering_reefs.tres"),
	preload("res://scripts/data/terrains/crushing_depths.tres")
	],
	# Nyarlathotep
	"THE INFINITE MESSENGER": [
	preload("res://scripts/data/terrains/labyrinth_of_shifting_faces.tres"),
	preload("res://scripts/data/terrains/vault_of_echoes.tres"),
	preload("res://scripts/data/terrains/procession_of_gloom.tres"),
	preload("res://scripts/data/terrains/veiled_sphinx.tres"),
	preload("res://scripts/data/terrains/twisted_mirror_dimension.tres")
	],
	# Azathoth
	"THE PRIMAL ROIL": [
	preload("res://scripts/data/terrains/pulsating_nexus.tres"),
	preload("res://scripts/data/terrains/dreamers_chasm.tres"),
	preload("res://scripts/data/terrains/throne_of_cosmic_cacophony.tres"),
	preload("res://scripts/data/terrains/astral_stream.tres"),
	preload("res://scripts/data/terrains/nucleus_of_genesis.tres")
	],
	# Yog-Sothoth
	"THE DIMENSIONAL WEAVE": [
	preload("res://scripts/data/terrains/whispering_gates.tres"),
	preload("res://scripts/data/terrains/reality_node.tres"),
	preload("res://scripts/data/terrains/omniscient_conflux.tres"),
	preload("res://scripts/data/terrains/vault_of_lost_keys.tres"),
	preload("res://scripts/data/terrains/infinite_beyond.tres")
	],
	# Shub-Niggurath
	"THE BLACK FERTILITY": [
	preload("res://scripts/data/terrains/grotto_of_propagation.tres"),
	preload("res://scripts/data/terrains/flesh_cauldron.tres"),
	preload("res://scripts/data/terrains/thousandfold_births.tres"),
	preload("res://scripts/data/terrains/glade_of_dark_motherhood.tres"),
	preload("res://scripts/data/terrains/bleeding_thicket.tres")
	],
	# Hastur
	"THE PALE SIGN": [
	preload("res://scripts/data/terrains/shrouded_shores_of_hali.tres"),
	preload("res://scripts/data/terrains/streets_of_carcosa.tres"),
	preload("res://scripts/data/terrains/theatre_of_destiny.tres"),
	preload("res://scripts/data/terrains/yellow_mist_downs.tres"),
	preload("res://scripts/data/terrains/palace_of_the_hidden_king.tres")
	],	
	# Dagon
	"THE ABYSSAL STALKER": [
	preload("res://scripts/data/terrains/sunken_city_of_yhanthlei.tres"),
	preload("res://scripts/data/terrains/deep_one_ritual_chambers.tres"),
	preload("res://scripts/data/terrains/twisted_tidepool.tres"),
	preload("res://scripts/data/terrains/grotto_of_the_starheaded_spawn.tres"),
	preload("res://scripts/data/terrains/oceanic_midnight.tres")
	],	
	# The Great Race of Yith
	"THE TIME-ECHOING SPIRES": [
	preload("res://scripts/data/terrains/the_library_of_eons.tres"),
	preload("res://scripts/data/terrains/displaced_corridors.tres"),
	preload("res://scripts/data/terrains/forgotten_knowledge_vault.tres"),
	preload("res://scripts/data/terrains/cone_shaped_city.tres"),
	preload("res://scripts/data/terrains/temporal_anomaly_field.tres")
	],	
	# The Great Race of Yith
	"THE WEAVER CHASM": [
	preload("res://scripts/data/terrains/loom_of_endless_silk.tres"),
	preload("res://scripts/data/terrains/pit_of_maddening_threads.tres"),
	preload("res://scripts/data/terrains/mount_voormithadreth.tres"),
	preload("res://scripts/data/terrains/trapped_chambers.tres"),
	preload("res://scripts/data/terrains/dream_nexus.tres")
	],		
	# The Nameless Mist
	"THE FORMLESS VEIL": [
	preload("res://scripts/data/terrains/shroud_of_oblivion.tres"),
	preload("res://scripts/data/terrains/echoing_vapors.tres"),
	preload("res://scripts/data/terrains/cloud_of_horrors.tres"),
	preload("res://scripts/data/terrains/misty_field_of_illusions.tres"),
	preload("res://scripts/data/terrains/ephemeral_nothingness.tres")
	],	
	# Tsathoggua
	"THE SLUMBERING ABYSS": [
	preload("res://scripts/data/terrains/caverns_of_hibernating_filth.tres"),
	preload("res://scripts/data/terrains/unholy_repose.tres"),
	preload("res://scripts/data/terrains/toad_god_dream.tres"),
	preload("res://scripts/data/terrains/pool_of_primeval_slime.tres"),
	preload("res://scripts/data/terrains/chambers_of_gluttony.tres")
	],
	# Nug and Yeb
	"THE CORRUPTED TWINS": [
	preload("res://scripts/data/terrains/fractured_birthing_ground.tres"),
	preload("res://scripts/data/terrains/blighted_chasm.tres"),
	preload("res://scripts/data/terrains/sanctuary_of_aberrations.tres"),
	preload("res://scripts/data/terrains/twisted_progeny_pits.tres"),
	preload("res://scripts/data/terrains/chambers_of_form.tres")
	],	
	# Ithaqua
	"THE FROST HARBRINGER": [
	preload("res://scripts/data/terrains/windswept_glaciers.tres"),
	preload("res://scripts/data/terrains/icy_peaks_of_endless_hunt.tres"),
	preload("res://scripts/data/terrains/chasm_of_frozen_screams.tres"),
	preload("res://scripts/data/terrains/veiled_solitude.tres"),
	preload("res://scripts/data/terrains/trail_of_footless_prints.tres")
	],		
	# Zhar and Lloigor
	"THE DUALITY OF DESOLATION": [
	preload("res://scripts/data/terrains/desert_of_lost_minds.tres"),
	preload("res://scripts/data/terrains/scorched_plains.tres"),
	preload("res://scripts/data/terrains/vault_of_imprisioned_winds.tres"),
	preload("res://scripts/data/terrains/wasteland_of_echoes.tres"),
	preload("res://scripts/data/terrains/dissecated_ruins.tres")
	],	
	# Vulthoom
	"THE BLIGHTED BLOOM": [
	preload("res://scripts/data/terrains/fungal_gardens.tres"),
	preload("res://scripts/data/terrains/crystal_spore_caves.tres"),
	preload("res://scripts/data/terrains/psychedelic_field.tres"),
	preload("res://scripts/data/terrains/chambers_of_maddening_arona.tres"),
	preload("res://scripts/data/terrains/root_of_the_cosmos.tres")
	],		
	# Vulthoom
	"THE ELDEST PUTRESENCE": [
	preload("res://scripts/data/terrains/mire_of_decay.tres"),
	preload("res://scripts/data/terrains/pit_of_antilife.tres"),
	preload("res://scripts/data/terrains/gland_of_corruption.tres"),
	preload("res://scripts/data/terrains/swelling_charnel_mound.tres"),
	preload("res://scripts/data/terrains/necrotic_sea.tres")
	]	
}

const PLAYER_TERRAIN_POOL = [
	preload("res://scripts/data/terrains/PlayerTerrains/alexandrian_great_library.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/cleopatra_throne_room.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/da_vinci_ingenuity_workshop.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/hanging_gardens_canopy.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/roman_senate_floor.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/silk_road_grand_bazaar.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/sun_tzu_strategy_tent.tres"),
	preload("res://scripts/data/terrains/PlayerTerrains/lighthouse_of_pharos.tres")
	
]
