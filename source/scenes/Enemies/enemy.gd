extends Enemy


var stopped : bool = false

var gameItemToAttack : GameItem
var gameItemToAttackQueue : Array[GameItem]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !stopped:
		position = position.move_toward(targetLocation, speed * delta)
	else:
		timeLeftToAttack -= delta
		if timeLeftToAttack <= 0:
			gameItemToAttack.attack(attackStrength)
			timeLeftToAttack = timeToAttack

func continueMoving() -> void:
	if gameItemToAttackQueue.is_empty():
		stopped = false
		gameItemToAttack = null
		return
	
	gameItemToAttack = gameItemToAttackQueue.pop_front()
	gameItemToAttack.gameItemDestroyed.connect(continueMoving)
	timeLeftToAttack = 0
	return

	


func _on_body_entered(body:Node2D) -> void:
	if !body.is_in_group("tower"):
		return
	
	print("area entered")
	var space_state := get_world_2d().direct_space_state

	var query := PhysicsRayQueryParameters2D.create(position, targetLocation, collision_mask, [self])
	
	var result := space_state.intersect_ray(query)
	
	if result:
		if result.rid == body.get_rid():
			if !stopped:
				stopped = true
				gameItemToAttack = body as GameItem
				gameItemToAttack.gameItemDestroyed.connect(continueMoving)
				timeLeftToAttack = 0
				return 
			
			gameItemToAttackQueue.push_back(body as GameItem)
			
		
