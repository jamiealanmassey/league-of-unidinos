extends StaticBody2D

export(PackedScene) var minion_scene = preload("res://Minions/Minion.tscn")

var minion = null

func _on_EnemySpawner_timeout():
	
	minion = minion_scene.instance()
	minion.set_position(self.get_position())
	get_tree().get_root().add_child(minion)

	
	pass # replace with function body
