extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var script := load("res://scripts/forest_monster.gd")
	_check(script != null, "forest_monster.gd must exist")
	if script != null:
		var monster = script.new()
		_check(monster.has_method("get_supported_states"), "monster state API is required")
		_check(monster.has_method("get_profile"), "monster profile API is required")
		if monster.has_method("get_supported_states"):
			_check(monster.get_supported_states() == ["IDLE", "WANDER", "CHASE", "HURT", "DEAD"], "monster states must match contract")
		if monster.has_method("get_profile"):
			for kind in ["slime", "boar"]:
				var profile: Dictionary = monster.get_profile(kind)
				_check(not profile.is_empty(), "%s profile must exist" % kind)
				_check(float(profile.get("detection_radius", 0.0)) > 0.0, "%s detection radius must be positive" % kind)
				_check(float(profile.get("home_radius", 0.0)) > 0.0, "%s home radius must be positive" % kind)
		monster.free()
	if failures.is_empty():
		print("FOREST_V1_MONSTER_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
