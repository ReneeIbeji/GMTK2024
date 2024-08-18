class_name Enemy
extends Area2D

signal enemyDied(enemy : Enemy)

@export var speed : float 
@export var maxHealth : int
@export var attackStrength : int
@export var timeToAttack : float = 5
var timeLeftToAttack : float
var targetLocation : Vector2
var health : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func attack(healthDelta : int) -> void:
	health -= healthDelta

	if health <= 0:
		enemyDied.emit(self)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
