extends PopupDialog

func updateScoreboard()->void:
	var sv = $InfoPanel/ScoreValue
	var wv = $InfoPanel/WavesValue
	var sf = $InfoPanel/ShotsValue
	var ac = $InfoPanel/AccuracyValue
	var mk = $InfoPanel/MinesValue
	var ek = $InfoPanel/EnemyKillsValue
	sv.text = "%s" % Scoreboard.score
	wv.text = "%s" % (Scoreboard.wave-1)
	sf.text = "%s" % Scoreboard.shotsFired
	ek.text = "%s" % Scoreboard.enemyKills
	var accuracy:float = 0.0
	if(Scoreboard.shotsFired>0.0):
		accuracy = (float(Scoreboard.shotsHit) / float(Scoreboard.shotsFired) * 100.0)
	ac.text = "%3.1f" % accuracy
	ac.text += "%"
	mk.text = "%s" % Scoreboard.minesDestroyed

func _on_Cancel_pressed():
	get_tree().change_scene("res://scenes/Start.tscn")
