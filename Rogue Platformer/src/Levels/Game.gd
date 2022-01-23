extends Node2D

var player_health:int=10
var phase:=1
#phase = 0 = main menu
#phase = 1 = world
#phase = 2 = levelComplete

func set_health()->void:
	get_node("World").get_node("Player").health=player_health


func _ready() -> void:
	OS.window_fullscreen = true
	pass


func _process(delta: float) -> void:
	if(phase==1):
		pass
	#print(player_health)
	pass

func new_complete()->void:
	var comp = preload("res://src/Levels/LevelComplete.tscn").instance()
	comp.position.x=0
	comp.position.y=0
	add_child(comp)
	if(has_node("World")):
		get_node("World").queue_free()
	if(has_node("MainMenu")):
		get_node("MainMenu").queue_free()

func new_level()->void:
	print(player_health)
	var world = preload("res://src/Levels/World.tscn").instance()
	world.global_position=global_position
	add_child(world)
	if(has_node("LevelComplete")):
		get_node("LevelComplete").queue_free()
	if(has_node("MainMenu")):
		get_node("MainMenu").queue_free()
	get_node("World").get_node("Player").health=player_health
