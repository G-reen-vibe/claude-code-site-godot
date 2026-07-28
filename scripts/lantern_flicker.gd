extends OmniLight3D
## Organic candle-style flicker for point lights.
##
## Sums three unsynchronized sine waves so the flicker never visibly loops —
## the warm, unstable lantern light is a staple of Octopath's night scenes.

@export var base_energy: float = 2.4
@export var flicker_amount: float = 0.5
@export var flicker_speed: float = 7.0

var _time: float = 0.0


func _ready() -> void:
	_time = randf() * 100.0


func _process(delta: float) -> void:
	_time += delta * flicker_speed
	var noise := sin(_time) * 0.5 \
			+ sin(_time * 2.33 + 1.7) * 0.3 \
			+ sin(_time * 4.71 + 0.4) * 0.2
	light_energy = maxf(base_energy + noise * flicker_amount, 0.0)
