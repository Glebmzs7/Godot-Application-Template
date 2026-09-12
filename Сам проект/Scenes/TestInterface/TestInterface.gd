extends Node

## Regression test for the fix where a recreated node's children (nested
## under a wrapper key next to __Data_D/__Inspector_D/__Node_D) used to be
## lost — fC_SyncingNodesWithConfig_1111 now calls fC_MassCreatingNode_0001
## (wrapped by name) instead of the single-node creator at both the
## new-node and recreate-existing-node paths.

var _ui = load("res://Godot_Template/Class_UI.gd").new()
var _all_nodes: Dictionary = {}


func _build_config(panel_type: String) -> Dictionary:
	return {
		"TestPanel": {
			"__Data_D": {"__type_S": panel_type, "__Scene_size_V2i": Vector2i(540, 900)},
			"__Inspector_D": {"anchor_right": 1.0, "anchor_bottom": 1.0},
			"__Node_D": {},
			"Children": {
				"TestChildLabel": {
					"__Data_D": {"__type_S": "Label", "__Scene_size_V2i": Vector2i(540, 900)},
					"__Inspector_D": {"text": "child"},
					"__Node_D": {},
				},
			},
		},
	}


func _ready() -> void:
	add_child(_ui)

	var config_a: Dictionary = _build_config("Panel")
	_ui.fC_MassCreatingNode_0001(config_a, _all_nodes)
	var child_present_after_create: bool = _all_nodes.has("TestChildLabel")

	# Force full recreation of TestPanel by changing its __type_S — the same
	# trigger _fC_SyncExistingNode uses to decide "recreate, don't just update"
	var config_b: Dictionary = _build_config("PanelContainer")
	_ui.fC_SyncingNodesWithConfig_1111(_all_nodes, config_a, config_b)
	var child_present_after_recreate: bool = _all_nodes.has("TestChildLabel")

	var passed: bool = child_present_after_create and child_present_after_recreate
	if passed:
		print("TestInterface: PASSED — child survived create and recreate")
	else:
		print("TestInterface: FAILED — child after create: %s, child after recreate: %s" % [
			child_present_after_create, child_present_after_recreate,
		])
