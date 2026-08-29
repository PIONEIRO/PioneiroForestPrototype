extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var script := load("res://scripts/forest_test.gd")
	_check(script != null, "forest_test.gd must load")
	if script != null:
		var forest = script.new()
		_check(forest.has_method("get_layout_counts"), "forest layout counts API is required")
		_check(forest.has_method("get_tree_collision_ratio"), "tree collision ratio API is required")
		if forest.has_method("get_layout_counts"):
			var counts: Dictionary = forest.get_layout_counts()
			_check(int(counts.get("trees", 0)) >= 18, "forest needs at least 18 trees")
			_check(int(counts.get("bushes", 0)) >= 8, "forest needs at least 8 bushes")
			_check(int(counts.get("rocks", 0)) >= 6, "forest needs at least 6 rocks")
			_check(int(counts.get("logs", 0)) >= 2, "forest needs at least 2 logs")
			_check(int(counts.get("flowers", 0)) >= 6, "forest needs at least 6 flower patches")
		if forest.has_method("get_tree_collision_ratio"):
			_check(float(forest.get_tree_collision_ratio()) <= 0.35, "tree collision must cover trunk/base, not canopy")
		forest.free()
	if failures.is_empty():
		print("FOREST_V1_LAYOUT_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
