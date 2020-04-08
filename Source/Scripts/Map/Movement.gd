extends Node

const STANDING = 0
const WALKING = 1
const RUNNING = 2

var state = 0
var character
var body: KinematicBody2D
var direction: Vector2
var remaining_steps = 0

signal step_taken

func step_taken():
	if remaining_steps > 0:
		remaining_steps -= 1
	if remaining_steps == 0:
		character.stop()
	emit_signal("step_taken")

func step():
	if character.can_move():
		if state == WALKING:
			character.walk(1)
		elif state == RUNNING:
			character.run(1)

func walk(steps: int):
	if character.can_move() && state != WALKING:
		state = WALKING
		return _walk(steps)
	return false

func run(steps: int):
	if character.can_move() && state != RUNNING:
		state = RUNNING
		return _run(steps)
	return false

func stop():
	if state != STANDING:
		state = STANDING
		return _stop()
	return false

func _walk(steps: int):
	pass

func _run(steps: int):
	pass

func _stop():
	pass