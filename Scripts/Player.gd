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

const MOVEMENT_SPEED = 4
const TILE_SIZE = 16

onready var a_ray_cast = $A_RayCast2D
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
		process_player_movement_input()
	else:
		move(delta)

func process_player_movement_input():
	if Input.is_action_pressed("ui_accept"):
		print_and_draw_ray_cast_a()
	
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

func try_move_left():	
	facing_right = false
	input_direction = Vector2(-1, 0)
	set_state_walking()

func try_move_right():
	facing_right = true
	input_direction = Vector2(1, 0)
	set_state_walking()

func try_move_up():
	input_direction = Vector2(0, -1)
	set_state_walking()

func try_move_down():
	input_direction = Vector2(0, 1)
	set_state_walking()

func move(delta):
	percent_moved_to_next_tile += MOVEMENT_SPEED * delta
	if percent_moved_to_next_tile >= 1.0:
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

func set_state_climbing():
	current_state = STATE.CLIMBING
	add_input_direction_to_anim_trees();
	initial_position = position	
	anim_state.travel("Walk")

func set_state_jumping():
	current_state = STATE.JUMPING
	add_input_direction_to_anim_trees();
	initial_position = position	
	anim_state.travel("Walk")

func add_input_direction_to_anim_trees():
	var input_direction_copy = input_direction
	if facing_right:
		input_direction_copy.x += 0.1
	else:
		input_direction_copy.x -= 0.1
	anim_tree.set("parameters/Idle/blend_position", input_direction_copy)
	anim_tree.set("parameters/Walk/blend_position", input_direction_copy)

func collision_in_direction(ray_cast, direction):
	var new_position
	var new_cast_to
	
	var position_pixel = 16
	var cast_to_pixels = 8
	
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

	ray_cast.position = new_position
	ray_cast.cast_to = new_cast_to
	ray_cast.force_raycast_update()
	
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
	
	return ray_cast.is_colliding()

func _draw():
	draw_line(from_a_1, to_a_1, color_a)
	draw_line(from_a_2, to_a_2, color_a)
	draw_line(from_a_3, to_a_3, color_a)
	draw_line(from_a_4, to_a_4, color_a)

func print_line(text_to_print):
	print_count += 1
	print(str(print_count) + ": " + str(text_to_print))

func print_and_draw_ray_cast_a():
	if (OS.get_ticks_msec() - start_time < 1000):
		return
	else:
		start_time = OS.get_ticks_msec()
	
	if collision_in_direction(a_ray_cast, DIRECTION.LEFT):
		print_line("a_ray_cast - DIRECTION.LEFT - true")
	else:
		print_line("a_ray_cast - DIRECTION.LEFT - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.RIGHT):
		print_line("a_ray_cast - DIRECTION.RIGHT - true")
	else:
		print_line("a_ray_cast - DIRECTION.RIGHT - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.UP):
		print_line("a_ray_cast - DIRECTION.UP - true")
	else:
		print_line("a_ray_cast - DIRECTION.UP - false")
	
	if collision_in_direction(a_ray_cast, DIRECTION.DOWN):
		print_line("a_ray_cast - DIRECTION.DOWN - true")
	else:
		print_line("a_ray_cast - DIRECTION.DOWN - false")
