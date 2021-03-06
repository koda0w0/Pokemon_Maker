extends Node

const Utils = preload("res://Source/Scripts/Utils.gd")

export(String) var pokemon_name
export(int) var regional_dex_nr
export(int) var national_dex_nr

export(int) var hp
export(int) var attack
export(int) var defense
export(int) var special_attack
export(int) var special_defense
export(int) var speed

export(int) var catch_rate
export(int) var happiness
export(PackedScene) var gender_chance

export(int) var egg_cycles
export(int) var base_xp
export(PackedScene) var growth_rate
export(String) var category = ""
export(float) var height
export(float) var weight
export(PackedScene) var color
export(PackedScene) var shape

export(String, MULTILINE) var dex_entry

export(PackedScene) var sprite_collection

func get_sprite_collection() -> Node:
	return Utils.unpack(self, sprite_collection, "Sprites")
