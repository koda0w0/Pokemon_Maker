extends Node

const Move = preload("res://Source/Scripts/Battle/Move.gd")

var pokemon
var trainer

func has_space():
	return get_child_count() < 4

func has_moves_left():
	for move in get_children():
		if move._can_use():
			return true
	return false

func swap(index1: int, index2: int):
	var move = get_child(index1)
	move_child(move, index2)

func learn(move: Move):
	if has_space():
		pass
	elif true: #should learn query
		#show Movepool
		get_children()[0] = move
		pass

func _enter_tree():
	pokemon = get_parent()
	trainer = pokemon.trainer