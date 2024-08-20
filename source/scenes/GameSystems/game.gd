class_name Game
extends Node2D




enum mouseState {None, Item, PowerUp}

signal gameover()
var  gameRunning : bool

@export var EnemyScene : PackedScene
@export var upgradeMouseIcon : CompressedTexture2D

var shipHealth : int
var pointCount : int

@export var maxShipHealth : int
@export var numberOfSecondsPerPoint : int 


var currentHandState : mouseState
 
var currentPlacingItem : placeableItem


var itemInHandSprite : TextureRect 

var enemysInPlay : Array[Enemy]

var mouseOnCell : bool
var cellMouseOn : Vector2

@export var testPlaceableItem : placeableItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameRunning = true
	gameover.connect(whenGameOver)
	shipHealth = maxShipHealth
	pointCount = 10
	currentHandState = mouseState.None

	get_tree().create_timer(numberOfSecondsPerPoint).timeout.connect(accumulatePoints)

	GlobalNodes.gameNode = self

	itemInHandSprite = TextureRect.new()
	$UI.add_child(itemInHandSprite)
	spawn_enemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$UI/Health.text = "Health: " + str(shipHealth)
	$UI/Points.text = "Points: " + str(pointCount)
	if currentHandState != mouseState.None:
		itemInHandSprite.position = get_viewport().get_mouse_position() + Vector2(20,20)
	if gameRunning:

		if mouseOnCell:	
			if Input.is_action_just_pressed("ACTION_ClickOnGridCell") && currentHandState == mouseState.Item:
				var result : bool = GlobalNodes.baseGridNode.place_item_on_grid(cellMouseOn.x, cellMouseOn.y, currentPlacingItem)
				if result:
					clear_placing_item()
			if Input.is_action_just_pressed("ACTION_ClickOnGridCell") && currentHandState == mouseState.PowerUp:
				var result : bool = GlobalNodes.baseGridNode.powerup_item_on_grid(cellMouseOn.x, cellMouseOn.y)
				if result:
					deSet_mouse_upgrade()

func whenGameOver() -> void:
	print("gameover")
	gameRunning = false
	for enemy in enemysInPlay:
		enemy.queue_free()


func spawn_enemy() -> void:
	$EnemySpawnPoints/SpawnPoint.progress_ratio = randf()
	var enemySpawnPoint : Vector2 = $EnemySpawnPoints/SpawnPoint.position

	var tempEnemyNode : Enemy = EnemyScene.instantiate()
	tempEnemyNode.position = enemySpawnPoint
	tempEnemyNode.targetLocation = GlobalNodes.baseGridNode.mainShipNode.global_position
	tempEnemyNode.health = tempEnemyNode.maxHealth
	tempEnemyNode.enemyDied.connect(remove_enemy)
	tempEnemyNode.hitShip.connect(shipHit)

	add_child(tempEnemyNode)
	enemysInPlay.append(tempEnemyNode)


func shipHit(enemy : Enemy) -> void:
	shipHealth -= 1
	remove_enemy(enemy)
	if shipHealth <= 0:
		gameover.emit()


func remove_enemy(enemy : Enemy) -> void:
	enemysInPlay.erase(enemy)


func set_placing_item(item : placeableItem) -> void:
	currentHandState = mouseState.Item
	currentPlacingItem = item	
	itemInHandSprite.texture = item.icon

func clear_placing_item() -> void:
	currentHandState = mouseState.None
	currentPlacingItem = null
	itemInHandSprite.texture = null

func set_mouse_upgrade() -> void:
	currentHandState = mouseState.PowerUp
	itemInHandSprite.texture = upgradeMouseIcon

func deSet_mouse_upgrade() -> void:
	currentHandState = mouseState.None
	itemInHandSprite.texture = null




func mouse_enter_grid_cell(row : int , column : int) -> void:
	mouseOnCell =  true
	cellMouseOn = Vector2(row,column)

func mouse_exits_grid_cell(row : int, column : int) -> void:
	if mouseOnCell:
		if cellMouseOn == Vector2(row,column):
			mouseOnCell = false
			cellMouseOn = Vector2(-1,-1)

func _on_towerTest_button_pressed() -> void:
	if pointCount < 10:
		return
	
	set_placing_item(testPlaceableItem)
	pointCount -= 10

func _on_upgradeTest_button_test() -> void:
	if currentHandState == mouseState.None:
		if pointCount < 6:
			return
		set_mouse_upgrade()
		pointCount -= 6
		return
	elif currentHandState == mouseState.PowerUp:
		pointCount += 6
		deSet_mouse_upgrade()

func accumulatePoints() -> void:
	if gameRunning:
		pointCount += 1
		get_tree().create_timer(numberOfSecondsPerPoint).timeout.connect(accumulatePoints)
