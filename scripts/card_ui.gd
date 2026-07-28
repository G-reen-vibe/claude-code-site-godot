extends Panel
## Visual card. Set `entry` ({"id": String, "up": bool, ...}) before adding to
## the tree. Combat stores per-copy state (e.g. Rampage bonus) in the entry.

signal clicked(card)

const TYPE_BG := {
	"attack": Color(0.33, 0.13, 0.12),
	"skill": Color(0.12, 0.23, 0.33),
	"power": Color(0.25, 0.16, 0.35),
	"status": Color(0.2, 0.2, 0.23),
	"curse": Color(0.16, 0.12, 0.19),
}
const RARITY_BORDER := {
	"starter": Color(0.55, 0.57, 0.6),
	"common": Color(0.63, 0.65, 0.67),
	"uncommon": Color(0.35, 0.68, 0.78),
	"rare": Color(0.9, 0.72, 0.25),
	"status": Color(0.45, 0.4, 0.5),
	"curse": Color(0.42, 0.32, 0.5),
}
const TYPE_ART := {
	"attack": preload("res://assets/icons/attack.svg"),
	"skill": preload("res://assets/icons/defend.svg"),
	"power": preload("res://assets/icons/star.svg"),
	"status": preload("res://assets/icons/unknown.svg"),
	"curse": preload("res://assets/icons/skull.svg"),
}

var entry: Dictionary = {}
var selected := false
var hoverable := true

func _ready() -> void:
	pivot_offset = Vector2(size.x / 2.0, size.y)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	refresh()

func refresh() -> void:
	if entry.is_empty():
		return
	var def := CardsDB.get_def(entry)
	var sb := StyleBoxFlat.new()
	sb.bg_color = TYPE_BG.get(def.type, Color(0.2, 0.2, 0.2))
	sb.set_border_width_all(3)
	sb.border_color = RARITY_BORDER.get(def.rarity, Color.GRAY)
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 4
	add_theme_stylebox_override("panel", sb)
	$V/Top/CostOrb/CostLabel.text = "-" if def.get("unplayable", false) else str(def.cost)
	if def.get("x_cost", false):
		$V/Top/CostOrb/CostLabel.text = "X"
	$V/Top/NameLabel.text = def.display_name
	$V/Art/Icon.texture = TYPE_ART.get(def.type, TYPE_ART["status"])
	$V/TypeLabel.text = String(def.type).capitalize()
	var txt: String = def.text
	if entry.get("_bonus", 0) > 0:
		txt += " (now +%d)" % entry._bonus
	$V/TextLabel.text = txt

func set_selected(v: bool) -> void:
	selected = v
	modulate = Color(1, 1, 0.55) if v else Color.WHITE

func set_affordable(v: bool) -> void:
	if selected:
		return
	modulate = Color.WHITE if v else Color(0.55, 0.55, 0.6)

func _on_hover(entering: bool) -> void:
	if not hoverable:
		return
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.13, 1.13) if entering else Vector2.ONE, 0.12)
	z_index = 10 if entering else 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
