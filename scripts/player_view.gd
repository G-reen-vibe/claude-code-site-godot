extends Control
## The hero's battle presence: sprite, HP bar, block badge, statuses.

func _ready() -> void:
	var cdef: Dictionary = Run.CHARACTERS[Run.character]
	$V/SpriteBox/Sprite.texture = load(cdef.sprite)
	$V/NameLabel.text = cdef.name

func refresh(block: int, status_text: String) -> void:
	$V/HPRow/HPBar.max_value = Run.max_hp
	$V/HPRow/HPBar.value = Run.hp
	$V/HPRow/HPBar/HPLabel.text = "%d/%d" % [Run.hp, Run.max_hp]
	$V/HPRow/BlockBox.visible = block > 0
	$V/HPRow/BlockBox/BlockLabel.text = str(block)
	$V/StatusLabel.text = status_text

func _sprite_center() -> Vector2:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	return sprite.global_position + sprite.size / 2.0

func play_hit(amount: int) -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	FloatText.spawn(self, _sprite_center(), str(amount), Color(1, 0.35, 0.3), 30)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.06)
	tw.tween_property(sprite, "position:x", sprite.position.x - 10.0, 0.05)
	tw.tween_property(sprite, "position:x", sprite.position.x + 8.0, 0.07)
	tw.tween_property(sprite, "position:x", sprite.position.x, 0.05)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func play_blocked() -> void:
	FloatText.spawn(self, _sprite_center(), "Blocked", Color(0.6, 0.8, 1), 20)

func play_block_gain(amount: int) -> void:
	FloatText.spawn(self, _sprite_center(), "+%d Block" % amount, Color(0.62, 0.8, 1), 22)

func play_heal(amount: int) -> void:
	FloatText.spawn(self, _sprite_center(), "+%d HP" % amount, Color(0.5, 0.9, 0.5), 22)

func play_gold_stolen(amount: int) -> void:
	FloatText.spawn(self, _sprite_center(), "-%d Gold!" % amount, Color(1, 0.85, 0.4), 22)

func play_lunge() -> void:
	var sprite: TextureRect = $V/SpriteBox/Sprite
	var tw := create_tween().set_trans(Tween.TRANS_QUAD)
	tw.tween_property(sprite, "position:x", sprite.position.x + 30.0, 0.1).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "position:x", sprite.position.x, 0.18).set_ease(Tween.EASE_IN_OUT)
