extends Control
## Full-screen overlay showing a grid of cards. Used to view the deck or to
## pick a card (upgrade / remove / transform). Instantiate, add_child, then
## call open(). Emits picked(index) when selectable, closed when dismissed.

signal picked(index)
signal closed

const CARD_SCENE := preload("res://scenes/Card.tscn")

var selectable := false

func open(entries: Array, title: String, p_selectable: bool, filter: Callable = Callable()) -> void:
	selectable = p_selectable
	$Panel/V/Title.text = title
	var grid: GridContainer = $Panel/V/Scroll/Grid
	for child in grid.get_children():
		child.queue_free()
	for i in entries.size():
		if filter.is_valid() and not filter.call(entries[i]):
			continue
		var cu := CARD_SCENE.instantiate()
		cu.entry = entries[i]
		cu.hoverable = false
		cu.set_meta("deck_index", i)
		grid.add_child(cu)
		cu.clicked.connect(_on_card_clicked)
	visible = true

func _on_card_clicked(card: Panel) -> void:
	if not selectable:
		return
	var idx: int = card.get_meta("deck_index")
	picked.emit(idx)
	queue_free()

func _on_close_button_pressed() -> void:
	closed.emit()
	queue_free()
