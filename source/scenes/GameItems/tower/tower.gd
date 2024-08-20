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
			if enemy not in currentAttackTargets:
				print("new enemy in range")
				currentAttackTargets.append(enemy)
				enemy.enemyDied.connect(removeDeadEnemyFromTargets)
				enemy.hitShip.connect(removeDeadEnemyFromTargets)
		else:
			if currentAttackTargets.has(enemy):
				currentAttackTargets.erase(enemy)
				enemy.enemyDied.disconnect(removeDeadEnemyFromTargets)
				enemy.hitShip.disconnect(removeDeadEnemyFromTargets)


func doAttack() -> void:
	var attackTarget : Enemy  = currentAttackTargets[randi() % currentAttackTargets.size()] 
	var projectileNode : Node2D = projectileScene.instantiate()
	projectileNode.position = position
	projectileNode.targetEnemy = attackTarget
	if currentlyUpgraded:
		projectileNode.attackStrength = attackStrength * 3
	else:
		projectileNode.attackStrength = attackStrength
	add_sibling(projectileNode)

func upgrade() -> void:
	health = maxHealth 

func removeDeadEnemyFromTargets(enemy : Enemy) -> void:
	currentAttackTargets.erase(enemy)
