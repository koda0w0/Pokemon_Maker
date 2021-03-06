extends "Importer.gd"

const Move = preload("res://Source/Data/Move.gd")
const PhysicalMove = preload("res://Source/Data/PhysicalMove.gd")
const SpecialMove = preload("res://Source/Data/SpecialMove.gd")
const StatusMove = preload("res://Source/Data/StatusMove.gd")

const Effect = preload("res://Source/Scripts/Battle/Effect.gd")
const EffectBoost = preload("res://Source/Scripts/Battle/Effects/EffectBoost.gd")
const EffectParalysis = preload("res://Source/Scripts/Battle/Effects/EffectParalysis.gd")
const EffectBurn = preload("res://Source/Scripts/Battle/Effects/EffectBurn.gd")
const EffectPoison = preload("res://Source/Scripts/Battle/Effects/EffectPoison.gd")
const EffectBadPoison = preload("res://Source/Scripts/Battle/Effects/EffectBadPoison.gd")
const EffectSleep = preload("res://Source/Scripts/Battle/Effects/EffectSleep.gd")
const EffectFreeze = preload("res://Source/Scripts/Battle/Effects/EffectFreeze.gd")

const EffectConfusion = preload("res://Source/Scripts/Battle/Effects/EffectConfusion.gd")
const EffectFlinch = preload("res://Source/Scripts/Battle/Effects/EffectFlinch.gd")

const Utils = preload("res://Source/Scripts/Utils.gd")

var contest_effects = []
var moves = []
var api_items = []

func _create_item():
	match api_item["damage_class"]["name"]:
		"status": return StatusMove.new()
		"physical": return PhysicalMove.new()
		"special": return SpecialMove.new()

func _import_item(item):
	item.move_name = api_item["name"].capitalize()
	item.type = load("res://Source/Data/Type/" + api_item["type"]["name"] + ".tscn")
	match api_item["damage_class"]["name"]:
		"status": item.damage_class = Move.DamageClass.Status
		"physical": item.damage_class = Move.DamageClass.Physical
		"special": item.damage_class = Move.DamageClass.Special
		
	if api_item["power"] != null:
		item.power = int(api_item["power"])
	if api_item["accuracy"] != null:
		item.accuracy = int(api_item["accuracy"])
	if api_item["priority"] != null:
		item.priority = int(api_item["priority"])
	if api_item["pp"] != null:
		item.pp = int(api_item["pp"])
	
	if api_item["meta"] != null:
		item.flags = 0
		var cat_name = api_item["meta"]["category"]["name"]
		if cat_name.find("damage") != -1:
			item.flags |= int(pow(2, 5))
		if cat_name.find("ailment") != -1:
			item.flags |= int(pow(2, 6))
		if cat_name.find("heal") != -1:
			item.flags |= int(pow(2, 7))
		if cat_name == "ohko":
			item.flags |= int(pow(2, 11))
		if cat_name == "field-effect":
			item.flags |= int(pow(2, 12))
		if cat_name == "whole_field_effect":
			item.flags |= int(pow(2, 13))
		if cat_name == "damage+lower":
			item.flags |= int(pow(2, 9))
		if cat_name == "damage+raise":
			item.flags |= int(pow(2, 10))
	
	if api_item["target"]["name"].find("selected-pokemon") != -1:
		item.hit_range = Move.HitRange.Opponent
	if api_item["target"]["name"] == "all-opponents" || api_item["target"]["name"] == "random-opponent":
		item.hit_range |= Move.HitRange.All_Opponents
	if api_item["target"]["name"] == "all-other-pokemon":
		item.hit_range |= Move.HitRange.All
	if api_item["target"]["name"] == "user" || api_item["target"]["name"] == "specific-move":
		item.hit_range |= Move.HitRange.User
	if api_item["target"]["name"] == "ally":
		item.hit_range |= Move.HitRange.Partner
	if api_item["target"]["name"] == "user-or-ally":
		item.hit_range |= Move.HitRange.User_or_Partner
	if api_item["target"]["name"] == "users-field" || api_item["target"]["name"] == "user-and-allies":
		item.hit_range |= Move.HitRange.User_Field
	if api_item["target"]["name"] == "opponents-field":
		item.hit_range |= Move.HitRange.Opponent_Field
	if api_item["target"]["name"] == "entire-field" || api_item["target"]["name"] == "all-pokemon":
		item.hit_range |= Move.HitRange.Entire_Field
	
	import_effects(item)
	
	if api_item["contest_type"] != null:
		match api_item["contest_type"]["name"]:
			"cool": item.contest_type = Move.ContestType.Cool
			"beauty": item.contest_type = Move.ContestType.Beauty
			"cute": item.contest_type = Move.ContestType.Cute
			"smart": item.contest_type = Move.ContestType.Smart
			"tough": item.contest_type = Move.ContestType.Tough
	
	if api_item["contest_effect"] != null:
		yield(get_contest_effect(api_item["contest_effect"]["url"]), "completed")
		item.contest_effect = load("res://Source/Data/Contest-Effect/contest_effect" + str(result["id"]) + ".tscn")
	item.description = get_en_description(api_item["flavor_text_entries"], "flavor_text")
	
	moves.append(item)
	api_items.append(api_item)
	yield(get_tree().create_timer(0), "timeout")

