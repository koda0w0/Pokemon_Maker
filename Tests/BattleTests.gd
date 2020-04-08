extends WATTest

const Battle = preload("res://Source/Scripts/Battle/Battle.gd")
const Pokemon = preload("res://Source/Scripts/Battle/Pokemon.gd")
const Movepool = preload("res://Source/Scripts/Battle/Movepool.gd")
const SPECIES_PATH = "res://Source/Data/Pokemon/"
const NATURE_PATH = "res://Source/Data/Nature/"
const MOVE_PATH = "res://Source/Data/Move/"

var battle_scene = preload("res://Scenes/BattleBase.tscn")
var trainer_scene = preload("res://Scenes/Trainer/TestTrainer.tscn")

var battle: Battle
var trainer1
var trainer2

func set_up():
	battle = battle_scene.instance()
	add_child(battle)
	trainer1 = trainer_scene.instance()
	trainer2 = trainer_scene.instance()
	battle.add_ally_trainer(trainer1)
	battle.add_opponent_trainer(trainer2)

func tear_down():
	remove_child(battle)

func create_basic_pokemon(name: String, level: int, moves: Array, nature: String) -> Pokemon:
	var pokemon = Pokemon.new()
	pokemon.species = load(SPECIES_PATH + name + ".tscn")
	pokemon.nature = load(NATURE_PATH + nature + ".tscn")
	pokemon.level = level
	pokemon.calculate_stats()
	pokemon.full_heal()
	for move in moves:
		pokemon.get_movepool().add_move(load(MOVE_PATH + move + ".tscn"))
	return pokemon

func test_add_pokemon():
	var charmander := create_basic_pokemon("charmander", 5, ["tackle"], "hardy")
	var squirtle := create_basic_pokemon("squirtle", 5, ["tackle"], "hardy")
	trainer1.pokemon_party.add_child(charmander)
	trainer2.pokemon_party.add_child(squirtle)
	
	expect.is_equal(1, trainer1.pokemon_party.get_pokemon_count(), "Trainer1 has 1 Pokemon")
	expect.is_equal(1, trainer2.pokemon_party.get_pokemon_count(), "Trainer2 has 1 Pokemon")
	
	expect.is_equal(18, charmander.current_hp, "Charmander has 18 hp")
	expect.is_equal(10, charmander.attack, "Charmander has 10 attack")
	expect.is_equal(9, charmander.defense, "Charmander has 9 defense")
	expect.is_equal(11, charmander.special_attack, "Charmander has 11 special attack")
	expect.is_equal(10, charmander.special_defense, "Charmander has 10 special defense")
	expect.is_equal(11, charmander.speed, "Charmander has 11 speed")
	
	expect.is_equal(19, squirtle.current_hp, "Squirtle has 19 hp")
	expect.is_equal(9, squirtle.attack, "Squirtle has 9 attack")
	expect.is_equal(11, squirtle.defense, "Squirtle has 11 defense")
	expect.is_equal(10, squirtle.special_attack, "Squirtle has 10 special attack")
	expect.is_equal(11, squirtle.special_defense, "Squirtle has 11 special defense")
	expect.is_equal(9, squirtle.speed, "Squirtle has 9 speed")

func test_modified_pokemon():
	var zangoose := create_basic_pokemon("zangoose", 42, ["tackle"], "adamant")
	var seviper := create_basic_pokemon("seviper", 69, ["tackle"], "hardy")
	
	zangoose.attack_iv = 31
	zangoose.speed_iv = 20
	zangoose.special_attack_iv = 5
	zangoose.attack_ev = 252
	zangoose.speed_ev = 252
	zangoose.calculate_stats()
	
	seviper.hp_iv = 12
	seviper.hp_ev = 252
	seviper.defense_iv = 28
	seviper.defense_ev = 128
	seviper.special_defense_ev = 128
	seviper.calculate_stats()
	seviper.current_hp = 9999
	
	expect.is_equal(155, zangoose.attack, "Zangoose has 155 attack")
	expect.is_equal(51, zangoose.special_attack, "Zangoose has 51 special_attack")
	expect.is_equal(115, zangoose.speed, "Zangoose has 115 speed")
	
	expect.is_equal(231, seviper.current_hp, "Seviper has 231 hp")
	expect.is_equal(129, seviper.defense, "Seviper has 129 defense")
	expect.is_equal(109, seviper.special_defense, "Seviper has 109 special_defense")

