extends Node2D

export(PackedScene) var orb_scene = preload("res://World/Buff/Buff.tscn")

func _on_OrbTimer_timeout():
	var orb = orb_scene.instance()
	orb.set_position(self.get_position())
	get_tree().get_root().add_child(orb)
