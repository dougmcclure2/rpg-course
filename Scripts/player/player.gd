extends CharacterBody2D

@onready var arrow_scene:PackedScene = preload("res://Scenes/projectiles/arrow.tscn")
@onready var weapon_marker = get_node("weapon")
@export var speed:int = 80

var dying:bool = false
var attacking_melee:bool = false
var attacking_ranged:bool = false

var health:int = 5
var damage:int = 2

func _physics_process(delta: float) -> void:
	
	if not dying:
		weapon_marker.look_at(get_global_mouse_position())
		attack_check(delta)
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("WalkRight") - Input.get_action_strength("WalkLeft")
		input_vector.y = Input.get_action_strength("WalkDown") - Input.get_action_strength("WalkUp")
		
		velocity = input_vector*speed
		move_and_slide()


func _on_melee_body_entered(body: Node2D) -> void:
	# check for damaging monster
	if attacking_melee and body.is_in_group("monster"):
		body.hit(damage)

func attack_check(delta: float):
	if Input.is_action_just_pressed("Attack") and !attacking_melee:
		var target_position: Vector2 = (get_global_mouse_position() - weapon_marker.global_position).normalized()
		melee_attack(target_position)
		var arrow_temp = arrow_scene.instantiate()
		arrow_temp.direction = target_position
		add_child(arrow_temp)
	
func melee_attack(target_pos):
	attacking_melee = true
	var tween = create_tween()
	tween.tween_property(weapon_marker, "position", target_pos*10, 0.2)
	tween.tween_callback(return_default)
	
func return_default():
	var tween = create_tween()
	tween.tween_property(weapon_marker, "position", Vector2.ZERO, 0.2)
	await get_tree().create_timer(0.5).timeout
	attacking_melee = false

func _on_timer_timeout() -> void:
	attacking_ranged = false
