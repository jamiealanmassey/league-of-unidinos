extends KinematicBody2D

enum PlayerState {
	IDLE,
	MOVING,
	JUMPING,
	CHARGING
}

const Cooldown = preload('res://Cooldown.gd')

onready var charge_cooldown = null

export(float) var max_health = 100
export(float) var current_health = 100
export(float) var base_damage = 5

export(float) var move_speed = 250
export(float) var gravity = 1200
export(float) var jump_speed = -600
export(float) var charge_boost_factor = 10
export(float) var charge_duration = 0.08
export(float) var charge_duration_cooldown = 2

var velocity = Vector2()
var key_states = []
var player_state = PlayerState.IDLE

var charge_timer = null

signal player_moved
signal player_killed
signal player_respawned


## Defines the KeyState as tuples of (bool, int, string)
##   => where bool is pressed state, and
##   => where int is timestamp of when they key was pressed, and
##   => where string is the identifier of the actual key
class KeyState:
	func _init(name):
		self.state = false
		self.stamp = 0
		self.name = name
	
	var state = false
	var stamp = 0
	var name = ""


## Custom sorting class for KeyState objects (sorts by timestamp)
class key_statesorter:
	static func sort(a, b):
		return (a.stamp < b.stamp)


# Updates a single key input based on its name; if it has
## been pressed then turn the state on and save the timestamp
func update_input(key_state):
	if (Input.is_action_pressed(key_state.name)):
		key_state.state = true
		key_state.stamp = OS.get_ticks_msec()
	else:
		key_state.state = false


## Helper function to calculate the input for this frame of
## the game by updating all key states
func calulate_input():
	if (player_state == PlayerState.CHARGING):
		return
	
	velocity.x = 0
	for key_index in range(key_states.size()):
		update_input(key_states[key_index])
	
	key_states.sort_custom(key_statesorter, "sort")
	for key in key_states:
		if (key.state):
			if (key.name == "left"):
				velocity.x -= move_speed
				set_player_state(false)
			elif (key.name == "right"):
				velocity.x += move_speed
				set_player_state(false)
			elif (key.name == "jump" && is_on_floor()):
				velocity.y = jump_speed
				set_player_state(true)
			elif (key.name == "charge" && player_state != PlayerState.CHARGING && charge_cooldown.is_ready()):
				player_state = PlayerState.CHARGING
				charge_timer.start()
			else:
				set_player_state(false)
	
	if (velocity.x != 0 && player_state == PlayerState.CHARGING):
		velocity.x *= charge_boost_factor
	
	if (velocity.x != 0 && velocity.y != 0):
		emit_signal("player_moved")


## charge_timer callback to reset the player state and stop them
## from charging forever
func on_charge_complete():
	player_state = PlayerState.IDLE
	set_player_state(is_on_floor())


## Takes damage (caps health to 0 or 100) and checks if the player has
## died or not
func take_damage(amount):
	current_health = clamp(current_health - amount, 0, max_health)
	if (current_health == 0):
		emit_signal("player_killed")


## Helper function to determine the state that the player is currently in
func set_player_state(is_jumping):
	if (player_state == PlayerState.CHARGING):
		return
	
	if (is_jumping):
		player_state = PlayerState.JUMPING
	else:
		if (velocity.x != 0 && velocity.y != 0):
			player_state = PlayerState.MOVING
		else:
			player_state = PlayerState.IDLE


func _ready():
	key_states = [
	KeyState.new("left"), 
	KeyState.new("right"), 
	KeyState.new("jump"), 
	KeyState.new("attack"),
	KeyState.new("special"),
	KeyState.new("charge")]
	
	charge_timer = Timer.new()
	charge_timer.set_one_shot(true)
	charge_timer.set_wait_time(charge_duration)
	charge_timer.connect("timeout", self, "on_charge_complete")
	add_child(charge_timer)
	
	charge_cooldown = Cooldown.new(charge_duration_cooldown)


func _process(delta):
	calulate_input()
	charge_cooldown.tick(delta)


func _physics_process(delta):
	velocity.y += gravity * delta
	if (player_state == PlayerState.JUMPING && is_on_floor()):
		set_player_state(false)
	velocity = move_and_slide(velocity, Vector2(0, -1))
