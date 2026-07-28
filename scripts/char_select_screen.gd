extends Control
## Pick your hero before the climb.

func _ready() -> void:
	_fill_panel($IroncladPanel, "ironclad")
	_fill_panel($SilentPanel, "silent")

func _fill_panel(panel: Panel, id: String) -> void:
	var cdef: Dictionary = Run.CHARACTERS[id]
	var rdef: Dictionary = RelicsDB.RELICS[cdef.relic]
	panel.get_node("V/Sprite").texture = load(cdef.sprite)
	panel.get_node("V/Name").text = cdef.name
	panel.get_node("V/Stats").text = "%d Max HP" % cdef.max_hp
	panel.get_node("V/Relic").text = "%s — %s" % [rdef.name, rdef.text]
	panel.get_node("V/Desc").text = cdef.desc

func _on_ironclad_pressed() -> void:
	_choose("ironclad")

func _on_silent_pressed() -> void:
	_choose("silent")

func _choose(id: String) -> void:
	Run.new_run(id)
	get_node("/root/Main").goto("neow")
