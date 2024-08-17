extends Camera2D


@export var cameraSpeed : float = 1
var targetPosition : Vector2

var lastMousePosition : Vector2
var currentMousePosition : Vector2

var cameraDragging : bool = false
var mouseInWindow : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(get_local_mouse_position())
	if cameraDragging && Input.is_action_pressed("ACTION_DragCamera") && mouseInWindow:
		lastMousePosition = currentMousePosition
		currentMousePosition = get_local_mouse_position()

		var mousePositionDelta : Vector2 = lastMousePosition - currentMousePosition
		position += mousePositionDelta * cameraSpeed 

	elif cameraDragging && !Input.is_action_pressed("ACTION_DragCamera") || !mouseInWindow:
		cameraDragging = false
	elif !cameraDragging && Input.is_action_pressed("ACTION_DragCamera") && mouseInWindow:
		cameraDragging = true
		currentMousePosition = get_local_mouse_position()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouseInWindow = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouseInWindow = true

