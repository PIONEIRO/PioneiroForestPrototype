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
		_check(int(constants.get("VISUAL_VERSION", 0)) == 3, "V3 player must declare VISUAL_VERSION=3")
		_check(str(constants.get("WEAPON_CLASS", "")) == "TWO_HANDED_LONGSWORD", "V3 player must use a two-handed longsword")
		_check(int(constants.get("DEPTH_BASE", 0)) >= 5000, "V3 player depth base must keep actors above ground")
		_check(str(constants.get("PLAYER_TEXTURE_PATH", "")) == "res://assets/art_v3/warrior_greatsword_8dir.png", "V3 player texture path must point to approved warrior")
		_check(str(constants.get("ATTACK_TEXTURE_PATH", "")) == "res://assets/art_v3/greatsword_slash.png", "V3 attack texture path must point to greatsword slash")
		var player = player_script.new()
		_check(player.has_method("depth_index_for_y"), "V3 player must expose depth_index_for_y")
		if player.has_method("depth_index_for_y"):
			_check(int(player.depth_index_for_y(-600.0)) > 0, "player must remain above ground at negative Y")
			_check(int(player.depth_index_for_y(600.0)) > int(player.depth_index_for_y(-600.0)), "depth must still increase with Y")
		player.free()

	var forest_script := load("res://scripts/forest_test.gd") as Script
	_check(forest_script != null, "forest_test.gd must load")
	if forest_script != null:
		var constants: Dictionary = forest_script.get_script_constant_map()
		_check(int(constants.get("DEPTH_BASE", 0)) >= 5000, "V3 forest props must share positive depth base")
		var forest = forest_script.new()
		_check(forest.has_method("depth_index_for_y"), "V3 forest must expose depth_index_for_y")
		if forest.has_method("depth_index_for_y"):
			_check(int(forest.depth_index_for_y(-600.0)) > 0, "forest props at negative Y must stay above ground")
		forest.free()

	var monster_script := load("res://scripts/forest_monster.gd") as Script
	_check(monster_script != null, "forest_monster.gd must load")
	if monster_script != null:
		var constants: Dictionary = monster_script.get_script_constant_map()
		_check(int(constants.get("DEPTH_BASE", 0)) >= 5000, "V3 monsters must use positive depth base")
		var monster = monster_script.new()
		_check(monster.has_method("depth_index_for_y"), "V3 monsters must expose depth_index_for_y")
		if monster.has_method("depth_index_for_y"):
			_check(int(monster.depth_index_for_y(-600.0)) > 0, "monsters at negative Y must stay above ground")
		monster.free()

	for path in [
		"res://assets/art_v3/warrior_greatsword_8dir.png",
		"res://assets/art_v3/greatsword_slash.png"
	]:
		_check(FileAccess.file_exists(path), "V3 asset missing: %s" % path)

	if failures.is_empty():
		print("FOREST_VISUAL_PROTOTYPE_V3_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
