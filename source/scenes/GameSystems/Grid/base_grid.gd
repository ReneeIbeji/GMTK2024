class_name BaseGrid
extends Node2D

@export var gridSquare : PackedScene
@export var shipPlaceableItem : placeableItem

@export var gridRowsCount : int = 10
@export var gridColumnsCount : int = 10

@export var shipRow : int
@export var shipColumn : int


var mainShipNode : GameItem
var gridCells : Array[Array]
var gridCellsContents : Array[Array]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalNodes.baseGridNode = self

	var cellDimensions : Vector2 = Vector2(125,125)

	for y in range(gridRowsCount):
		var tempRow : Array[Node2D]
		for x in range(gridColumnsCount):
			var tempSquare : GridCell = gridSquare.instantiate()
			tempSquare.position = position + Vector2(cellDimensions.x * x, cellDimensions.y * y)
			tempSquare.gridRow = y
			tempSquare.gridColumn = x
			tempSquare.rotate(PI * (y % 2))
			tempSquare.mouse_on_cell.connect(mouse_enters_new_cell)
			tempSquare.mouse_off_cell.connect(mouse_exits_current_cell)
			add_child(tempSquare)
			tempRow.append(tempSquare)

		gridCells.append(tempRow)

		var tempArray : Array[GameItem] = []
		tempArray.resize(gridColumnsCount)
		gridCellsContents.append(tempArray)

	place_item_on_grid(shipColumn,shipRow,shipPlaceableItem)		
	mainShipNode = get_item_on_grid(shipColumn,shipRow)
	


func place_item_on_grid(row : int, column : int , item : placeableItem) -> bool:
	if gridCellsContents[row][column] != null:
		return false

	var tempItemNode : GameItem = item.scene.instantiate() as GameItem
	tempItemNode.position = get_cell_position(row,column)

	tempItemNode.gridRow = row
	tempItemNode.gridColumn = column

	add_child(tempItemNode)
	gridCellsContents[row][column] = tempItemNode

	tempItemNode.gameItemDestroyed.connect(remove_item_from_grid)

	return true

func remove_item_from_grid(row : int, column : int) -> void:
	gridCellsContents[row][column] = null

func powerup_item_on_grid(row : int, column : int) -> bool:
	var gameItem : GameItem = get_item_on_grid(row, column)
	
	if gameItem == null:
		return false
	
	if gameItem == mainShipNode:
		return false

	if gameItem.currentlyUpgraded:
		return false

	if !set_scale_of_item(row, column, gameItem.upgradeSize):
		return false


	gameItem.upgrade()
	gameItem.currentlyUpgraded = true

	var powerDown := Callable(self, "powerdown_item_on_grid").bind(row,column)
	get_tree().create_timer(5).timeout.connect(powerDown)

	return true

func powerdown_item_on_grid(row : int, column : int) -> void:
	var gameItem : GameItem = get_item_on_grid(row, column)
	gameItem.degrade()
	gameItem.currentlyUpgraded = false
	set_scale_of_item(row, column, 1)

func set_scale_of_item(row : int, column : int, itemScale) -> bool:
	var gameItem : GameItem = get_item_on_grid(row, column)

	for x in range(column, column + itemScale):
		for y in range(row, row + itemScale): 
			if x == column && y == row:
				continue

			if get_item_on_grid(y,x) != null:
				return false

	gameItem.scale = Vector2(itemScale,itemScale)
	gameItem.position += Vector2(125 * (itemScale - 2) + 62.5, 125 * (itemScale - 2) + 62.5)

	return true



func get_item_on_grid(row : int, column : int) -> GameItem:
	return gridCellsContents[row][column]

func get_cell_position(row : int, column : int) -> Vector2:
	return gridCells[row][column].position

func mouse_enters_new_cell(row : int, column : int):
	GlobalNodes.gameNode.mouse_enter_grid_cell(row, column)

func mouse_exits_current_cell(row : int, column : int) -> void:
	GlobalNodes.gameNode.mouse_exits_grid_cell(row, column)
