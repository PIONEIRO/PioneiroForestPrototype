extends Node2D

const PlayerScript = preload("res://scripts/player.gd")
const MonsterScript = preload("res://scripts/forest_monster.gd")

const PROP_TEXTURES := {
	"oak": "res://assets/art/tree_oak.svg",
	"pine": "res://assets/art/tree_pine.svg",
	"bush": "res://assets/art/bush.svg",
	"rock": "res://assets/art/rock.svg",
	"log": "res://assets/art/log.svg",
	"flowers": "res://assets/art/flower_patch.svg"
}

const TREE_LAYOUT := [
	[Vector2(-850,-560),"pine",0.80],[Vector2(-620,-590),"oak",0.82],[Vector2(-360,-610),"pine",0.76],[Vector2(-80,-600),"oak",0.86],[Vector2(210,-610),"pine",0.79],[Vector2(500,-570),"oak",0.83],[Vector2(790,-530),"pine",0.82],
	[Vector2(-900,-300),"oak",0.84],[Vector2(-875,40),"pine",0.80],[Vector2(-900,360),"oak",0.86],[Vector2(-760,610),"pine",0.78],
	[Vector2(860,-280),"oak",0.85],[Vector2(900,30),"pine",0.80],[Vector2(870,340),"oak",0.86],[Vector2(730,610),"pine",0.78],
	[Vector2(-460,570),"oak",0.84],[Vector2(-150,620),"pine",0.78],[Vector2(170,600),"oak",0.84],[Vector2(480,570),"pine",0.80],
	[Vector2(-470,-170),"oak",0.78],[Vector2(470,-130),"pine",0.75],[Vector2(-560,250),"pine",0.72],[Vector2(560,270),"oak",0.77]
]

const BUSH_LAYOUT := [Vector2(-690,-330),Vector2(-320,-420),Vector2(340,-430),Vector2(700,-330),Vector2(-700,180),Vector2(-310,420),Vector2(300,440),Vector2(710,150),Vector2(-120,330),Vector2(120,-310)]
const ROCK_LAYOUT := [Vector2(-600,-70),Vector2(-280,-280),Vector2(280,-260),Vector2(620,-20),Vector2(-420,350),Vector2(420,340),Vector2(-90,500),Vector2(110,500)]
const LOG_LAYOUT := [Vector2(-260,120),Vector2(330,120),Vector2(40,-430)]
const FLOWER_LAYOUT := [Vector2(-520,-390),Vector2(-120,-430),Vector2(210,-390),Vector2(520,-330),Vector2(-600,320),Vector2(-170,420),Vector2(220,390),Vector2(590,300)]

var _world: Node2D
var _actors: Node2D
var _hud: CanvasLayer
var _player: ForestPlayer

func get_layout_counts() -> Dictionary:
	return {"trees": TREE_LAYOUT.size(), "bushes": BUSH_LAYOUT.size(), "rocks": ROCK_LAYOUT.size(), "logs": LOG_LAYOUT.size(), "flowers": FLOWER_LAYOUT.size()}

func get_tree_collision_ratio() -> float:
	return 48.0 / 240.0

func _ready() -> void:
	_world = get_node("World") as Node2D
	_actors = get_node("Actors") as Node2D
	_hud = get_node("HUD") as CanvasLayer
	queue_redraw()
	_build_environment()
	_spawn_player()
	_spawn_monsters()
	_build_hud()
	print("FOREST_VISUAL_PROTOTYPE_V1_READY")

