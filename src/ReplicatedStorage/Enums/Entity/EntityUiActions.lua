-- these actiosn get sent from server to client to indicate what happened on the board

local Actions = {
	ENABLE_MAP_CONTROL = "Enable Map Control",
	DISABLE_MAP_CONTROL = "Disable Map Control",
	UPDATE_MAP_DATA = "Update Map Data",
	CONNECT_TO_INSTANCE = "Connect To Instance",
	HIDE_SCREEN = "Hide Screen",
	SHOW_SCREEN = "Show Screen",
	UPDATE_PLAYER_HEALTH = "Update Player Health",
	UPDATE_PLAYER_DECK = "Update Player Deck",
	UPDATE_PLAYER_MONEY = "Update Player Money",
	ADD_ECHOES = "Add Echoes",
	UPDATE_ECHO_COUNT = "Update Echo Count",
	UPGRADE_CARD = "Upgrade Card",
	SHOW_END_GAME = "Show End Game",
	GENERATE_NEW_MAP = "Generate New Map",
	CAMERA_FOCUS_INSTANCE = "Camera Focus Instance",
	DISCONNECT_FROM_INSTANCE = "Disconnect From Instance",
}

return Actions
