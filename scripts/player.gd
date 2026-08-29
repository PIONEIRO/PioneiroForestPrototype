extends CharacterBody2D
class_name ForestPlayer

signal attack_started(direction_index: int, origin: Vector2)

const VISUAL_VERSION := 5
const WEAPON_CLASS := "TWO_HANDED_LONGSWORD"
const DEPTH_BASE := 2048
const PLAYER_TEXTURE_SOURCE_PREFIX := "res://assets/art_v4/warrior_greatsword_simple_8dir.b64."
const PLAYER_TEXTURE_CHUNKS := 6
const SOURCE_CELL_SIZE := Vector2(64.0, 96.0)
const CELL_SIZE := Vector2(96.0, 96.0)
const WALK_FRAMES := 4
const ATTACK_FRAMES := 6
const WALK_FPS := 8.0
const ATTACK_FPS := 13.0
const SPEED := 220.0
const ATTACK_COOLDOWN := 0.46
const ART_SCALE := 1.12
const CAMERA_ZOOM := 1.32

var facing_index := 0
var _visual: Sprite2D
var _shadow: Sprite2D
var _base_visual_position := Vector2.ZERO
var _attack_was_down := false
var _attack_timer := 0.0
var _walk_time := 0.0
var _state := "idle"
var _frame := 0
var _idle_texture: Texture2D
var _walk_texture: Texture2D
var _attack_texture: Texture2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_build_collision()
	_build_animation_textures()
	_build_visual()
	_build_camera()
	_apply_frame()

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
	var moving := move_dir.length_squared() > 0.001
	if moving:
		facing_index = direction_index_from_vector(move_dir)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	z_index = depth_index_for_y(global_position.y)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_handle_attack()
	_animate_visual(delta, moving)

func _handle_attack() -> void:
	var attack_down := Input.is_physical_key_pressed(KEY_SPACE)
	if attack_down and not _attack_was_down and _attack_timer <= 0.0:
		_attack_timer = ATTACK_COOLDOWN
		_state = "attack"
		_frame = 0
		attack_started.emit(facing_index, global_position)
	_attack_was_down = attack_down

func _animate_visual(delta: float, moving: bool) -> void:
	if _visual == null:
		return
	if _attack_timer > 0.0:
		_state = "attack"
		var attack_elapsed := ATTACK_COOLDOWN - _attack_timer
		_frame = mini(ATTACK_FRAMES - 1, int(floor(attack_elapsed * ATTACK_FPS)))
		_visual.position = _base_visual_position + facing_vector_from_index(facing_index) * minf(2.0, attack_elapsed * 8.0)
	else:
		if moving:
			_state = "walk"
			_walk_time += delta
			_frame = int(floor(_walk_time * WALK_FPS)) % WALK_FRAMES
			var bob := -1.0 if _frame in [1, 3] else 0.0
			_visual.position = _base_visual_position + Vector2(0, bob)
		else:
			_state = "idle"
			_frame = 0
			_walk_time = 0.0
			_visual.position = _base_visual_position
	_apply_frame()

func _apply_frame() -> void:
	if _visual == null:
		return
	match _state:
		"walk": _visual.texture = _walk_texture
		"attack": _visual.texture = _attack_texture
		_: _visual.texture = _idle_texture
	_visual.region_rect = Rect2(float(facing_index) * CELL_SIZE.x, float(_frame) * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)

func _build_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 24)
	collision.shape = shape
	collision.position = Vector2(0, -10)
	add_child(collision)

func _load_source_image() -> Image:
	var encoded := ""
	for index in range(PLAYER_TEXTURE_CHUNKS):
		var path := "%s%d.txt" % [PLAYER_TEXTURE_SOURCE_PREFIX, index]
		if not FileAccess.file_exists(path):
			push_error("V5 player source missing: %s" % path)
			return null
		encoded += FileAccess.get_file_as_string(path).strip_edges()
	var raw := Marshalls.base64_to_raw(encoded)
	var image := Image.new()
	var error := image.load_png_from_buffer(raw)
	if error != OK:
		push_error("V5 player source decode failed: %s" % error)
		return null
	if image.get_width() != 512 or image.get_height() != 96:
		push_error("V5 player source has unexpected dimensions")
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image

func _build_animation_textures() -> void:
	var source := _load_source_image()
	if source == null:
		return
	var idle := Image.create_empty(int(CELL_SIZE.x) * 8, int(CELL_SIZE.y), false, Image.FORMAT_RGBA8)
	var walk := Image.create_empty(int(CELL_SIZE.x) * 8, int(CELL_SIZE.y) * WALK_FRAMES, false, Image.FORMAT_RGBA8)
	var attack := Image.create_empty(int(CELL_SIZE.x) * 8, int(CELL_SIZE.y) * ATTACK_FRAMES, false, Image.FORMAT_RGBA8)
	idle.fill(Color(0,0,0,0))
	walk.fill(Color(0,0,0,0))
	attack.fill(Color(0,0,0,0))
	for direction in range(8):
		var source_rect := Rect2i(direction * int(SOURCE_CELL_SIZE.x), 0, int(SOURCE_CELL_SIZE.x), int(SOURCE_CELL_SIZE.y))
		var base_x := direction * int(CELL_SIZE.x) + 16
		idle.blit_rect(source, source_rect, Vector2i(base_x, 0))
		_draw_weapon(idle, direction, 0, 0.0, false)
		for frame in range(WALK_FRAMES):
			var y := frame * int(CELL_SIZE.y)
			walk.blit_rect(source, source_rect, Vector2i(base_x, y))
			_draw_walk_legs(walk, direction, frame, y)
			_draw_weapon(walk, direction, y, 0.0, false)
		for frame in range(ATTACK_FRAMES):
			var y := frame * int(CELL_SIZE.y)
			var lunge := facing_vector_from_index(direction) * float([0,1,2,3,2,0][frame])
			attack.blit_rect(source, source_rect, Vector2i(base_x + int(round(lunge.x)), y + int(round(lunge.y))))
			var swing := [-1.05, -0.65, -0.25, 0.18, 0.58, 0.88][frame]
			_draw_weapon(attack, direction, y, swing, true)
	_idle_texture = ImageTexture.create_from_image(idle)
	_walk_texture = ImageTexture.create_from_image(walk)
	_attack_texture = ImageTexture.create_from_image(attack)

