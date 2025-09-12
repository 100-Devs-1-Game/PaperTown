class_name TagContainer
extends RefCounted

signal tag_new(tag: StringName)
signal tag_added(tag: StringName, new_value: int)
signal tag_subbed(tag: StringName, new_value: int)
signal tag_deleted(tag: StringName)
signal tags_changed

var _tags: Dictionary[StringName, int] = {}


static func new_from_dictionary(initial_tags: Dictionary[StringName, int]) -> TagContainer:
	var tags = TagContainer.new()
	for tag in initial_tags:
		tags.add(tag, initial_tags[tag])
	return tags


static func new_from_container(container: TagContainer) -> TagContainer:
	var tags = TagContainer.new()
	for tag in container._tags:
		tags.add(tag, container._tags[tag])
	return tags


func init(initial_tags: Array[StringName] = []) -> void:
	for tag in initial_tags:
		add(tag)


func to_array() -> Array[StringName]:
	return _tags.keys()


func to_dictionary() -> Dictionary[StringName, int]:
	return _tags.duplicate(true)


func add(tag: StringName, increment: int = 1):
	assert(increment > 0)
	assert(!tag.ends_with(".*"))
	assert(!tag.ends_with("."))
	_tags[tag] = _tags.get(tag, 0) + increment

	var tag_value = _tags[tag]
	if tag_value == increment:
		tag_new.emit(tag)

	tag_added.emit(tag, tag_value)
	tags_changed.emit()


func add_each(tags: Array[StringName], increment: int = 1):
	for tag in tags:
		add(tag, increment)


func add_initial(tag: StringName):
	if _tags.get(tag, 0) != 0:
		assert(false)
		print_stack()
		return

	add(tag)


func sub(tag: StringName, decrement: int = 1):
	assert(decrement > 0)
	assert(!tag.ends_with(".*"))
	assert(!tag.ends_with("."))
	_tags[tag] = max(_tags.get(tag, 0) - decrement, 0)

	var tag_value = _tags[tag]
	tag_subbed.emit(tag, tag_value)

	if tag_value == 0:
		delete(tag)
	else:
		tags_changed.emit()


func sub_each(tags: Array[StringName], decrement: int = 1):
	for tag in tags:
		sub(tag, decrement)


func delete(tag: StringName):
	assert(!tag.ends_with(".*"))
	assert(!tag.ends_with("."))

	_tags.erase(tag)
	tag_deleted.emit(tag)
	tags_changed.emit()


func delete_each(tags: Array[StringName]):
	for tag in tags:
		delete(tag)


func clear():
	delete_each(_tags.keys())


func has(tag: StringName) -> bool:
	if _tags.has(tag):
		assert(_tags[tag] > 0)
		return true

	# otherwise we asked for an exact match which isn't there
	if !tag.ends_with(".*") || len(tag) < 3:
		return false

	# now we can look for partial matches
	# TODO: cache/precompute partial paths
	tag = tag.trim_suffix(".*")
	for owned_tag in _tags:
		if owned_tag.begins_with(tag):
			assert(_tags[owned_tag] > 0)
			return true

	return false


func get_count(tag: StringName) -> int:
	assert(!tag.ends_with(".*"))
	assert(!tag.ends_with("."))

	return _tags.get(tag, 0)


func has_any(tags: Array[StringName]) -> bool:
	for tag in tags:
		if has(tag):
			return true

	return false


func has_all(tags: Array[StringName]) -> bool:
	for tag in tags:
		if not has(tag):
			return false

	return true
