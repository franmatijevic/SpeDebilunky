extends Node2D

var green:=false
var red:=false
var white:=false

var health
var level

var playerx
var playery

export var temple:=true

var polje = [[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
var start
var x
var y
var array = [[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
#Start = 4
#Start with dropdown = 5
#Hallway = 1
#Dropdown = 2
#End of level = 9
#Side tile = 0
#shop = 7
#Dungeon = 8

#Lair left = 10


var current_time:=0.0

var poison_time:float=0.0

var alter:=false
var shop_angry:int=0

var end_right=4
var end_down=4

var lair_dir:=false

var frame

func _ready() -> void:
	var transition=preload("res://src/Other/TransitionEffect.tscn").instance()
	transition.choice=true
	
	#Big level or small level
	if(randi()%9==0):
		if(randi()%4==0):
			end_down=8
			end_right=4
		else:
			end_right=5
			end_down=5
	
	randomize()
	start=randi()%end_right
	polje[0][start]=4
	x=start
	y=0
	var banned_route
	
	while(y<end_down):
		randomize()
		var direction = randi()%3
		if(banned_route==0 and direction==0):
			direction=1
		if(banned_route==1 and direction==1):
			direction=0
		
		if(direction == 0):
			if(x==0 or banned_route==0):
				direction = 1
			else: 
				x=x-1
				banned_route=1
		
		if(direction == 1):
			if(x==end_right-1 or banned_route == 1):
				direction=2
			else: 
				x=x+1
				banned_route=0
		
		if(direction == 2):
			if(y==end_down-1):
				polje[y][x]=9
				#print("exit")
				break
			y=y+1
			if(polje[y-1][x]==4): 
				polje[y-1][x]=5
			else: polje[y-1][x]=2
			banned_route=4
		polje[y][x]=1
	
	for i in range(end_down-1):
		for j in range(end_right):
			if(polje[i+1][j]==1):
				if(polje[i][j]==2 or polje[i][j]==5):
					polje[i+1][j]=6
	
	if(end_right==4):
		if(end_down==4):
			frame=preload("res://src/environment/Frame.tscn").instance()
		else:
			frame=preload("res://src/environment/Frame4x8.tscn").instance()
	else:
		frame=preload("res://src/environment/Frame5x5.tscn").instance()
	frame.position.x=0
	frame.position.y=0
	
	
	
	for i in range(end_down):
		for j in range(end_right):
			match polje[i][j]:
				1:
					create_hallway(i,j)
				2:
					create_dropdown(i,j)
				4:
					array[i][j]=preload("res://src/levelPieces/start1.tscn").instance()
					if(randi()%2==0):
						array[i][j]=preload("res://src/DungeonPieces/start1.tscn").instance()
					array[i][j].global_position.x=80 + j * 160
					array[i][j].global_position.y=64 + i * 128
					add_child(array[i][j])
				5:
					create_startdropdown(i,j)
				6: 
					create_hallwaywithdrop(i,j)
				7:
					pass
					#create_shop(i,j,dir_shops[where_shop])
				8:
					create_dungeon(i,j)
				9:
					create_exit(i,j)
				0:
					create_side_room(i,j)
				10:
					create_lair(i,j)
	add_child(frame)
	
	randomize()
	var music=randi()%2
	if(!get_node("/root/Game").music):
		get_node("Music1").volume_db=-80
		get_node("Music2").volume_db=-80
		get_node("Music3").volume_db=-80
	
	if(music==0):
		get_node("Music1").play()
	elif(music==1):
		get_node("Music2").play()
	
	get_node("/root/Game/World/Kanvas/UI/Darkness").visible=true
	if(temple):
		for _i in frame.get_node("Dirt").get_children():
			_i.get_node("Dirt").texture=load("res://Assets/TempleBlocks/dungeon_tile_mid.png")
	
	if(temple):
		get_node("Background1").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background2").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background3").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background4").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background5").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background6").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background7").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background8").texture=load("res://Assets/Backgrounds/background_2.png")
		get_node("Background9").texture=load("res://Assets/Backgrounds/background_2.png")
	
	if(get_parent().goggles):
		get_node("/root/Game/World/Kanvas/UI/Goggles").visible=true
	
	if(get_parent().red_key):
		get_node("/root/Game/World/Kanvas/UI/KeyRed").visible=true
	
	if(get_parent().green_key):
		get_node("/root/Game/World/Kanvas/UI/KeyGreen").visible=true
	
	if(get_parent().white_key):
		get_node("/root/Game/World/Kanvas/UI/KeyWhite").visible=true
	
	print("level: ", level)

	get_node("BlackScreen").queue_free()
	add_player()
	if(get_node("/root/Game").boss_level!=-1 and int(get_node("/root/Game").boss_level*(2.0/3.0))==level):
		get_node("Kanvas/UI").print_something("So this is what hides behind the mines...")
	elif(end_down==8):
		get_node("Kanvas/UI").print_something("It looks like a long way down...")
	elif(end_right==5):
		get_node("Kanvas/UI").print_something("My voice echoes in here...")

func _process(delta: float) -> void:
	if(!get_node("/root/Game").music):
		get_node("/root/Game/World/Music1").volume_db=-80
		get_node("/root/Game/World/Music2").volume_db=-80
		get_node("/root/Game/World/Music3").volume_db=-80
	
	
	if(has_node("Player")):
		current_time=current_time+delta
		if(get_node("Player").poisoned and int(current_time)!=0 and int(current_time)%30==0 and !get_node("Player").iframes_on and current_time-poison_time>poison_time+1):
			if(get_node("Player").health==1):
				get_node("Player").last_damage="Poison"
				get_node("Player").spike_death=true
				get_node("Player").death(true)
			else:
				get_node("Player").damage(1)
	var minutes=floor(current_time/60.0)
	var seconds=int(current_time)%60
	if(seconds>9):
		get_node("Kanvas/UI/time").text=str(minutes)+":"+str(seconds)
	else:
		get_node("Kanvas/UI/time").text=str(minutes)+":0"+str(seconds)

func create_lair(i: int, j:int)->void:
	match randi()%2:
		0:
			array[i][j]=preload("res://src/levelPieces/LairLeft.tscn").instance()
		1:
			array[i][j]=preload("res://src/levelPieces/LairRight.tscn").instance()
	
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	if(lair_dir):
		array[i][j].global_position.x+=160
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])

