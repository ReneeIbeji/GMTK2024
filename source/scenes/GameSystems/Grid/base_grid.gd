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


func _ready() -> void:
	GlobalNodes.baseGridNode = self

	var cellDimensions : Vector2 = Vector2(125,125)

	# Instantiate and place grid cells into the game world
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

		# Builds up array of grid cells
		gridCells.append(tempRow)

		# Builds up array to store game items in each grid cell
		var tempArray : Array[GameItem] = []
		tempArray.resize(gridColumnsCount)
		gridCellsContents.append(tempArray)

	# Places the main ship to defend onto the grid
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

# Attempts to power up an item on the grid, returns true if successful, returns false if unsuccessful
func powerup_item_on_grid(row : int, column : int) -> bool:
	var gameItem : GameItem = get_item_on_grid(row, column)
	
	# Check if gameitem furfills the conditions to be powered up
	if gameItem == null:
		return false
	
	if gameItem == mainShipNode:
		return false

	if gameItem.currentlyUpgraded:
		return false

	# Checks if its possible
	if !set_scale_of_item(row, column, gameItem.upgradeSize):
		return false


	gameItem.upgrade()
	gameItem.currentlyUpgraded = true

	# Sets the game item on the grid to be powered down after 5 seconds havbe passed by calling a function
	var powerDown := Callable(self, "powerdown_item_on_grid").bind(row,column)
	get_tree().create_timer(5).timeout.connect(powerDown)

	return true

func powerdown_item_on_grid(row : int, column : int) -> void:
	var gameItem : GameItem = get_item_on_grid(row, column)
	if gameItem == null:
		return
	if gameItem.is_queued_for_deletion():
		return
	gameItem.degrade()
	gameItem.currentlyUpgraded = false
	set_scale_of_item(row, column, 1)

# Trys to scale up an item on the grid in a valid way so it doesn't occupy cells that already contain items,
#  returns true if successful and false if note
func set_scale_of_item(row : int, column : int, itemScale : int) -> bool:
	var gameItem : GameItem = get_item_on_grid(row, column)
	var scaleCorner : Vector2 = get_valid_scale_pos(row, column, itemScale)

	# If itemScale is 1, run a different procedure to treturn the item to its original scale
	if itemScale == 1:
		gameItem.position = get_cell_position(row,column)
		gameItem.scale = Vector2(1,1)

		# Remove gameitem from every cell except original position
		for y in range(0, gridColumnsCount):
			for x in range(0, gridRowsCount):
				print(Vector2(y,x))
				if x == gameItem.gridColumn && y == gameItem.gridRow:
					continue
				if get_item_on_grid(y,x) != gameItem:
					continue
				gridCellsContents[y][x] = null
		return true
		
	

	# Check for failure of finding a possible corner position for the scaled up gameitem
	if scaleCorner == Vector2(-1, -1):
		return false
	

	# Add game item to every grid cell which it now spans over
	for y in range(scaleCorner.y, scaleCorner.y + itemScale):
		for x in range(scaleCorner.x, scaleCorner.x + itemScale):
			print(Vector2(x,y))
			gridCellsContents[x][y] = gameItem
	
	# Correctly position and scale the game item on screen to correspond to scale up
	gameItem.position = get_cell_position(scaleCorner.x,scaleCorner.y)
	gameItem.scale = Vector2(itemScale,itemScale)
	gameItem.position += Vector2(125 * (itemScale - 2) + 62.5, 125 * (itemScale - 2) + 62.5)

	return true

# Returns a valid position for the corner of the scaled up game item, if no valid position, return a (-1,-1) Vector
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

# Checks if a scale up corner position for a game item is valid (none of the grid cells it would span already contain an item)
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
