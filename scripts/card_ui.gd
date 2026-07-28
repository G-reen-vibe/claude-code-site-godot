extends Panel
## Visual card. Set `entry` ({"id": String, "up": bool}) before adding to the tree.

signal clicked(card)

const TYPE_TINT := {
	"attack": Color(0.75, 0.35, 0.35),
	"skill": Color(0.35, 0.55, 0.8),
	"power": Color(0.6, 0.45, 0.85),
}

var entry: Dictionary = {}
var selected := false

func _ready() -> void:
	if entry.is_empty():
		return
	var def := CardsDB.get_def(entry)
	$V/Top/CostLabel.text = str(def.cost)
	$V/Top/NameLabel.text = def.display_name
	$V/TypeLabel.text = String(def.type).capitalize()
	$V/TextLabel.text = def.text
	self_modulate = TYPE_TINT.get(def.type, Color.WHITE)

func set_selected(v: bool) -> void:
	selected = v
	modulate = Color(1, 1, 0.55) if v else Color.WHITE

func set_affordable(v: bool) -> void:
	if selected:
		return
	modulate = Color.WHITE if v else Color(0.6, 0.6, 0.65)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)
