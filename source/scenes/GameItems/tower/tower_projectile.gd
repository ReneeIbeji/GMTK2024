extends Area2D

@export var speed : float
var targetEnemy : Enemy
var targetPosition : Vector2
var attackStrength : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if targetEnemy == null:
		return
	targetEnemy.enemyDied.connect(whenTargetDestroyed)
	targetEnemy.hitShip.connect(whenTargetDestroyed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if targetEnemy == null:
		whenTargetDestroyed(null)
	targetPosition = targetEnemy.global_position

	global_position = global_position.move_toward(targetPosition, speed * delta)
	
	if global_position.is_equal_approx(targetPosition):
		targetEnemy.attack(attackStrength)
		queue_free()

func whenTargetDestroyed(enemy : Enemy) -> void:
	queue_free()	
