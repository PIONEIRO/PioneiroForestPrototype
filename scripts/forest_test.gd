extends Node2D

const PlayerScript = preload("res://scripts/player.gd")
const MonsterScript = preload("res://scripts/forest_monster.gd")
const DEPTH_BASE := 6000

const GRASS_TEXTURE := preload("res://assets/art_v2/grass_tile.png")
const DIRT_TEXTURE := preload("res://assets/art_v2/dirt_tile.png")

const PROP_TEXTURES := {
	"oak_a": "res://assets/art_v2/tree_oak_a.png",
	"oak_b": "res://assets/art_v2/tree_oak_b.png",
	"pine": "res://assets/art_v2/tree_pine.png",
	"bush": "res://assets/art_v2/bush.png",
	"rock": "res://assets/art_v2/rock.png",
	"log": "res://assets/art_v2/log.png",
	"flowers": "res://assets/art_v2/flowers.png"
}

const TREE_LAYOUT := [
	[Vector2(-780,-510),"pine",0.92],[Vector2(-620,-540),"oak_a",0.92],[Vector2(-455,-520),"oak_b",0.90],[Vector2(-290,-560),"pine",0.90],[Vector2(-110,-530),"oak_a",0.94],[Vector2(70,-555),"oak_b",0.91],[Vector2(255,-530),"pine",0.91],[Vector2(430,-545),"oak_a",0.93],[Vector2(610,-515),"oak_b",0.90],[Vector2(790,-500),"pine",0.92],
	[Vector2(-860,-360),"oak_a",0.93],[Vector2(-880,-165),"pine",0.91],[Vector2(-875,45),"oak_b",0.90],[Vector2(-860,250),"oak_a",0.94],[Vector2(-820,455),"pine",0.91],
	[Vector2(860,-350),"oak_b",0.92],[Vector2(880,-145),"pine",0.90],[Vector2(875,60),"oak_a",0.94],[Vector2(865,265),"oak_b",0.91],[Vector2(825,465),"pine",0.92],
	[Vector2(-720,555),"oak_b",0.92],[Vector2(-540,570),"pine",0.91],[Vector2(-360,560),"oak_a",0.94],[Vector2(-170,585),"oak_b",0.90],[Vector2(25,560),"pine",0.91],[Vector2(225,580),"oak_a",0.94],[Vector2(420,555),"oak_b",0.91],[Vector2(610,570),"pine",0.90],[Vector2(780,535),"oak_a",0.93],
	[Vector2(-600,-310),"oak_b",0.88],[Vector2(-450,-250),"pine",0.86],[Vector2(515,-300),"oak_a",0.89],[Vector2(650,-215),"pine",0.86],
	[Vector2(-620,195),"pine",0.86],[Vector2(-505,320),"oak_a",0.89],[Vector2(540,325),"oak_b",0.88],[Vector2(660,185),"pine",0.86],
	[Vector2(-250,-335),"oak_a",0.84],[Vector2(290,-350),"oak_b",0.84],[Vector2(-315,365),"pine",0.83],[Vector2(335,380),"oak_a",0.85]
]

