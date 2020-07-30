extends Node

var CanMove: bool = true

enum E_MovementState { STATE_IDLE, STATE_JUMPING, STATE_LANDING, 
STATE_SPRINTING, STATE_CROUCHING, STATE_HIDING,
STATE_WALKING_FORWARD, STATE_WALKING_BACKWARD, STATE_STRAFE_LEFT, STATE_STRAFE_RIGHT
}
var G_CurrentMovementState

enum E_CameraState { STATE_NORMAL, STATE_PEEK_LEFT, STATE_PEEK_RIGHT, STATE_ZOOM_IN}
var G_CurrentCameraState

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GetWorld.G_CurrentInputModeState = GetWorld.E_InputModeState.STATE_KEYBOARD_MOUSE
	G_CurrentMovementState = E_MovementState.STATE_IDLE
	pass 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	pass
