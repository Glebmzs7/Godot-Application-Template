extends Node
class_name Class_UI

var Сlass_Dictionary = load("res://Class/Class_Dictionary.gd").new()
var Class_Logger = load("res://Class/Class_Loger.gd").new()

#Функционал:
#	Создание и вставка узла в сцену по конфигурации
#Форматы данных:
#	Входные:
#		X_NodeConfig_D: Dictionary —  {"__Data_D": {"__type_S": ,"__Scene_size_V2i": ,"__Path_to_the_node_location_S": },"__Inspector_D": {}, "__Node_D": {}}
#	Выходные:
#		Dictionary — {уникалноье_имя: {Node, Scene_size, Zero_point, Size}}
#Принцип работы:
#	1. Читает тип из __Data_D и создаёт узел
#	2. Применяет свойства из __Inspector_D
#	3. Подключает сигналы из __Node_D
#	4. Вставляет в указанный контейнер текущей сцены
#	5. Возвращает инфу о созданном узле
func fC_Creating_Node_CrTr(X_NodeConfig_D: Dictionary, A_BelongTo_A: Array) -> Dictionary:
	print("▶ Создание узла по конфигурации")
	
	# 0. Подготовка словарей
	var pLX_Data_D: Dictionary = X_NodeConfig_D.get("__Data_D", {})
	var pLX_Inspector_D: Dictionary = X_NodeConfig_D.get("__Inspector_D", {})
	var pLX_Signals_D: Dictionary = X_NodeConfig_D.get("__Node_D", {})

	# 1. Создание узла по типу
	if not pLX_Data_D.has("__type_S"):
		push_error("⛔ Не указан тип объекта (__type_S)")
		return {}

	var pLX_NodeType_S: String = pLX_Data_D["__type_S"]
	var pLX_NodeObj: Node
	
	if ClassDB.class_exists(pLX_NodeType_S):
		pLX_NodeObj = ClassDB.instantiate(pLX_NodeType_S)
	else:
		push_error("⛔ Несуществующий тип: %s" % pLX_NodeType_S)
		return {}

	# 2. Применение свойств из Inspector
	for key in pLX_Inspector_D:
		var value = pLX_Inspector_D[key]

		if typeof(value) != TYPE_DICTIONARY:
			pLX_NodeObj.set(key, value)
		else:
			var sub_obj = ClassDB.instantiate(value["type"])
			for sub_key in value:
				sub_obj.set(sub_key, value[sub_key])
			pLX_NodeObj.set(key, sub_obj)

	# 3. Подключение сигналов через Callable
	for pLX_SignalName_S: String in pLX_Signals_D.keys():
		var pLX_Callback: Callable = pLX_Signals_D[pLX_SignalName_S]
		if not pLX_Callback.is_valid():
			push_warning("⚠️ Callable недействителен для сигнала: %s" % pLX_SignalName_S)
			continue
		if pLX_NodeObj.has_signal(pLX_SignalName_S):
			pLX_NodeObj.connect(pLX_SignalName_S, pLX_Callback)
		else:
			push_warning("⚠️ Узел не имеет сигнала: %s" % pLX_SignalName_S)

	# 4. Поиск контейнера в текущей сцене
	if not pLX_Data_D.has("__Path_to_the_node_location_S"):
		push_error("⛔ Нет '__Path_to_the_node_location_S' в конфигурации")
		return {}

	var pLX_InsertPath: NodePath = pLX_Data_D["__Path_to_the_node_location_S"]
	
	# Проверка доступности дерева сцены
	var pLX_Tree: SceneTree = get_tree()
	if pLX_Tree == null:
		push_error("⛔ SceneTree не инициализирован")
		return {}
	
	# Получение корневой сцены
	var pLX_Root: Window = pLX_Tree.get_root()
	if pLX_Root == null:
		push_error("⛔ Корневое окно не найдено")
		return {}

	var pLX_CurrentScene: Node = pLX_Root.get_child(0)
	if pLX_CurrentScene == null:
		push_error("⛔ Активная сцена не найдена")
		return {}

	if not pLX_CurrentScene.has_node(pLX_InsertPath):
		push_error("⛔ Узел по пути '%s' не найден" % pLX_InsertPath)
		return {}

	var pLX_Container: Node = pLX_CurrentScene.get_node(pLX_InsertPath)
	pLX_Container.add_child(pLX_NodeObj)

	# 5. Возврат результата
	var pLX_NodeName_S: String = pLX_Inspector_D.get("name", "UnnamedNode")

	print("✅ Объект '%s' создан и вставлен в %s" % [pLX_NodeName_S, pLX_InsertPath])
	return {
		pLX_NodeName_S: {
			"Node": pLX_NodeObj,
			"Scene_size": pLX_Data_D.get("__Scene_size_V2i", Vector2i.ZERO),
			"Zero_point": pLX_Data_D.get("__Zero_point", Vector2.ZERO),
			"name": pLX_Inspector_D.get("name", Vector2i.ZERO),
			"Size": pLX_Inspector_D.get("Size", Vector2i.ZERO),
			"A_BelongTo_A": A_BelongTo_A,
			"__Path_to_the_node_location_S": pLX_Data_D.get("__Path_to_the_node_location_S", Vector2.ZERO),
		}
	}


