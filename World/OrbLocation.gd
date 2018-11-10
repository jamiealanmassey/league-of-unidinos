extends Node2D

export(PackedScene) var orb_scene = preload("res://World/Buff/Buff.tscn")

var orb = null

func _on_OrbTimer_timeout():
	if (orb != null):
		orb.queue_free()
	
	orb = orb_scene.instance()
	orb.set_position(self.get_position())
	get_tree().get_root().add_child(orb)

func _check_timer():
	
	