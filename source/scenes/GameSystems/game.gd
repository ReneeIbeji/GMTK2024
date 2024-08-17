class_name Game
extends Node2D

var currentPlacingItem : placeableItem

var itemInHand : bool = false

var itemInHandSprite : TextureRect 

var mouseOnCell : bool
var cellMouseOn : Vector2

@export var testPlaceableItem : placeableItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalNodes.gameNode = self

	itemInHandSprite = TextureRect.new()
	$UI.add_child(itemInHandSprite)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# print("mouse grid pos: ", cellMouseOn)
	# Display item in hand
	if itemInHand:
		itemInHandSprite.position = get_viewport().get_mouse_position()

	
	if Input.is_action_just_pressed("ACTION_ClickOnGridCell") && mouseOnCell && itemInHand:
		var tempItemNode : GameItem = currentPlacingItem.scene.instantiate()
		tempItemNode.position = GlobalNodes.baseGridNode.get_cell_position(cellMouseOn.x, cellMouseOn.y)
		GlobalNodes.baseGridNode.add_child(tempItemNode)
		GlobalNodes.baseGridNode.place_item_on_grid(cellMouseOn.x, cellMouseOn.y, tempItemNode)
		clear_placing_item()




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