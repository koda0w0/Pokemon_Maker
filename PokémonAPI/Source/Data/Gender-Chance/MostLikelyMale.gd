extends "res://Source/Data/GenderChance.gd"

func _generate_gender():
	if Utils.trigger(0.875):
		return Gender.Male
	return Gender.Female