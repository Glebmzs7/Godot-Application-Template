extends Node

class_name Class_Logger

var Class_Help = load("res://Class/Class_Help.gd").new()

## Где хранятся пути по потокам (0 это данные о программе (Количество потоков и тп в словаре)
var FileStraming_path := "res://Save/Logger/Straming_path.json"
var Straming_path := [] #Получаем ауктальный массив надо дописать

var FileLogger:= "res://Save/Logger/Logger.log"
var FrequencyUpdates := 10
var TimeUpdate := 1.0
var LogBuffer = []

func Start_Logger (File:= self):
	Straming_path[0]["Streams"] += 1
	if File is Node:
		Straming_path.append([File.get_script().resource_path])
	

#Дабавления коментария с переменными в буфер
func Adding_Buffer (Comments: String, DictionaryVariables: Dictionary):
	pass

#Получения массива с указанием на симовлы с которых начинаетс комбинация в строке
func PlacesofTextLine (Descriptions: String, Set: String) -> Array:
	var ArrayOutputs = []
	if Descriptions.contains(Set):
		var whileflag1 = true
		while whileflag1:
			if ArrayOutputs == []:
				if Descriptions.contains(Set):
					ArrayOutputs.append(Descriptions.find(Set)) 
			else:
				var NextLocation = Descriptions.find(Set, ArrayOutputs[ArrayOutputs.size()-1])
				if NextLocation != -1:
					ArrayOutputs.append(NextLocation)
	return ArrayOutputs
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
		var v_Bv_Continue = v__Result[0][0]		## Продолжать глобальный обход? при true -1< Уровень
		var v_Bv_ContinueFor = v__Result[0][1]	## Продолжать текущий цикл? при true 0< Уровень
		var v_Bv_GoDeeper = v__Result[0][2]		## Идти вглубь структуры? при true +1 Уровень

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
#Вспомогательныая функция для fC_OvergrowthIf_Tr добовляет символы в 
func New_PathOvergrowth (Parametrs):
	var Comments = Parametrs[0]
#ДОбовления перемещения по коду в буфер в формате (код, с значениями, результат)
func New_Path (Descriptions: String, DictionaryVariables: Dictionary):
	var Comments: String
	var NumberOperationsс:= 1
	if Descriptions.contains("if") or Descriptions.contains("while"):
		#Сохраняем из коментария все базовые символы 
		var ArrayComparisonOperations := {
			"==" = PlacesofTextLine(Descriptions,"=="),
			"!=" = PlacesofTextLine(Descriptions,"!="),
			">=" = PlacesofTextLine(Descriptions,">="),
			"<=" = PlacesofTextLine(Descriptions,"<="),
			">" = PlacesofTextLine(Descriptions,">"),
			"<" = PlacesofTextLine(Descriptions,"<"),
			"and" = PlacesofTextLine(Descriptions,"and"),
			"or" = PlacesofTextLine(Descriptions,"or"),
			"if" = PlacesofTextLine(Descriptions,"if"),
			"while" = PlacesofTextLine(Descriptions,"while"),
			"(" = PlacesofTextLine(Descriptions,"("),
			")" = PlacesofTextLine(Descriptions,")"),
			}
		#Получаем все не базовые слова
		var ResrtDescriptions = Descriptions.duplicate()
		ResrtDescriptions
		#Содаем 
		var CommentsSizeMax = length(ResrtDescriptions)
		var CommentsSizeReall = 0
		while CommentsSizeMax != CommentsSizeReall
			fC_OvergrowthIf_Tr(ArrayComparisonOperations,{"func": New_PathOvergrowth,"Parametrs": [Comments]})
			is 

	elif Descriptions.contains("for"):
		pass

#Переносим буфер в логи
func Saving_Logs (LogBuffer, FileLogger, Straming_path):
	pass

#Воспроизводства визульного состояния программы
func ReplayReader (FileLogger, TimePLay, TimeEnd, SeqPlay, SeqEnd):
	pass

#Стирания путей работы при запуски программы 
func Resetting_Straming_path (FileStraming_path):
	pass

#Стираем те логи что устарее
func Resetting_FileLogger (FileLogger):
	pass
