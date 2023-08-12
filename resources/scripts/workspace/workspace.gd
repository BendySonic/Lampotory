#################################
#author:BendySonic
#last_edited:BendySonic
#################################
#workspace.gd
#script for laboratory workspace
#################################
class_name Workspace extends Node2D

#private variables
#Константы путей папок - сцен рабочей области, ресурсов тел, сцен тел.
const SCENES_PATH = "res://resources/scenes/workspace/"
const RESOURCES_PATH = "res://resources/scenes/resources/body_resources/"
const BODIES_PATH = "res://resources/scenes/bodies/"

#Список сцен, тел
const SCENES = ["ui", "grid_widget", "cursor_widget", "property"]
const BODIES = ["mechanic_body"]

#Константы панели, грид контейнера внутри панели, контейнера свойств
const GRID_PATH = ("VBox/HBox2/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/PanelBodies/VBoxContainer/Margin/VBox/Margin/Grid")
const PANEL_PATH = "VBox/HBox2/PanelContainer"
const PROPERTIES_PATH = ("VBox/HBox2/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/PanelProperties/VBoxContainer/Margin/VBox")

#Словари, хранящие загруженные ресурсы сцен рабочей области,
#ресурсов тел, сцен тел
var scenes:Dictionary
var resources:Dictionary
var bodies:Dictionary
#Активный ресурс тела (Обновляется перед созданием нового тела)
var choosen_res:BodyResource
#Число объектов в рабочей области (Идентификатор)
var body_count:int = 0

#Удобные обращаения к нодам из загруженных сцен рабочей области
var ui:Node
var grid:Node
var properties:Node
var panel:Node

#Удобное обращение к слоям рабочей области
@onready var layer_ui:CanvasLayer = $LayerUI
@onready var layer_selected:CanvasLayer = $LayerSelected
@onready var layer_workspace:Node2D = $LayerWorkspace


#private functions
func _ready():
	load_scenes()
	load_body_resources()
	load_body_scene()
	set_scenes()
	
	set_signals()


func set_signals():
	LampSignalManager.widget_input.connect(on_grid_widget_gui_input)
	LampSignalManager.body_input.connect(on_body_gui_input)
	LampSignalManager.play.connect(on_play)
	LampSignalManager.pause.connect(on_pause)

#Установка побочных сцен в сцене рабочей области
func set_scenes():
	#ui
	ui = scenes["ui"].instantiate()
	layer_ui.add_child(ui)
	
	#grid, panel, properties
	grid = ui.get_node(GRID_PATH)
	panel = ui.get_node(PANEL_PATH)
	properties = ui.get_node(PROPERTIES_PATH)
	
	#GridWidget's
	for widget_name in BODIES:
		var widget = scenes["grid_widget"].instantiate()
		grid.add_child(widget)
		widget.construct(resources[widget_name])


func load_scenes():
	for scene_name in SCENES:
		scenes[scene_name] = load(SCENES_PATH + scene_name + ".tscn")


func load_body_resources():
	for body_name in BODIES:
		resources[body_name] = load(RESOURCES_PATH + body_name + ".tres")


func load_body_scene():
	for body_name in BODIES:
		bodies[body_name] = load(BODIES_PATH + body_name + ".tscn")

#При взаимодействии с элементом таблицы объектов
func on_grid_widget_gui_input(event:InputEventMouse, grid_widget:GridWidget):
	if event is InputEventMouseButton:
		#GridWidget нажат
		if event.is_pressed():
			choosen_res = resources[grid_widget.get_widget_name()].duplicate()
			
			var cursor_widget = scenes["cursor_widget"].instantiate()
			layer_selected.add_child(cursor_widget)
			cursor_widget.construct(choosen_res)
				
		#GridWidget отпущен / создание тела
		if not event.is_pressed():
			body_count += 1
			choosen_res.body_id["value_x"] = body_count
			
			var body = bodies[choosen_res.body_name].instantiate()
			body.position = get_global_mouse_position()
			choosen_res.position["value_x"] = body.position.x
			choosen_res.position["value_y"] = body.position.y
			body.construct(choosen_res)
			body.name = str(body_count)
			layer_workspace.add_child(body)
			
			var cursor_widget = layer_selected.get_child(0)
			layer_selected.remove_child(cursor_widget)
			cursor_widget.queue_free()

#Открытие свойств объекта в окне при нажатии на объект
func on_body_gui_input(res_properties:Array[Dictionary], id:int):
	#Очистка поля свойств
	if bool(properties.get_child_count()):
		for child in properties.get_children():
			child.queue_free()
	#Обновление поля свойств (Каждое свойство = сцена)
	for property in res_properties:
		var property_scene = scenes["property"].instantiate()
		properties.add_child(property_scene)
		#Заглавия разделов
		if property["value_type"] == -1:
			property_scene.title_panel.visible = true
			property_scene.title.text = property["name"]
			continue
		#Обычные свойства / передача типа свойства
		property_scene.property_panel.visible = true
		property_scene.property.text = property["name"]
		property_scene.type = property["value_type"]
		property_scene.body_id = id
		if property["vector"]:
			property_scene.down_container.visible = true
			if property["can_change"]:
				property_scene.x_edit.visible = true
				property_scene.x_label.visible = true
				property_scene.x_edit.text = str(property["value_x"])
				property_scene.y_edit.visible = true
				property_scene.y_label.visible = true
				property_scene.y_edit.text = str(property["value_y"])
		else:
			if property["can_change"]:
				property_scene.x_edit.visible = true
				property_scene.x_edit.text = str(property["value_x"])
			else:
				property_scene.x_value_label.visible = true
				property_scene.x_value_label.text = str(property["value_x"])


func on_play():
	for body in layer_workspace.get_children():
		body.play()


func on_pause():
	pass
