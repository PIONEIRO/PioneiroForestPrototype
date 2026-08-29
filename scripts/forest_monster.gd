extends CharacterBody2D
class_name ForestMonster

enum State { IDLE, WANDER, CHASE, HURT, DEAD }

const DEPTH_BASE := 6000
const PROFILES := {
	"slime": {"max_health": 3, "move_speed": 82.0, "detection_radius": 260.0, "home_radius": 190.0, "texture": "res://assets/art_v2/monster_slime.png", "scale": 0.96},
	"boar": {"max_health": 5, "move_speed": 112.0, "detection_radius": 340.0, "home_radius": 230.0, "texture": "res://assets/art_v2/monster_boar.png", "scale": 0.96}
}

var monster_kind := "slime"
var max_health := 3
var current_health := 3
var move_speed := 82.0
var detection_radius := 260.0
var home_radius := 190.0
var state: State = State.IDLE

var _player: Node2D
var _home_position := Vector2.ZERO
var _wander_goal := Vector2.ZERO
var _state_timer := 1.2
var _sprite: Sprite2D
var _base_sprite_y := 0.0
var _health_fill: ColorRect
var _rng := RandomNumberGenerator.new()
var _anim_phase := 0.0

func get_supported_states() -> Array[String]:
	return ["IDLE", "WANDER", "CHASE", "HURT", "DEAD"]

func get_profile(kind: String) -> Dictionary:
	var profile: Dictionary = PROFILES.get(kind, {})
	return profile.duplicate(true)

func depth_index_for_y(world_y: float) -> int:
	return DEPTH_BASE + int(round(world_y))

func configure(kind: String, player: Node2D) -> void:
	monster_kind = kind if PROFILES.has(kind) else "slime"
	_player = player
	var profile: Dictionary = PROFILES[monster_kind]
	max_health = int(profile["max_health"])
	current_health = max_health
	move_speed = float(profile["move_speed"])
	detection_radius = float(profile["detection_radius"])
	home_radius = float(profile["home_radius"])

func _ready() -> void:
	add_to_group("forest_monsters")
	collision_layer = 4
	collision_mask = 1
	_home_position = global_position
	_rng.seed = int(get_instance_id()) * 92821 + 17
	_build_collision()
	_build_visual()
	_build_health_bar()
	_state_timer = _rng.randf_range(0.7, 1.8)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	z_index = depth_index_for_y(global_position.y)
	_state_timer -= delta
	_anim_phase += delta * (7.5 if monster_kind == "slime" else 9.0)
	_update_visual_motion()

	if state != State.HURT and _player != null and is_instance_valid(_player):
		var distance := global_position.distance_to(_player.global_position)
		if distance <= detection_radius:
			state = State.CHASE
		elif state == State.CHASE and distance > detection_radius * 1.35:
			state = State.IDLE
			_state_timer = 0.8

	match state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _state_timer <= 0.0:
				_choose_wander_goal()
				state = State.WANDER
		State.WANDER:
			var to_goal := _wander_goal - global_position
			if to_goal.length() < 18.0 or _state_timer <= 0.0:
				state = State.IDLE
				_state_timer = _rng.randf_range(0.7, 1.6)
				velocity = Vector2.ZERO
			else:
				velocity = to_goal.normalized() * move_speed * 0.65
				move_and_slide()
		State.CHASE:
			if _player != null and is_instance_valid(_player):
				var to_player := _player.global_position - global_position
				if to_player.length() > 34.0:
					velocity = to_player.normalized() * move_speed
					move_and_slide()
				else:
					velocity = Vector2.ZERO
		State.HURT:
			velocity = velocity.move_toward(Vector2.ZERO, 820.0 * delta)
			move_and_slide()
			if _state_timer <= 0.0:
				state = State.IDLE
				_state_timer = 0.35
				if _sprite != null:
					_sprite.modulate = Color.WHITE

func take_hit(damage: int, origin: Vector2) -> void:
	if state == State.DEAD:
		return
	current_health = maxi(0, current_health - damage)
	_update_health_bar()
	if current_health <= 0:
		_die()
		return
	state = State.HURT
	_state_timer = 0.18
	var knock_dir := (global_position - origin).normalized()
	if knock_dir == Vector2.ZERO:
		knock_dir = Vector2.DOWN
	velocity = knock_dir * 165.0
	if _sprite != null:
		_sprite.modulate = Color(1.0, 0.62, 0.62)

func is_dead() -> bool:
	return state == State.DEAD

func _choose_wander_goal() -> void:
	var angle := _rng.randf_range(0.0, TAU)
	var radius := _rng.randf_range(home_radius * 0.3, home_radius)
	_wander_goal = _home_position + Vector2(cos(angle), sin(angle) * 0.72) * radius
	_state_timer = _rng.randf_range(1.8, 3.6)

func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.45)
	tween.tween_property(self, "scale", Vector2(0.72, 0.72), 0.45)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _build_collision() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 22) if monster_kind == "slime" else Vector2(46, 26)
	collision.shape = shape
	collision.position = Vector2(0, -8)
	add_child(collision)

func _build_visual() -> void:
	var shadow := Sprite2D.new()
	shadow.texture = load("res://assets/art_v2/shadow.png")
	shadow.scale = Vector2(0.55, 0.42) if monster_kind == "slime" else Vector2(0.78, 0.50)
	shadow.position = Vector2(0, -1)
	shadow.z_index = -1
	add_child(shadow)

	var profile: Dictionary = PROFILES[monster_kind]
	_sprite = Sprite2D.new()
	_sprite.texture = load(str(profile["texture"]))
	var art_scale := float(profile["scale"])
	_sprite.scale = Vector2(art_scale, art_scale)
	_base_sprite_y = -float(_sprite.texture.get_height()) * art_scale * 0.5
	_sprite.position = Vector2(0, _base_sprite_y)
	add_child(_sprite)

func _build_health_bar() -> void:
	var back := ColorRect.new()
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.color = Color(0.06, 0.05, 0.04, 0.88)
	back.position = Vector2(-29, -79 if monster_kind == "slime" else -87)
	back.size = Vector2(58, 7)
	add_child(back)
	_health_fill = ColorRect.new()
	_health_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_fill.color = Color(0.49, 0.83, 0.31, 0.96)
	_health_fill.position = Vector2(2, 2)
	_health_fill.size = Vector2(54, 3)
	back.add_child(_health_fill)
	_update_health_bar()

func _update_health_bar() -> void:
	if _health_fill == null:
		return
	var ratio := float(current_health) / maxf(1.0, float(max_health))
	_health_fill.size.x = 54.0 * ratio

func _update_visual_motion() -> void:
	if _sprite == null:
		return
	var amplitude := 2.0 if state == State.CHASE else 0.9
	_sprite.position.y = _base_sprite_y + sin(_anim_phase) * amplitude
	if velocity.x != 0.0:
		_sprite.flip_h = velocity.x < 0.0
