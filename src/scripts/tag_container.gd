@tool
class_name TagContainer
extends Resource

## TagContainer is used to store different tags
##
## It has the following functionality:
## 1. Tags have an associated 'count', essentially a reference count.
##		This allows multiple systems to add the same tag and later remove a 'count' amount of them.
##		This prevents those other systems from breaking due to a tag being removed.
## 2. It integrates with the editor to provide selectable tags
## 3. There's a tag prefix that can be used to filter what tags are allowed to be stored
##		This can be used to limit what tags can be added via the editor, as well as via code
##
## Save/load as a normal resource, or call to_array() or to_dictionary()
##
## Tags are referred to exactly, unless they end in '.*', in which case it is a prefix search
## e.g [example.one, example.two] would match "example.*" but not "example"
##
## Only exact tags can be stored in a container, i.e "example" is okay, but "example.*" is not
## All tags must be defined as constants in the 'Tags' autoload: "res://autoloads/tags.gd"

signal tag_new(tag: StringName)
signal tag_added(tag: StringName, new_count: int)
signal tag_subbed(tag: StringName, new_count: int)
signal tag_deleted(tag: StringName)
signal tags_changed

const _PROPERTY_TAG_PREFIX: StringName = &"__tag_prefix"
const _PROPERTY_TAG_PREFIX_EMPTY: StringName = &" "
const _PROPERTY_ADD_TAG: StringName = &"__add_tag"
const _PROPERTY_TAG: StringName = &"__tags/"

# you should never need to turn this off
static var enforce_tags_exist := true

@export_storage var tag_prefix: StringName = "":
	get:
		return tag_prefix
	set(value):
		if tag_prefix == value:
			return

		if value == _PROPERTY_TAG_PREFIX_EMPTY:
			value = ""

		if value == "":
			tag_prefix = value
			notify_property_list_changed()
			return

		if !value.ends_with(".*"):
			push_error(
				"TagContainer: tried assigning tag_prefix '%s' but that's invalid?" % [value]
			)
			return

		tag_prefix = value

		for tag in _tags.keys():
			if !tag.begins_with(tag_prefix.trim_suffix(".*")):
				delete(tag)

		notify_property_list_changed()

@export_storage var _tags: Dictionary[StringName, int] = {}


static func new_from_dictionary(initial_tags: Dictionary[StringName, int]) -> TagContainer:
	var tags = TagContainer.new()

	for tag in initial_tags:
		tags.add(tag, initial_tags[tag])

	return tags


static func new_from_container(container: TagContainer) -> TagContainer:
	var tags = TagContainer.new()

	tags.tag_prefix = container.tag_prefix
	for tag in container._tags:
		tags.add(tag, container._tags[tag])

	return tags


func _init(initial_tags: Array[StringName] = [], p_tag_prefix: String = "") -> void:
	tag_prefix = p_tag_prefix
	for tag in initial_tags:
		add(tag)

	# e.g each instantiated enemy scene would have its own separate copy of the resource
	# otherwise it would be shared between them all
	resource_local_to_scene = true


func to_array() -> Array[StringName]:
	return _tags.keys()


func to_dictionary() -> Dictionary[StringName, int]:
	return _tags.duplicate(true)


func add(tag: StringName, increment: int = 1):
	assert(increment > 0)
	increment = max(increment, 1)

	if !_is_valid_leaf_tag(tag):
		push_error("TagContainer: failed to add invalid tag '%s" % tag)
		assert(false)
		return

	_tags[tag] = _tags.get(tag, 0) + increment

	var tag_value = _tags[tag]
	if tag_value == increment:
		tag_new.emit(tag)

	tag_added.emit(tag, tag_value)
	tags_changed.emit()
	notify_property_list_changed()


func add_each(tags: Array[StringName], increment: int = 1):
	for tag in tags:
		add(tag, increment)


func sub(tag: StringName, decrement: int = 1):
	assert(decrement > 0)
	decrement = max(decrement, 1)

	if !_is_valid_leaf_tag(tag):
		push_error("TagContainer: failed to sub invalid tag '%s" % tag)
		assert(false)
		return

	_tags[tag] = max(_tags.get(tag, 0) - decrement, 0)

	var tag_value = _tags[tag]
	tag_subbed.emit(tag, tag_value)

	if tag_value == 0:
		delete(tag)
	else:
		tags_changed.emit()
		notify_property_list_changed()

	assert(tag_value >= 0)


func sub_each(tags: Array[StringName], decrement: int = 1):
	for tag in tags:
		sub(tag, decrement)


func delete(tag: StringName):
	assert(!tag.ends_with(".*"))
	assert(!tag.ends_with("."))
	assert(_tag_exists(tag))

	var deleted := _tags.erase(tag)
	if not deleted:
		return

	tag_deleted.emit(tag)
	tags_changed.emit()
	notify_property_list_changed()


