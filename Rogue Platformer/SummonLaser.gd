extends KinematicBody2D

var player
var speed:=215.0

var dir

var sound:=false
var collide:=false

var summon:=true

func _ready() -> void:
	if(get_node("/root/Game/World").has_node("Player")):
		player=get_node("/root/Game/World/Player")
		dir = Vector2(player.global_position-global_position).normalized()
	else:
		queue_free()


func _physics_process(delta: float) -> void:
	if(dir!=null):
		move_and_slide(dir * speed)
	if($Ground.is_colliding()):
		summon=false
	$Ground.enabled=false

func _process(delta: float) -> void:
	if(sound and collide):
		queue_free()

func _on_Wall_body_entered(body: Node) -> void:
	summon_creature()
	remove()

func summon_creature()->void:
	if(!summon):
		return
	var enemy
	match randi()%3:
		0:
			enemy=preload("res://src/Actors/Bat.tscn").instance()
		1:
			enemy=preload("res://src/Actors/Snake.tscn").instance()
		2:
			enemy=preload("res://src/Actors/Spider.tscn").instance()
	enemy.position=position
	get_parent().add_child(enemy)

func _on_Player_body_entered(body: Node) -> void:
	if(body.name=="Player" and !body.iframes_on):
		body.last_damage="beholder"
		if(body.health<2):
			if(global_position.x<body.global_position.x):
				body.death(true)
			else:
				body.death(false)
		else:
			body.damage(1)
	#summon_creature()
	remove()

func remove()->void:
	get_node("LaserBallGreen").visible=false
	get_node("Wall").monitoring=false
	get_node("Player").monitoring=false
	get_node("Enemy").monitoring=false
	collide=true
	speed=0.0


func _on_Enemy_body_entered(body: Node) -> void:
	summon_creature()
	body.death()
	remove()

func _on_Laser_finished() -> void:
	sound=true
