extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var packed := load("res://scenes/forest_test.tscn") as PackedScene
	_check(packed != null, "ForestTest scene must load")
	if packed != null:
		var instance := packed.instantiate()
		_check(instance.name == "ForestTest", "root must be ForestTest")
		_check(instance.get_node_or_null("World") != null, "World node is required")
		_check(instance.get_node_or_null("Actors") != null, "Actors node is required")
		_check(instance.get_node_or_null("HUD") != null, "HUD node is required")
		instance.free()
	if failures.is_empty():
		print("FOREST_V1_BOOT_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
