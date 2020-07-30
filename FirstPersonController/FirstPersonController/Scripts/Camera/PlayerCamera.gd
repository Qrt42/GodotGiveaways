extends Camera

# This should be attached to child of Handheld Effect Object

export var MouseSensitivity: float = 0.2
export var PeekAngle: float = 15.0
export var StrafeTiltAngle: float = 3.0

export var PeekOffset: float = 2.2
export var MinLookAngle: float = -70.0
export var MaxLookAngle: float = 70.0
export var RotationDampening: float = 7.0
export var ZoomTiltAmount: float = -2.0
export var SprintTiltAmount: float = 4.5
export var ZoomOffset: Vector3 = Vector3(0, 0, -0.5)
export var CrouchOffset: Vector3 = Vector3(0, -0.75, 0.0)

export var BaseFOV: float = 55.0
export var ZoomFOV: float = 45.0
export var SprintFOV: float = 65.0
export var MoveBackwardFOV: float = 58.0
export var FOVSpeed: float = 3.0

export var CameraRotationSpeed: float = 3.0
export var CameraMoveSpeed: float = 3.0

var TargetCameraTilt: Vector3 = Vector3.ZERO
var TargetCameraOffset: Vector3 = Vector3.ZERO
var TargetCameraRotation: Vector3 = Vector3.ZERO
var TargetFOV: float = 55.0

var RotationAxisValue: Vector2 = Vector2.ZERO
var PrevDirection: Vector3 = Vector3.ZERO
var CurDirection: Vector3 = Vector3.ZERO
var LookInAudio = preload("res://FirstPersonController/Assets/Audio/SFX/LookInSFX.ogg")
var LookOutAudio = preload("res://FirstPersonController/Assets/Audio/SFX/LookOutSFX.ogg")
var ZoomInAudio = preload("res://FirstPersonController/Assets/Audio/SFX/ZoomInSFX.ogg")
var ZoomOutAudio = preload("res://FirstPersonController/Assets/Audio/SFX/ZoomOutSFX.ogg")

onready var _CameraAudioPlayer = $CameraAudioPlayer

func _physics_process(delta: float) -> void:
	if GlobalPlayer.CanMove:
		_processState()
		_processInput()
		_processInputType()
		_processMovement(delta)
	pass

func _processState() -> void:
	match GlobalPlayer.G_CurrentMovementState:
		GlobalPlayer.E_MovementState.STATE_IDLE:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = 0.0
			TargetFOV = BaseFOV
			pass
		GlobalPlayer.E_MovementState.STATE_HIDING:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = 0.0
			TargetFOV = BaseFOV	
			pass
		GlobalPlayer.E_MovementState.STATE_STRAFE_LEFT:
			TargetCameraTilt.z = deg2rad(StrafeTiltAngle)
			TargetCameraOffset.y = 0.0
			TargetFOV = BaseFOV
			pass
		GlobalPlayer.E_MovementState.STATE_STRAFE_RIGHT:
			TargetCameraTilt.z = deg2rad(-StrafeTiltAngle)
			TargetCameraOffset.y = 0.0
			TargetFOV = BaseFOV	
			pass
		GlobalPlayer.E_MovementState.STATE_WALKING_FORWARD:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = 0.0
			TargetFOV = BaseFOV	
			pass
		GlobalPlayer.E_MovementState.STATE_WALKING_BACKWARD:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = 0.0
			TargetFOV = MoveBackwardFOV	
			pass
		GlobalPlayer.E_MovementState.STATE_SPRINTING:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = CrouchOffset.y/3
			TargetFOV = SprintFOV	
			pass
		GlobalPlayer.E_MovementState.STATE_CROUCHING:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.y = CrouchOffset.y
			TargetFOV = BaseFOV	
			pass
	pass

