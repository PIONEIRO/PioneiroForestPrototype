extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var player_script := load("res://scripts/player.gd") as Script
	_check(player_script != null, "player.gd must load")
	if player_script != null:
		var constants: Dictionary = player_script.get_script_constant_map()
		_check(int(constants.get("VISUAL_VERSION", 0)) == 5, "V5 player must declare VISUAL_VERSION=5")
		_check(str(constants.get("WEAPON_CLASS", "")) == "TWO_HANDED_LONGSWORD", "V5 must keep two-handed longsword identity")
		_check(str(constants.get("PLAYER_TEXTURE_SOURCE_PREFIX", "")) == "res://assets/art_v4/warrior_greatsword_simple_8dir.b64.", "V5 must reuse approved warrior source")
		_check(Vector2(constants.get("SOURCE_CELL_SIZE", Vector2.ZERO)) == Vector2(64, 96), "V5 source cells must remain 64x96")
		_check(Vector2(constants.get("CELL_SIZE", Vector2.ZERO)) == Vector2(96, 96), "V5 runtime cells need sword-safe padding")
		_check(int(constants.get("WALK_FRAMES", 0)) == 4, "V5 walk must have 4 frames")
		_check(int(constants.get("ATTACK_FRAMES", 0)) == 6, "V5 attack must have 6 frames")
		_check(float(constants.get("CAMERA_ZOOM", 99.0)) <= 1.40, "V5 camera zoom must be reduced")
		_check(float(constants.get("ART_SCALE", 99.0)) <= 1.20, "V5 player art scale must be reduced")
	for index in range(6):
		_check(FileAccess.file_exists("res://assets/art_v4/warrior_greatsword_simple_8dir.b64.%d.txt" % index), "approved V4 source chunk missing")
	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V5_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
