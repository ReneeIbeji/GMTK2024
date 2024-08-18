extends GameItem

var currentAttackTargets : Array[Enemy]
@export var attackTime : float
@export var projectileScene : PackedScene
var timeLeftToAttack : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = maxHealth


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if !currentAttackTargets.is_empty():
		timeLeftToAttack -= delta
		if timeLeftToAttack <= 0:
			doAttack()
			timeLeftToAttack = attackCooldown			

	for enemy in GlobalNodes.gameNode.enemysInPlay:
		if position.distance_to(enemy.position) < attackDistance:
			if currentAttackTargets.is_empty():
				timeLeftToAttack = 0
			if !currentAttackTargets.has(enemy):
				currentAttackTargets.append(enemy)
				enemy.enemyDied.connect(removeDeadEnemyFromTargets)
		else:
			currentAttackTargets.erase(enemy)


func doAttack() -> void:
	var attackTarget : Enemy  = currentAttackTargets[randi() % currentAttackTargets.size()] 
	var projectileNode : Node2D = projectileScene.instantiate()
	projectileNode.position = position
	projectileNode.targetEnemy = attackTarget
	projectileNode.attackStrength = attackStrength
	add_sibling(projectileNode)

func removeDeadEnemyFromTargets(enemy : Enemy) -> void:
	currentAttackTargets.erase(enemy)
