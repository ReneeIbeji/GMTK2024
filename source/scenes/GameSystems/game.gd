class_name Game
extends Node2D

@export var EnemyScene : PackedScene
 
var currentPlacingItem : placeableItem

var itemInHand : bool = false

var itemInHandSprite : TextureRect 

var enemysInPlay : Array[Enemy]

var mouseOnCell : bool
var cellMouseOn : Vector2

@export var testPlaceableItem : placeableItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalNodes.gameNode = self

	itemInHandSprite = TextureRect.new()
	$UI.add_child(itemInHandSprite)
	spawn_enemy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# print("mouse grid pos: ", cellMouseOn)
	# Display item in hand
	if itemInHand:
		itemInHandSprite.position = get_viewport().get_mouse_position()

	
	if Input.is_action_just_pressed("ACTION_ClickOnGridCell") && mouseOnCell && itemInHand:
		var result : bool = GlobalNodes.baseGridNode.place_item_on_grid(cellMouseOn.x, cellMouseOn.y, currentPlacingItem)
		clear_placing_item()


func spawn_enemy() -> void:
	$EnemySpawnPoints/SpawnPoint.progress_ratio = randf()
	var enemySpawnPoint : Vector2 = $EnemySpawnPoints/SpawnPoint.position

	var tempEnemyNode : Enemy = EnemyScene.instantiate()
	tempEnemyNode.position = enemySpawnPoint
	tempEnemyNode.targetLocation = GlobalNodes.baseGridNode.mainShipNode.global_position
	tempEnemyNode.health = tempEnemyNode.maxHealth

	add_child(tempEnemyNode)
	enemysInPlay.append(tempEnemyNode)




func set_placing_item(item : placeableItem) -> void:
	currentPlacingItem = item	
	itemInHand = true
	itemInHandSprite.texture = item.icon

func clear_placing_item() -> void:
	currentPlacingItem = null
	itemInHand = false
	itemInHandSprite.texture = null

func _on_towerTest_button_pressed() -> void:
	set_placing_item(testPlaceableItem)

func mouse_enter_grid_cell(row : int , column : int) -> void:
	mouseOnCell =  true
	cellMouseOn = Vector2(row,column)

func mouse_exits_grid_cell(row : int, column : int) -> void:
	if mouseOnCell:
		if cellMouseOn == Vector2(row,column):
			mouseOnCell = false
			cellMouseOn = Vector2(-1,-1)
