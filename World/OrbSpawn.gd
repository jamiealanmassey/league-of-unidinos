extends Node2D

export(PackedScene) var orb_scene

func _on_OrbSpawn_timeout():
	var orb = orb_scene.instance()
	orb.set_position(self.get_position())
	self.add_child(orb)
	print(orb.get_position())