func _after_import():
	._after_import()
	var item
	var scene
	var path 
	var directory_name = destination + "/" + folder_name
	for i in moves.size():
		item = api_items[i]
		if item["contest_combos"] != null:
			import_combos("normal", i)
			import_combos("super", i)
			
			scene = PackedScene.new()
			scene.pack(moves[i])
			path = directory_name + "/" + moves[i].name + ".tscn"
			ResourceSaver.save(path, scene)
			pass

func import_effects(item):
	var effects
	if has_effect():
		effects = Utils.add_node_if_not_exists(item, item, "Effects")
		if api_item["stat_changes"].size() > 0:
			var effect = Utils.add_typed_node_if_not_exists(EffectBoost, effects, item, "Boosts")
			if api_item["meta"]["stat_chance"] == 0:
				effect.guaranteed = true
			else:
				effect.chance = api_item["meta"]["stat_chance"] / 100
			var flag_raise = int(pow(2, 10))
			if item.flags & flag_raise == flag_raise:
				effect.effected_pokemon = Effect.EffectedPokemon.User
			else:
				effect.effected_pokemon = Effect.EffectedPokemon.Target
			for stat_change in api_item["stat_changes"]:
				match stat_change["stat"]["name"]:
					"attack": effect.attack_boost = int(stat_change["change"])
					"defense": effect.defense_boost = int(stat_change["change"])
					"special-attack": effect.special_attack_boost = int(stat_change["change"])
					"special-denfense": effect.special_defense_boost = int(stat_change["change"])
					"speed": effect.speed_boost = int(stat_change["change"])
		if api_item["meta"]["ailment"]["name"] != "none":
			var effect
			match api_item["meta"]["ailment"]["name"]:
				"paralysis": effect = Utils.add_typed_node_if_not_exists(EffectParalysis, effects, item, "paralysis")
				"burn": effect = Utils.add_typed_node_if_not_exists(EffectBurn, effects, item, "burn")
				"poison": effect = Utils.add_typed_node_if_not_exists(EffectPoison, effects, item, "poison")
				"sleep": effect = Utils.add_typed_node_if_not_exists(EffectSleep, effects, item, "sleep")
				"freeze": effect = Utils.add_typed_node_if_not_exists(EffectFreeze, effects, item, "freeze")
				"confusion": effect = Utils.add_typed_node_if_not_exists(EffectConfusion, effects, item, "confusion")
			if effect != null:
				effect.effected_pokemon = Effect.EffectedPokemon.Target
				if api_item["effect_chance"] == null:
					effect.guaranteed = true
					effect.chance = 0
				else:
					effect.guaranteed = false
					effect.chance = api_item["effect_chance"] / 100
		if api_item["meta"]["flinch_chance"] > 0:
			var effect = Utils.add_typed_node_if_not_exists(EffectFlinch, effects, item, "flinch")
			effect.effected_pokemon = Effect.EffectedPokemon.Target
			if api_item["meta"]["flinch_chance"] == 100:
				effect.guaranteed = true
				effect.chance = 0
			else:
				effect.guaranteed = false
				effect.chance = api_item["meta"]["flinch_chance"] / 100

func has_effect() -> bool:
	return api_item["stat_changes"] != null || api_item["meta"]["ailment"]["name"] != "none"

func import_combos(contest: String, index: int):
	var item
	var move
	var node
	item = api_items[index]
	if item["contest_combos"][contest] != null:
		if item["contest_combos"][contest]["use_after"] != null:
			node = moves[index].get_node(contest)
			if node == null:
				node = Node.new()
				node.name = contest
				moves[index].add_child(node)
				node.owner = moves[index]
			for k in item["contest_combos"][contest]["use_after"].size():
				move = node.get_node(item["contest_combos"][contest]["use_after"][k]["name"])
				if move == null:
					move = Node.new()
					move.name = item["contest_combos"][contest]["use_after"][k]["name"]
					node.add_child(move)
					move.owner = moves[index]

func get_contest_effect(url):
	var id = int(url.substr(url.length() - 2, 1))
	for effect in contest_effects:
		if effect["id"] == id:
			result = effect
			yield(get_tree().create_timer(0), "timeout")
			return
	yield(do_request(api_item["contest_effect"]["url"], true), "completed")
	result = json.result
	contest_effects.append(result)
	