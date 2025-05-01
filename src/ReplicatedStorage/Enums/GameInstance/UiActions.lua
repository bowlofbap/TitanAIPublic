-- these actiosn get sent from server to client to indicate what happened on the board

local Actions = {
	SHOW_GUI = "Show",
	DRAW = "Draw",
	UPDATE_FRAMES = "UpdateFrames",
	DISCARD = "Discard",
	CHANGE_PHASE = "ChangePhase",
	RESET_DECK = "ResetDeck",
	PLAY_CARD = "PlayCard",
	GENERIC_RESPONSE = "GenericResponse",
	END_GAME = "End Game",
	OPEN_CARD_PACK = "OpenCardPack",
	DEPLETE_CARD = "DepleteCard",
	DEPLOY_UNIT = "DeployUnit",
	UPDATE_PLAYABLE_CARDS = "UpdatePlayableCards",
	CREATE_UNIT = "CreateUnit",
	MOVE_UNIT = "MoveUnit",
	DEAL_DAMAGE = "DealDamage",
	KILL_UNIT = "KillUnit",
	PLAY_UNIT_ANIMATION = "PlayUnitAnimation",
	PLAY_CARD_ANIMATION = "PlayCardAnimation",
	APPLY_HEAL = "ApplyHeal",
	APPLY_BLOCK = "ApplyBlock",
	UPDATE_STATUS = "UpdateStatus",
	UPDATE_NODE = "UpdateNode",
	SET_PLAYER_UNIT = "SetPlayerUnit"
}

return Actions
