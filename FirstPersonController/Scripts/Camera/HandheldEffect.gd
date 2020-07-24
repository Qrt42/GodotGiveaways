extends CollisionShape

export var IdleShakeRange: float = 3.5
export var IdleShakePower: float = 12.0

export var HidingShakeRange: float = 1.5
export var HidingShakePower: float = 3.0

export var StrafingShakeRange: float = 7.5
export var StrafingShakePower: float = 13.0

export var WalkForwardShakeRange: float = 9.5
export var WalkForwardShakePower: float = 20.0

export var WalkBackwardShakeRange: float = 6.5
export var WalkBackwardShakePower: float = 15.0

export var CrouchShakeRange: float = 2.5
export var CrouchShakePower: float = 7.0

export var SprintShakeRange: float = 25.0
export var SprintShakePower: float = 150.0

export(float, 0.0, 1.0) var ShakeDecay: float = 0.5

var CurrentShakePower: float = 0.0
var CurrentShakeRange: float = 0.0
var CurrentShakeTimerReset: float = 0.0
var CurrentShakeAmount: Vector2 = Vector2.ZERO
var CameraLerpSpeed: float = 5.0

var Timer: float = 0.0
var CameraMovementNoise: OpenSimplexNoise = OpenSimplexNoise.new()

func _ready() -> void:
	randomize()

	CameraMovementNoise.seed = randi()
	CameraMovementNoise.octaves = 6
	CameraMovementNoise.period = 80.0
	CameraMovementNoise.persistence = 0.65

	CurrentShakeRange = IdleShakeRange
	CurrentShakePower = IdleShakePower
	pass

func _physics_process(delta: float) -> void:
	_processState()
	_processShake(delta)
	pass

func _processState() -> void:
	match GlobalPlayer.G_CurrentMovementState:
		GlobalPlayer.E_MovementState.STATE_IDLE:
			CurrentShakeRange = IdleShakeRange
			CurrentShakePower = IdleShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_HIDING:
			CurrentShakeRange = HidingShakeRange
			CurrentShakePower = HidingShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_STRAFE_LEFT:
			CurrentShakeRange = StrafingShakeRange
			CurrentShakePower = StrafingShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_STRAFE_RIGHT:
			CurrentShakeRange = StrafingShakeRange
			CurrentShakePower = StrafingShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_WALKING_FORWARD:
			CurrentShakeRange = WalkForwardShakeRange
			CurrentShakePower = WalkForwardShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_WALKING_BACKWARD:
			CurrentShakeRange = WalkBackwardShakeRange
			CurrentShakePower = WalkBackwardShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_SPRINTING:
			CurrentShakeRange = SprintShakeRange
			CurrentShakePower = SprintShakePower
			pass
		GlobalPlayer.E_MovementState.STATE_CROUCHING:
			CurrentShakeRange = CrouchShakeRange
			CurrentShakePower = CrouchShakePower
			pass
	pass

func _processShake(delta: float) -> void:
	Timer += delta
	ShakeDecay = pow(ShakeDecay, 2)

	CurrentShakeAmount.x = CameraMovementNoise.get_noise_3d(Timer * CurrentShakePower, 0.0, 0.0) * CurrentShakeRange 
	rotation.x = lerp(rotation.x, deg2rad(CurrentShakeAmount.x), delta * CameraLerpSpeed)
	CurrentShakeAmount.y = CameraMovementNoise.get_noise_3d(0.0, Timer * CurrentShakePower, 0.0) * CurrentShakeRange
	rotation.y = lerp(rotation.y, deg2rad(CurrentShakeAmount.y), delta * CameraLerpSpeed)
	pass