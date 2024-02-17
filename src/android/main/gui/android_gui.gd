extends CanvasLayer
# Class for Main/GUI


signal item_pressed(item_data: ItemResource)
signal item_released()
signal items_window_mouse_exited()

signal play_toggled(button_pressed: bool)
signal reload_pressed()

signal copy_pressed()
signal cut_pressed()
signal paste_pressed()
signal delete_pressed()

signal save_project_pressed(name: String, theme: String)
signal open_project_pressed()

signal display_vector_toggled(toggled_on: bool)
signal clear_pressed()

const GUI_PATH = "res://src/main/gui/"

const ITEMS_WINDOW = "MarginContainer/HBoxContainer/VBoxContainer2/ItemsWindow/"
const ITEMS_BOX = ITEMS_WINDOW + "ItemsWindowBox/Body/BodyBox/Items/ScrollContainer/ItemsBox"

const PROPERTIES_WINDOW = "PropertiesWindow/"
const PROPERTIES_BOX = PROPERTIES_WINDOW + "Body/GridContainer/"

const PLAYER_WINDOW = "MarginContainer/HBoxContainer2/VBoxContainer/PlayerWindow/"
const PLAY_BUTTON = PLAYER_WINDOW + "Player/Play/PlayButton"
const RELOAD_BUTTON = PLAYER_WINDOW + "Player/Reload/ReloadButton"

const ACTIONS_WINDOW = "ActionsWindow/"
const ACTIONS_BOX = ACTIONS_WINDOW + "HBoxContainer/"
const COPY_BUTTON = ACTIONS_BOX + "MarginContainer/CopyButton"
const CUT_BUTTON = ACTIONS_BOX + "MarginContainer2/CutButton"
const PASTE_BUTTON = ACTIONS_BOX + "MarginContainer3/PasteButton"
const DELETE_BUTTON = ACTIONS_BOX + "MarginContainer4/DeleteButton"

const MENU_WINDOW = "MarginContainer/HBoxContainer/VBoxContainer2/MenuWindow/"
const MENU_BOX = MENU_WINDOW + "Panel/"
const EDIT_BUTTON = MENU_BOX + "Edit/EditButton"
const SAVE_BUTTON = MENU_BOX + "Save/SaveButton"

const SAVE_WINDOW = "SaveWindow/"
const SAVE_BOX = SAVE_WINDOW + "MarginContainer/VBoxContainer/"
const PROJECT_NAME_EDIT = SAVE_BOX + "ProjectNameEdit"
const PROJECT_THEME_EDIT = SAVE_BOX + "ProjectDescriptionEdit"

const EDIT_WINDOW = "EditWindow/"

# Children
@onready var items_window := get_node(ITEMS_WINDOW) as Control
@onready var items_box := get_node(ITEMS_BOX) as GridContainer

@onready var properties_window := get_node(PROPERTIES_WINDOW) as Control
@onready var properties_box := get_node(PROPERTIES_BOX) as GridContainer
@onready var no_properties_label := get_node(PROPERTIES_WINDOW + "Body/NoPropertiesLabel") as Label

@onready var actions_window := get_node(ACTIONS_WINDOW) as Control
@onready var actions_box := get_node(ACTIONS_BOX) as VBoxContainer

@onready var copy_button := get_node(COPY_BUTTON) as TextureButton
@onready var cut_button := get_node(CUT_BUTTON) as TextureButton
@onready var paste_button := get_node(PASTE_BUTTON) as TextureButton
@onready var delete_button := get_node(DELETE_BUTTON) as TextureButton

@onready var play_button := get_node(PLAY_BUTTON) as TextureButton
@onready var reload_button := get_node(RELOAD_BUTTON) as TextureButton

@onready var save_button := get_node(SAVE_BUTTON) as MenuButton
@onready var edit_button := get_node(EDIT_BUTTON) as MenuButton

@onready var save_window = get_node(SAVE_WINDOW) as PanelContainer
@onready var project_name_edit = get_node(PROJECT_NAME_EDIT) as LineEdit
@onready var project_theme_edit = get_node(PROJECT_THEME_EDIT) as LineEdit

@onready var edit_window = get_node(EDIT_WINDOW) as PanelContainer
# Resources
@onready var item_scene := preload(GUI_PATH + "gui_item.tscn")
@onready var property_scene := preload(GUI_PATH + "gui_property.tscn")


func _ready():
	save_button.get_popup().connect("id_pressed", _on_save_button_id_pressed)
	edit_button.get_popup().connect("id_pressed", _on_edit_button_id_pressed)

#region Input
func _on_item_pressed(item_data: ItemResource):
	emit_signal("item_pressed", item_data)

func _on_item_released():
	emit_signal("item_released")

func _on_items_window_mouse_exited():
	var local_mouse_position = items_window.get_local_mouse_position()
	if not Rect2(Vector2(), items_window.size).has_point(local_mouse_position):
		emit_signal("items_window_mouse_exited")

func _on_play_toggled(button_pressed: bool):
	emit_signal("play_toggled", button_pressed)

func _on_reload_pressed():
	play_button.button_pressed = false
	emit_signal("reload_pressed")

func _on_speed_up_button_toggled(button_pressed: bool):
	if button_pressed:
		Engine.time_scale = 1.5
	else:
		Engine.time_scale = 1.0

func _on_save_button_id_pressed(id: int):
	if id == 0:
		if Global.project_data.is_saved:
			emit_signal(
					"save_project_pressed", 
					Global.project_data.project_name,
					Global.project_data.project_theme
			)
		else:
			show_save_window()