const BUSH_LAYOUT := [
	Vector2(-710,-400),Vector2(-535,-410),Vector2(-360,-430),Vector2(-180,-410),Vector2(120,-420),Vector2(330,-410),Vector2(520,-405),Vector2(710,-390),
	Vector2(-760,-220),Vector2(-730,30),Vector2(-700,260),Vector2(-640,430),Vector2(735,-225),Vector2(745,20),Vector2(720,245),Vector2(650,430),
	Vector2(-520,-120),Vector2(-405,80),Vector2(-480,250),Vector2(500,-115),Vector2(420,90),Vector2(480,245),
	Vector2(-250,-210),Vector2(250,-225),Vector2(-260,250),Vector2(265,265),Vector2(-80,430),Vector2(90,-405)
]
const ROCK_LAYOUT := [
	Vector2(-650,-80),Vector2(-520,80),Vector2(-380,-180),Vector2(-305,125),Vector2(-160,-300),Vector2(155,-315),Vector2(320,125),Vector2(405,-180),
	Vector2(535,90),Vector2(650,-45),Vector2(-475,420),Vector2(470,430),Vector2(-70,475),Vector2(95,485)
]
const LOG_LAYOUT := [Vector2(-520,-260),Vector2(-330,300),Vector2(-70,-390),Vector2(250,330),Vector2(485,-275),Vector2(570,165)]
const FLOWER_LAYOUT := [
	Vector2(-610,-365),Vector2(-430,-360),Vector2(-230,-405),Vector2(15,-420),Vector2(190,-395),Vector2(390,-370),Vector2(600,-340),
	Vector2(-680,135),Vector2(-510,235),Vector2(-350,430),Vector2(-130,355),Vector2(95,365),Vector2(315,430),Vector2(520,225),Vector2(690,125),
	Vector2(-290,-105),Vector2(305,-95),Vector2(20,245)
]

var _world: Node2D
var _actors: Node2D
var _hud: CanvasLayer
var _player: ForestPlayer

func get_layout_counts() -> Dictionary:
	return {"trees": TREE_LAYOUT.size(), "bushes": BUSH_LAYOUT.size(), "rocks": ROCK_LAYOUT.size(), "logs": LOG_LAYOUT.size(), "flowers": FLOWER_LAYOUT.size()}

func get_tree_collision_ratio() -> float:
	return 42.0 / 208.0

func depth_index_for_y(world_y: float) -> int:
	return DEPTH_BASE + int(round(world_y))

func _ready() -> void:
	_world = get_node("World") as Node2D
	_actors = get_node("Actors") as Node2D
	_hud = get_node("HUD") as CanvasLayer
	queue_redraw()
	_build_environment()
	_spawn_player()
	_spawn_monsters()
	_build_hud()
	print("FOREST_VISUAL_PROTOTYPE_V3_READY")

func _draw() -> void:
	draw_texture_rect(GRASS_TEXTURE, Rect2(-980, -700, 1960, 1400), true)
	var path_segments := [
		Rect2(-980, -42, 430, 112),
		Rect2(-610, -70, 390, 116),
		Rect2(-275, -30, 400, 118),
		Rect2(70, 5, 350, 114),
		Rect2(365, -20, 355, 112),
		Rect2(665, -55, 315, 112)
	]
	for segment in path_segments:
		draw_texture_rect(DIRT_TEXTURE, segment, true)
	for p in [Vector2(-690,15),Vector2(-370,-15),Vector2(-40,20),Vector2(280,48),Vector2(590,18)]:
		draw_circle(p, 78, Color(0.52,0.39,0.24,0.28))
	draw_circle(Vector2(430, 250), 124, Color("#355a3d"))
	draw_circle(Vector2(430, 250), 108, Color("#4d88a2"))
	draw_circle(Vector2(410, 225), 72, Color("#5e9bb1"))
	for p in [Vector2(360,185),Vector2(490,180),Vector2(515,285),Vector2(350,300)]:
		draw_circle(p, 12, Color("#6f9855"))
	for p in [Vector2(-745,-305),Vector2(-575,350),Vector2(-155,-245),Vector2(185,300),Vector2(635,-285)]:
		draw_circle(p, 64, Color(0.17,0.31,0.16,0.22))

func _build_environment() -> void:
	for item in TREE_LAYOUT:
		_spawn_prop(str(item[1]), item[0], float(item[2]), true)
	for pos in BUSH_LAYOUT:
		_spawn_prop("bush", pos, 1.0, false)
	for pos in ROCK_LAYOUT:
		_spawn_prop("rock", pos, 1.0, true)
	for pos in LOG_LAYOUT:
		_spawn_prop("log", pos, 1.0, true)
	for pos in FLOWER_LAYOUT:
		_spawn_prop("flowers", pos, 1.0, false)

