extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _check_depth_contract(script: Script, label: String) -> void:
	var constants: Dictionary = script.get_script_constant_map()
	var base := int(constants.get("DEPTH_BASE", -1))
	_check(base >= 1000 and base <= 3000, "%s DEPTH_BASE must stay safely inside Godot z-index limits" % label)
	var instance = script.new()
	_check(instance.has_method("depth_index_for_y"), "%s must expose depth_index_for_y" % label)
	if instance.has_method("depth_index_for_y"):
		var top := int(instance.depth_index_for_y(-700.0))
		var bottom := int(instance.depth_index_for_y(700.0))
		_check(top > 0, "%s must remain above ground at negative Y" % label)
		_check(bottom > top, "%s depth must increase with Y" % label)
		_check(bottom <= 4095, "%s depth must stay within Godot z-index max" % label)
	instance.free()

func _run() -> void:
	var player_script := load("res://scripts/player.gd") as Script
	_check(player_script != null, "player.gd must load")
	if player_script != null:
		var constants: Dictionary = player_script.get_script_constant_map()
		_check(int(constants.get("VISUAL_VERSION", 0)) == 3, "V3 player must declare VISUAL_VERSION=3")
		_check(str(constants.get("WEAPON_CLASS", "")) == "TWO_HANDED_LONGSWORD", "V3 player must use a two-handed longsword")
		_check(str(constants.get("PLAYER_TEXTURE_PATH", "")) == "res://assets/art_v3/warrior_greatsword_8dir.svg", "V3 player texture path must point to approved warrior SVG")
		_check(str(constants.get("ATTACK_TEXTURE_PATH", "")) == "res://assets/art_v3/greatsword_slash.svg", "V3 attack texture path must point to greatsword slash SVG")
		_check_depth_contract(player_script, "player")

	var forest_script := load("res://scripts/forest_test.gd") as Script
	_check(forest_script != null, "forest_test.gd must load")
	if forest_script != null:
		_check_depth_contract(forest_script, "forest")

	var monster_script := load("res://scripts/forest_monster.gd") as Script
	_check(monster_script != null, "forest_monster.gd must load")
	if monster_script != null:
		_check_depth_contract(monster_script, "monster")

	for path in [
		"res://assets/art_v3/warrior_greatsword_8dir.svg",
		"res://assets/art_v3/greatsword_slash.svg"
	]:
		_check(FileAccess.file_exists(path), "V3 asset missing: %s" % path)

	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V3_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
