extends KinematicBody2D

export(float) var maxHealth = 100
export(float) var currentHealth = 100

export(float) var moveSpeed = 250
export(float) var velocitySpeed = 1
export(float) var gravity = 1000

var velocity = Vector2()
var keyStates = []

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
			match key.name:
				"left":
					velocity.x -= moveSpeed
				"right":
					velocity.x += moveSpeed
				"down":
					velocity.y += moveSpeed
	
	if (velocity.x != 0 && velocity.y != 0):
		emit_signal("player_moved")


func take_damage(amount):
	currentHealth = clamp(currentHealth - amount, 0, maxHealth)
	if (currentHealth == 0):
		emit_signal("player_killed")


func _ready():
	keyStates = [
	KeyState.new("left"), 
	KeyState.new("right"), 
	KeyState.new("up"), 
	KeyState.new("down")]


func _process(delta):
	calulate_input()


func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
