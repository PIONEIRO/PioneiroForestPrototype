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
		_check(int(constants.get("VISUAL_VERSION", 0)) == 4, "V4 player must declare VISUAL_VERSION=4")
		_check(str(constants.get("PLAYER_TEXTURE_PATH", "")) == "res://assets/art_v4/warrior_greatsword_simple_8dir.png", "V4 must use approved simple warrior")
		_check(Vector2(constants.get("CELL_SIZE", Vector2.ZERO)) == Vector2(64, 96), "V4 cell must be 64x96")
		_check(str(constants.get("WEAPON_CLASS", "")) == "TWO_HANDED_LONGSWORD", "V4 must keep two-handed longsword identity")
	_check(FileAccess.file_exists("res://assets/art_v4/warrior_greatsword_simple_8dir.png"), "approved V4 PNG missing")
	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V4_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
