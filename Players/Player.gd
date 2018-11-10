extends KinematicBody2D

enum PlayerState {
	IDLE,
	MOVING,
	JUMPING,
	CHARGING
}

export(float) var maxHealth = 100
export(float) var currentHealth = 100
export(float) var baseDamage = 5

export(float) var moveSpeed = 250
export(float) var gravity = 1200
export(float) var jumpSpeed = -600

var velocity = Vector2()
var keyStates = []
var playerState = PlayerState.IDLE

var chargeTimer = null
var chargeDuration = 2

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
class KeyStateSorter:
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
	velocity.x = 0
	for key_index in range(keyStates.size()):
		update_input(keyStates[key_index])
	
	keyStates.sort_custom(KeyStateSorter, "sort")
	for key in keyStates:
		if (key.state):
			if (key.name == "left"):
				velocity.x -= moveSpeed
				set_player_state(false)
			elif (key.name == "right"):
				velocity.x += moveSpeed
				set_player_state(false)
			elif (key.name == "jump" && is_on_floor()):
				velocity.y = jumpSpeed
				set_player_state(true)
			else:
				set_player_state(false)
	
	if (velocity.x != 0 && velocity.y != 0):
		emit_signal("player_moved")


## Takes damage (caps health to 0 or 100) and checks if the player has
## died or not
func take_damage(amount):
	currentHealth = clamp(currentHealth - amount, 0, maxHealth)
	if (currentHealth == 0):
		emit_signal("player_killed")



## Helper function to determine the state that the player is currently in
func set_player_state(is_jumping):
	if (is_jumping):
		playerState = PlayerState.JUMPING
	else:
		if (velocity.x != 0 && velocity.y != 0):
			playerState = PlayerState.MOVING
		else:
			playerState = PlayerState.IDLE


func _ready():
	keyStates = [
	KeyState.new("left"), 
	KeyState.new("right"), 
	KeyState.new("jump"), 
	KeyState.new("attack"),
	KeyState.new("special"),
	KeyState.new("charge")]
	
	chargeTimer = Timer.new()
	chargeTimer.set_one_shot(true)
	#chargeTimer.connect("timeout", self, "on_charge_compelete")


func _process(delta):
	calulate_input()


func _physics_process(delta):
	velocity.y += gravity * delta
	if (playerState == PlayerState.JUMPING && is_on_floor()):
		set_player_state(false)
	velocity = move_and_slide(velocity, Vector2(0, -1))
