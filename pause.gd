extends CanvasLayer

signal level_reset
signal level_quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PauseMenu.hide()


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


# Pause the game engine and show PauseMenu.
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	$PauseMenu.show()
	$PauseMenu/PanelContainer/VBoxContainer/ResumeButton.grab_focus()


# Close PauseMenu and unpause the game engine.
func _on_resume_button_pressed() -> void:
	$PauseMenu.hide()
	get_tree().paused = false


# Tell the current level to reload itself.
func _on_reset_button_pressed() -> void:
	level_reset.emit()


# Tell the current level to exit to Main.
func _on_quit_button_pressed() -> void:
	level_quit.emit()
