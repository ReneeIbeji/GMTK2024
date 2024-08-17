extends Node2D

var currentPlacingItem : placeableItem

var itemInHand : bool = false

var itemInHandSprite : Sprite2D 

@export var testPlaceableItem : placeableItem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itemInHandSprite = Sprite2D.new()
	add_child(itemInHandSprite)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Display item in hand
	itemInHandSprite.position = get_local_mouse_position()



func set_placing_item(item : placeableItem) -> void:
	currentPlacingItem = item	
	itemInHand = true
	itemInHandSprite.texture = item.icon

func _on_towerTest_button_pressed() -> void:
	set_placing_item(testPlaceableItem)
