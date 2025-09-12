extends "res://addons/gut/test.gd"


func test_add_and_has():
	var tc = TagContainer.new()
	tc.add("foo")
	assert_true(tc.has("foo"))
	assert_false(tc.has("bar"))


func test_add_multiple_increments():
	var tc = TagContainer.new()
	tc.add("foo")
	tc.add("foo", 2)
	assert_true(tc.has("foo"))

	tc.sub("foo", 2)
	assert_true(tc.has("foo"))

	tc.sub("foo", 1)
	assert_false(tc.has("foo"))


func test_add_initial():
	var tc = TagContainer.new()
	tc.add_initial("foo")
	assert_true(tc.has("foo"))


func test_delete():
	var tc = TagContainer.new()
	tc.add("foo", 3)
	tc.delete("foo")
	assert_false(tc.has("foo"))


func test_to_array_returns_all_tags():
	var tc = TagContainer.new()
	tc.add("foo")
	tc.add("bar")
	var arr = tc.to_array()
	assert_true("foo" in arr)
	assert_true("bar" in arr)


func test_has_any():
	var tc = TagContainer.new()
	tc.add("foo")
	assert_true(tc.has_any(["foo", "bar"]))
	assert_false(tc.has_any(["baz"]))


func test_has_all():
	var tc = TagContainer.new()
	tc.add("foo")
	tc.add("bar")
	assert_true(tc.has_all(["foo", "bar"]))
	assert_false(tc.has_all(["foo", "baz"]))


func test_hierarchical_has():
	var tc = TagContainer.new()
	tc.add("player.mage.fireball")

	assert_true(tc.has("player.*"))
	assert_true(tc.has("player.mage.*"))
	assert_true(tc.has("player.mage.fireball"))
	assert_false(tc.has("player.archer.*"))
	assert_false(tc.has("mage.*"))
	assert_false(tc.has("player"))


func test_add_each_and_sub_each():
	var tc = TagContainer.new()
	tc.add_each(["foo", "bar"])
	assert_true(tc.has("foo"))
	assert_true(tc.has("bar"))

	tc.sub_each(["foo", "bar"])
	assert_false(tc.has("foo"))
	assert_false(tc.has("bar"))


func test_delete_each():
	var tc = TagContainer.new()
	tc.add("foo")
	tc.add("bar")
	tc.delete_each(["foo", "bar"])
	assert_false(tc.has("foo"))
	assert_false(tc.has("bar"))


func test_to_and_from_dictionary():
	var tc = TagContainer.new()
	tc.add("foo", 2)
	tc.add("bar", 1)

	var d = tc.to_dictionary()
	assert_eq(d["foo"], 2)
	assert_eq(d["bar"], 1)

	var tc2 = TagContainer.new_from_dictionary(d)
	assert_true(tc2.has("foo"))
	assert_true(tc2.has("bar"))
	assert_eq(tc2.get_count("foo"), 2)


func test_new_from_container():
	var tc = TagContainer.new()
	tc.add("foo", 3)
	var tc2 = TagContainer.new_from_container(tc)

	assert_true(tc2.has("foo"))
	assert_eq(tc2.get_count("foo"), 3)


func test_signals_are_emitted():
	var tc = TagContainer.new()
	var added = []
	var deleted = []
	var subbed = []
	var new_tags = []

	tc.tag_added.connect(func(tag, value): added.append([tag, value]))
	tc.tag_deleted.connect(func(tag): deleted.append(tag))
	tc.tag_subbed.connect(func(tag, value): subbed.append([tag, value]))
	tc.tag_new.connect(func(tag): new_tags.append(tag))

	tc.add("foo")
	tc.add("foo")
	tc.sub("foo")
	tc.sub("foo")
	tc.add("bar")

	assert_eq(new_tags, [&"foo", &"bar"])
	assert_eq(added, [[&"foo", 1], [&"foo", 2], [&"bar", 1]])
	assert_eq(subbed, [[&"foo", 1], [&"foo", 0]])
	assert_eq(deleted, [&"foo"])
