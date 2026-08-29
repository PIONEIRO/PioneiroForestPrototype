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
		_check(str(constants.get("IDLE_TEXTURE_PATH", "")) == "res://assets/art_v5/warrior_idle_8dir.svg", "V5 idle sheet path mismatch")
		_check(str(constants.get("WALK_TEXTURE_PATH", "")) == "res://assets/art_v5/warrior_walk_8dir_4f.svg", "V5 walk sheet path mismatch")
		_check(str(constants.get("ATTACK_TEXTURE_PATH", "")) == "res://assets/art_v5/warrior_attack_8dir_6f.svg", "V5 attack sheet path mismatch")
		_check(Vector2(constants.get("CELL_SIZE", Vector2.ZERO)) == Vector2(64, 96), "V5 cell must stay 64x96")
		_check(int(constants.get("WALK_FRAMES", 0)) == 4, "V5 walk must have 4 frames")
		_check(int(constants.get("ATTACK_FRAMES", 0)) == 6, "V5 attack must have 6 frames")
		_check(float(constants.get("CAMERA_ZOOM", 99.0)) <= 1.40, "V5 camera zoom must be reduced")
		_check(float(constants.get("ART_SCALE", 99.0)) <= 1.20, "V5 player art scale must be reduced")
	_check(FileAccess.file_exists("res://assets/art_v5/warrior_idle_8dir.svg"), "V5 idle sheet missing")
	_check(FileAccess.file_exists("res://assets/art_v5/warrior_walk_8dir_4f.svg"), "V5 walk sheet missing")
	_check(FileAccess.file_exists("res://assets/art_v5/warrior_attack_8dir_6f.svg"), "V5 attack sheet missing")
	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V5_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
