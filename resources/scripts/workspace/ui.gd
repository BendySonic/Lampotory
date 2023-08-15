class_name UI extends Control

# -----------------------------------------------------------------------------
const GRID_PATH = (
	"VBox/HBox2/VBoxContainer2/PanelContainer/HBoxContainer/" +
	"MarginContainer/VBoxContainer/PanelBodies/VBoxContainer/" +
	"Margin/VBox/Margin/Grid"
)
const PANEL_PATH = "VBox/HBox2/PanelContainer"
const PROPERTIES_PATH = (
	"VBox/HBox2/VBoxContainer2/PanelContainer/HBoxContainer/MarginContainer/" +
	"VBoxContainer/PanelProperties/VBoxContainer/Margin/Properties"
)

@onready var grid_widget = preload("res://resources/scenes/workspace/" +
		"ui_grid_widget.tscn")
@onready var cursor_widget = preload("res://resources/scenes/workspace/" +
		"ui_cursor_widget.tscn")
@onready var property = preload("res://resources/scenes/workspace/" +
		"ui_property.tscn")
@onready var grid = get_node(GRID_PATH)
@onready var panel = get_node(PANEL_PATH)
@onready var properties = get_node(PROPERTIES_PATH)

# -----------------------------------------------------------------------------
func _process(delta):
	if grid.size.x >= 180 and grid.size.x < 280:
		grid.columns = 2
	elif grid.size.x >= 280:
		grid.columns = 3


func _on_play_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			LampSignalManager.emit_signal("play_pressed")


func _on_reload_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			LampSignalManager.emit_signal("reload_pressed")