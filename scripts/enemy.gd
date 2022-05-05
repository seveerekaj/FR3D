extends Area

const TRANSLATE_DIST = 0.2
var currDirection = 1
var transVec = Vector3()

func translateEnemy():
	if "NS" in name: # north/south moving enemies
		transVec = Vector3(0, 0, currDirection * TRANSLATE_DIST)
	elif "EW" in name: # east/west moving enemies
		transVec = Vector3(currDirection * TRANSLATE_DIST, 0, 0)
	global_translate(transVec)

func _physics_process(delta):
	translateEnemy()

func _on_enemy_body_entered(body):
	if body.name == "TheBall":
		get_tree().change_scene("res://assets/gameOver.tscn")
	# set direction to opposite, then translate enemy
	currDirection = -currDirection
	translateEnemy()
