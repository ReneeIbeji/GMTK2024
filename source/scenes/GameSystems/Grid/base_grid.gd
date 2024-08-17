extends Node2D

@export var gridSquare : PackedScene

@export var gridRowsCount : int = 10
@export var gridColumnsCount : int = 10


var gridCells : Array[Array]
var gridCellsContents : Array[Array]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cellDimensions : Vector2 = Vector2(125,125)

	for y in range(gridRowsCount):
		var tempRow : Array[Node2D]
		for x in range(gridColumnsCount):
			var tempSquare : GridCell = gridSquare.instantiate()
			tempSquare.position = position + Vector2(cellDimensions.x * x, cellDimensions.y * y)
			tempSquare.gridRow = y
			tempSquare.gridColumn = x
			tempSquare.rotate(PI * (y % 2))
			add_child(tempSquare)
			tempRow.append(tempSquare)
		gridCells.append(tempRow)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
