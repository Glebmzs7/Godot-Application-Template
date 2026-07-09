##Версия оформления
##2025-06-20 - mzs7 - начальная реализация
##2026-03-28 - mzs7 - обновление комментариев по стандартам
##0.2.0.1 - обновление комментариев
##2026-03-28 - mzs7 - обновление комментариев по стандартам
extends Node
class_name Class_ArrayAndOrDictionary

var Class_Help = load("res://Class/Class_Help.gd").new()

##Функционал:
##	Сравнивает два массива на полное совпадение (порядок и значение элементов)
##Форматы данных:
##	Входные:
##		array1: Array - первый массив для сравнения
##		array2: Array - второй массив для сравнения
##	Выходные:
##		bool - true если массивы идентичны, иначе false
##Принцип работы:
##	1. Проверка совпадения длины массивов
##	2. Поэлементное сравнение через оператор ==
##	3. Немедленный возврат false при обнаружении расхождения
func fL_CompareArrays_Tr(array1: Array, array2: Array) -> bool:
	## Длина должна совпадать
	if array1.size() != array2.size():
		return false

	## Поэлементное сравнение
	for i in range(array1.size()):
		if array1[i] != array2[i]:
			return false

	return true



##Функционал:
##	Сравнивает два массива на идентичность элементов без учета их порядка
##Форматы данных:
##	Входные:
##		array1: Array - первый массив для сравнения
##		array2: Array - второй массив для сравнения
##	Выходные:
##		bool - true если массивы содержат одинаковые элементы (количество и тип), иначе false
##Принцип работы:
##	1. Проверка равенства длин массивов
##	2. Подсчет частоты встречаемости элементов в первом массиве
##	3. Сравнение с частотой элементов во втором массиве
##	4. Возврат false при любом несоответствии
func fL_CompareArraysUnordered_Tr(array1: Array, array2: Array) -> bool:
	## Быстрая проверка длины
	if array1.size() != array2.size():
		return false

	## Создание словаря для подсчета элементов
	var element_count := {}

	## Подсчет элементов в первом массиве
	for element in array1:
		if element_count.has(element):
			element_count[element] += 1
		else:
			element_count[element] = 1

	## Проверка элементов второго массива
	for element in array2:
		if not element_count.has(element):
			return false  ## Элемент отсутствует в первом массиве

		element_count[element] -= 1
		if element_count[element] < 0:
			return false  ## Элемент встречается чаще, чем в первом массиве

	return true

##Функционал:
##	Callback-функция для слияния значений из второго словаря в первый
##Форматы данных:
##	Входные:
##		vLS_Key: String — текущий ключ
##		v_: Variant — текущее значение
##		vLD_External: Dictionary — {
##			"Target_D": Dictionary (куда пишем),
##			"Source_D": Dictionary (откуда берём)
##		}
##	Выходные:
##		Array:
##			[ [Bv_Continue, Bv_ContinueFor, Bv_GoDeeper], v_ChildValue ]
##Принцип работы:
##	1. Если значение — словарь и есть соответствие в обоих — рекурсивно
##	2. Иначе: перезаписываем/добавляем значение из второго словаря в первый
func fxL_MergeCallback_Tr(vLS_Key: String, v_, vLD_External: Dictionary) -> Array:
	var vLD_Target = vLD_External["Target_D"]
	var vLD_Source = vLD_External["Source_D"]

	## Если в Source есть этот ключ
	if vLD_Source.has(vLS_Key):
		var v_ValueFromSecond = vLD_Source[vLS_Key]

		## Если оба значения — словари, объединяем глубже
		if typeof(v_) == TYPE_DICTIONARY and typeof(v_ValueFromSecond) == TYPE_DICTIONARY:
			var new_sub_dict = v_.duplicate()
			vLD_Target[vLS_Key] = new_sub_dict  ## вставляем временно
			return [
				[true, true, true],  ## продолжать, цикл, рекурсивно
				v_ValueFromSecond  ## это будет следующая структура обхода
			]
		else:
			## Прямое копирование/перезапись
			vLD_Target[vLS_Key] = v_ValueFromSecond

	## В любом случае: не нужно углубляться
	return [[true, true, false], null]


