extends SceneTree

var failures: Array[String] = []
const REQUIRED := [
	"res://assets/art/player_ranger_8dir.svg",
	"res://assets/art/forest_slime.svg",
	"res://assets/art/forest_boar.svg",
	"res://assets/art/tree_oak.svg",
	"res://assets/art/tree_pine.svg",
	"res://assets/art/bush.svg",
	"res://assets/art/rock.svg",
	"res://assets/art/log.svg",
	"res://assets/art/flower_patch.svg",
	"res://assets/art/shadow.svg"
]

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	for path in REQUIRED:
		_check(FileAccess.file_exists(path), "missing artwork: %s" % path)
		if FileAccess.file_exists(path):
			var texture := load(path)
			_check(texture is Texture2D, "artwork must import as Texture2D: %s" % path)
	if failures.is_empty():
		print("FOREST_V1_ASSET_CONTRACT_PASS")
		quit(0)
	else:
		quit(1)
