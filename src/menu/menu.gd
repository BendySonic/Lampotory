class_name Menu
extends Control
# Class for menu


const SAVE_DIR = "saves/"

@onready var gui_project_scene := preload("res://src/menu/gui/gui_project.tscn")

var PANEL
var WORKSPACE
var BUTTONS
var MY_PROJECT_GRID_CONTAINER

@onready var panel: PanelContainer = get_node(PANEL)

@onready var buttons_container := get_node(BUTTONS)
@onready var new_button := get_node(BUTTONS + "NewButton")
@onready var my_projects_button := get_node(BUTTONS + "MyProjectsButton")

@onready var workspace_container := get_node(WORKSPACE)
@onready var new_container := get_node(WORKSPACE + "New")
@onready var new_grid_container := get_node(WORKSPACE + "New/MarginContainer/GridContainer")
@onready var my_projects_container := get_node(WORKSPACE + "MyProjects")
@onready var my_projects_grid_container := get_node(MY_PROJECT_GRID_CONTAINER)
@onready var settings_container := get_node(WORKSPACE + "Settings")

func _init():
	PANEL = OS.get_name() + "/Panel/"
	WORKSPACE = PANEL + "Panel/Workspace/"
	
	match OS.get_name():
		"Android":
			BUTTONS = PANEL + "Panel/Menu/Menu/Menu/Margin/Buttons/"
		"Windows":
			BUTTONS = PANEL + "Panel/Menu/Menu/Menu/Buttons/"
	
	MY_PROJECT_GRID_CONTAINER = WORKSPACE + "MyProjects/ScrollContainer/GridContainer"


func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

#region Menu Pages
func _on_new_button_toggled(button_pressed: bool):
	if button_pressed:
		_set_invisible_containers()
		new_container.set_visible(true)

func _on_my_projects_button_toggled(button_pressed: bool):
	new_container.set_visible(false)
	if button_pressed:
		_set_invisible_containers()
		my_projects_container.set_visible(true)
		
		load_projects()

func _on_settings_button_toggled(button_pressed: bool):
	if button_pressed:
		_set_invisible_containers()
		settings_container.set_visible(true)

func _set_invisible_containers():
	for container in workspace_container.get_children():
		container.set_visible(false)
#endregion


#region New project
func _on_lab_pressed(object):
	Global.project_data["project_mode"] = object.mode
	get_tree().change_scene_to_file("res://src/main/loading/loading.tscn")
#endregion

#region Load projects
func load_projects():
	for gui_project in my_projects_grid_container.get_children():
		gui_project.queue_free()

	var file_names = DirAccess.get_files_at(SAVE_DIR)
	for file_name in file_names:
		var file = FileAccess.open(SAVE_DIR + file_name, FileAccess.READ)
		var save: Dictionary = file.get_var()
		var project_data = save["project_data"]
		
		var gui_project: GUIProject = gui_project_scene.instantiate()
		gui_project.project_data = project_data
		
		my_projects_grid_container.add_child(gui_project)
#endregion
