extends CharacterBody2D
# Player character controller built on CharacterBody2D
# Handles input, movement, facing direction, and animation state


# --- Movement & Animation State ---

# Last facing direction used for animation lookup
# Defaults to DOWN so the character starts facing down (idle_down)
var cardinal_direction: Vector2 = Vector2.DOWN

# Raw input direction calculated every frame from player input
var direction: Vector2 = Vector2.ZERO

# Movement speed in pixels per second
var move_speed: float = 100.0

# High-level animation state (idle, walk, etc.)
# Combined with facing direction to form animation names
# Example: "idle_down", "walk_side"
var state: String = "idle"


# --- Node References ---

# Controls all character animations
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Visual sprite used for flipping left/right
@onready var sprite: Sprite2D = $Sprite2D


# Called once when the node enters the scene tree
func _ready() -> void:
	# Force initial animation so the character starts in "idle_down"
	update_animation()


# Called every frame (variable timestep)
func _process(delta: float) -> void:
	# Read directional input and convert it into a 2D vector
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Translate input direction into movement velocity
	velocity = direction * move_speed
	
	# Only update animations if state or facing direction actually changed
	if set_state() || set_direction():
		update_animation()


# Called every physics frame (fixed timestep)
func _physics_process(delta: float) -> void:
	# Apply velocity and resolve collisions
	move_and_slide()


# Updates the character's facing direction based on movement input
# Returns true if the facing direction changed
func set_direction() -> bool:
	var new_dir: Vector2 = cardinal_direction
	
	# Do not change facing direction when not moving
	if direction == Vector2.ZERO:
		return false
	
	# Horizontal movement takes priority if vertical input is zero
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	# Vertical movement takes priority if horizontal input is zero
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	# Skip update if direction did not change
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	
	# Flip sprite horizontally for left-facing direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


# Updates the character's animation state based on movement
# Returns true if the state changed
func set_state() -> bool:
	var new_state: String = "idle" if direction == Vector2.ZERO else "walk"
	
	if new_state == state:
		return false
	
	state = new_state
	return true


# Plays the animation matching the current state and facing direction
func update_animation() -> void:
	animation_player.play(state + "_" + anim_direction())


# Converts facing direction into a string used by animation names
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		# LEFT and RIGHT share the same animation ("side")
		return "side"