#Функционал:
#	Перебор массива с вызовом fC_Creating_Node_CrTr когда есть подходящие данные 
#Форматы данных:
#	Входные:
#		vXD_NodeConfig - Dictionary —  {Dictionary: "__Data_D": {"__type_S": ,"__Scene_size_V2i": ,"__Path_to_the_node_location_S": },"__Inspector_D": {}, "__Node_D": {}}
#		vXD_All_nodes - Dictionary куда будут сохранятся созданными нодами
#	Выходные: 
#		vXD_All_nodes - Dictionary с всме созданными нодами {уникалноье_имя: {Node, Scene_size, Zero_point, Size}}
#Принцип работы:
#	Протосор вызов перебора с функциеё для выызова создания ноды
func fC_Mass_Creating_Node_CrTr (vXD_NodeConfig: Dictionary, vXD_All_nodes: Dictionary):
	print ("fC_Mass_Creating_Node_CrTr")
	Сlass_Dictionary.fС_Overgrowth_tree_Tr (vXD_NodeConfig, f__Checking_conditions, {"vXD_All_nodes": vXD_All_nodes})


#Функционал:
#	Проверяет подходит ли условие для создания узла, вызывает fC_Creating_Node_CrTr если да, и возвращает флаги обработки
#Форматы данных:
#	Входные:
#		vLS_key: String — ключ в словаре
#		v_D_Holderv2: Dictionary — вложенный словарь
#		vLD_func_variable: Dictionary — параметры, включая накопленные ноды
#	Выходные:
#		Array — [продолжать обход, продолжать цикл, углубляться в дерево]
#Принцип работы:
#	1. Проверка системных ключей
#	2. Обработка структуры с данными
#	3. Возврат логики обхода
func f__Checking_conditions(vLS_key: String, v_D_Holderv2: Dictionary, vLD_func_variable: Dictionary) -> Array:
	print("f__Checking_conditions ", vLS_key)

	# Получаем и клонируем массив принадлежности
	var A_BelongTo_A: Array = []
	if vLD_func_variable.has("A_BelongTo_A"):
		A_BelongTo_A = vLD_func_variable["A_BelongTo_A"].duplicate()

	# Системные ключи — пропуск углубления и цикла
	if vLS_key == "__Data_D" or vLS_key == "__Inspector_D" or vLS_key == "__Node_D":
		return [true, false, false]

	# Добавляем родителя, если есть
	if v_D_Holderv2.has("v__Ebeveyn"):
		A_BelongTo_A.append(v_D_Holderv2["v__Ebeveyn"])

	# Проверка на валидную структуру узла
	if v_D_Holderv2.has("__Data_D") and v_D_Holderv2.has("__Inspector_D") and v_D_Holderv2.has("__Node_D"):
		var v_D_Holderv3 = fC_Creating_Node_CrTr(v_D_Holderv2, A_BelongTo_A)
		vLD_func_variable["vXD_All_nodes"].merge(v_D_Holderv3)

		# Обновление массива принадлежностей
		vLD_func_variable["A_BelongTo_A"] = A_BelongTo_A

		# Мы не хотим углубляться после создания ноды
		return [true, true, false]

	# Обычный проход — разрешаем всё
	vLD_func_variable["A_BelongTo_A"] = A_BelongTo_A
	return [true, true, true]


