extends Node

var Class_ArrayAndOrDictionary = load("res://Class/Class_ArrayAndOrDictionary.gd").new()

func test_full_correctness():
	print("\n===== TEST FULL CORRECTNESS =====")

	var tests = [
		# +
		{
			"name": "equal",
			"a": {"x": 1},
			"b": {"x": 1},
			"expected": "+"
		},

		# -
		{
			"name": "value_diff",
			"a": {"x": 1},
			"b": {"x": 2},
			"expected": "-"
		},

		# >
		{
			"name": "only_in_a",
			"a": {"x": 1},
			"b": {},
			"expected_child": { "x": ">" }
		},

		# <
		{
			"name": "only_in_b",
			"a": {},
			"b": {"x": 1},
			"expected_child": { "x": "<" }
		},

		# ~ (оба есть, но внутри изменения)
		{
			"name": "nested_diff",
			"a": {"x": {"y": 1}},
			"b": {"x": {"y": 2}},
			"expected": "~"
		},

		# массивы одинаковые
		{
			"name": "array_equal",
			"a": {"arr": [1,2]},
			"b": {"arr": [1,2]},
			"expected": "+"
		},

		# массивы разные
		{
			"name": "array_diff",
			"a": {"arr": [1,2]},
			"b": {"arr": [1,3]},
			"expected": "~"
		},

		# сложный кейс (~-, ~>, ~<)
		{
			"name": "complex_mix",
			"a": {"a": 1, "b": 2},
			"b": {"a": 1, "c": 3},
			"expected": "~"
		}
	]

	for t in tests:
		var result = {}
		Class_ArrayAndOrDictionary.fC_ComparisonsOf2Variables_0101(t["a"], t["b"], result)

		print("--- ", t["name"], " ---")
		print(result)

		# проверка root result
		if t.has("expected"):
			assert(result.has("result"))
			assert(result["result"] == t["expected"], "FAIL: " + t["name"])

		# проверка child
		if t.has("expected_child"):
			for k in t["expected_child"]:
				assert(result["Child"].has(k), "Missing key " + k)
				assert(
					result["Child"][k]["result"] == t["expected_child"][k],
					"Wrong result for " + k
				)

	print("\n✅ ALL CORRECTNESS TESTS PASSED")

func test_performance():
	print("\n===== TEST PERFORMANCE =====")
	Time.get_ticks_usec()

	var iterations = 1000

	# генерим сложные структуры
	var a = _generate_big_dict(4, 4)
	var b = _generate_big_dict(4, 4)

	var start_time = Time.get_ticks_usec()

	for i in range(iterations):
		var result = {}
		Class_ArrayAndOrDictionary.fC_ComparisonsOf2Variables_0101(a, b, result)

	var end_time = Time.get_ticks_usec()

	var total_time = end_time - start_time
	var avg_time = float(total_time) / iterations

	print("Iterations: ", iterations)
	print("Total time (usec): ", total_time)
	print("Avg time (usec): ", avg_time)
	print("Avg time (ms): ", avg_time / 1000.0)

	print("\n✅ PERFORMANCE TEST DONE")

func _generate_big_dict(depth: int, width: int):
	if depth == 0:
		return randi() % 100

	var d = {}

	for i in range(width):
		var key = "k_" + str(depth) + "_" + str(i)

		if randi() % 2 == 0:
			d[key] = _generate_big_dict(depth - 1, width)
		else:
			var arr = []
			for j in range(width):
				arr.append(_generate_big_dict(depth - 1, width))
			d[key] = arr

	return d

func _ready() -> void:
	test_full_correctness()
	test_performance()
