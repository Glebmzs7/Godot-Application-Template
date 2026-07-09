extends Node

class_name Class_Help

var TYPE_NAMES := {
	TYPE_NIL: "Nil",
	TYPE_BOOL: "Bool",
	TYPE_INT: "Int",
	TYPE_FLOAT: "Float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_VECTOR2I: "Vector2i",
	TYPE_RECT2: "Rect2",
	TYPE_RECT2I: "Rect2i",
	TYPE_VECTOR3: "Vector3",
	TYPE_VECTOR3I: "Vector3i",
	TYPE_TRANSFORM2D: "Transform2D",
	TYPE_VECTOR4: "Vector4",
	TYPE_VECTOR4I: "Vector4i",
	TYPE_PLANE: "Plane",
	TYPE_QUATERNION: "Quaternion",
	TYPE_AABB: "AABB",
	TYPE_BASIS: "Basis",
	TYPE_TRANSFORM3D: "Transform3D",
	TYPE_COLOR: "Color",
	TYPE_STRING_NAME: "StringName",
	TYPE_NODE_PATH: "NodePath",
	TYPE_RID: "RID",
	TYPE_OBJECT: "Object",
	TYPE_CALLABLE: "Callable",
	TYPE_SIGNAL: "Signal",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_PACKED_BYTE_ARRAY: "PackedByteArray",
	TYPE_PACKED_INT32_ARRAY: "PackedInt32Array",
	TYPE_PACKED_INT64_ARRAY: "PackedInt64Array",
	TYPE_PACKED_FLOAT32_ARRAY: "PackedFloat32Array",
	TYPE_PACKED_FLOAT64_ARRAY: "PackedFloat64Array",
	TYPE_PACKED_STRING_ARRAY: "PackedStringArray",
	TYPE_PACKED_VECTOR2_ARRAY: "PackedVector2Array",
	TYPE_PACKED_VECTOR3_ARRAY: "PackedVector3Array",
	TYPE_PACKED_COLOR_ARRAY: "PackedColorArray"
}

var ITERABLE_TYPES := {
	TYPE_ARRAY: true,
	TYPE_DICTIONARY: true,
	TYPE_PACKED_BYTE_ARRAY: true,
	TYPE_PACKED_INT32_ARRAY: true,
	TYPE_PACKED_INT64_ARRAY: true,
	TYPE_PACKED_FLOAT32_ARRAY: true,
	TYPE_PACKED_FLOAT64_ARRAY: true,
	TYPE_PACKED_STRING_ARRAY: true,
	TYPE_PACKED_VECTOR2_ARRAY: true,
	TYPE_PACKED_VECTOR3_ARRAY: true,
	TYPE_PACKED_COLOR_ARRAY: true
}

var ARRAY_TYPES := {
	TYPE_ARRAY: true,
	TYPE_PACKED_BYTE_ARRAY: true,
	TYPE_PACKED_INT32_ARRAY: true,
	TYPE_PACKED_INT64_ARRAY: true,
	TYPE_PACKED_FLOAT32_ARRAY: true,
	TYPE_PACKED_FLOAT64_ARRAY: true,
	TYPE_PACKED_STRING_ARRAY: true,
	TYPE_PACKED_VECTOR2_ARRAY: true,
	TYPE_PACKED_VECTOR3_ARRAY: true,
	TYPE_PACKED_COLOR_ARRAY: true
}


func get_iter_keys(container):
	print("-get_iter_keys-")
	print(container)
	var type_id = typeof(container)
	if type_id == TYPE_DICTIONARY:
		print(container.keys())
		return container.keys()
	if type_id == TYPE_ARRAY or type_id in ARRAY_TYPES:
		print(range(container.size()))
		return range(container.size())
	return null


func FunctioСall (FuncParametrs: Dictionary, EmbeddedParameters = null):
	print ("FunctioСall: ", FuncParametrs, ", ", EmbeddedParameters)
	if not FuncParametrs.has("func"):
		push_error("FunctioСall FuncParametrs missing 'func' key")
		return
	if typeof(FuncParametrs ["func"]) != TYPE_CALLABLE:
		push_error("FunctioСall FuncParametrs [func] not Callable. Actual value: ", FuncParametrs["func"], " Type: ", typeof(FuncParametrs ["func"]))
		return
	elif FuncParametrs ["func"] == null:
		push_error("FunctioСall FuncParametrs [func] is null")
		return null
	else:
		if ITERABLE_TYPES.has(typeof(FuncParametrs ["Parametrs"])):
			push_error("FunctioСall FuncParametrs [Parametrs] not ITERABLE_TYPES")
			return
		var Parametrs
		if typeof(FuncParametrs ["Parametrs"]) == typeof(EmbeddedParameters) and EmbeddedParameters != null:
			if typeof(FuncParametrs ["Parametrs"]) == TYPE_DICTIONARY and typeof(EmbeddedParameters) == TYPE_DICTIONARY:
				# Создаем копию параметров, чтобы избежать изменений оригинала
				Parametrs = FuncParametrs ["Parametrs"].duplicate()
				Parametrs.merge(EmbeddedParameters)
			elif ITERABLE_TYPES.has(typeof(FuncParametrs ["Parametrs"])) and ITERABLE_TYPES.has(typeof(EmbeddedParameters)):
				Parametrs = FuncParametrs ["Parametrs"] + EmbeddedParameters
			else:
				push_error("FunctioСall FuncParametrs [Parametrs] and EmbeddedParameters not one type")
				return
		elif EmbeddedParameters == null:
			# Создаем копию параметров, чтобы избежать изменений оригинала
			Parametrs = FuncParametrs ["Parametrs"].duplicate()
		else:
			push_error("FunctioСall FuncParametrs [Parametrs] and EmbeddedParameters not one type")
			return
		var Return = FuncParametrs ["func"].call (Parametrs)
		return Return
