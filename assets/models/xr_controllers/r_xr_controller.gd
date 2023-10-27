@tool
extends Node

@onready var ax = $R_XR_controller/R_XR_Controller_empty/R_XR_AX_button
@onready var by = $R_XR_controller/R_XR_Controller_empty/R_XR_BY_button
@onready var xjoy = $R_XR_controller/R_XR_Controller_empty/R_XR_joystick
@onready var yjoy = $R_XR_controller/R_XR_Controller_empty/R_XR_joystick
@onready var grab = $R_XR_controller/R_XR_Controller_empty/R_XR_grab
@onready var trigger = $R_XR_controller/R_XR_Controller_empty/R_XR_trigger

@onready var ax_label = $AX
@onready var by_label = $BY
@onready var xjoy_label = $"X axis"
@onready var yjoy_label = $"Y axis"
@onready var grab_label = $grab
@onready var trigger_label = $trigger

func _ready():
	Globals.line($lines, ax.position, ax_label.position)
	Globals.line($lines, by.position, by_label.position)
	Globals.line($lines, xjoy.position, xjoy_label.position)
	Globals.line($lines, yjoy.position, yjoy_label.position)
	Globals.line($lines, grab.position, grab_label.position)
	Globals.line($lines, trigger.position, trigger_label.position)

func update_labels():
	if Globals.grab_with_trigger:
		grab_label.text = "none"
		trigger_label.text = "Trigger / Grab"
	else:
		grab_label.text = "Grab"
		trigger_label.text = "Trigger"