func _processInput() -> void:
	if GlobalPlayer.G_CurrentMovementState != GlobalPlayer.E_MovementState.STATE_SPRINTING and \
		GlobalPlayer.G_CurrentMovementState != GlobalPlayer.E_MovementState.STATE_HIDING:
	
		if Input.is_action_pressed("PeekLeft"):
			TargetCameraTilt.z = deg2rad(PeekAngle)
			TargetCameraOffset.x = -PeekOffset
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_PEEK_LEFT
			pass
		elif Input.is_action_pressed("PeekRight"):
			TargetCameraTilt.z = deg2rad(-PeekAngle)
			TargetCameraOffset.x = PeekOffset
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_PEEK_RIGHT
		elif Input.is_action_pressed("ZoomIn"):
			TargetCameraTilt.z = deg2rad(ZoomTiltAmount)
			TargetCameraOffset.z = ZoomOffset.z
			TargetFOV = ZoomFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_ZOOM_IN
			pass	
		else:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.x = 0.0
			TargetCameraOffset.z = 0.0
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_NORMAL
			pass
		_processSound()

	if GlobalPlayer.G_CurrentMovementState == GlobalPlayer.E_MovementState.STATE_CROUCHING:
		if Input.is_action_pressed("PeekLeft"):
			TargetCameraTilt.z = deg2rad(PeekAngle/2)
			TargetCameraOffset.x = -PeekOffset/2
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_PEEK_LEFT
			pass
		elif Input.is_action_pressed("PeekRight"):
			TargetCameraTilt.z = deg2rad(-PeekAngle/2)
			TargetCameraOffset.x = PeekOffset/2
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_PEEK_RIGHT
		elif Input.is_action_pressed("ZoomIn"):
			TargetCameraTilt.z = deg2rad(ZoomTiltAmount/2)
			TargetCameraOffset.z = ZoomOffset.z/2
			TargetFOV = ZoomFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_ZOOM_IN
			pass
		else:
			TargetCameraTilt.z = 0.0
			TargetCameraOffset.x = 0.0
			TargetCameraOffset.z = 0.0
			TargetFOV = BaseFOV
			GlobalPlayer.G_CurrentCameraState = GlobalPlayer.E_CameraState.STATE_NORMAL
			pass
		_processSound()

	pass

func _processSound() -> void:
	if Input.is_action_just_pressed("PeekLeft"):
		_CameraAudioPlayer.stream = LookOutAudio
		_CameraAudioPlayer.play()
		pass
	elif Input.is_action_just_pressed("PeekRight"):
		_CameraAudioPlayer.stream = LookOutAudio
		_CameraAudioPlayer.play()
		pass
	elif Input.is_action_just_pressed("ZoomIn"):
		_CameraAudioPlayer.stream = ZoomInAudio
		_CameraAudioPlayer.play()
		pass

	if Input.is_action_just_released("PeekLeft"):
		_CameraAudioPlayer.stream = LookInAudio
		_CameraAudioPlayer.play()
		pass
	elif Input.is_action_just_released("PeekRight"):
		_CameraAudioPlayer.stream = LookInAudio
		_CameraAudioPlayer.play()
		pass
	elif Input.is_action_just_released("ZoomIn"):
		_CameraAudioPlayer.stream = ZoomOutAudio
		_CameraAudioPlayer.play()
		pass
	pass

func _processInputType() -> void:
	if GetWorld.G_CurrentInputModeState == GetWorld.E_InputModeState.STATE_KEYBOARD:
		RotationAxisValue.y = Input.get_action_strength("LookUp") - Input.get_action_strength("LookDown") * CameraRotationSpeed
	if GetWorld.G_CurrentInputModeState == GetWorld.E_InputModeState.STATE_KEYBOARD_MOUSE:
		RotationAxisValue.y *= MouseSensitivity
	pass

func _processMovement(delta: float) -> void:

	TargetCameraRotation.y = lerp(TargetCameraRotation.y, RotationAxisValue.y, delta * RotationDampening)
	rotate_x(deg2rad(-TargetCameraRotation.y))
	rotation_degrees.x = clamp(rotation_degrees.x, MinLookAngle, MaxLookAngle)

	rotation.y = lerp(rotation.y, TargetCameraTilt.y, delta * CameraRotationSpeed)
	rotation.z = lerp(rotation.z, TargetCameraTilt.z, delta * CameraRotationSpeed)
	translation.x = lerp(translation.x , TargetCameraOffset.x, delta * CameraMoveSpeed)
	translation.y = lerp(translation.y , TargetCameraOffset.y, delta * CameraMoveSpeed)
	translation.z = lerp(translation.z , TargetCameraOffset.z, delta * CameraMoveSpeed)
	fov = lerp(fov, TargetFOV, delta * FOVSpeed)
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		CurDirection.y = event.relative.y
		RotationAxisValue.y = CurDirection.y
		if PrevDirection.y != CurDirection.y:
			PrevDirection.y = CurDirection.y

