@tool
class_name FlattenHierarchy
extends EditorScript

func _run():
	var selected_nodes := EditorInterface.get_selection().get_selected_nodes()
	for node in selected_nodes:
		if node is Node3D:
			flatten_hierarchy(node, node)
		else:
			print("skipping ", node.name)

func flatten_hierarchy(root: Node3D, parent: Node3D):
	print("flattening ", root.name)
	var meshes_to_reparent = []

	for child in parent.get_children():
		if child is MeshInstance3D:
			print("queued adding %s to %s" % [child.name, root.name])
			meshes_to_reparent.append(child)
		elif child.get_child_count() > 0:
			flatten_hierarchy(root, child)

	for mesh in meshes_to_reparent:
		print("added %s to %s" % [mesh.name, root.name])
		var global_transform = mesh.global_transform
		mesh.get_parent().remove_child(mesh)
		root.add_child(mesh)
		mesh.owner = root.owner
		if mesh.owner == null:
			mesh.owner = root
		print(mesh.owner)
		mesh.global_transform = global_transform
		mesh.name = parent.name
