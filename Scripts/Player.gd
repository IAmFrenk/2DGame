extends KinematicBody2D

enum STATE {
	IDLE,
	WALKING,
	JUMPING,
	FALLING,
	CLIMBING,
}

enum DIRECTION {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

const color_a = Color(255, 0, 0)
var from_a_1 = Vector2.ZERO
var from_a_2 = Vector2.ZERO
var from_a_3 = Vector2.ZERO
var from_a_4 = Vector2.ZERO
var to_a_1 = Vector2.ZERO
var to_a_2 = Vector2.ZERO
var to_a_3 = Vector2.ZERO
var to_a_4 = Vector2.ZERO

const color_b = Color(0, 255, 0)
var from_b_1 = Vector2.ZERO
var from_b_2 = Vector2.ZERO
var from_b_3 = Vector2.ZERO
var from_b_4 = Vector2.ZERO
var to_b_1 = Vector2.ZERO
var to_b_2 = Vector2.ZERO
var to_b_3 = Vector2.ZERO
var to_b_4 = Vector2.ZERO

const MOVEMENT_SPEED = 4
const TILE_SIZE = 16

onready var overworld_ray_cast = $OverworldRayCast2D
onready var ladder_ray_cast = $LadderRayCast2D
onready var a_ray_cast = $A_RayCast2D
onready var b_ray_cast = $B_RayCast2D
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")

var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
var percent_moved_to_next_tile = 0.0
var facing_right = true
var current_state = STATE.IDLE
var print_count = 0

var start_time

func _ready():
	initial_position = position
	start_time = OS.get_ticks_msec()

func _physics_process(delta):
	update()
	if current_state == STATE.IDLE:
#		if collision_in_direction(overworld_ray_cast, DIRECTION.DOWN, false) || collision_in_direction(ladder_ray_cast, DIRECTION.DOWN, false):
			process_player_movement_input()
#		else:
#			process_player_movement_input() # todo
#			input_direction = Vector2(0, 1)
#			set_state_falling()
#	elif current_state == STATE.WALKING || STATE.FALLING:
	else:
		move(delta)

func process_player_movement_input():
	if Input.is_action_pressed("ui_accept"):
		print_and_draw_ray_cast_a()
	
	if Input.is_action_pressed("ui_cancel"):
		print_and_draw_ray_cast_b()
	
	if Input.is_action_pressed("left") && Input.is_action_pressed("right"):
		return
	
	if Input.is_action_pressed("up") && Input.is_action_pressed("down"):
		return
	
	if !Input.is_action_pressed("left") && !Input.is_action_pressed("right") && !Input.is_action_pressed("up") && !Input.is_action_pressed("down"):
		return
	
	if Input.is_action_pressed("left"):
		try_move_left()
	elif Input.is_action_pressed("right"):
		try_move_right()
	elif Input.is_action_pressed("up"):
		try_move_up()
	elif Input.is_action_pressed("down"):
		try_move_down()
	
#	if input_direction.y == 0:
#		input_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
#		frenk_print(input_direction.x)
#	if input_direction.x == 0:
#		input_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
#		frenk_print(input_direction.y)
#
#	if input_direction != Vector2.ZERO && input_direction.y != 1:
#		start_time = OS.get_ticks_msec()
#		set_state_walking()

func try_move_left():	
	facing_right = false
	input_direction = Vector2(-1, 0)
	set_state_walking()
	
#	if current_state == STATE.CLIMBING && collision_in_direction(overworld_ray_cast, DIRECTION.DOWN, true):
#		frenk_print("Won't move because climbing with no Overworld ground below.")
#		return

func try_move_right():
	facing_right = true
#	if current_state == STATE.CLIMBING && collision_in_direction(overworld_ray_cast, DIRECTION.DOWN, true):
#		frenk_print("Won't move because climbing with no Overworld ground below.")
#		return
	input_direction = Vector2(1, 0)
	set_state_walking()

func try_move_up():		
#	TODO: Can't move up if on ladder and no ladder above.
	
#	if collision_in_direction(ladder_ray_cast, DIRECTION.UP, true):
#		todo: ladder animation
#		frenk_print("ladder above")
#		pass
#	else:
#		todo: jump animation
#		frenk_print("no ladder above")
#		pass
	input_direction = Vector2(0, -1)
	set_state_walking()

func try_move_down():
#	if collision_in_direction(ladder_ray_cast, DIRECTION.DOWN, true):
	input_direction = Vector2(0, 1)
	set_state_walking()

func move(delta):
#	todo: tween?
#	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	percent_moved_to_next_tile += MOVEMENT_SPEED * delta
	if percent_moved_to_next_tile >= 1.0:
#		var start_time = OS.get_ticks_msec()
#		frenk_print("Elapsed time: ", OS.get_ticks_msec() - start_time)
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		set_state_idle()
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)

func set_state_idle():
	current_state = STATE.IDLE
	anim_state.travel("Idle")	

func set_state_walking():
	current_state = STATE.WALKING
	add_input_direction_to_anim_trees();
	initial_position = position	
	anim_state.travel("Walk")

func set_state_falling():
	current_state = STATE.FALLING	
	add_input_direction_to_anim_trees()
	initial_position = position
	anim_state.travel("Walk")
#	anim_state.travel("Fall") todo

func set_state_climbing():
	current_state = STATE.CLIMBING
	add_input_direction_to_anim_trees();
	initial_position = position	
	anim_state.travel("Walk")
#	anim_state.travel("Climb") todo

func set_state_jumping():
#	frenk_print("set_state_jumping") todo
	current_state = STATE.JUMPING
	add_input_direction_to_anim_trees();
	initial_position = position	
	anim_state.travel("Walk")
#	anim_state.travel("Jump") todo

