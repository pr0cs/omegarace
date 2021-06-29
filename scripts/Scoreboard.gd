extends Node

onready var mod_player:ModPlayer = $ModPlayer

signal score_updated
signal player_died
signal wave_updated
signal enemy_killed
signal rotation

# Enums
enum EnemyDir{LEFT, UP, RIGHT, DOWN}
enum WaveType{	NORMAL, # normal, nothing special
				HYPER,	# fast movement
				HORDE,	# lots of baddies
				BLITZ}	# lots of evolvers

# Global Vars
var rng = RandomNumberGenerator.new()

# signal variables
var rotation: = 0.0 setget set_rotation
var score: = 0 setget set_score
var lives: = 0 setget set_lives
var wave: = 1 setget set_wave
var currentWaveType = WaveType.NORMAL

# local variables
var hiscore: = 0
var playerPos:Vector2 = Vector2.ZERO

func play_music()->void:
	mod_player.file = "res://assets/MOD.Raising Hell.mod"
	mod_player.play()

func stop_music()->void:
	mod_player.stop()
	
func set_player_position(pos:Vector2)->void:
	playerPos = pos

func get_player_position()->Vector2:
	return playerPos
	
func get_random_wavetype() -> int:
	if wave < 5:
		print("Wave:Easy/Normal")
		return WaveType.NORMAL
	else:
		var chance = rng.randi() & 100
		# this could feasibly look at the wave and get progressively harder
		if( chance < 40):
			print("Wave:Normal")
			return WaveType.NORMAL
		elif chance >39 and chance < 60:
			print("Wave:Hyper")
			return WaveType.HYPER
		elif chance > 59 and chance < 80:
			print("Wave:Horde")
			return WaveType.HORDE
		elif chance > 79:
			print("Wave:Blitz")
			return WaveType.BLITZ
	print("Wave:Default Normal")
	return WaveType.NORMAL
	
func set_current_wavetype(waveType:int) -> void:
	currentWaveType = waveType

func get_current_wavetype() -> int:
	return currentWaveType
	
func isGameOver() -> bool:
	return (lives<=0)

func set_rotation(value:float) -> void:
	rotation = value
	emit_signal("rotation",rotation)

func set_score(value: int) -> void:
	score = value
	if score > hiscore:
		hiscore = score
	emit_signal("score_updated")
	return
	
func set_lives(value: int) -> void:
	var died:bool=lives>value
	lives=value
	if(died):
		emit_signal("player_died")
	return

func set_wave(value:int) -> void:
	wave = value
	emit_signal("wave_updated")
	return


func enemy_killed(enemy:Node2D) -> void:
	var value = enemy.get_score_value()
	set_score(score+value)
	emit_signal("enemy_killed",enemy)

	
func randomize() -> void:
	rng.randomize()
	
func randi_range(start:int,end:int) -> int:
	return rng.randi_range(start,end)

func randi(end:int)->int:
	return rng.randi()%end

func randf_range(start:float,end:float) -> float:
	return rng.randf_range(start,end)
