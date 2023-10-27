@tool
class_name PigRescuePlayer
extends Resource

@export var name : String = ""
@export var color : String = ""
@export var hands : String = ""
@export var time : int = 0
@export var score : int = 0
@export var max_level : int = 0

# This method checks for configuration issues.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if name == "":
		warnings.append("Player must have a name")
	
	if color == "":
		warnings.append("Player must have an image")

	# Return warnings
	return warnings
