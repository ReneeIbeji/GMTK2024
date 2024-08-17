class_name GridCell
extends Area2D

var gridRow : int 
var gridColumn : int

var mouseOnSquare : bool

signal mouse_on_cell(row : int, column : int)
signal mouse_off_cell(row : int, column : int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(mouse_entered_cell)
	mouse_exited.connect(mouse_exited_cell)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func mouse_entered_cell() -> void:
	mouse_on_cell.emit(gridRow, gridColumn)

func mouse_exited_cell() -> void:
	mouse_off_cell.emit(gridRow, gridColumn)

	
