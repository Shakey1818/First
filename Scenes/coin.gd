extends Area2D

signal picked_up(pos: Vector2)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		picked_up.emit(global_position)
		queue_free()