func add_input_direction_to_anim_trees():
	var input_direction_copy = input_direction
	if facing_right:
		input_direction_copy.x += 0.1
	else:
		input_direction_copy.x -= 0.1
	anim_tree.set("parameters/Idle/blend_position", input_direction_copy)
	anim_tree.set("parameters/Walk/blend_position", input_direction_copy)

func collision_in_direction(ray_cast, direction, print_something):
	var new_position
	var new_cast_to
	
	var position_pixel = 9
	var cast_to_pixels = 5
	
	if direction == DIRECTION.LEFT:
		new_position = Vector2(-position_pixel, 0)
		new_cast_to = Vector2(-cast_to_pixels, 0)
	elif direction == DIRECTION.RIGHT:
		new_position = Vector2(position_pixel, 0)
		new_cast_to = Vector2(cast_to_pixels, 0)
	elif direction == DIRECTION.UP:
		new_position = Vector2(0, -position_pixel)
		new_cast_to = Vector2(0, -cast_to_pixels)
	else: # elif direction == DIRECTION.DOWN:
		new_position = Vector2(0, position_pixel)
		new_cast_to = Vector2(0, cast_to_pixels)

	if print_something:
		frenk_print("ray_cast.position: " + str(ray_cast.position))

	ray_cast.position = new_position
	ray_cast.cast_to = ray_cast.position + new_cast_to
	ray_cast.force_raycast_update()
	
	if print_something:
		frenk_print("new_position: " + str(ray_cast.position))
		frenk_print("ray_cast.cast_to: " + str(ray_cast.cast_to))
	
	if ray_cast == a_ray_cast:
		if direction == DIRECTION.LEFT:
			from_a_1 = ray_cast.position
			to_a_1 = ray_cast.position + ray_cast.cast_to
		elif direction == DIRECTION.RIGHT:
			from_a_2 = ray_cast.position
			to_a_2 = ray_cast.position + ray_cast.cast_to
		elif direction == DIRECTION.UP:
			from_a_3 = ray_cast.position
			to_a_3 = ray_cast.position + ray_cast.cast_to
		else: # elif direction == DIRECTION.DOWN:
			from_a_4 = ray_cast.position
			to_a_4 = ray_cast.position + ray_cast.cast_to
	else: #ray_cast == b_ray_cast:
		if direction == DIRECTION.LEFT:
			from_b_1 = ray_cast.position
			to_b_1 = ray_cast.position + ray_cast.cast_to
		elif direction == DIRECTION.RIGHT:
			from_b_2 = ray_cast.position
			to_b_2 = ray_cast.position + ray_cast.cast_to
		elif direction == DIRECTION.UP:
			from_b_3 = ray_cast.position
			to_b_3 = ray_cast.position + ray_cast.cast_to
		else: # elif direction == DIRECTION.DOWN:
			from_b_4 = ray_cast.position
			to_b_4 = ray_cast.position + ray_cast.cast_to
	
	var is_colliding = ray_cast.is_colliding()
	
	ray_cast.position = Vector2.ZERO
	ray_cast.force_raycast_update()
	
	return is_colliding

func _draw():
	draw_line(from_a_1, to_a_1, color_a)
	draw_line(from_a_2, to_a_2, color_a)
	draw_line(from_a_3, to_a_3, color_a)
	draw_line(from_a_4, to_a_4, color_a)
	
	draw_line(from_b_1, to_b_1, color_b)
	draw_line(from_b_2, to_b_2, color_b)
	draw_line(from_b_3, to_b_3, color_b)
	draw_line(from_b_4, to_b_4, color_b)

func frenk_print(text_to_print):
	print_count += 1
	print(str(print_count) + ": " + str(text_to_print))

func print_and_draw_ray_cast_a():
	if (OS.get_ticks_msec() - start_time < 1000):
		return
	else:
		start_time = OS.get_ticks_msec()
	
	if collision_in_direction(a_ray_cast, DIRECTION.LEFT, true):
		frenk_print("a_ray_cast - DIRECTION.LEFT - true")
	else:
		frenk_print("a_ray_cast - DIRECTION.LEFT - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.RIGHT, true):
		frenk_print("a_ray_cast - DIRECTION.RIGHT - true")
	else:
		frenk_print("a_ray_cast - DIRECTION.RIGHT - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.UP, true):
		frenk_print("a_ray_cast - DIRECTION.UP - true")
	else:
		frenk_print("a_ray_cast - DIRECTION.UP - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.DOWN, true):
		frenk_print("a_ray_cast - DIRECTION.DOWN - true")
	else:
		frenk_print("a_ray_cast - DIRECTION.DOWN - false")

func print_and_draw_ray_cast_b():
	if (OS.get_ticks_msec() - start_time < 1000):
		return
	else:
		start_time = OS.get_ticks_msec()
	
	if collision_in_direction(b_ray_cast, DIRECTION.LEFT, true):
		frenk_print("b_ray_cast - DIRECTION.LEFT - true")
	else:
		frenk_print("b_ray_cast - DIRECTION.LEFT - false")
	
	if collision_in_direction(b_ray_cast, DIRECTION.RIGHT, true):
		frenk_print("b_ray_cast - DIRECTION.RIGHT - true")
	else:
		frenk_print("b_ray_cast - DIRECTION.RIGHT - false")
	
	if collision_in_direction(b_ray_cast, DIRECTION.UP, true):
		frenk_print("b_ray_cast - DIRECTION.UP - true")
	else:
		frenk_print("b_ray_cast - DIRECTION.UP - false")
	
	if collision_in_direction(b_ray_cast, DIRECTION.DOWN, true):
		frenk_print("b_ray_cast - DIRECTION.DOWN - true")
	else:
		frenk_print("b_ray_cast - DIRECTION.DOWN - false")