func create_dungeon_gate(i:int, j:int)->void:
	
	array[i][j]=preload("res://src/levelPieces/DungeonGate.tscn").instance()
	
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	add_child(array[i][j])

func create_exit(i:int, j:int)->void:
	match randi()%2:
		0:
			array[i][j]=preload("res://src/DungeonPieces/exit1.tscn").instance()
		1:
			array[i][j]=preload("res://src/DungeonPieces/exit2.tscn").instance()
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	if(get_node("/root/Game").boss_level==level+1):
		array[i][j].get_node("exit/DungeonDoors").texture=load("res://Assets/Doors/beholder_gate.png")
		array[i][j].get_node("exit/DungeonDoorsOpen").texture=load("res://Assets/Doors/beholder_gate_1.png")
	add_child(array[i][j])

func create_dungeon(i: int, j:int)->void:
	match randi()%1:
		0:
			array[i][j]=preload("res://src/levelPieces/lootbank.tscn").instance()
		1:
			pass
		2:
			pass
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	if(randi()%2==0):
		for _i in array[i][j].get_children():
			if(_i.name!="TrollDeath"):
				_i.position.x=-_i.position.x
	add_child(array[i][j])

func create_shop(i:int, j:int, dir:bool)->void:
	array[i][j]=preload("res://src/levelPieces/Shop.tscn").instance()
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	if(!dir):
		array[i][j].dir=true
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
			if(_i.name=="Mole"):
				_i.get_node("AnimatedSprite").set_flip_h(false)
	add_child(array[i][j])

func create_hallwaywithdrop(i:int, j:int)->void:
	randomize()
	var room=randi()%5
	match room:
		0:
			array[i][j]=preload("res://src/DungeonPieces/HallwayDrop1.tscn").instance()
		1:
			array[i][j]=preload("res://src/DungeonPieces/HallwayDrop2.tscn").instance()
		2:
			array[i][j]=preload("res://src/levelPieces/hallway5.tscn").instance()
		3: 
			array[i][j]=preload("res://src/levelPieces/hallwaywithdrop4.tscn").instance()
		4:
			array[i][j]=preload("res://src/levelPieces/SpikesDropDown.tscn").instance()
	
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	var flip=randi()%2
	if(flip==0):
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])


func create_startdropdown(i:int, j:int)->void:
	randomize()
	var room=randi()%5
	match room:
		0:
			array[i][j]=preload("res://src/levelPieces/startdropdown1.tscn").instance()
		1:
			array[i][j]=preload("res://src/levelPieces/startdropdown2.tscn").instance()
		2:
			array[i][j]=preload("res://src/DungeonPieces/StartDrop1.tscn").instance()
		3:
			array[i][j]=preload("res://src/DungeonPieces/start1.tscn").instance()
		4:
			array[i][j]=preload("res://src/DungeonPieces/StartDrop1.tscn").instance()
		5:
			array[i][j]=preload("res://src/DungeonPieces/StartDrop1.tscn").instance()
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	var flip=randi()%2
	if(flip==0):
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])