#Функционал:
#	Переберает словарь и если ключь из массива ключей совпадает то вызыввает функцию передовай туда всю информацию
#Форматы данных:
#	Входные:
#		vXD_All_nodes: Dictionary, vXA_Array_key: [key1, key2,...], vLS_func: Callable, vLD_func_variable: Dictionary
#	Выходные:
#		Нет
#Принцип работы:
#	Как именно функция достигает результата, какие шаги предпринимает
func fC_Node_changes_key (vXD_All_nodes: Dictionary, vXA_Array_key: Array, vLS_func: Callable, vLD_func_variable: Dictionary):
	var vL_Array_Del := []
	var v__Result
	
	for vL_An in vXD_All_nodes:
		for vL_Ak in vXA_Array_key:
			if vXD_All_nodes [vL_An] ["A_BelongTo_A"].has (vL_Ak):
				v__Result = vLS_func.call(vXD_All_nodes, vL_An, vL_Ak, vL_Array_Del, vLD_func_variable)
				if v__Result [0] == false:
					break
		if v__Result [1] == false:
			break
	
	for vL_Ad in vL_Array_Del:
		vXD_All_nodes.erase(vL_Ad)


#Функционал:
#	Генерация набора конфигураций по шаблону с вариативной частью
#Форматы данных:
#	Входные:
#		vD_BaseTemplate: Dictionary — общая часть
#		vD_DiffTemplate: Dictionary — часть, где есть %N (индекс)
#		vI_Count: Int — сколько копий делать
#Выходные:
#		Dictionary с уникальными узлами
#Принцип работы:
#	Создает N копий с заменой %N на индекс
func fxG_BatchFillNodeConfig_Cr(vD_BaseTemplate: Dictionary, vD_DiffTemplate: Dictionary, vI_Count: int) -> Dictionary:
	var vD_Result: Dictionary = {}

	for vI_N in range(vI_Count):
		var vD_Clone := vD_BaseTemplate.duplicate(true)
		var vS_Name = vD_DiffTemplate.get("__name_S", "Node%N").replace("%N", str(vI_N + 1))

		# Вставляем имя
		vD_Clone["__Inspector_D"]["name"] = vS_Name

		# Заменяем другие поля, если указаны
		for k in vD_DiffTemplate:
			if k == "__name_S":
				continue
			var val = vD_DiffTemplate[k]
			if typeof(val) == TYPE_STRING:
				val = val.replace("%N", str(vI_N + 1))
			vD_Clone["__Inspector_D"][k] = val

		# Сохраняем под уникальным ключом
		vD_Result[vS_Name] = vD_Clone
	
	return vD_Result


#Функционал:
#	Изменяет свойства существующих нод
func fxC_UpdateExistingNodes_Ch(vXD_All_nodes: Dictionary, vD_Changes: Dictionary):
	for name in vD_Changes:
		if not vXD_All_nodes.has(name):
			Class_Logger.fx__Log_Warn("Нода %s не найдена для обновления." % name)
			continue
		var node = vXD_All_nodes[name]["Node"]
		for property in vD_Changes[name]:
			if node.has_method("set") and node.has_property(property):
				node.set(property, vD_Changes[name][property])
				Class_Logger.fx__Log_Info("Поле %s ноды %s обновлено." % [property, name])
			else:
				Class_Logger.fx__Log_Warn("Свойство %s не найдено у ноды %s." % [property, name])


#Функционал:
#	Выполнить смену сцены с любого места
func fxC_SceneSwitching (scene_path):
	get_tree().call_deferred("change_scene_to_file", scene_path)


#Функционал:
#Удаляет ноды по условию
func fxC_MassDelitNode(MassOfExistingNodes: Dictionary, RemovalCondition: Callable) -> void:
	# Массив для удаления
	var v_DeletionQueue_A: Array = []

	for elMOFN in MassOfExistingNodes:
		# Перебор тегов для проверки
		for elMOFNABA in MassOfExistingNodes[elMOFN]["A_BelongTo_A"]:
			# Проверяем условие с помощью переданной функции
			if RemovalCondition.call(elMOFNABA, MassOfExistingNodes[elMOFN]):
				MassOfExistingNodes[elMOFN]["Node"].queue_free()
				v_DeletionQueue_A.append(elMOFN)
				break # можно прервать, чтобы не удалять дважды

	# Удаляем отмеченные элементы
	for elDQ in v_DeletionQueue_A:
		MassOfExistingNodes.erase(elDQ) 


func fxC_ZoneReplacement(Coordinates: Dictionary, Zones: String, MewZones: Dictionary):
	for el_Z in Coordinates [Zones]:
		el_Z["Node"].queue_free()
	Coordinates [Zones].erase()
	Coordinates [MewZones]


#func fxC_StatusOperator(Zones, Status, ):
#	fxC_ZoneReplacement(Zones, )