func _spawn_prop(kind: String, pos: Vector2, visual_scale: float, solid: bool) -> void:
	var holder: Node2D
	if solid:
		holder = StaticBody2D.new()
		(holder as StaticBody2D).collision_layer = 1
		(holder as StaticBody2D).collision_mask = 0
	else:
		holder = Node2D.new()
	holder.name = "%s_%d" % [kind.capitalize(), _world.get_child_count()]
	holder.position = pos
	holder.z_index = depth_index_for_y(pos.y)
	_world.add_child(holder)

	var shadow := Sprite2D.new()
	shadow.texture = load("res://assets/art_v2/shadow.png")
	shadow.position = Vector2(0, -2)
	shadow.z_index = -1
	shadow.scale = Vector2(1.10,0.72) if kind in ["oak_a","oak_b","pine"] else Vector2(0.64,0.48)
	holder.add_child(shadow)

	var sprite := Sprite2D.new()
	var texture := load(str(PROP_TEXTURES[kind])) as Texture2D
	sprite.texture = texture
	sprite.scale = Vector2(visual_scale, visual_scale)
	sprite.position.y = -float(texture.get_height()) * visual_scale * 0.5 + (5.0 if kind in ["oak_a","oak_b","pine"] else 1.0)
	holder.add_child(sprite)

	if solid:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		if kind in ["oak_a", "oak_b", "pine"]:
			shape.size = Vector2(42, 28)
			collision.position = Vector2(0, -10)
		elif kind == "rock":
			shape.size = Vector2(48, 28)
			collision.position = Vector2(0, -8)
		else:
			shape.size = Vector2(70, 20)
			collision.position = Vector2(0, -7)
		collision.shape = shape
		holder.add_child(collision)

func _spawn_player() -> void:
	_player = PlayerScript.new()
	_player.name = "Player"
	_player.position = Vector2(-90, 165)
	_actors.add_child(_player)
	_player.attack_started.connect(_on_player_attack)

func _spawn_monsters() -> void:
	_spawn_monster("slime", Vector2(-360,-130))
	_spawn_monster("slime", Vector2(245,165))
	_spawn_monster("boar", Vector2(500,-180))
	_spawn_monster("boar", Vector2(-500,260))

func _spawn_monster(kind: String, pos: Vector2) -> void:
	var monster: ForestMonster = MonsterScript.new()
	monster.name = "%s_%d" % [kind.capitalize(), _actors.get_child_count()]
	monster.position = pos
	monster.configure(kind, _player)
	_actors.add_child(monster)

func _on_player_attack(direction_index: int, origin: Vector2) -> void:
	var facing := _player.facing_vector_from_index(direction_index)
	for node in get_tree().get_nodes_in_group("forest_monsters"):
		var monster := node as ForestMonster
		if monster == null or monster.is_dead():
			continue
		var delta := monster.global_position - origin
		var distance := delta.length()
		if distance <= 118.0 and distance > 0.001 and facing.dot(delta.normalized()) >= 0.18:
			monster.take_hit(1, origin)

func _build_hud() -> void:
	var panel := ColorRect.new()
	panel.color = Color(0.027,0.043,0.030,0.84)
	panel.position = Vector2(18,18)
	panel.size = Vector2(430,78)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(panel)

	var title := Label.new()
	title.text = "PIONEIRO FOREST — VISUAL V3"
	title.position = Vector2(30,26)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#f2e2b4"))
	_hud.add_child(title)

	var controls := Label.new()
	controls.text = "WASD / Setas: mover   •   Espaço: espada longa 2 mãos"
	controls.position = Vector2(30,53)
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color("#d9ead0"))
	_hud.add_child(controls)

	var note := Label.new()
	note.text = "V3: guerreiro aprovado + profundidade corrigida"
	note.position = Vector2(30,75)
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#a9c9a0"))
	_hud.add_child(note)