##Функционал:
##	Рекурсивное объединение двух словарей с приоритетом второго словаря
##Форматы данных:
##	Входные:
##		@param Dict1: Dictionary - базовый словарь
##		@param Dict2: Dictionary - словарь с приоритетными значениями
##	Выходные:
##		@returns Dictionary - объединенный словарь
##Принцип работы:
##	1. Создает глубокую копию Dict1
##	2. Для каждого ключа в Dict2:
##		- Если ключ существует в основном словаре:
##			* Если оба значения - словари, выполняется рекурсивное слияние
##			* Иначе значение заменяется на значение из Dict2
##		- Если ключа нет, он добавляется из Dict2
##	3. Возвращает результирующий словарь
func fG_MergeDictionariesRecursive_Cr(Dict1: Dictionary, Dict2: Dictionary) -> Dictionary:
	var result := Dict1.duplicate(true)

	for key in Dict2:
		if result.has(key):
			## Если оба значения - словари, рекурсивно объединяем их
			if typeof(result[key]) == TYPE_DICTIONARY and typeof(Dict2[key]) == TYPE_DICTIONARY:
				result[key] = fG_MergeDictionariesRecursive_Cr(result[key], Dict2[key])
			else:
				## Если не оба словари, перезаписываем значением из Dict2
				result[key] = Dict2[key]
		else:
			## Если ключа нет в result, просто добавляем его
			result[key] = Dict2[key]

	return result


##Функционал:
##	Рекурсивный обход словаря с применением callback-функции
##	и управлением процессом через возвращаемые флаги
##Форматы данных:
##	Входные:
##		vLD_FirstVariable: Dictionary - словарь для обработки
##		vLS_func: Callable - callback-функция обработки
##		vLD_func_variable: Dictionary - дополнительные данные
##	Выходные:
##		нет
##Принцип работы:
##	1. Инициализация флага глобального продолжения
##	2. Рекурсивный обход элементов словаря
##	3. Вызов callback-функции для каждого элемента
##	4. Обработка возвращаемых флагов управления
##	5. Рекурсивный вызов при необходимости углубления
func fC_OvergrowthIf_Tr (vLD_FirstVariable: Dictionary, vLS_func: Dictionary, PathArray:= []) -> void:
	## Флаг продолжения глобального обхода
	var vLBv_GlobalContinue := true

	## Создаем копию словаря параметров, чтобы не изменять оригинальный
	var vLS_func_copy = vLS_func.duplicate()

	## Перебор ключей словаря
	for vLS_Key in vLD_FirstVariable:
		## Проверка флага глобального продолжения
		if not vLBv_GlobalContinue:
			break
		## Вызов callback-функции с параметрами:
		##	- ключ элемента
		##	- значение элемента
		##	- дополнительные данные
		PathArray.append(vLS_Key)
		if not Class_Help.ITERABLE_TYPES_MAP.has(typeof(vLS_func_copy["Parametrs"])):
			vLS_func_copy["Parametrs"] = []
		var v__Result = Class_Help.FunctionCall(vLS_func_copy, PathArray)

		## Декомпозиция результата callback:
		var v_Bv_Continue = v__Result[0][0]		## Продолжать глобальный обход?
		var v_Bv_ContinueFor = v__Result[0][1]	## Продолжать текущий цикл?
		var v_Bv_GoDeeper = v__Result[0][2]		## Идти вглубь структуры?

		## Управление флагами на основе результата
		if not v_Bv_Continue:
			vLBv_GlobalContinue = false
		if not v_Bv_ContinueFor:
			PathArray.pop_back()
			break
		if v_Bv_GoDeeper:
			##N Рекурсивный вызов для вложенных данных
			fC_OvergrowthIf_Tr(v__Result[1], vLS_func_copy, PathArray)
		PathArray.pop_back()


## Обход любой структуры данных (массивы, словари и т.д.)
##
## @param variables: Структура данных для обхода
## @param funcparametrs: Параметры функции обратного вызова
## @param PathArray: Массив путей к элементам (по умолчанию пустой)
func UniversalBypass (variables, funcparametrs: Dictionary, PathArray:= []):
	var variables1 = variables
	var type_id = typeof(variables)
	if type_id in Class_Help.ITERABLE_TYPES:
		variables1 = variables.duplicate(true)
	var returnfunc1
	var keys = Class_Help.get_iter_keys(variables1)
	if keys == null:
		returnfunc1 = Class_Help.FunctionCall(funcparametrs, [type_id, variables1, PathArray, null])
	else:
		for elV in keys:
			var element = variables1[elV]
			PathArray.append(elV)
			returnfunc1 = Class_Help.FunctionCall(funcparametrs, [type_id , variables1, PathArray, elV])
			match returnfunc1:
				"Deeper":
					if typeof (variables1[elV]) in Class_Help.ITERABLE_TYPES_MAP:
						UniversalBypass(variables1[elV], funcparametrs, PathArray)
					else:
						PathArray.pop_back()
						push_error("⛔ ",variables1," при ", elV, " Не обходится")
				"Further":
					PathArray.pop_back()
					pass
				"Higher":
					PathArray.pop_back()
					break
				_:
					push_error("⛔ returnfunc1 UniversalBypass при ",variables1," и ", funcparametrs, " = ", returnfunc1)
					return

