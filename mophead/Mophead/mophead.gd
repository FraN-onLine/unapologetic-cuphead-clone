extends CharacterBody2D

# =========================
# MOVEMENT
# =========================

const SPEED = 220.0
const JUMP_FORCE = -500.0
const GRAVITY = 1400.0

# =========================
# DASH
# =========================

const DASH_SPEED = 650.0
const DASH_TIME = 0.18
const DASH_COOLDOWN = 0.6

var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_cooldown_timer = 0.0

# =========================
# WEAPONS
# =========================

@export var blue_bullet_scene: PackedScene
@export var pink_bullet_scene: PackedScene

enum WeaponType {
	BLUE,
	PINK
}

var current_weapon = WeaponType.BLUE

var shoot_timer = 0.0

# =========================
# NODES
# =========================

@onready var sprite = $MopheadSprite
@onready var shoot_point = $ShootPoint
@onready var dash_timer = $DashTimer

# =========================
# STATE
# =========================

var facing = 1


func _physics_process(delta):

	# =========================
	# TIMERS
	# =========================

	if shoot_timer > 0:
		shoot_timer -= delta

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# =========================
	# GRAVITY
	# =========================

	if not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta

	# =========================
	# DASHING
	# =========================

	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		return

	# =========================
	# MOVE
	# =========================

	var dir = Input.get_axis("left", "right")

	if dir != 0:

		velocity.x = dir * SPEED

		facing = sign(dir)

		sprite.scale.x = facing

	else:

		velocity.x = move_toward(velocity.x, 0, SPEED)

	# =========================
	# JUMP
	# =========================

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# =========================
	# SHOOTING
	# =========================

	handle_shooting()

	# =========================
	# DASH
	# =========================

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		start_dash()

	# =========================
	# SWITCH WEAPON
	# =========================

	if Input.is_action_just_pressed("switch"):
		switch_weapon()

	move_and_slide()


func handle_shooting():

	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		fire_weapon()


func fire_weapon():

	match current_weapon:

		WeaponType.BLUE:
			fire_blue()

		WeaponType.PINK:
			fire_pink()


func fire_blue():

	var bullet = blue_bullet_scene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = shoot_point.global_position

	var aim = get_aim_direction()

	bullet.direction = aim.normalized()

	shoot_timer = bullet.fire_rate

	# face toward horizontal aim
	if aim.x != 0:
		facing = sign(aim.x)
		sprite.scale.x = facing


func fire_pink():

	var aim = get_aim_direction()

	var spread_angles = [-10, 0, 10]

	for angle_deg in spread_angles:

		var bullet = pink_bullet_scene.instantiate()

		get_tree().current_scene.add_child(bullet)

		bullet.global_position = shoot_point.global_position

		var dir = aim.rotated(deg_to_rad(angle_deg))

		bullet.direction = dir.normalized()

	# get firerate from temporary bullet
	var temp_bullet = pink_bullet_scene.instantiate()
	shoot_timer = temp_bullet.fire_rate
	temp_bullet.queue_free()

	# face toward horizontal aim
	if aim.x != 0:
		facing = sign(aim.x)
		sprite.scale.x = facing


func switch_weapon():

	if current_weapon == WeaponType.BLUE:
		current_weapon = WeaponType.PINK
	else:
		current_weapon = WeaponType.BLUE

	print("Current Weapon: ", current_weapon)


func get_aim_direction() -> Vector2:

	var aim = Vector2.ZERO

	# =========================
	# VERTICAL
	# =========================

	if Input.is_action_pressed("up"):
		aim.y -= 1

	if Input.is_action_pressed("down"):
		aim.y += 1

	# =========================
	# HORIZONTAL
	# =========================

	if Input.is_action_pressed("left"):
		aim.x -= 1

	if Input.is_action_pressed("right"):
		aim.x += 1

	# =========================
	# DEFAULT TO FACING
	# =========================

	if aim == Vector2.ZERO:
		aim.x = facing

	return aim.normalized()


func start_dash():

	is_dashing = true

	var aim = get_aim_direction()

	# =========================
	# NO UPWARD DASHES
	# =========================

	# straight up
	if aim.y < 0 and aim.x == 0:
		aim = Vector2(facing, 0)

	# upper diagonals become horizontal
	if aim.y < 0 and aim.x != 0:
		aim = Vector2(sign(aim.x), 0)

	# fallback
	if aim == Vector2.ZERO:
		aim = Vector2(facing, 0)

	dash_direction = aim.normalized()

	dash_cooldown_timer = DASH_COOLDOWN

	dash_timer.start(DASH_TIME)


func _on_dash_timer_timeout():

	is_dashing = false