func test_get_last_moves():
	var scizor = create_basic_pokemon("scizor", 60, [], "hardy")
	var moves = scizor.get_last_learnable_moves()
	var movepool = scizor.get_movepool()
	for m in moves:
		movepool.add_move(m.move)
	
	expect.is_equal("Night-slash", movepool.get_move(3).get_move_data().move_name, "Scizor learned Night Slash")
	expect.is_equal("Double-hit", movepool.get_move(2).get_move_data().move_name, "Scizor learned Double Hit")
	expect.is_equal("Iron-head", movepool.get_move(1).get_move_data().move_name, "Scizor learned Iron Head")
	expect.is_equal("Swords-dance", movepool.get_move(0).get_move_data().move_name, "Scizor learned Swords Dance")
	
	var aggron = create_basic_pokemon("aggron", 40, [], "hardy")
	moves = aggron.get_last_learnable_moves()
	movepool = aggron.get_movepool()
	for m in moves:
		movepool.add_move(m.move)
	
	expect.is_equal("Take-down", movepool.get_move(3).get_move_data().move_name, "Aggron learned Take Down")
	expect.is_equal("Metal-sound", movepool.get_move(2).get_move_data().move_name, "Aggron learned Metal Sound")
	expect.is_equal("Iron-tail", movepool.get_move(1).get_move_data().move_name, "Aggron learned Iron Tail")
	expect.is_equal("Iron-defense", movepool.get_move(0).get_move_data().move_name, "Aggron learned Iron Defense")

func test_damage():
	var pidgeotto = create_basic_pokemon("pidgeotto", 25, ["gust", "tackle", "twister", "sand-attack"], "modest")
	var breloom = create_basic_pokemon("breloom", 35, ["seed-bomb", "mach-punch", "tackle", "swords-dance"], "gentle")
	trainer1.pokemon_party.add_child(pidgeotto)
	trainer2.pokemon_party.add_child(breloom)
	pidgeotto.calculate_stats()
	breloom.calculate_stats()
	battle.start_async()
	expect.is_equal(pidgeotto, trainer1.current_pokemon, "Trainer1's first pokemon is Pidgeotto")
	expect.is_equal(breloom, trainer2.current_pokemon, "Trainer2's first pokemon is Breloom")
	trainer1.custom_move("Gust", "")
	trainer2.custom_move("Tackle", "")
	expect.is_less_than(breloom.current_hp, 69, "Breloom's HP lower than 69")
	expect.is_less_than(pidgeotto.current_hp, 33, "Pidgeotto's's HP lower than 33")

func test_stat_change_damage():
	var milotic = create_basic_pokemon("milotic", 38, ["surf", "fake-tears"], "hardy")
	var furret = create_basic_pokemon("furret", 55, ["headbutt", "sharpen"], "hardy")
	trainer1.pokemon_party.add_child(milotic)
	trainer2.pokemon_party.add_child(furret)
	milotic.calculate_stats()
	furret.calculate_stats()
	battle.start_async()
	trainer1.custom_move("Fake-tears", "")
	trainer2.custom_move("Sharpen", "")
	trainer1.custom_move("Surf", "")
	trainer2.custom_move("Headbutt", "")
	print(milotic.current_defense)
	print(furret.current_attack)
	print(milotic.current_special_attack)
	print(furret.current_special_defense)
	expect.is_less_than(milotic.current_hp, 33, "Milotic's HP lower than 33")
	expect.is_less_than(furret.current_hp, 59, "Furret's's HP lower than 59")
	print(furret.current_hp)
	print(milotic.current_hp)

func pre():
	set_up()

func end():
	tear_down()