##Функционал:
##	Описание, что делает функция на уровне задачи
##Форматы данных:
##	Входные:
##		Variables1 - исходная структура данных
##		PathArray: Array - массив ключей/индексов пути
##		FuncParametrs: Dictionary - функциональные параметры (по умолчанию пустой словарь)
##	Выходные:
##		Variant - значение по указанному пути
##Принцип работы:
##	Как именно функция достигает результата, какие шаги предпринимает
func PassageAlongWay (Variables1, PathArray: Array, FuncParametrs:= {}):
	var VariablesReturn = Variables1.duplicate(true)  # Глубокое копирование
	for elPA in PathArray:
		if FuncParametrs != {}:
			var flagPassageAlongWay = true
			# Создаем копию словаря параметров, чтобы не изменять оригинальный
			var FuncParametrsCopy = FuncParametrs.duplicate()
			var ReturnFunctionCall = Class_Help.FunctionCall(FuncParametrsCopy,[VariablesReturn, Variables1, elPA])
			pass
			if ReturnFunctionCall != null and ReturnFunctionCall.has("VariablesReturn"):
				VariablesReturn = PassageAlongWay(VariablesReturn, ReturnFunctionCall ["VariablesReturn"])
			if ReturnFunctionCall != null and ReturnFunctionCall.has("flagPassageAlongWay"):
				flagPassageAlongWay = ReturnFunctionCall ["flagPassageAlongWay"]
			if flagPassageAlongWay:
				VariablesReturn = VariablesReturn [elPA]
				print("-PassageAlongWay- Good flagPassageAlongWay")
			else:
				print("-PassageAlongWay- Not flagPassageAlongWay")
		else:
			VariablesReturn = VariablesReturn [elPA]
	return VariablesReturn

##Функционал:
##	Описание, что делает функция на уровне задачи
##Форматы данных:
##	Входные:
##		PathArray: Array - массив ключей/индексов пути
##		FuncParametrs: Dictionary - функциональные параметры
##		Variables - структура данных для проверки
##	Выходные:
##		Нет
##Принцип работы:
##	Как именно функция достигает результата, какие шаги предпринимает
func CheckingPath (PathArray: Array, FuncParametrs: Dictionary, Variables):
	var originalPathArray = PathArray.duplicate()
	while len(originalPathArray)-1 > 0:
		originalPathArray.pop_back()
		# Создаем копию словаря параметров, чтобы не изменять оригинальный
		var FuncParametrsCopy = FuncParametrs.duplicate()
		Class_Help.FunctionCall(FuncParametrsCopy, [PassageAlongWay(originalPathArray, Variables)])



##Функционал:
##	Сравнивает 2 переменных если переменные не совпали но явялются контенером проходятся в нутри и сравниваются
##Форматы данных:
##	Входные:
##		Variables1 - Перва переменная для сравнения
##		Variables2 - Вторая переменная для сравнения
##		ReturnDictionary - Словарь по формату "result": "", "Values": [],"Child"*: [] *только если будет сравнения на уровне ниже
##Принцип работы:
##	1. Проверка на полное соотвествие
##	2. Если 1. false то Проверка на то что оба контенеры если да то создаем список детей и вызываем UniversalBypass с _C_ComparisonsOf2Variables_0101 для обхода и сравнения
##	3. Если нет то сохраем в ReturnDictionary что переменные разные
func fC_ComparisonsOf2Variables_0101 (Variables1, Variables2, ReturnDictionary):
	var ChildReturnDictionary := {}
	if typeof(Variables1) == typeof(Variables2):
		if Variables1 == Variables2:
			ReturnDictionary["result"] = "+"
			ReturnDictionary["Values"] = [Variables1, Variables2]
		elif TYPE_DICTIONARY == typeof(Variables1) and  TYPE_DICTIONARY == typeof(Variables2):
			for elV1 in Variables1:
				if Variables2.has(elV1):
					ChildReturnDictionary[elV1] = {}
				else:
					ChildReturnDictionary[elV1]["result"] = ">"
					ChildReturnDictionary[elV1]["Values"] = [Variables1 [elV1]]
			for elV2 in Variables2:
				if Variables1.has(elV2):
					ChildReturnDictionary[elV2] = {}
				else:
					ChildReturnDictionary[elV2]["result"] = "<"
					ChildReturnDictionary[elV2]["Values"] = [Variables2 [elV2]]
			ReturnDictionary["result"] = "~"
			ReturnDictionary["Values"] = [Variables1, Variables2]
			ReturnDictionary["Child"] = ChildReturnDictionary
			UniversalBypass(ReturnDictionary, {"func": _C_ComparisonsOf2Variables_0101, "Parametrs": [Variables1, Variables2]})
		else:
			ReturnDictionary["result"] = "-"
			ReturnDictionary["Values"] = [Variables1, Variables2]
	elif Class_Help.ARRAY_TYPES_MAP.has(typeof(Variables1)) and Class_Help.ARRAY_TYPES_MAP.has(typeof(Variables2)):
		var LengthArray = min(Variables1.size(), Variables2.size())
		var Counter = 0
		while LengthArray > 0:
			ChildReturnDictionary[str(Counter)] = {}
			LengthArray -= 1
			Counter += 1
		LengthArray = max(Variables1.size(), Variables2.size()) - Counter
		while LengthArray > 0:
			if Variables1.size() > Variables2.size():
				ChildReturnDictionary[str(Counter)]["result"] = ">"
				ChildReturnDictionary[str(Counter)]["Values"] = [Variables1]
			else:
				ChildReturnDictionary[str(Counter)]["result"] = "<"
				ChildReturnDictionary[str(Counter)]["Values"] = [Variables2]
			LengthArray -= 1
			Counter += 1
		ReturnDictionary["result"] = "~"
		ReturnDictionary["Values"] = [Variables1, Variables2]
		ReturnDictionary["Child"] = ChildReturnDictionary
		UniversalBypass(ReturnDictionary, {"func": _C_ComparisonsOf2Variables_0101, "Parametrs": [Variables1, Variables2]})
	else:
		ReturnDictionary["result"] = "-"
		ReturnDictionary["Values"] = [Variables1, Variables2]


