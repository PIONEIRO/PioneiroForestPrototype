extends SceneTree

const REQUIRED_ASSETS := {
	"res://assets/art_v2/grass_tile.png": Vector2i(64, 64),
	"res://assets/art_v2/dirt_tile.png": Vector2i(64, 64),
	"res://assets/art_v2/tree_oak_a.png": Vector2i(160, 208),
	"res://assets/art_v2/tree_oak_b.png": Vector2i(160, 208),
	"res://assets/art_v2/tree_pine.png": Vector2i(160, 208),
	"res://assets/art_v2/bush.png": Vector2i(80, 64),
	"res://assets/art_v2/rock.png": Vector2i(80, 64),
	"res://assets/art_v2/log.png": Vector2i(112, 64),
	"res://assets/art_v2/flowers.png": Vector2i(64, 48),
	"res://assets/art_v2/player_ranger_8dir.png": Vector2i(768, 128),
	"res://assets/art_v2/monster_slime.png": Vector2i(80, 64),
	"res://assets/art_v2/monster_boar.png": Vector2i(96, 72),
	"res://assets/art_v2/attack_slash.png": Vector2i(96, 96)
}

func _initialize() -> void:
	var failures: Array[String] = []
	var forest_script := load("res://scripts/forest_test.gd") as Script
	var forest = forest_script.new()
	var counts: Dictionary = forest.get_layout_counts()
	_check(int(counts.get("trees", 0)) >= 36, "V2 precisa de pelo menos 36 arvores", failures)
	_check(int(counts.get("bushes", 0)) >= 24, "V2 precisa de pelo menos 24 arbustos", failures)
	_check(int(counts.get("rocks", 0)) >= 12, "V2 precisa de pelo menos 12 pedras", failures)
	_check(int(counts.get("logs", 0)) >= 5, "V2 precisa de pelo menos 5 troncos", failures)
	_check(int(counts.get("flowers", 0)) >= 16, "V2 precisa de pelo menos 16 manchas florais", failures)
	forest.free()

	var player_script := load("res://scripts/player.gd") as Script
	var constants: Dictionary = player_script.get_script_constant_map()
	_check(int(constants.get("VISUAL_VERSION", 0)) == 2, "Player deve declarar VISUAL_VERSION=2", failures)
	_check(float(constants.get("ART_SCALE", 0.0)) >= 0.78, "Player V2 deve ocupar mais tela", failures)
	_check(float(constants.get("CAMERA_ZOOM", 0.0)) >= 1.55, "Camera V2 deve ser mais proxima", failures)

	for path in REQUIRED_ASSETS.keys():
		_check(FileAccess.file_exists(path), "asset V2 ausente: %s" % path, failures)
		if FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			_check(not image.is_empty(), "asset V2 invalido: %s" % path, failures)
			if not image.is_empty():
				_check(image.get_size() == REQUIRED_ASSETS[path], "dimensao inesperada em %s: %s" % [path, image.get_size()], failures)

	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V2_CONTRACT_PASS")
		quit(0)
		return
	for message in failures:
		push_error(message)
	quit(1)

func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
