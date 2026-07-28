extends Control
## Pick your hero and ascension level before the climb.

var asc_choice: Dictionary = {}

func _ready() -> void:
	for id in Run.CHARACTERS:
		asc_choice[id] = 0
		$Row.add_child(_build_panel(id))

func _build_panel(id: String) -> Panel:
	var cdef: Dictionary = Run.CHARACTERS[id]
	var rdef: Dictionary = RelicsDB.RELICS[cdef.relic]
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(280, 560)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 14
	v.offset_top = 12
	v.offset_right = -14
	v.offset_bottom = -12
	v.add_theme_constant_override("separation", 6)
	panel.add_child(v)
	var sprite := TextureRect.new()
	sprite.texture = load(cdef.sprite)
	sprite.custom_minimum_size = Vector2(0, 170)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	v.add_child(sprite)
	var name_label := Label.new()
	name_label.text = cdef.name
	name_label.add_theme_font_size_override("font_size", 21)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(name_label)
	var stats := Label.new()
	stats.text = "%d Max HP" % cdef.max_hp
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_color_override("font_color", Color(0.95, 0.6, 0.58))
	v.add_child(stats)
	var relic := Label.new()
	relic.text = "%s — %s" % [rdef.name, rdef.text]
	relic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	relic.add_theme_font_size_override("font_size", 12)
	relic.add_theme_color_override("font_color", Color(0.7, 0.85, 1))
	relic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relic.custom_minimum_size = Vector2(0, 56)
	v.add_child(relic)
	var desc := Label.new()
	desc.text = cdef.desc
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.78, 0.76, 0.72))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(desc)
	# Ascension picker (unlocked by winning runs).
	var unlocked := Run.unlocked_ascension(id)
	var asc_row := HBoxContainer.new()
	asc_row.alignment = BoxContainer.ALIGNMENT_CENTER
	asc_row.add_theme_constant_override("separation", 8)
	var minus := Button.new()
	minus.text = "-"
	var asc_label := Label.new()
	asc_label.text = "Ascension 0"
	asc_label.custom_minimum_size = Vector2(110, 0)
	asc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	asc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var plus := Button.new()
	plus.text = "+"
	plus.disabled = unlocked == 0
	minus.disabled = true
	var update_asc := func(delta: int) -> void:
		asc_choice[id] = clamp(asc_choice[id] + delta, 0, unlocked)
		asc_label.text = "Ascension %d" % asc_choice[id]
		asc_label.tooltip_text = "" if asc_choice[id] == 0 \
			else "\n".join(PackedStringArray(Run.ASCENSION_INFO.slice(0, asc_choice[id])))
		minus.disabled = asc_choice[id] <= 0
		plus.disabled = asc_choice[id] >= unlocked
	minus.pressed.connect(update_asc.bind(-1))
	plus.pressed.connect(update_asc.bind(1))
	asc_row.add_child(minus)
	asc_row.add_child(asc_label)
	asc_row.add_child(plus)
	v.add_child(asc_row)
	var unlock_hint := Label.new()
	unlock_hint.text = "Win to unlock A%d" % (unlocked + 1) if unlocked < Run.MAX_ASCENSION \
		else "All ascensions unlocked!"
	unlock_hint.add_theme_font_size_override("font_size", 11)
	unlock_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.66))
	unlock_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(unlock_hint)
	var choose := Button.new()
	choose.text = "Choose"
	choose.add_theme_font_size_override("font_size", 17)
	choose.pressed.connect(_choose.bind(id))
	v.add_child(choose)
	return panel

func _choose(id: String) -> void:
	Run.new_run(id, asc_choice[id])
	get_node("/root/Main").goto("neow")
