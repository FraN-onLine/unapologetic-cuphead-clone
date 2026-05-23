extends CharacterBody2D

# =========================
# MOVEMENT
# =========================

const SPEED = 260.0
const JUMP_FORCE = -520.0
const GRAVITY = 1400.0

# =========================
# DASH
# =========================

const DASH_SPEED = 700.0
const DASH_TIME = 0.18

var is_dashing = false
var dash_direction = Vector2.ZERO

# =========================
# SHOOTING
# =========================

@export var bullet_scene: PackedScene

@onready var sprite = $MopheadSprite
@onready var shoot_point = $ShootPoint
@onready var dash_timer = $DashTimer

var facing = 1 # 1 = right, -1 = left


func _physics_process(delta):

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
	# HORIZONTAL MOVEMENT
	# =========================

	var dir = Input.get_axis("left", "right")

	if dir != 0:
		velocity.x = dir * SPEED

		# Face direction
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
	# SHOOT
	# =========================

	if Input.is_action_just_pressed("shoot"):
		shoot()

	# =========================
	# DASH
	# =========================

	if Input.is_action_just_pressed("dash"):
		start_dash()

	move_and_slide()


func shoot():

	if bullet_scene == null:
		return

	var aim = get_aim_direction()

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = shoot_point.global_position

	# send direction to bullet
	bullet.direction = aim.normalized()

	# rotate player toward horizontal aim
	if aim.x != 0:
		facing = sign(aim.x)
		sprite.scale.x = facing


func get_aim_direction() -> Vector2:

	var aim = Vector2.ZERO

	# Vertical
	if Input.is_action_pressed("up"):
		aim.y -= 1

	if Input.is_action_pressed("down"):
		aim.y += 1

	# Horizontal
	if Input.is_action_pressed("left"):
		aim.x -= 1

	if Input.is_action_pressed("right"):
		aim.x += 1

	# If no aiming keys, shoot where facing
	if aim == Vector2.ZERO:
		aim.x = facing

	return aim.normalized()


func start_dash():

	is_dashing = true

	var aim = get_aim_direction()

	# If no input, dash where facing
	if aim == Vector2.ZERO:
		aim = Vector2(facing, 0)

	dash_direction = aim.normalized()

	dash_timer.start(DASH_TIME)


func _on_dash_timer_timeout():
	is_dashing = false