func _draw() -> void:
	draw_rect(Rect2(-1200, -900, 2400, 1800), Color("#577d45"), true)
	draw_circle(Vector2(-520,-260), 360, Color("#648a4e"))
	draw_circle(Vector2(520,250), 390, Color("#4f7541"))
	draw_circle(Vector2(50,-40), 520, Color("#60854a"))
	var path := PackedVector2Array([Vector2(-1100,120),Vector2(-760,70),Vector2(-420,80),Vector2(-120,20),Vector2(160,45),Vector2(480,10),Vector2(820,60),Vector2(1100,20),Vector2(1100,190),Vector2(820,180),Vector2(500,140),Vector2(180,175),Vector2(-120,150),Vector2(-430,200),Vector2(-760,175),Vector2(-1100,230)])
	draw_colored_polygon(path, Color("#9b7a4d"))
	var path_inner := PackedVector2Array([Vector2(-1100,145),Vector2(-760,105),Vector2(-420,115),Vector2(-120,62),Vector2(160,82),Vector2(480,48),Vector2(820,98),Vector2(1100,58),Vector2(1100,148),Vector2(820,140),Vector2(500,105),Vector2(180,135),Vector2(-120,113),Vector2(-430,160),Vector2(-760,140),Vector2(-1100,192)])
	draw_colored_polygon(path_inner, Color("#aa8958"))
	for patch in [Vector2(-680,-170),Vector2(-350,300),Vector2(330,-350),Vector2(690,270),Vector2(0,480),Vector2(70,-470)]:
		draw_circle(patch, 95, Color(0.25,0.42,0.24,0.24))

func _build_environment() -> void:
	for item in TREE_LAYOUT:
		_spawn_prop(str(item[1]), item[0], float(item[2]), true)
	for pos in BUSH_LAYOUT:
		_spawn_prop("bush", pos, 0.72, false)
	for pos in ROCK_LAYOUT:
		_spawn_prop("rock", pos, 0.70, true)
	for pos in LOG_LAYOUT:
		_spawn_prop("log", pos, 0.72, true)
	for pos in FLOWER_LAYOUT:
		_spawn_prop("flowers", pos, 0.68, false)

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
	holder.z_index = int(pos.y)
	_world.add_child(holder)

	var shadow := Sprite2D.new()
	shadow.texture = load("res://assets/art/shadow.svg")
	shadow.position = Vector2(0, -2)
	shadow.z_index = -1
	shadow.scale = Vector2(0.76,0.48) if kind in ["oak","pine"] else Vector2(0.46,0.34)
	holder.add_child(shadow)

	var sprite := Sprite2D.new()
	var texture := load(str(PROP_TEXTURES[kind])) as Texture2D
	sprite.texture = texture
	sprite.scale = Vector2(visual_scale, visual_scale)
	sprite.position.y = -float(texture.get_height()) * visual_scale * 0.5 + (8.0 if kind in ["oak","pine"] else 3.0)
	holder.add_child(sprite)

	if solid:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		if kind in ["oak", "pine"]:
			shape.size = Vector2(48, 28)
			collision.position = Vector2(0, -10)
		elif kind == "rock":
			shape.size = Vector2(52, 30)
			collision.position = Vector2(0, -8)
		else:
			shape.size = Vector2(72, 22)
			collision.position = Vector2(0, -7)
		collision.shape = shape
		holder.add_child(collision)

func _spawn_player() -> void:
	_player = PlayerScript.new()
	_player.name = "Player"
	_player.position = Vector2(-40, 230)
	_actors.add_child(_player)
	_player.attack_started.connect(_on_player_attack)

func _spawn_monsters() -> void:
	_spawn_monster("slime", Vector2(-390,-40))
	_spawn_monster("slime", Vector2(390,280))
	_spawn_monster("boar", Vector2(450,-250))
	_spawn_monster("boar", Vector2(-500,300))

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
	panel.color = Color(0.035,0.055,0.038,0.84)
	panel.position = Vector2(18,18)
	panel.size = Vector2(430,92)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud.add_child(panel)

	var title := Label.new()
	title.text = "PIONEIRO FOREST — PROTÓTIPO VISUAL V1"
	title.position = Vector2(32,28)
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#f2e2b4"))
	_hud.add_child(title)

	var controls := Label.new()
	controls.text = "WASD / Setas: mover em 8 direções   •   Espaço: atacar"
	controls.position = Vector2(32,58)
	controls.add_theme_font_size_override("font_size", 15)
	controls.add_theme_color_override("font_color", Color("#d9ead0"))
	_hud.add_child(controls)

	var note := Label.new()
	note.text = "Teste: escala, profundidade, mata e leitura dos monstros"
	note.position = Vector2(32,82)
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color("#a9c9a0"))
	_hud.add_child(note)
