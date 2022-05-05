extends KinematicBody

const SPEED = 11
const SPEED_DELTA = 0.5
const COLLISION_FREEZE_DIST = 1.25
const COLLISION_BOUNCE_X_THRESH = 0.01
const NORMAL_X_THRESH = 0.01
const FIRST_SURFACE = 0
const COLOR_RED = Color8(255,0,0)
const COLOR_GREEN = Color8(0,255,0)
const COLOR_BLUE = Color8(0,0,255)
const COLOR_ORANGE = Color8(255,174,0)
const COLOR_PURPLE = Color8(181,0,255)
const BOX_RED = "box_red"
const BOX_GREEN = "box_green"
const BOX_BLUE = "box_blue"
const BOX_ORANGE = "box_orange"
const BOX_PURPLE = "box_purple"
const BOX_BROWN = "box_brown"
const BOX_CHANGE_RED = "box_change_red"
const BOX_CHANGE_GREEN = "box_change_green"
const BOX_CHANGE_BLUE = "box_change_blue"
const BOX_CHANGE_ORANGE = "box_change_orange"
const BOX_CHANGE_PURPLE = "box_change_purple"
const SPHERE_RED = "red"
const SPHERE_GREEN = "green"
const SPHERE_BLUE = "blue"
const SPHERE_ORANGE = "orange"
const SPHERE_PURPLE = "purple"

var velocity = Vector3(0,0,1) * SPEED
var lastCollisionPos

func isEastWestCollision(normal):
	# return true if the normal has a non-zero x-component (east/west rather than north/south collision)
	return normal.x > NORMAL_X_THRESH || normal.x < -NORMAL_X_THRESH

# change the velocity of the ball upon collision, given a collision normal
func velocity_bounce(normal):
	velocity = velocity.bounce(normal)
	velocity.y = 0
	# z component of velocity should be constant, either positive or negative
	if velocity.z > 0:
		velocity.z = SPEED
	else:
		velocity.z = -SPEED
	
	# if velocity after collision is greater than threshold, set x component of velocity to full.
	# this is to emulate the behavior of collisions in Frozen Fruits Frenzy
	if isEastWestCollision(normal):
		if velocity.x > COLLISION_BOUNCE_X_THRESH:
			velocity.x = SPEED
		elif velocity.x < -COLLISION_BOUNCE_X_THRESH:
			velocity.x = -SPEED

func moveBall():
	# only allow user input to move the ball if there is no last collision position,
	# or if the distance to the last collision position is greater than freeze threshold
	if !lastCollisionPos || global_transform.origin.distance_to(lastCollisionPos) > COLLISION_FREEZE_DIST:
		lastCollisionPos = null
		if Input.is_action_pressed("ui_left"):
			velocity.x = lerp(velocity.x, -SPEED, SPEED_DELTA)
		elif Input.is_action_pressed("ui_right"):
			velocity.x = lerp(velocity.x, SPEED, SPEED_DELTA)
		else:
			velocity.x = lerp(velocity.x, 0, SPEED_DELTA)

func changeSphereColor(color, colorStr):
	$MeshInstance.get_mesh().surface_get_material(FIRST_SURFACE).set_albedo(color)
	$MeshInstance.get_mesh().surface_get_material(FIRST_SURFACE).resource_name = colorStr

# take appropriate action when sphere collides with a box (either destroy box or change sphere color)
func onCollision(collider):
	var boxColor = collider.get_node("MeshInstance").get_surface_material(FIRST_SURFACE).resource_name
	var sphereColor = $MeshInstance.get_mesh().surface_get_material(FIRST_SURFACE).resource_name
	match boxColor:
			BOX_RED, BOX_GREEN, BOX_BLUE, BOX_ORANGE, BOX_PURPLE:
				if sphereColor in boxColor: # if sphere and box are same color, destroy the box
					collider.queue_free()
			BOX_CHANGE_RED:
				changeSphereColor(COLOR_RED, SPHERE_RED)
			BOX_CHANGE_GREEN:
				changeSphereColor(COLOR_GREEN, SPHERE_GREEN)
			BOX_CHANGE_BLUE:
				changeSphereColor(COLOR_BLUE, SPHERE_BLUE)
			BOX_CHANGE_ORANGE:
				changeSphereColor(COLOR_ORANGE, SPHERE_ORANGE)
			BOX_CHANGE_PURPLE:
				changeSphereColor(COLOR_PURPLE, SPHERE_PURPLE)

# this function is called 60 frames per second, regardless of the speed of the computer running the game
func _physics_process(delta):
	moveBall() # allow user input to move the ball
	
	var collision = move_and_collide(velocity * delta)
	if collision && "breakable_box" in collision.get_collider().name:
		if isEastWestCollision(collision.normal):
			lastCollisionPos = collision.position
		velocity_bounce(collision.normal)
		onCollision(collision.get_collider())
		
