extends Player


enum {EASY=1, MEDIUM=2, HARD=3, MAD_GENIUS=4}

func _init(level).("AI level " + str(level), []):
    pass


#* This is an override of player's takeTurn()
func takeTurn(underAttack):
    if underAttack:
        defend()


func defend():
    pass


func decideAttack():
    pass
