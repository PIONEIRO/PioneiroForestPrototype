extends CharacterBody2D
class_name ForestPlayer

signal attack_started(direction_index: int, origin: Vector2)

const VISUAL_VERSION := 4
const WEAPON_CLASS := "TWO_HANDED_LONGSWORD"
const DEPTH_BASE := 2048
const PLAYER_TEXTURE_SOURCE_PREFIX := "res://assets/art_v4/warrior_greatsword_simple_8dir.b64."
const PLAYER_TEXTURE_CHUNKS := 6
const ATTACK_TEXTURE_PATH := "res://assets/art_v3/greatsword_slash.svg"
const SPEED := 220.0
const ATTACK_COOLDOWN := 0.30
const CELL_SIZE := Vector2(64.0, 96.0)
const ART_SCALE := 1.48
const CAMERA_ZOOM := 1.72

var facing_index := 0
var _visual: Sprite2D
var _shadow: Sprite2D
var _attack_fx: Sprite2D
var _base_visual_position := Vector2.ZERO
var _attack_was_down := false
var _attack_timer := 0.0
var _walk_phase := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_build_collision()
	_build_visual()
	_build_camera()
	_apply_direction_visual()

func normalized_input(raw: Vector2) -> Vector2:
	if raw.length_squared() > 1.0:
		return raw.normalized()
	return raw

func direction_index_from_vector(value: Vector2) -> int:
	if value.length_squared() <= 0.000001:
		return facing_index
	var angle := rad_to_deg(atan2(value.y, value.x))
	if angle >= 67.5 and angle < 112.5:
		return 0
	if angle >= 22.5 and angle < 67.5:
		return 1
	if angle >= -22.5 and angle < 22.5:
		return 2
	if angle >= -67.5 and angle < -22.5:
		return 3
	if angle >= -112.5 and angle < -67.5:
		return 4
	if angle >= -157.5 and angle < -112.5:
		return 5
	if angle >= 112.5 and angle < 157.5:
		return 7
	return 6

func facing_vector_from_index(index: int) -> Vector2:
	var vectors := [
		Vector2(0, 1), Vector2(1, 1).normalized(), Vector2(1, 0), Vector2(1, -1).normalized(),
		Vector2(0, -1), Vector2(-1, -1).normalized(), Vector2(-1, 0), Vector2(-1, 1).normalized()
	]
	return vectors[clampi(index, 0, 7)]

func depth_index_for_y(world_y: float) -> int:
	return DEPTH_BASE + int(round(world_y))

func _physics_process(delta: float) -> void:
	var raw := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wasd := Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	)
	if wasd.length_squared() > 0.0:
		raw = wasd
	var move_dir := normalized_input(raw)
	velocity = move_dir * SPEED
	if move_dir.length_squared() > 0.001:
		facing_index = direction_index_from_vector(move_dir)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	z_index = depth_index_for_y(global_position.y)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_handle_attack()
	_animate_visual(delta, move_dir.length_squared() > 0.001)

func _handle_attack() -> void:
	var attack_down := Input.is_physical_key_pressed(KEY_SPACE)
	if attack_down and not _attack_was_down and _attack_timer <= 0.0:
		_attack_timer = ATTACK_COOLDOWN
		attack_started.emit(facing_index, global_position)
		_update_attack_fx(true)
	_attack_was_down = attack_down

func _animate_visual(delta: float, moving: bool) -> void:
	if _visual == null:
		return
	_walk_phase += delta * (10.0 if moving else 2.0)
	var bob := sin(_walk_phase) * (1.8 if moving else 0.35)
	var attack_lift := 0.0
	if _attack_timer > ATTACK_COOLDOWN * 0.55:
		attack_lift = 3.0
	_visual.position = _base_visual_position + Vector2(0, bob - attack_lift)
	_apply_direction_visual()
	_update_attack_fx(_attack_timer > 0.08)

func _apply_direction_visual() -> void:
	if _visual == null:
		return
	_visual.region_rect = Rect2(float(facing_index) * CELL_SIZE.x, 0.0, CELL_SIZE.x, CELL_SIZE.y)

func _update_attack_fx(show_fx: bool) -> void:
	if _attack_fx == null:
		return
	_attack_fx.visible = show_fx
	if not show_fx:
		return
	var facing := facing_vector_from_index(facing_index)
	_attack_fx.position = facing * 68.0 + Vector2(0, -48)
	_attack_fx.rotation = facing.angle()
	var alpha := clampf(_attack_timer / ATTACK_COOLDOWN, 0.25, 1.0)
	_attack_fx.modulate = Color(1, 1, 1, alpha)

func _build_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 24)
	collision.shape = shape
	collision.position = Vector2(0, -10)
	add_child(collision)

func _load_player_texture() -> Texture2D:
	var encoded := ""
	for index in range(PLAYER_TEXTURE_CHUNKS):
		var path := "%s%d.txt" % [PLAYER_TEXTURE_SOURCE_PREFIX, index]
		if not FileAccess.file_exists(path):
			push_error("V4 player texture source missing: %s" % path)
			return null
		encoded += FileAccess.get_file_as_string(path).strip_edges()
	var raw := Marshalls.base64_to_raw(encoded)
	var image := Image.new()
	var error := image.load_png_from_buffer(raw)
	if error != OK:
		push_error("V4 player texture decode failed: %s" % error)
		return null
	if image.get_width() != 512 or image.get_height() != 96:
		push_error("V4 player texture has unexpected dimensions")
		return null
	return ImageTexture.create_from_image(image)

func _build_visual() -> void:
	_shadow = Sprite2D.new()
	_shadow.texture = load("res://assets/art_v2/shadow.png")
	_shadow.scale = Vector2(0.78, 0.58)
	_shadow.position = Vector2(0, -2)
	_shadow.z_index = -1
	add_child(_shadow)

	_visual = Sprite2D.new()
	_visual.texture = _load_player_texture()
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.region_enabled = true
	_visual.region_rect = Rect2(0, 0, CELL_SIZE.x, CELL_SIZE.y)
	_visual.centered = false
	_visual.scale = Vector2(ART_SCALE, ART_SCALE)
	_base_visual_position = Vector2(-CELL_SIZE.x * ART_SCALE * 0.5, -93.0 * ART_SCALE)
	_visual.position = _base_visual_position
	add_child(_visual)

	_attack_fx = Sprite2D.new()
	_attack_fx.texture = load(ATTACK_TEXTURE_PATH)
	_attack_fx.scale = Vector2(0.95, 0.95)
	_attack_fx.visible = false
	_attack_fx.z_index = 4
	add_child(_attack_fx)

func _build_camera() -> void:
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.zoom = Vector2(CAMERA_ZOOM, CAMERA_ZOOM)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.5
	camera.limit_left = -950
	camera.limit_right = 950
	camera.limit_top = -670
	camera.limit_bottom = 670
	add_child(camera)
