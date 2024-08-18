class_name Enemy
extends Area2D

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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
