extends Node2D

var allowed_portraits = ["Cat", "Cop", "Girl", "DriverGrapple",
	"DriverSpeedDrop", "DriverSpeedLow", "DriverSpeedMax", "DriverSpeedUp"]
var current_portrait

var dialogue_active
var random_gen = RandomNumberGenerator.new()
# Stored as [portrait, text] pairs
var dialogue_options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switch_portrait("Cat")
	dialogue_active = false
	dialogue_options = [
		["Cat", "Mrow!"],
		["Cop", "Stop! You've violated the law!"],
		["Girl", "Are we there yet?"],
		["DriverSpeedMax", "It's alright, I know a shortcut!"],
		["Girl", "Officer, why are you texting and driving?"],
		["DriverGrapple", "We'll get there when we get there!"],
	]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func switch_portrait(portrait: String):
	for allowed_portrait in allowed_portraits:
		get_node(allowed_portrait).stop()
		get_node(allowed_portrait).hide()
	if portrait in allowed_portraits:
		get_node(portrait).show()
		get_node(portrait).play("default")
		current_portrait = portrait

func _on_minivan_high_speed() -> void:
	if current_portrait != "DriverSpeedMax" && not dialogue_active:
		switch_portrait("DriverSpeedMax")


func _on_minivan_low_speed() -> void:
	if current_portrait != "DriverSpeedLow" && not dialogue_active:
		switch_portrait("DriverSpeedLow")


func _on_minivan_slowing_down() -> void:
	if current_portrait != "DriverSpeedDrop" && not dialogue_active:
		switch_portrait("DriverSpeedDrop")


func _on_minivan_speeding_up() -> void:
	if current_portrait != "DriverSpeedUp" && not dialogue_active:
		switch_portrait("DriverSpeedUp")

func triggerRandomDialogue():
	var random_index = random_gen.randi_range(0, dialogue_options.size() - 1)
	var chosen_dialogue = dialogue_options[random_index]
	switch_portrait(chosen_dialogue[0])
	get_node("neccessary").get_node("DialogueText").text = chosen_dialogue[1]
	

func cleanupDialogue():
	get_node("neccessary").get_node("DialogueText").text = ""

# Every 8 seconds, show dialogue for 3s
func _on_trigger_dialogue_timer_timeout() -> void:
	get_node("EndDialogueTimer").start()
	dialogue_active = true
	triggerRandomDialogue()


func _on_end_dialogue_timer_timeout() -> void:
	dialogue_active = false
	cleanupDialogue()
