class_name ActionInfoText
extends Control

@onready var text_info = $NinePatchRect/Label
var texts:Array = ["Select a target", "Confirm targets"]

enum InfoActionIndex{
	SELECT_TARGET,
	CONFIRM_ACTION
}

func set_text_info(textIndex:InfoActionIndex):
	text_info.text = texts[textIndex]
