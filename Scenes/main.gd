# Main.gd (root: Node2D)
extends Node2D

@export var coin_count: int = 10
@export var spawn_margin: Vector2 = Vector2(32, 32)
@export var coin_scene: PackedScene = preload("res://Scenes/Coin.tscn")
@export var pickup_sound: AudioStream  # <— assign your OGG/WAV in the Inspector

@onready var score_label: Label = $HUD/ScoreLabel

var score: int = 0
var rng := RandomNumberGenerator.new()
var coins_alive: int = 0

func _ready() -> void:
	rng.randomize()
	# Connect any coins already in the tree (optional)
	for coin in get_tree().get_nodes_in_group("coins"):
		if coin.has_signal("picked_up"):
			coin.picked_up.connect(_on_coin_picked)
			coins_alive += 1

	if coins_alive == 0:
		_spawn_coins(coin_count)

func _spawn_coins(count: int) -> void:
	var area := _get_spawn_rect()
	for i in count:
		var coin := coin_scene.instantiate()
		coin.position = Vector2(
			rng.randf_range(area.position.x, area.position.x + area.size.x),
			rng.randf_range(area.position.y, area.position.y + area.size.y)
		)
		coin.picked_up.connect(_on_coin_picked)  # now receives a Vector2
		add_child(coin)
		coins_alive += 1

func _get_spawn_rect() -> Rect2:
	var rect := get_viewport_rect()
	rect.position += spawn_margin
	rect.size -= spawn_margin * 2.0
	return rect

func _on_coin_picked(world_pos: Vector2) -> void:
	score += 1
	score_label.text = "Score: %d" % score
	coins_alive -= 1
	_play_pickup_sound(world_pos)

	if coins_alive <= 0:
		_spawn_coins(coin_count)

func _play_pickup_sound(at_pos: Vector2) -> void:
	if pickup_sound == null:
		return
	var p := AudioStreamPlayer2D.new()
	p.stream = pickup_sound
	p.position = at_pos
	add_child(p)
	p.play()
	p.finished.connect(func(): p.queue_free())
