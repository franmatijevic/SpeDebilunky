extends "res://src/Actors/Actor.gd"

var direction: = false
var change: = false
var can_move=1
var health:=12

var angry:bool=false
var idle:bool=false

var player_close:=false
var try_to_attack:=false

var last_damage:String="troll"
var play_sound:bool=false

var can_destroy:bool=true
var look_for_player:bool=true

var knock_back_h:float=280.0
var knock_back_v:float=200.0

func _ready() -> void:
	get_node("BlockDestroy").monitoring=false
	get_node("AnimatedSprite").animation="default"
	velocity.x = speed.x


func _on_ClubDetect_body_entered(body: Node) -> void:
	if(angry and !try_to_attack):
		if(velocity.x>0.0):
			get_node("AnimatedSprite").set_flip_h( true)
			get_node("AnimatedSprite").position.x=9
			get_node("TrollStand").set_flip_h(true)
		else:
			get_node("AnimatedSprite").set_flip_h( false )
			get_node("AnimatedSprite").position.x=-9
			get_node("TrollStand").set_flip_h(false)
		attack()

func _on_BlockDestroy_body_entered(body):
	if(body.name!="Bedrock1" and body.name!="Bedrock2" and body.name!="Bedrock3" and body.name!="Bedrock4"):
		body.destroy()

func _on_BlockDestroy_area_entered(area: Area2D) -> void:
	area.get_parent().destroy()

func _on_Head_body_entered(body: Node) -> void:
	pass
	body.enemy_jump()
	#health=health-1
	#var blood=preload("res://src/Other/Blood.tscn").instance()
	#blood.position=position
	#blood.position.y=blood.position.y-10
	#get_parent().add_child(blood)

func _on_DetectWhip_area_entered(area: Area2D) -> void:
	health=health-1
	var blood=preload("res://src/Other/Blood.tscn").instance()
	blood.position=position
	blood.position.y=blood.position.y-10
	get_parent().add_child(blood)



func _on_ClubDamage_body_entered(body: Node) -> void:
	if(!body.iframes_on):
		body.iframes()
		body.ledge_grab=false
		body.climbing=false
		if(body.health<3):
			get_node("Sound2").play()
			body.club_death=true
			if(body.global_position.x>global_position.x):
				body.death(true)
			else:
				body.death(false)
		body.health=body.health-2
		body.stunned()
		if(body.global_position.x>global_position.x):
			body.knock_h=knock_back_h
			body.side_stunned=true
		else:
			body.knock_h=-knock_back_h
			body.side_stunned=false
		body.knock_v=knock_back_v

func _process(delta: float) -> void:
	if(health<1):
		death()
	if(angry):
		if(!play_sound):
			play_random_sound()
		if(can_destroy):
			while_can_destroy()
		if(look_for_player):
			find_player()
	
	
	if(velocity.x>0.0):
		direction=true
		get_node("BlockDestroy").position.x=14
		get_node("ClubDetect").position.x=14
		get_node("ClubDamage").position.x=15
	else:
		direction=false
		get_node("BlockDestroy").position.x=-14
		get_node("ClubDetect").position.x=-14
		get_node("ClubDamage").position.x=-15
	if(can_move!=0 and !try_to_attack):
		get_node("AnimatedSprite").set_flip_h( direction )
		get_node("AnimatedSprite2").set_flip_h( direction )

func _physics_process(delta: float) -> void:
	if(is_on_wall() and is_on_floor()):
		velocity.x *= -1.0
	if(!idle and !angry):
		idle()
	
	velocity.y = move_and_slide(velocity*can_move, Vector2.UP).y

func play_random_sound()->void:
	play_sound=true
	var k=randi()%4
	var time_in_seconds = 30
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	match k:
		0:
			get_node("Sound1").play()
		1:
			get_node("Sound2").play()
		2:
			get_node("Sound3").play()
		3:
			get_node("Sound4").play()
	play_sound=false

func attack()->void:
	if(!try_to_attack):
		try_to_attack=true
		var ex_speed=velocity.x
		velocity.x=0.0
		
		get_node("TrollStand").visible=true
		get_node("AnimatedSprite2").visible=false
		
		var time_in_seconds = 0.6
		yield(get_tree().create_timer(time_in_seconds), "timeout")
		
		if(ex_speed>0.0):
			get_node("ClubDamage").position.x=15
		else:
			get_node("ClubDamage").position.x=-15
		get_node("AnimatedSprite").visible=true
		get_node("TrollStand").visible=false
		get_node("ClubDamage").monitoring=true
		get_node("AnimatedSprite").frame=0
		
		time_in_seconds = 0.1
		yield(get_tree().create_timer(time_in_seconds), "timeout")
		get_node("ClubDamage").monitoring=false
		
		time_in_seconds = 1
		yield(get_tree().create_timer(time_in_seconds), "timeout")
		
		get_node("AnimatedSprite").visible=false
		get_node("AnimatedSprite2").visible=true
		velocity.x=ex_speed
		try_to_attack=false



func while_can_destroy()->void:
	can_destroy=false
	var time_in_seconds = 15
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	get_node("BlockDestroy").monitoring=false
	
	time_in_seconds = 25
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	get_node("BlockDestroy").monitoring=true
	can_destroy=true

func find_player()->void:
	look_for_player=false
	var time_in_seconds = 1
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	if(get_parent().get_parent().has_node("Player")):
		var dir=get_parent().get_parent().get_node("Player").global_position.x
		if(global_position.x<dir):
			velocity.x=abs(velocity.x)
		else:
			velocity.x=-abs(velocity.x)
	look_for_player=true

func death()->void:
	get_parent().get_node("TrollDeath").play()
	get_node("CollisionShape2D").free()
	var blood=preload("res://src/Other/Blood.tscn").instance()
	blood.position=position
	blood.position.y=blood.position.y-12
	blood.get_node("Particles2D").amount=50
	get_parent().add_child(blood)
	queue_free()

func idle()->void:
	idle=true
	can_move=0
	get_node("AnimatedSprite2").visible=false
	get_node("AnimatedSprite3").visible=true
	var time_in_seconds = 3
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	can_move=1
	get_node("AnimatedSprite2").visible=true
	get_node("AnimatedSprite3").visible=false
	time_in_seconds = 5
	yield(get_tree().create_timer(time_in_seconds), "timeout")
	idle=false