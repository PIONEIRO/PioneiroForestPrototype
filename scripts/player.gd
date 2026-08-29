extends CharacterBody2D
class_name ForestPlayer

signal attack_started(direction_index: int, origin: Vector2)

const SPEED := 220.0
const ATTACK_COOLDOWN := 0.30
const CELL_SIZE := Vector2(256.0, 320.0)
const ART_SCALE := 0.58

var facing_index := 0
var _visual: Sprite2D
var _shadow: Sprite2D
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
	z_index = int(global_position.y)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_handle_attack()
	_animate_visual(delta, move_dir.length_squared() > 0.001)

func _handle_attack() -> void:
	var attack_down := Input.is_physical_key_pressed(KEY_SPACE)
	if attack_down and not _attack_was_down and _attack_timer <= 0.0:
		_attack_timer = ATTACK_COOLDOWN
		attack_started.emit(facing_index, global_position)
	_attack_was_down = attack_down

func _animate_visual(delta: float, moving: bool) -> void:
	if _visual == null:
		return
	_walk_phase += delta * (13.0 if moving else 3.0)
	var bob := sin(_walk_phase) * (2.2 if moving else 0.7)
	var attack_lift := 0.0
	if _attack_timer > ATTACK_COOLDOWN * 0.55:
		attack_lift = 4.0
	_visual.position = _base_visual_position + Vector2(0, bob - attack_lift)
	_visual.rotation = sin(_walk_phase * 0.5) * (0.012 if moving else 0.004)
	_apply_direction_visual()

func _apply_direction_visual() -> void:
	if _visual == null:
		return
	_visual.region_rect = Rect2(float(facing_index) * CELL_SIZE.x, 0.0, CELL_SIZE.x, CELL_SIZE.y)

func _build_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(30, 22)
	collision.shape = shape
	collision.position = Vector2(0, -10)
	add_child(collision)

func _build_visual() -> void:
	_shadow = Sprite2D.new()
	_shadow.texture = load("res://assets/art/shadow.svg")
	_shadow.scale = Vector2(0.54, 0.44)
	_shadow.position = Vector2(0, -2)
	_shadow.z_index = -1
	add_child(_shadow)

	_visual = Sprite2D.new()
	_visual.texture = load("res://assets/art/player_ranger_8dir.svg")
	_visual.region_enabled = true
	_visual.region_rect = Rect2(0, 0, CELL_SIZE.x, CELL_SIZE.y)
	_visual.centered = false
	_visual.scale = Vector2(ART_SCALE, ART_SCALE)
	_base_visual_position = Vector2(-128.0 * ART_SCALE, -292.0 * ART_SCALE)
	_visual.position = _base_visual_position
	add_child(_visual)

func _build_camera() -> void:
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.zoom = Vector2(1.12, 1.12)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6.0
	camera.limit_left = -1120
	camera.limit_right = 1120
	camera.limit_top = -820
	camera.limit_bottom = 820
	add_child(camera)
