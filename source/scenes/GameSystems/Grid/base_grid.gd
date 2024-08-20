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
	if gameItem.is_queued_for_deletion():
		return
	if gameItem == null:
		return

	gameItem.degrade()
	gameItem.currentlyUpgraded = false
	set_scale_of_item(row, column, 1)

func set_scale_of_item(row : int, column : int, itemScale : int) -> bool:
	var gameItem : GameItem = get_item_on_grid(row, column)
	var scaleCorner : Vector2 = get_valid_scale_pos(row, column, itemScale)

	if itemScale == 1:
		gameItem.position = get_cell_position(row,column)
		gameItem.scale = Vector2(1,1)
		for y in range(0, gridRowsCount):
			for x in range(0, gridColumnsCount):
				if get_item_on_grid(y,x) != gameItem:
					continue
				if x == gameItem.gridColumn && y == gameItem.gridRow:
					continue
				gridCellsContents[y][x] = null
		return true
		

	if scaleCorner == Vector2(-1, -1):
		return false
	
	print(scaleCorner)
	for y in range(scaleCorner.y, scaleCorner.y + itemScale):
		for x in range(scaleCorner.x, scaleCorner.x + itemScale):
			print(Vector2(x,y))
			gridCellsContents[x][y] = gameItem

	gameItem.position = get_cell_position(scaleCorner.x,scaleCorner.y)
	gameItem.scale = Vector2(itemScale,itemScale)
	gameItem.position += Vector2(125 * (itemScale - 2) + 62.5, 125 * (itemScale - 2) + 62.5)

	return true

func get_valid_scale_pos(row : int, column : int, itemScale : int) -> Vector2:

	var gameItem : GameItem = get_item_on_grid(row, column)

	# middle check
	if check_scale_pos(row,column,itemScale,gameItem):
		return Vector2(row,column)
	# top left
	if check_scale_pos(row - itemScale + 1,column - itemScale + 1,itemScale,gameItem):
		return Vector2(row - itemScale + 1,column - itemScale + 1)

	# top middle
	if check_scale_pos(row - itemScale + 1,column,itemScale,gameItem):
		return Vector2(row - itemScale + 1,column)

	# middle left 
	if check_scale_pos(row,column - itemScale + 1,itemScale,gameItem):
		return Vector2(row,column - itemScale + 1)

	
	return Vector2(-1,-1)


func check_scale_pos(row : int, column : int, itemScale : int, gameItem : GameItem) -> bool:


	if row < 0 || column < 0:
		return false

	print(column + itemScale - 1)
	print(gridColumnsCount)
	if (row + itemScale - 1 >= gridRowsCount) || (column + itemScale - 1 >= gridColumnsCount) :
		return false
	

	for x in range(column, column + itemScale):
		for y in range(row, row + itemScale): 
			if x == gameItem.gridColumn && y == gameItem.gridRow:
				continue

			if get_item_on_grid(y,x) != null:
				return false
	
	return true


func get_item_on_grid(row : int, column : int) -> GameItem:
	return gridCellsContents[row][column]

func get_cell_position(row : int, column : int) -> Vector2:
	return gridCells[row][column].position

func mouse_enters_new_cell(row : int, column : int):
	GlobalNodes.gameNode.mouse_enter_grid_cell(row, column)

func mouse_exits_current_cell(row : int, column : int) -> void:
	GlobalNodes.gameNode.mouse_exits_grid_cell(row, column)
