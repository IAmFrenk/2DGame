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
	CURRENT,
}

enum TILEMAPS {
	OVERWORLD,
	LADDER,
}

const MOVEMENT_SPEED = 4
const TILE_SIZE = 16

onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")

onready var parent_node = get_parent()
onready var overworld_tile_map = parent_node.get_node("OverworldTileMap")
onready var ladder_tile_map = parent_node.get_node("LadderTileMap")

var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
var percent_moved_to_next_tile = 0.0
var facing_right = true
var current_state = STATE.IDLE
var print_count = 0
var tiles_fallen = 0

var god_mode = false

func _ready():
	initial_position = position

func _physics_process(delta):
	if current_state == STATE.IDLE:
		if (god_mode
		|| (coll_in_dir(TILEMAPS.OVERWORLD, DIRECTION.DOWN) || coll_in_dir(TILEMAPS.LADDER, DIRECTION.CURRENT))):
			if tiles_fallen != 0:
				frenk_print("tiles_fallen: " + str(tiles_fallen))
				tiles_fallen = 0
			process_player_movement_input()
		else:
			set_state_falling()
	else:
		move(delta)

func process_player_movement_input():
	if Input.is_action_pressed("left") && Input.is_action_pressed("right"):
		return
	
	if Input.is_action_pressed("up") && Input.is_action_pressed("down"):
		return
	
	if (!Input.is_action_pressed("left")
	&& !Input.is_action_pressed("right")
	&& !Input.is_action_pressed("up")
	&& !Input.is_action_pressed("down")):
		return
	
	if Input.is_action_pressed("left"):
		try_move_left_or_right(DIRECTION.LEFT)
	elif Input.is_action_pressed("right"):
		try_move_left_or_right(DIRECTION.RIGHT)
	elif Input.is_action_pressed("up"):
		try_move_up()
	elif Input.is_action_pressed("down"):
		try_move_down()

func try_move_left_or_right(direction):
	if direction != DIRECTION.LEFT && direction != DIRECTION.RIGHT:
		return
	
	facing_right = direction == DIRECTION.RIGHT
		
#	if (!god_mode
#	&& coll_in_dir(TILEMAPS.OVERWORLD, direction)
#	&& !coll_in_dir(TILEMAPS.LADDER, direction)):
#		return
	
	if direction == DIRECTION.LEFT:
		set_state_walking(Vector2(-1, 0))
	else:
		set_state_walking(Vector2(1, 0))

func try_move_up():
	if (!god_mode
	&& !coll_in_dir(TILEMAPS.OVERWORLD, DIRECTION.DOWN)
	&& !coll_in_dir(TILEMAPS.LADDER, DIRECTION.UP)):
		return
	
	set_state_walking(Vector2(0, -1))

func try_move_down():
	if (!god_mode
	&& coll_in_dir(TILEMAPS.OVERWORLD, DIRECTION.DOWN)
	&& !coll_in_dir(TILEMAPS.LADDER, DIRECTION.DOWN)):
		return
	
	set_state_walking(Vector2(0, 1))

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

func set_state_walking(new_input_direction):
	input_direction = new_input_direction
	current_state = STATE.WALKING
	add_input_direction_to_anim_trees()
	initial_position = position
	anim_state.travel("Walk")

func set_state_falling():
	tiles_fallen += 1	
	input_direction = Vector2(0, 1)
	current_state = STATE.FALLING
	add_input_direction_to_anim_trees()
	initial_position = position
	anim_state.travel("Walk")
#	anim_state.travel("Fall") todo

func set_state_climbing():
	current_state = STATE.CLIMBING
	add_input_direction_to_anim_trees()
	initial_position = position	
	anim_state.travel("Walk")
#	anim_state.travel("Climb") todo

func set_state_jumping():
	current_state = STATE.JUMPING
	add_input_direction_to_anim_trees()
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

func coll_in_dir(tile_map, direction):
	var tile_map_to_use
	
	if tile_map == TILEMAPS.OVERWORLD:
		tile_map_to_use = overworld_tile_map
	else: # elif tile_map == TILEMAPS.LADDER:
		tile_map_to_use = ladder_tile_map	
	
	var global_pos = get_global_position()
	
	var collisionVectorX = Vector2(TILE_SIZE, 0)
	var collisionVectorY = Vector2(0, TILE_SIZE)
	
	if direction == DIRECTION.LEFT:
		global_pos -= collisionVectorX
	elif direction == DIRECTION.RIGHT:
		global_pos += collisionVectorX
	elif direction == DIRECTION.UP:
		global_pos -= collisionVectorY
	elif direction == DIRECTION.DOWN:
		global_pos += collisionVectorY
	
	var world_to_map_coord = tile_map_to_use.world_to_map(global_pos)
	return tile_map_to_use.get_cellv(world_to_map_coord) != -1

func frenk_print(text_to_print):
	print_count += 1
	print(str(print_count) + ": " + str(text_to_print))
