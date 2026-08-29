extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var script := load("res://scripts/player.gd")
	_check(script != null, "player.gd must exist")
	if script != null:
		var player = script.new()
		_check(player.has_method("direction_index_from_vector"), "direction helper is required")
		_check(player.has_method("normalized_input"), "normalized_input helper is required")
		if player.has_method("direction_index_from_vector"):
			var cases := [
				[Vector2(0, 1), 0], [Vector2(1, 1), 1], [Vector2(1, 0), 2], [Vector2(1, -1), 3],
				[Vector2(0, -1), 4], [Vector2(-1, -1), 5], [Vector2(-1, 0), 6], [Vector2(-1, 1), 7]
			]
			for item in cases:
				_check(player.direction_index_from_vector(item[0]) == item[1], "direction mismatch for %s" % item[0])
		if player.has_method("normalized_input"):
			var diagonal: Vector2 = player.normalized_input(Vector2(1, 1))
			_check(abs(diagonal.length() - 1.0) < 0.0001, "diagonal input must be normalized")
		player.free()
	if failures.is_empty():
		print("FOREST_V1_PLAYER_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
