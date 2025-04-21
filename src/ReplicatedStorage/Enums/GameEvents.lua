local GameEvents = {
	--GAME INSTANCE EVENTS--
	GAME_START = "Game Start",
	FINISH_GAME = "Game Finished",
	LOADED_UNIT = "Loaded Unit",
	BEFORE_MOVE = "Before Moving",
	MOVED = "Moved",
	ATTACKING = "Attacking",
	BEFORE_DAMAGE = "Before Damage",
	AFTER_DAMAGE = "After Damage",
	HEALING = "Healing",
	DEATH = "Dead",
	CHANGE_PHASE = "Turn Change",
	START_UNIT_TURN = "Start Unit Turn",
	END_UNIT_TURN = "End Unit Turn",
	PLAY_CARD = "Play Card",
	DRAW = "Draw",
	SHUFFLE = "Shuffle",
	BLOCKING = "Blocking",
	APPLYING_BLOCK = "Apply block",
	DEPLETING_CARD = "Depleting Card",
	OPENING_CARD_PACK = "Opening card pack",
	HEALTH_CHANGED = "Health Changed",
	GRANT_ENERGY = "Grant Energy",
	
	--GAME ENTITY EVENTS--
	PLAYER_HEALTH_CHANGED = "Player Health Changed", -- for maxhealth as well
	PLAYER_HEALTH_HURT_HEAL = "Player Health hurt/heal",
	CHANGE_MONEY = "Change Money",
	ADD_CARD = "Add to Deck",
	ADD_ECHO = "Add Echo",
	UPDATE_ECHO_COUNT = "Update Echo Count",
	ENTERED_INSTANCE = "Entered Instance",
	FINISH_INSTANCE = "Finished Instance",
	UPGRADE_CARD = "Upgrade Card",
	CONNECT_TO_INSTANCE = "Connect To Instance"
	--SHOP INSTANCE EVENTS--
	
	--CHEST INSTANCE EVENTS--
	
	--EVENT INSTANCE EVENTS--
}

return GameEvents