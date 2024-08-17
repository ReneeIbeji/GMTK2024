class_name BaseGrid
extends Node2D

@export var gridSquare : PackedScene
@export var shipGameItem : PackedScene

@export var gridRowsCount : int = 10
@export var gridColumnsCount : int = 10

@export var shipRow : int
@export var shipColumn : int


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

	var tempShipNode : GameItem = shipGameItem.instantiate()
	tempShipNode.position = get_cell_position(shipRow,shipColumn)
	add_child(tempShipNode)
	place_item_on_grid(shipColumn,shipRow,tempShipNode)	
	


func place_item_on_grid(row : int, column : int , item : GameItem) -> void:
	gridCellsContents[row][column] = item

func get_item_on_grid(row : int, column : int) -> GameItem:
	return gridCellsContents[row][column]

func get_cell_position(row : int, column : int) -> Vector2:
	return gridCells[row][column].position

func mouse_enters_new_cell(row : int, column : int):
	GlobalNodes.gameNode.mouse_enter_grid_cell(row, column)

func mouse_exits_current_cell(row : int, column : int) -> void:
	GlobalNodes.gameNode.mouse_exits_grid_cell(row, column)
