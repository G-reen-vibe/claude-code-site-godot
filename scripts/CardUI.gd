extends Button
## Visual widget for a single card (used in the hand and in reward screens).
## Instanced from res://scenes/Card.tscn, then configured with setup().

signal card_clicked(index: int)

const TYPE_COLORS := {
	"attack": Color(0.75, 0.22, 0.17),
	"skill": Color(0.15, 0.62, 0.35),
	"power": Color(0.16, 0.45, 0.75),
}

var card_id := ""
var index := -1


func _ready() -> void:
	pressed.connect(func(): card_clicked.emit(index))


func setup(id: String, idx: int) -> void:
	card_id = id
	index = idx
	var card: Dictionary = CardLibrary.CARDS[id]
	get_node("TypeStrip").color = TYPE_COLORS.get(card["type"], Color.GRAY)
	get_node("VBox/TopRow/CostLabel").text = str(card["cost"])
	get_node("VBox/TopRow/NameLabel").text = card["name"]
	get_node("VBox/TypeLabel").text = String(card["type"]).capitalize()
	get_node("VBox/DescLabel").text = card["desc"]
	tooltip_text = "%s (%d)\n%s" % [card["name"], card["cost"], card["desc"]]
