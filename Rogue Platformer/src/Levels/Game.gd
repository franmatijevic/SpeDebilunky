extends Node2D

var player_health:int=4
var player_money:int=0
var player_rope:int=4
var player_bomb:int=4
var level:=0

var old_health:int=0
var old_money:int=0
var old_rope:int=0
var old_bomb:int=0

var total_time:=0.0
var current_time:=0.0

var last_damage:String=" "

var paused:=preload("res://src/Other/PauseScreen.tscn").instance()

func set_health()->void:
	get_node("World").get_node("Player").health=player_health
	get_node("World").get_node("Player").money=player_money
	get_node("World").get_node("Player").rope=player_rope
	get_node("World").get_node("Player").bomb=player_bomb

func _ready() -> void:
	#get_node("PauseLayer/Pause").visible=false
	OS.window_fullscreen = true

func _process(delta: float) -> void:
	pass
	
	
	if(get_tree().paused):
		if(Input.is_action_just_pressed("ui_accept")):
			print("nesto ako bas mora")
	
	if(Input.is_action_just_pressed("ui_cancel") and has_node("World")):
		if(get_tree().paused == false):
			pause_menu(true)
		else:
			pause_menu(false)

func _get_viewport_center() -> Vector2:
	var transform : Transform2D = get_viewport_transform()
	var scale : Vector2 = transform.get_scale()
	return -transform.origin / scale + get_viewport_rect().size / scale / 2

func pause_menu(on: bool)->void:
	if(on):
		#get_node("World/Kanvas/UI").visible=false
		get_tree().paused = true
		#get_node("PauseNode/Pause/PauseMenu").visible=true
	else:
		#get_node("World/Kanvas/UI").visible=true
		#get_node("PauseNode/Pause/PauseMenu").visible=false
		get_tree().paused = false

func new_complete()->void:
	var comp = preload("res://src/Levels/LevelComplete.tscn").instance()
	comp.position.x=0
	comp.position.y=0
	add_child(comp)
	comp.level=level
	if(has_node("World")):
		get_node("World").queue_free()
	if(has_node("MainMenu")):
		get_node("MainMenu").queue_free()

func new_level()->void:
	var world = preload("res://src/Levels/World.tscn").instance()
	world.global_position=global_position
	level=level+1
	old_health=player_health
	old_bomb=player_bomb
	old_money=player_money
	old_rope=player_rope
	world.get_node("Kanvas/UI").get_node("LevelNumber").text=str(level)
	add_child(world)
	if(has_node("LevelComplete")):
		get_node("LevelComplete").queue_free()
	if(has_node("MainMenu")):
		get_node("MainMenu").queue_free()
	set_health()


func _on_Quit_button_down() -> void:
	get_tree().quit()


func _on_Quit_pressed() -> void:
	print("uuf")
