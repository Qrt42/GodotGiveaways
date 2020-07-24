extends KinematicBody

const ACCELERATION: float = 15.0
const FRICTION: float = 0.45
const DAMPING: float = 0.1
const DEAD_ZONE: float = 0.05
const GRAVITY: float = -42.0
const JUMP_FORCE: float = 10.0

export var PlayerRotationSensitivity : float = 3.0
export var RotationDampening: float = 7.0

export var MouseSensitivity : float = 0.2
export var StrafeSpeed: float = 1.25
export var WalkForwardSpeed: float = 1.35
export var WalkBackwardSpeed: float = 1.00
export var SprintSpeed: float = 2.35
export var CrouchSpeed: float = 0.65


var CurrentMaxSpeed: float = 0.0
var Velocity: Vector3 = Vector3.ZERO
var PrevDirection: Vector3 = Vector3.ZERO
var CurDirection: Vector3 = Vector3.ZERO
var TargetPlayerRotation: Vector3 = Vector3.ZERO

var MovementAxisValue: Vector2 = Vector2.ZERO
var RotationAxisValue: Vector2 = Vector2.ZERO

onready var _FirstPersonCamera = $HeadCollision/FirstPersonCamera

func _physics_process(delta) -> void:
	if GlobalPlayer.CanMove:
		_processInput()
		_checkState()
		_processState()
		_processMovement(delta)
	pass

func _processInput() -> void:
	MovementAxisValue.x = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	MovementAxisValue.y = Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Velocity.y = JUMP_FORCE

	if Input.is_action_pressed("Sprint") and is_on_floor() and -MovementAxisValue.y > 0:
		GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_SPRINTING
		pass
	elif Input.is_action_pressed("Crouch") and is_on_floor():
		GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_CROUCHING
		pass
	else:
		GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_IDLE
		pass
	pass 


func _processDirection() -> Vector3:
	var FacingDirection: = Vector3.ZERO
	FacingDirection += _FirstPersonCamera.global_transform.basis.x * MovementAxisValue.x
	FacingDirection += _FirstPersonCamera.global_transform.basis.z * MovementAxisValue.y
	FacingDirection = FacingDirection.normalized()
	return FacingDirection

func _processMovement(delta) -> void:

	if abs(MovementAxisValue.x) > DEAD_ZONE:
		Velocity.x += MovementAxisValue.x * ACCELERATION * delta
		Velocity.x *= pow(1 - DAMPING, delta * 10)
	else:
		Velocity.x = lerp(Velocity.x, 0, FRICTION)
	if abs(MovementAxisValue.y) > DEAD_ZONE:
		Velocity.z += MovementAxisValue.y * ACCELERATION * delta
		Velocity.z *= pow(1 - DAMPING, delta * 10)
	else:
		Velocity.z = lerp(Velocity.z, 0, FRICTION)


	Velocity.x = _processDirection().x * CurrentMaxSpeed
	Velocity.y += GRAVITY * delta
	Velocity.z = _processDirection().z * CurrentMaxSpeed
	Velocity = move_and_slide(Velocity, Vector3.UP)
	Velocity.x = clamp(Velocity.x, -CurrentMaxSpeed * 0.9, CurrentMaxSpeed * 0.9)
	Velocity.z = clamp(Velocity.z, -CurrentMaxSpeed, CurrentMaxSpeed)

	if GetWorld.G_CurrentInputModeState == GetWorld.E_InputModeState.STATE_KEYBOARD:
		RotationAxisValue.x = Input.get_action_strength("LookRight") - Input.get_action_strength("LookLeft") * PlayerRotationSensitivity

	if GetWorld.G_CurrentInputModeState == GetWorld.E_InputModeState.STATE_KEYBOARD_MOUSE:
		RotationAxisValue.x *= MouseSensitivity

	TargetPlayerRotation.x = lerp(TargetPlayerRotation.x, RotationAxisValue.x, delta * RotationDampening)
	rotate_y(deg2rad(-TargetPlayerRotation.x))
	pass

func _processState() -> void:
	match GlobalPlayer.G_CurrentMovementState:
		GlobalPlayer.E_MovementState.STATE_IDLE:
			CurrentMaxSpeed = 0.0
		GlobalPlayer.E_MovementState.STATE_HIDING:
			CurrentMaxSpeed = 0.0
		GlobalPlayer.E_MovementState.STATE_STRAFE_LEFT:
			CurrentMaxSpeed = StrafeSpeed
		GlobalPlayer.E_MovementState.STATE_STRAFE_RIGHT:
			CurrentMaxSpeed = StrafeSpeed
		GlobalPlayer.E_MovementState.STATE_WALKING_FORWARD:
			CurrentMaxSpeed = WalkForwardSpeed
		GlobalPlayer.E_MovementState.STATE_WALKING_BACKWARD:
			CurrentMaxSpeed = WalkBackwardSpeed
		GlobalPlayer.E_MovementState.STATE_SPRINTING:
			CurrentMaxSpeed = SprintSpeed
		GlobalPlayer.E_MovementState.STATE_CROUCHING:
			CurrentMaxSpeed = CrouchSpeed
	pass

func _checkState() -> void:
	if GlobalPlayer.G_CurrentMovementState != GlobalPlayer.E_MovementState.STATE_SPRINTING and \
		GlobalPlayer.G_CurrentMovementState != GlobalPlayer.E_MovementState.STATE_CROUCHING and \
		GlobalPlayer.G_CurrentMovementState != GlobalPlayer.E_MovementState.STATE_HIDING:
		if MovementAxisValue.length() == 0.0:
			GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_IDLE
		elif -MovementAxisValue.y > 0:
			GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_WALKING_FORWARD
		elif -MovementAxisValue.y < 0:
			GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_WALKING_BACKWARD
		elif MovementAxisValue.x > 0:
			GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_STRAFE_RIGHT
		elif MovementAxisValue.x < 0:
			GlobalPlayer.G_CurrentMovementState = GlobalPlayer.E_MovementState.STATE_STRAFE_LEFT
	pass
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		CurDirection.x = event.relative.x
		RotationAxisValue.x = CurDirection.x
		if PrevDirection.x != CurDirection.x:
			PrevDirection.x = CurDirection.x
