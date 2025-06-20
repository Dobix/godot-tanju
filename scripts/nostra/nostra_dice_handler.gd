extends Node

enum Result { PLAYER, NPC, DRAW }
var dice_result

var player_result
var npc_result

@onready var result_label: Label = $Result_label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var start_button: Button = $Start_Button

signal round_start_dice_finished(result)
signal decide_winner_dice_finished(result)

func start_dice_round(purpose: String) -> void:
	await start_button.pressed
	start_button.hide()
	player_roll()
	await get_tree().create_timer(2.0).timeout
	npc_roll()
	await get_tree().create_timer(2.0).timeout

	if player_result > npc_result:
		dice_result = Result.PLAYER
	elif npc_result > player_result:
		dice_result = Result.NPC
	else:
		dice_result = Result.DRAW
		
	match purpose:
		"round_start":
			match dice_result:
				Result.PLAYER:
					result_label.text = "Du beginnst!"
				Result.NPC:
					result_label.text = "Gegner beginnt!"
				Result.DRAW:
					result_label.text = "Unentschieden! Nochmal würfeln!"
			await get_tree().create_timer(2.0).timeout
			emit_signal("round_start_dice_finished", dice_result)
		"decide_winner":
			match dice_result:
				Result.PLAYER:
					result_label.text = "Du bekommst die Karten!"
				Result.NPC:
					result_label.text = "Der Gegner bekommt die Karten!"
				Result.DRAW:
					result_label.text = "Unentschieden! Beide bekommen ihre Karte!"
			await get_tree().create_timer(2.0).timeout
			emit_signal("decide_winner_dice_finished", dice_result)


func player_roll() -> void:
	anim_sprite.play("rolling")
	anim.play("jump")
	await get_tree().create_timer(1.0).timeout
	player_result = randi() % 6 + 1
	anim_sprite.play("face_%d" % player_result)
	result_label.text = "Du hast eine " + str(player_result) + " gewürfelt."

func npc_roll() -> void:
	anim_sprite.play("rolling")
	anim.play("jump")
	result_label.text = ""
	npc_result = randi() % 6 + 1
	await get_tree().create_timer(1.0).timeout
	anim_sprite.play("face_%d" % npc_result)
	result_label.text = "Gegner würfelt eine " + str(npc_result) + "."
