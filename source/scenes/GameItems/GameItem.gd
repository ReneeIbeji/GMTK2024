class_name GameItem
extends StaticBody2D

@export var maxHealth : int
@export var health : int
@export var attackCooldown : int
@export var attackStrenth : int

signal gameItemDestroyed()

func attack(healthDelta : int ) -> void:
    health -= healthDelta

    if health <= 0:
        destroyed()


func destroyed() -> void:
    gameItemDestroyed.emit()
    queue_free()

    