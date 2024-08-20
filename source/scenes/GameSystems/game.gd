class_name Game
extends Node2D




enum mouseState {None, Item, PowerUp}

signal gameover()
var  gameRunning : bool

@export var waveStates : Array[WaveState]
@export var EnemyScene : PackedScene
@export var upgradeMouseIcon : CompressedTexture2D

var shipHealth : int
var pointCount : int

@export var maxShipHealth : int
@export var startPointsNumber : int
@export var numberOfSecondsPerPoint : int 

var currentTimeBetweenWaves : int

var currentHandState : mouseState
 
var currentPlacingItem : placeableItem


var itemInHandSprite : TextureRect 

var enemysInPlay : Array[Enemy]

var mouseOnCell : bool
var cellMouseOn : Vector2
var gameRunTimer : float


@export var testPlaceableItem : placeableItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameRunning = true
	gameover.connect(whenGameOver)
	shipHealth = maxShipHealth
	pointCount = startPointsNumber
	currentHandState = mouseState.None

	get_tree().create_timer(numberOfSecondsPerPoint).timeout.connect(accumulatePoints)

	GlobalNodes.gameNode = self

	itemInHandSprite = TextureRect.new()
	itemInHandSprite.scale = Vector2(0.2,0.2)
	$UI.add_child(itemInHandSprite)
	spawn_enemy_wave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameRunning:
		gameRunTimer += delta
		$UI/Health.text = "Health: " + str(shipHealth)
		$UI/Points.text = "Points: " + str(pointCount)
		$UI/score.text = "Score: " + str(int(gameRunTimer))

		if currentHandState != mouseState.None:
			itemInHandSprite.position = get_viewport().get_mouse_position() + Vector2(20,20)
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
	$EndMenu/Score.text = str(int(gameRunTimer))
	$EndMenu.show()
	gameRunning = false
	for enemy in enemysInPlay:
		enemy.queue_free()


	enemysInPlay.clear()

func getCurrentWaveState() -> WaveState:
	var lastWaveState = waveStates[0]

	for i in range(1,waveStates.size()):
		if waveStates[i].timePassed > gameRunTimer:
			return lastWaveState
		lastWaveState = waveStates[i]
	
	return lastWaveState

func spawn_enemy() -> void:
	$EnemySpawnPoints/SpawnPoint.progress_ratio = randf()
	var enemySpawnPoint : Vector2 = $EnemySpawnPoints/SpawnPoint.position

	var tempEnemyNode : Enemy = EnemyScene.instantiate()
	tempEnemyNode.position = enemySpawnPoint
	tempEnemyNode.targetLocation = GlobalNodes.baseGridNode.mainShipNode.global_position
	tempEnemyNode.health = tempEnemyNode.maxHealth
	tempEnemyNode.enemyDied.connect(remove_enemy)
	tempEnemyNode.hitShip.connect(shipHit)
	var callable : Callable = Callable(tempEnemyNode, "gameOver")
	gameover.connect(callable)

	add_child(tempEnemyNode)
	enemysInPlay.append(tempEnemyNode)

func spawn_enemy_wave() -> void:
	if gameRunning:
		var enemyNum = randi_range(getCurrentWaveState().minEnemysInRound,getCurrentWaveState().maxEnemysInRound)
		for i in range(enemyNum):
			spawn_enemy()
		get_tree().create_timer(getCurrentWaveState().timeBetweenWaves).timeout.connect(spawn_enemy_wave)
	

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
	itemInHandSprite.queue_free()
	itemInHandSprite = TextureRect.new()
	itemInHandSprite.scale = Vector2(0.2,0.2)
	$UI.add_child(itemInHandSprite)
	itemInHandSprite.texture = item.icon

func clear_placing_item() -> void:
	currentHandState = mouseState.None
	currentPlacingItem = null
	itemInHandSprite.texture = null

func set_mouse_upgrade() -> void:
	currentHandState = mouseState.PowerUp
	itemInHandSprite.queue_free()
	itemInHandSprite = TextureRect.new()
	itemInHandSprite.scale = Vector2(0.02,0.02)
	$UI.add_child(itemInHandSprite)
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