func delete_each(tags: Array[StringName]):
	for tag in tags:
		delete(tag)


func clear():
	delete_each(_tags.keys())


func has(tag: StringName) -> bool:
	if !_tag_exists(tag):
		push_error(
			"TagContainer: attempted to check if we contain the tag '%s' but this isn't a tag" % tag
		)
		assert(false)
		return false

	if _tags.has(tag):
		assert(_tags[tag] > 0)
		return _tags[tag] > 0

	# otherwise we asked for an exact match which isn't there
	if !tag.ends_with(".*") || len(tag) < 3:
		return false

	# now we can look for partial matches
	# TODO: cache/precompute partial paths
	tag = tag.trim_suffix(".*")
	for owned_tag in _tags:
		if owned_tag.begins_with(tag):
			assert(_tags[owned_tag] > 0)
			return _tags[owned_tag] > 0

	return false


func count(tag: StringName) -> int:
	assert(!tag.ends_with("."))
	if !_tag_exists(tag):
		assert(false)
		return 0

	if not tag.ends_with(".*"):
		return _tags.get(tag, 0)

	var count := 0
	tag = tag.trim_suffix(".*")
	for owned_tag in _tags:
		if owned_tag.begins_with(tag):
			assert(_tags[owned_tag] > 0)
			count += max(_tags[owned_tag], 0)

	return count


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


func _is_valid_leaf_tag(tag: StringName) -> bool:
	if (
		tag.ends_with(".")
		or tag.ends_with(".*")
		or not tag.begins_with(tag_prefix.trim_suffix(".*"))
	):
		assert(false)
		return false

	return _tag_exists(tag)


func _is_valid_branch_tag(tag: StringName) -> bool:
	if (
		tag.ends_with(".")
		or not tag.ends_with(".*")
		or not tag.begins_with(tag_prefix.trim_suffix(".*"))
	):
		assert(false)
		return false

	return _tag_exists(tag)


func _tag_exists(tag: StringName) -> bool:
	if not enforce_tags_exist:
		return true

	var defined_tags = Tags.get_script().get_script_constant_map()
	var exists: bool = defined_tags.values().has(tag)
	assert(exists)
	return exists


##
## Everything below here affects the inspector/editor
##


func _get_property_list() -> Array[Dictionary]:
	var props: Array[Dictionary] = []

	# We show a property for each tag we contain
	# we use slashes to nest them like a tree
	for tag in _tags:
		props.append(
			{
				"name": _PROPERTY_TAG + tag.replace(".", "/"),
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_EDITOR,
				"hint_string": tag
			}
		)

	var constants = Tags.get_script().get_script_constant_map()
	var available: Array[String] = []
	var available_prefix: Array[String] = []

	# The editor won't show a dropdown if the value is empty, so we use space instead
	if tag_prefix != "":
		available_prefix.append(_PROPERTY_TAG_PREFIX_EMPTY)

	for key in constants:
		var value: String = str(constants[key])
		if (
			!has(value)
			&& !value.ends_with(".*")
			&& (tag_prefix == "" || value.begins_with(tag_prefix.trim_suffix(".*")))
		):
			available.append(value)

		if tag_prefix != value && value.ends_with(".*"):
			available_prefix.append(value)

	props.append(
		{
			"name": _PROPERTY_TAG_PREFIX,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(available_prefix),
			"usage": PROPERTY_USAGE_EDITOR
		}
	)

	if available.is_empty():
		props.append(
			{
				"name": _PROPERTY_ADD_TAG,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
				"hint_string": "None Available",
				"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
			}
		)
	else:
		(
			props
			. append(
				{
					"name": _PROPERTY_ADD_TAG,
					"type": TYPE_STRING,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": ",".join(available),
					"usage": PROPERTY_USAGE_EDITOR,
				}
			)
		)

	return props


func _set(property: StringName, value) -> bool:
	if property == _PROPERTY_TAG_PREFIX:
		tag_prefix = value
		return true

	if property == _PROPERTY_ADD_TAG && value != "":
		if !has(value):
			add(value)
		return true

	if property.begins_with(_PROPERTY_TAG):
		var key := property.trim_prefix(_PROPERTY_TAG).replace("/", ".")
		if has(key) && value == false:
			delete(key)
		return true

	return false


func _get(property: StringName):
	if property == _PROPERTY_TAG_PREFIX:
		if tag_prefix == "":
			return _PROPERTY_TAG_PREFIX_EMPTY

		return tag_prefix

	if property == _PROPERTY_ADD_TAG:
		return ""

	if property.begins_with(_PROPERTY_TAG):
		var key := property.trim_prefix(_PROPERTY_TAG).replace("/", ".")
		if has(key):
			return true

	return null
