extends SceneTree

const REQUIRED_ASSETS := [
	"res://assets/art_v2/grass_tile.png",
	"res://assets/art_v2/dirt_tile.png",
	"res://assets/art_v2/tree_oak_a.png",
	"res://assets/art_v2/tree_oak_b.png",
	"res://assets/art_v2/tree_pine.png",
	"res://assets/art_v2/bush.png",
	"res://assets/art_v2/rock.png",
	"res://assets/art_v2/log.png",
	"res://assets/art_v2/flowers.png",
	"res://assets/art_v2/player_ranger_8dir.png",
	"res://assets/art_v2/monster_slime.png",
	"res://assets/art_v2/monster_boar.png",
	"res://assets/art_v2/attack_slash.png",
	"res://assets/art_v2/shadow.png"
]

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var forest_script := load("res://scripts/forest_test.gd") as Script
	_check(forest_script != null, "forest_test.gd deve carregar")
	if forest_script != null:
		var forest = forest_script.new()
		var counts: Dictionary = forest.get_layout_counts()
		_check(int(counts.get("trees", 0)) >= 36, "V2 precisa de pelo menos 36 arvores")
		_check(int(counts.get("bushes", 0)) >= 24, "V2 precisa de pelo menos 24 arbustos")
		_check(int(counts.get("rocks", 0)) >= 12, "V2 precisa de pelo menos 12 pedras")
		_check(int(counts.get("logs", 0)) >= 5, "V2 precisa de pelo menos 5 troncos")
		_check(int(counts.get("flowers", 0)) >= 16, "V2 precisa de pelo menos 16 manchas florais")
		forest.free()

	var player_script := load("res://scripts/player.gd") as Script
	_check(player_script != null, "player.gd deve carregar")
	if player_script != null:
		var constants: Dictionary = player_script.get_script_constant_map()
		_check(int(constants.get("VISUAL_VERSION", 0)) == 2, "Player deve declarar VISUAL_VERSION=2")
		_check(float(constants.get("ART_SCALE", 0.0)) >= 0.78, "Player V2 deve ocupar mais tela")
		_check(float(constants.get("CAMERA_ZOOM", 0.0)) >= 1.55, "Camera V2 deve ser mais proxima")

	for path in REQUIRED_ASSETS:
		_check(FileAccess.file_exists(path), "asset V2 ausente: %s" % path)

	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V2_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