func _on_edit_button_id_pressed(id: int):
	if id == 0:
		Global.project_data["project_name"] = ""
		Global.project_data["project_theme"] = ""
		Global.project_data["project_mode"] = ""
		Global.project_data["is_saved"] = false
		get_tree().change_scene_to_file("res://src/menu/menu.tscn")
	if id == 1:
		show_edit_window()

func _on_display_vector_button_toggled(toggled_on):
	emit_signal("display_vector_toggled", toggled_on)

func _on_clear_button_pressed():
	emit_signal("clear_pressed")
#endregion



#region ItemsWindow
func create_items(item_resources: Array[ItemResource]):
	for item_data in item_resources:
		var new_item = item_scene.instantiate()
		new_item.init(item_data)
		new_item.connect("item_pressed", _on_item_pressed)
		new_item.connect("item_released", _on_item_released)
		items_box.add_child(new_item)
#endregion


#region Select
func clear_select():
	delete_actions()
	delete_properties()

func create_actions(cursor: GUICursor):
	actions_window.set_global_position(cursor.get_screen_transform().origin)
	limit_actions()
	copy_button.set_disabled(true)
	copy_button.modulate = Color(0.812, 0.812, 0.812)
	cut_button.set_disabled(true)
	cut_button.modulate = Color(0.812, 0.812, 0.812)
	delete_button.set_disabled(true)
	delete_button.modulate = Color(0.812, 0.812, 0.812)
	actions_window.set_visible(true)

func create_actions_with_body(body: NormalBody):
	actions_window.set_global_position(Global.cursor.get_screen_transform().origin)
	limit_actions()
	copy_button.set_disabled(false)
	copy_button.modulate = Color(1, 1, 1)
	cut_button.set_disabled(false)
	cut_button.modulate = Color(1, 1, 1)
	delete_button.set_disabled(false)
	delete_button.modulate = Color(1, 1, 1)
	actions_window.set_visible(true)

func delete_actions():
	actions_window.set_visible(false)

func limit_actions():
	if (
		actions_window.get_global_position().x > 
		(Vector2(get_window().size).x - 320)
		or actions_window.get_global_position().y > 
		(Vector2(get_window().size).y - 250)
	):
		actions_window.global_position = (
			actions_window.global_position.clamp(
				Vector2(0, 0), (Vector2(get_window().size) - Vector2(320, 250))
			)
		)
	if (
		actions_window.get_global_position().x < 260
		or actions_window.get_global_position().y < 50
	):
		actions_window.global_position = (
			actions_window.global_position.clamp(
				Vector2(260, 50), (Vector2(get_window().size) - Vector2(300, 300))
			)
		)


func create_properties(body: NormalBody):
	delete_properties()
	properties_window.set_position(actions_window.get_position() + Vector2(0, 50))
	properties_window.set_visible(true)
	var body_properties = body.get_properties()
	
	no_properties_label.set_visible(body_properties.is_empty())
	for body_property in body_properties:
		var value = body.get_property(body_property)
		
		var new_property = property_scene.instantiate()
		new_property.create_property(body, body_property, value)
		properties_box.add_child(new_property)

func delete_properties():
	properties_window.set_visible(false)
	for child in properties_box.get_children():
		if not child == no_properties_label:
			child.queue_free()


func _on_copy_button_down():
	copy_button.modulate = Color(0.812, 0.812, 0.812)

func _on_cut_button_down():
	cut_button.modulate = Color(0.812, 0.812, 0.812)

func _on_paste_button_down():
	paste_button.modulate = Color(0.812, 0.812, 0.812)

func _on_delete_button_down():
	delete_button.modulate = Color(0.812, 0.812, 0.812)


func _on_copy_button_up():
	copy_button.modulate = Color(1, 1, 1)
	emit_signal("copy_pressed")

func _on_cut_button_up():
	cut_button.modulate = Color(1, 1, 1)
	emit_signal("cut_pressed")

func _on_paste_button_up():
	paste_button.modulate = Color(1, 1, 1)
	emit_signal("paste_pressed")

func _on_delete_button_up():
	delete_button.modulate = Color(1, 1, 1)
	emit_signal("delete_pressed")
#endregion


#region SaveWindow
func show_save_window():
	save_window.set_visible(true)
	save_window.set_global_position(Vector2(DisplayServer.window_get_size() / 2)
			- Vector2(save_window.size / 2))

func hide_save_window():
	save_window.set_visible(false)

func _on_save_project_button_pressed():
	emit_signal(
			"save_project_pressed", 
			project_name_edit.get_text(),
			project_theme_edit.get_text()
	)
#endregion

#region EditWindow
func show_edit_window():
	edit_window.set_visible(true)
	edit_window.set_global_position(Vector2(DisplayServer.window_get_size() / 2)
			- Vector2(save_window.size / 2))

func hide_edit_window():
	edit_window.set_visible(false)
#endregion

func _on_exit_button_pressed():
	hide_save_window()
	hide_edit_window()


# NOTE:
# Don't use: legacy code --->>>

#region Cursor
#func create_cursor(item_data: ItemResource):
	#delete_cursor()
	#var cursor: GUICursor = cursor_scene.instantiate()
	#cursor.init(item_data)
	#cursor_layer.add_child(cursor)

#func delete_cursor():
	#for child in cursor_layer.get_children():
		#cursor_layer.remove_child(child)
		#child.queue_free()
#endregion