##Функционал:
##	Плучаем акутальные по пути переменные для сравнения и сравневаем
##Форматы данных:
##	Входные:
##		originalVariables1 - изначальная первая переменая для сравнения
##		originalVariables2 - изначальная вторая переменая для сравнения
##		originalReturnDictionary - изначальная сравнительный словарь
##		PathArray - массив пути к актуальным параметрам
##Принцип работы:
##	1.через PassageAlongWay получаем актаульные переменные
##	2. Проверяем что проверка возможно и нужна (необходимость)
##	3. Формируем результат по условияем
##		3.1. Если полное совподения фиксируем это {"result": "+","Values": [Variables1, Variables2]} return "Further"
##			3.1.1 Вызывваем CheckingPath для изменения результатов при необходимости
##		3.2. Если оба словая то формирует матьерял для дальнешей работы {"result": "~", "Values": [Variables1, Variables2],"Child": ChildReturnDictionary} return "Deeper"
##		3.3. Если оба массивы то формирует матьерял для дальнешей работы ReturnDictionary {"result": "~", "Values": [Variables1, Variables2],"Child": ChildReturnDictionary} return "Deeper"
##		3.4. Если не чего более то фиксируем это {"result": "~", "Values": [Variables1, Variables2],"Child": ChildReturnDictionary} return "Further"
func _C_ComparisonsOf2Variables_0101 (InputArray: Array):
	if InputArray[5] == "Child":
		var PathArray = InputArray[4]
		#1.Получаем акуальные изменения
		var ReturnDictionary = PassageAlongWay(InputArray[3],PathArray)
		var Variables1 = PassageAlongWay(InputArray[3],PathArray, {"func":_PAW_CO2V})
		var Variables2 = PassageAlongWay(InputArray[3],PathArray, {"func":_PAW_CO2V})
		#Сверка переменных
		#3.Формируем результат
		var ChildReturnDictionary := {}
		if  typeof(Variables1) == typeof(Variables2):
			if Variables1 == Variables2:
				ReturnDictionary["result"] = "+"
				ReturnDictionary["Values"] = [Variables1, Variables2]
				CheckingPath(PathArray, {"func": _CP_CO2V, "Parametrs": []}, ReturnDictionary)
				return "Further"
			elif TYPE_DICTIONARY == typeof(Variables1) and TYPE_DICTIONARY == typeof(Variables2):
				for elV1 in Variables1:
					if Variables2.has(elV1):
						ChildReturnDictionary[elV1] = {}
					else:
						ChildReturnDictionary[elV1]["result"] = ">"
						ChildReturnDictionary[elV1]["Values"] = [Variables1 [elV1]]
				for elV2 in Variables2:
					if Variables1.has(elV2):
						ChildReturnDictionary[elV2] = {}
					else:
						ChildReturnDictionary[elV2]["result"] = "<"
						ChildReturnDictionary[elV2][ "Values"] = [Variables2 [elV2]]
				ReturnDictionary["result"] = "~"
				ReturnDictionary["Values"] = [Variables1, Variables2]
				ReturnDictionary["Child"] = ChildReturnDictionary
				return "Deeper"
			else:
				ReturnDictionary["result"] = "-"
				ReturnDictionary["Values"] = [Variables1, Variables2]
				CheckingPath(PathArray, {"func": _CP_CO2V, "Parametrs": []}, ReturnDictionary)
				return "Further"

		elif Class_Help.ARRAY_TYPES_MAP.has(typeof(Variables1)) and Class_Help.ARRAY_TYPES_MAP.has(typeof(Variables2)):
			var LengthArray = min(Variables1.size(), Variables2.size())
			var Counter = 0
			while LengthArray > 0:
				ChildReturnDictionary[str(Counter)] = {}
				LengthArray -= 1
				Counter += 1
			LengthArray = max(Variables1.size(), Variables2.size()) - Counter
			while LengthArray > 0:
				if Variables1.size() > Variables2.size():
					ChildReturnDictionary[str(Counter)]["result"] = ">"
					ChildReturnDictionary[str(Counter)]["Values"] = [Variables1]
				else:
					ChildReturnDictionary[str(Counter)]["result"] = "<"
					ChildReturnDictionary[str(Counter)]["Values"] = [Variables2]
				LengthArray -= 1
				Counter += 1
			ReturnDictionary["result"] = "~"
			ReturnDictionary["Values"] = [Variables1, Variables2]
			ReturnDictionary["Child"] = ChildReturnDictionary
			return "Deeper"
		else:
			ReturnDictionary["result"] = "-"
			ReturnDictionary["Values"] = [Variables1, Variables2]
			CheckingPath(PathArray, {"func": _CP_CO2V, "Parametrs": []}, ReturnDictionary)
			return "Further"
	else:
		return "Further"

