extends CanvasLayer

export var NormalBarHeight: float = 100.0
export var PeekBarHeight: float = 115.0
export var ZoomBarHeight: float = 132.0
export var BarLerpSpeed: float = 2.0

var CurrentBarHeightTop: float = NormalBarHeight
var CurrentBarHeightBottom: float = NormalBarHeight

onready var _TopBar = $Top
onready var _BottomBar = $Bottom

func _process(delta: float) -> void:
	match GlobalPlayer.G_CurrentCameraState:
		GlobalPlayer.E_CameraState.STATE_NORMAL:
			CurrentBarHeightTop = NormalBarHeight
			CurrentBarHeightBottom = NormalBarHeight
			pass
		GlobalPlayer.E_CameraState.STATE_PEEK_LEFT:
			CurrentBarHeightTop = PeekBarHeight
			CurrentBarHeightBottom = PeekBarHeight
			pass
		GlobalPlayer.E_CameraState.STATE_PEEK_RIGHT:
			CurrentBarHeightTop = PeekBarHeight
			CurrentBarHeightBottom = PeekBarHeight
			pass
		GlobalPlayer.E_CameraState.STATE_ZOOM_IN:
			CurrentBarHeightTop = ZoomBarHeight
			CurrentBarHeightBottom = ZoomBarHeight
			pass

	_TopBar.margin_bottom = lerp(_TopBar.margin_bottom, CurrentBarHeightTop, delta * BarLerpSpeed)
	_BottomBar.margin_top = lerp(_BottomBar.margin_top, -NormalBarHeight - (CurrentBarHeightTop - NormalBarHeight), delta * BarLerpSpeed)
	pass



