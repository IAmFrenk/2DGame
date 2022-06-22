extends CanvasLayer

const CHAR_READ_RATE = 0.04

onready var textbox_container = $TextboxContainer
onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label
onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []

func _ready():
	print("Starting state: " + current_state_to_string())
	hide_textbox();
	queue_text("1 oke fijn om te horen. oke fijn om te horen. oke fijn om te horen. oke fijn om te horen.")
	queue_text("2 oke fijn om te horen. oke fijn om te horen. oke fijn om te horen. oke fijn om te horen.")
	queue_text("3 oke fijn om te horen. oke fijn om te horen. oke fijn om te horen. oke fijn om te horen.")
	queue_text("4 oke fijn om te horen. oke fijn om te horen. oke fijn om te horen. oke fijn om te horen.")

func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.percent_visible = 1.0
				$Tween.stop_all()
				show_end_symbol()
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				hide_textbox()

func queue_text(next_text):
	text_queue.push_back(next_text)

func display_text():
	var next_text = text_queue.pop_front()
	change_state(State.READING)
	label.text = next_text
	show_textbox()
	hide_end_symbol()
	$Tween.interpolate_property(
		label, "percent_visible", 0.0, 1.0,
		len(next_text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func hide_textbox():
	if text_queue.empty():
		start_symbol.text = ""
		label.text = ""
		hide_end_symbol()
		textbox_container.hide()

func _on_Tween_tween_all_completed():
	change_state(State.FINISHED)
	show_end_symbol()

func change_state(next_state):
	current_state = next_state
	print("Changing state to: " + state_enum_to_string(next_state))

func state_enum_to_string(state):
	match state:
		State.READY:
			return "State.READY"
		State.READING:
			return "State.READING"
		State.FINISHED:
			return "State.FINISHED"
	return "Unknown State"

func current_state_to_string():
	return state_enum_to_string(current_state)

func show_end_symbol():
	end_symbol.text = "v"

func hide_end_symbol():
	end_symbol.text = ""
