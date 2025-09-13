extends GutTest

var test_rng: RandomNumberGenerator


func before_each() -> void:
	RngUtils.global_rng = RandomNumberGenerator.new()
	RngUtils.global_rng.seed = 1234
	test_rng = RandomNumberGenerator.new()
	test_rng.seed = 1234


func test_chancef() -> void:
	assert_eq(RngUtils.chancef(0.1), false)


func test_chance100() -> void:
	assert_eq(RngUtils.chance100(60), true)


func test_chancef_rng() -> void:
	assert_eq(RngUtils.chancef_rng(0.1, test_rng), false)


func test_chance100_rng() -> void:
	assert_eq(RngUtils.chance100_rng(60, test_rng), true)


func test_chance100_or_rng() -> void:
	assert_eq(RngUtils.chance100_or_rng(10, 5, test_rng), true)


func test_chance100_seq_rng() -> void:
	assert_eq(RngUtils.chance100_seq_rng(80, test_rng), 5)


func test_multi_chance100_rng() -> void:
	assert_eq(RngUtils.multi_chance100_rng(80, test_rng), 3)
