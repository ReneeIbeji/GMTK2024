extends Camera2D


@export var cameraSpeed : float = 1
@export var zoomSpeed : float = 1
var targetPosition : Vector2

var lastMousePosition : Vector2
var currentMousePosition : Vector2

var cameraDragging : bool = false
var mouseInWindow : bool = true

var zoomPos : Vector2

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

	print(Input.get_axis("CAMERA_ZoomIn","CAMERA_ZoomOut"))
	if Input.is_action_pressed("CAMERA_ZoomIn"):
		print("zoom in")
	if Input.is_action_pressed("CAMERA_ZoomOut"):
		zoom -= Vector2(1,1) * zoomSpeed * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoomPos = get_global_mouse_position()
				cameraZoomIn(1)
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoomPos = get_global_mouse_position()
				cameraZoomIn(-1)

func cameraZoomIn(value : float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	zoom += Vector2(1,1) * zoomSpeed * value * zoom
	zoom = zoom.clampf(0.25,3)
	var new_mouse_pos : Vector2 = get_global_mouse_position()
	position += mouse_pos - new_mouse_pos

 
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouseInWindow = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouseInWindow = true
