extends CanvasLayer

export(PackedScene) var textbox_style

var style_container: Control
var text_label: RichTextLabel
onready var container := $Container

func set_textbox_style(value: PackedScene) -> void:
	textbox_style = value
	if style_container != null:
		remove_child(style_container)
	if textbox_style != null:
		style_container = textbox_style.instance();
		container.add_child(style_container)
		container.move_child(style_container, 0)
		text_label = get_node("Container/" + style_container.name + "/" + style_container.text_node)

func _ready() -> void:
	set_physics_process(false)
	set_textbox_style(textbox_style)
	style_container._hide()
