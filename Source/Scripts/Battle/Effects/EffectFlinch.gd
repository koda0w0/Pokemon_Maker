extends "res://Source/Scripts/Battle/Effect.gd"

const Flinch = preload("res://Source/Scripts/Battle/SecondaryStatus/Flinch.gd")

func _execute(pokemon):
	pokemon.add_secondary_status(Flinch.new())