func create_dropdown(i:int, j:int)->void:
	randomize()
	var room=randi()%3
	match room:
		0:
			array[i][j]=preload("res://src/DungeonPieces/Dropdown1.tscn").instance()
		1:
			array[i][j]=preload("res://src/levelPieces/dropdown2.tscn").instance()
		2:
			array[i][j]=preload("res://src/levelPieces/dropdown3.tscn").instance()
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	var flip=randi()%2
	if(flip==0):
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])

func create_hallway(i:int, j:int) ->void:
	randomize()
	var room=randi()%16
	match room:
		0:
			array[i][j]=preload("res://src/levelPieces/hallway1.tscn").instance()
		1:
			array[i][j]=preload("res://src/levelPieces/hallblanka1.tscn").instance()
		2:
			array[i][j]=preload("res://src/levelPieces/hallblanka2.tscn").instance()
		3:
			array[i][j]=preload("res://src/levelPieces/hallblanka3.tscn").instance()
		4:
			array[i][j]=preload("res://src/levelPieces/dropdown2.tscn").instance()
		5:
			array[i][j]=preload("res://src/levelPieces/hallway3.tscn").instance()
		6:
			array[i][j]=preload("res://src/levelPieces/hallway5.tscn").instance()
		7:
			array[i][j]=preload("res://src/levelPieces/dropdown3.tscn").instance()
		8:
			array[i][j]=preload("res://src/levelPieces/hallway4.tscn").instance()
		9:
			array[i][j]=preload("res://src/levelPieces/hallwaydrop3.tscn").instance()
		10:
			array[i][j]=preload("res://src/levelPieces/Bridge.tscn").instance()
		11:
			array[i][j]=preload("res://src/levelPieces/LavaPool.tscn").instance()
		12:
			array[i][j]=preload("res://src/levelPieces/t_hallway1.tscn").instance()
		13:
			array[i][j]=preload("res://src/DungeonPieces/Hallway1.tscn").instance()
		14:
			array[i][j]=preload("res://src/DungeonPieces/Hallway2.tscn").instance()
		15:
			array[i][j]=preload("res://src/DungeonPieces/Hallway3.tscn").instance()
	
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	var flip=randi()%2
	if(flip==0):
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])

func create_side_room(i:int, j:int) ->void:
	randomize()
	if(randi()%13==-2 and !alter):
		alter=true
		array[i][j]=preload("res://src/levelPieces/EvilAlter.tscn").instance()
	else:
		var room=randi()%7
		match room:
			0:
				array[i][j]=preload("res://src/levelPieces/sideroom1.tscn").instance()
			1:
				array[i][j]=preload("res://src/levelPieces/sideroom5.tscn").instance()
			2:
				array[i][j]=preload("res://src/levelPieces/blanka1.tscn").instance()
			3:
				array[i][j]=preload("res://src/levelPieces/blanka2.tscn").instance()
			4:
				array[i][j]=preload("res://src/levelPieces/sideroom2.tscn").instance()
			5:
				array[i][j]=preload("res://src/levelPieces/sideroom3.tscn").instance()
			6:
				array[i][j]=preload("res://src/levelPieces/sideroom4.tscn").instance()
	array[i][j].global_position.x=80 + j * 160
	array[i][j].global_position.y=64 + i * 128
	var flip=randi()%2
	if(flip==0):
		for _i in array[i][j].get_children():
			_i.position.x=-_i.position.x
	add_child(array[i][j])

func add_player()->void:
	var player = preload("res://src/Actors/Player.tscn").instance()
	player.global_position.x=80+start*160
	player.global_position.y=34
	player.get_node("Camera2D").limit_right+=(end_right-4)*160
	player.get_node("Camera2D").limit_bottom+=(end_down-4)*128
	player.poisoned=get_parent().poisoned
	player.goggles=get_parent().goggles
	
	add_child(player)

func create_decorations()->void:
	var r
	var polje = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]]
	for i in range(4):
		for j in range(4):
			r=randi()%3
			if(r==0):
				polje[i][j]=preload("res://src/Other/Fossil.tscn").instance()
				r=randi()%128
				polje[i][j].global_position.x=float(r)+i*160 + 16
				r=randi()%96
				polje[i][j].global_position.y=float(r)+j*128 + 16
				r=randi()%2
				if(r==0):
					polje[i][j].get_node("AnimatedSprite").set_flip_h(true)
				r=randi()%6
				match r:
					0:
						polje[i][j].get_node("AnimatedSprite").animation="an1"
					1:
						polje[i][j].get_node("AnimatedSprite").animation="an2"
					2:
						polje[i][j].get_node("AnimatedSprite").animation="an3"
					3:
						polje[i][j].get_node("AnimatedSprite").animation="an4"
					4:
						polje[i][j].get_node("AnimatedSprite").animation="an5"
					5:
						polje[i][j].get_node("AnimatedSprite").animation="an6"
				add_child(polje[i][j])


