## Random number generator static utility class.
class_name RngUtils

static var global_rng


static func get_global_rng() -> RandomNumberGenerator:
	if global_rng == null:
		set_global_rng()
	return global_rng


static func set_global_rng() -> void:
	global_rng = RandomNumberGenerator.new()
	global_rng.randomize()


## Returns bool [code]true[/code] if [param c] is greater than a random value
## between 0.0 and 1.0, bool [code]false[/code] otherwise.
static func chancef(c: float) -> bool:
	return chancef_rng(c, get_global_rng())


static func chancef_rng(c: float, rng: RandomNumberGenerator) -> bool:
	return c > rng.randf()


## Returns [code]true[/code] if [param c] divided by 100 is greater than a
## random value between 0.0 and 1.0, [code]false[/code] otherwise.[br]
## For example:[br]
## [codeblock]
## if chance100(25):
##     print("25% chance to hit")
## [/codeblock]
static func chance100(c: float) -> bool:
	return chance100_rng(c, get_global_rng())


static func chance100_rng(c: float, rng: RandomNumberGenerator) -> bool:
	return chancef_rng(c / 100.0, rng)


## Returns [code]true[/code] if [param c] divided by 100 is greater than a
## random value between 0.0 and 1.0 at least once within [param n] number of
## tries, [code]false[/code] otherwise.
static func chance100_or(c: float, n: int) -> bool:
	return chance100_or_rng(c, n, get_global_rng())


static func chance100_or_rng(c: float, n: int, rng: RandomNumberGenerator) -> bool:
	for i in n:
		if chance100_rng(c, rng):
			return true
	return false


## Returns the number of consecutive times [param c] divided by 100 is
## greater than a new random value between 0.0 and 1.0 each time. The value of
## [param c] must be less than 100.
static func chance100_seq(c: float) -> bool:
	return chance100_seq_rng(c, get_global_rng())


static func chance100_seq_rng(c: float, rng: RandomNumberGenerator) -> int:
	assert(c < 100)
	var ctr: int = 0
	while chance100_rng(c, rng):
		ctr += 1
	return ctr


## Returns the number of consecutive times [param c] is greater than a new random
## value between 0.0 and 100.0 when reducing [param c] by that random value
## upon each iteration. Also known as [i]meaningful chances > 100%[/i].


static func multi_chance100(c: float) -> int:
	return multi_chance100_rng(c, get_global_rng())


static func multi_chance100_rng(c: float, rng: RandomNumberGenerator) -> int:
	var ctr := 0
	var total_chance: float = c
	while true:
		var r: float = rng.randf() * 100
		if r < total_chance:
			ctr += 1
			total_chance -= r
		else:
			break

	return ctr


## Same as [method Array.pick_random] method but using the [RandomNumberGenerator] [param rng].
static func pick_random_rng(arr: Array, rng: RandomNumberGenerator):
	return arr[rng.randi() % arr.size()]


## Same as [method Array.shuffle] but using the [RandomNumberGenerator] [param rng].
static func shuffle_rng(arr: Array, rng: RandomNumberGenerator) -> Array:
	var source_arr = arr.duplicate()
	var result := []
	while not source_arr.is_empty():
		var idx = rng.randi() % source_arr.size()
		result.append(source_arr[idx])
		source_arr.remove_at(idx)
	return result
