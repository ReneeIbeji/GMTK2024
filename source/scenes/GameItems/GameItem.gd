class_name GameItem
extends StaticBody2D

var gridRow : int
var gridColumn : int

var currentlyUpgraded : bool = false
@export var maxHealth : int
@export var health : int
@export var attackCooldown : int
@export var attackStrength : int
@export var attackDistance : int

@export var upgradeSize : int


signal gameItemDestroyed()

func attack(healthDelta : int ) -> void:
    health -= healthDelta

    if health <= 0:
        destroyed()


func destroyed() -> void:
    gameItemDestroyed.emit(gridRow,gridColumn)
    queue_free()

    
func upgrade() -> void:
    pass

func degrade() -> void:
    pass