##Функционал:
##	Описание, что делает функция на уровне задачи
##Форматы данных:
##	Входные:
##		PathArray - массив пути (не используется в теле функции)
##		Variables - словарь переменных для обновления результата
##	Выходные:
##		Нет
##Принцип работы:
##	Как именно функция достигает результата, какие шаги предпринимает
func _CP_CO2V (PathArray, Variables):
	if Variables.has("result"):
		if Variables ["result"] == "~":
			var ValueCounter = {"-":0, "+":0, ">":0, "<": 0,"~": 0, "~-":0, "~>":0, "~<":0, "~>-":0, "~<-":0 }
			for elChild in Variables["Child"]:
				ValueCounter [Variables [elChild] ["result"]] += 1  # Исправление ошибки: было "=+ 1" должно быть "+= 1"
			if ValueCounter["~>-"] + ValueCounter["~<-"] > 0:
				pass
			elif ValueCounter["~-"] + ValueCounter["~>"] + ValueCounter ["~<"] > 0:
				pass
			else:
				if ValueCounter["+"]>0:
					if ValueCounter["-"]>0:
						if ValueCounter[">"]>0 and ValueCounter["<"]>0:
							Variables ["result"] = "~-"
						elif ValueCounter[">"]>0:
							Variables ["result"] = "~>-"
						elif  ValueCounter["<"]>0:
							Variables ["result"] = "~<-"
						else:
							Variables ["result"] = "~-"
					else:
						if ValueCounter[">"]>0 and ValueCounter["<"]>0:
							Variables ["result"] = "~-"
						elif ValueCounter[">"]>0:
							Variables ["result"] = "~>"
						elif ValueCounter["<"]>0:
							Variables ["result"] = "~<"
						else:
							Variables ["result"] = "~"
				else:
					if ValueCounter["-"]>0:
						Variables ["result"] = "-"
					else:
						if ValueCounter[">"]>0 and ValueCounter["<"]>0:
							Variables ["result"] = "-"
						elif ValueCounter[">"]>0:
							Variables ["result"] = ">"
						elif  ValueCounter["<"]>0:
							Variables ["result"] = "<"
						else:
							Variables ["result"] = "+"

##Функционал:
##	Пропускает в пути к переменной ключи из ReturnDictionary
##Форматы данных:
##	Входные:
##		VariablesReturn - переменная итоговая
##		Variables1 - переменная Variables1 исходная
##		elPA - ключь разницы между VariablesReturn и Variables1
##	Выходные:
##		"flagPassageAlongWay": - будет ли добавить время
##Принцип работы:
##	зачем?
func _PAW_CO2V (Array):
	var elPA = Array[2]
	if elPA == "Child":
		return {"flagPassageAlongWay": false}