func _draw_walk_legs(image: Image, direction: int, frame: int, y_offset: int) -> void:
	var center_x := direction * int(CELL_SIZE.x) + 48
	var stride := [3, 1, -3, -1][frame]
	var boot_y := y_offset + 82
	_draw_disc(image, center_x - 7 + stride, boot_y, 4, Color("#3b261c"))
	_draw_disc(image, center_x + 7 - stride, boot_y + (1 if frame in [1,3] else 0), 4, Color("#4c2f1e"))
	_draw_line(image, Vector2i(center_x - 5, boot_y - 10), Vector2i(center_x - 7 + stride, boot_y - 2), Color("#20252b"), 3)
	_draw_line(image, Vector2i(center_x + 5, boot_y - 10), Vector2i(center_x + 7 - stride, boot_y - 2), Color("#20252b"), 3)

func _draw_weapon(image: Image, direction: int, y_offset: int, swing_offset: float, attacking: bool) -> void:
	var facing := facing_vector_from_index(direction)
	var facing_angle := atan2(facing.y, facing.x)
	var theta := facing_angle - 1.42 + swing_offset
	var center := Vector2(direction * int(CELL_SIZE.x) + 48, y_offset + 50)
	var handle := center + Vector2(cos(theta), sin(theta)) * 5.0
	var tip := center + Vector2(cos(theta), sin(theta)) * (43.0 if attacking else 37.0)
	var perp := Vector2(-sin(theta), cos(theta))
	_draw_line(image, Vector2i(handle - Vector2(cos(theta), sin(theta)) * 3.0), Vector2i(tip), Color("#10151b"), 5)
	_draw_line(image, Vector2i(handle), Vector2i(tip), Color("#c9d4dc"), 3)
	_draw_line(image, Vector2i(handle + Vector2(1,0)), Vector2i(tip + Vector2(1,0)), Color("#f5f7f5"), 1)
	_draw_line(image, Vector2i(handle + perp * 6.0), Vector2i(handle - perp * 6.0), Color("#c89b42"), 3)
	var grip_end := handle - Vector2(cos(theta), sin(theta)) * 10.0
	_draw_line(image, Vector2i(handle), Vector2i(grip_end), Color("#5a341f"), 4)
	_draw_disc(image, int(round(handle.x - cos(theta) * 2.0)), int(round(handle.y - sin(theta) * 2.0)), 2, Color("#8c5b35"))
	_draw_disc(image, int(round(handle.x - cos(theta) * 7.0)), int(round(handle.y - sin(theta) * 7.0)), 2, Color("#8c5b35"))
	if attacking:
		var shoulder := center + Vector2(-facing.x * 2.0, -6.0)
		_draw_line(image, Vector2i(shoulder), Vector2i(handle), Color("#77828a"), 4)

func _draw_line(image: Image, start: Vector2i, finish: Vector2i, color: Color, width: int = 1) -> void:
	var x0 := start.x
	var y0 := start.y
	var x1 := finish.x
	var y1 := finish.y
	var dx := absi(x1 - x0)
	var sx := 1 if x0 < x1 else -1
	var dy := -absi(y1 - y0)
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		_draw_disc(image, x0, y0, maxi(0, width / 2), color)
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

func _draw_disc(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	for yy in range(cy - radius, cy + radius + 1):
		for xx in range(cx - radius, cx + radius + 1):
			if xx < 0 or yy < 0 or xx >= image.get_width() or yy >= image.get_height():
				continue
			if Vector2(xx - cx, yy - cy).length_squared() <= radius * radius:
				image.set_pixel(xx, yy, color)

func _build_visual() -> void:
	_shadow = Sprite2D.new()
	_shadow.texture = load("res://assets/art_v2/shadow.png")
	_shadow.scale = Vector2(0.68, 0.50)
	_shadow.position = Vector2(0, -2)
	_shadow.z_index = -1
	add_child(_shadow)

	_visual = Sprite2D.new()
	_visual.texture = _idle_texture
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.region_enabled = true
	_visual.region_rect = Rect2(0, 0, CELL_SIZE.x, CELL_SIZE.y)
	_visual.centered = false
	_visual.scale = Vector2(ART_SCALE, ART_SCALE)
	_base_visual_position = Vector2(-CELL_SIZE.x * ART_SCALE * 0.5, -92.0 * ART_SCALE)
	_visual.position = _base_visual_position
	add_child(_visual)

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
