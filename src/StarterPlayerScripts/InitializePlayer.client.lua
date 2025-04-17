
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local RobloxPlayer = game.Players.LocalPlayer
local ClientScripts = game:GetService("ReplicatedStorage").Client
local Player = require(ClientScripts.Classes.Player)
local GuiManager = require(ClientScripts.Classes.GuiManager)
local AudioHandler = require(ClientScripts.Classes.AudioHandler)
local AudioSettings = require(game:GetService("ReplicatedStorage").Enums.Client.AudioSettings)
local AudioClientEvent = game:GetService("ReplicatedStorage").Remotes.AudioClientEvent
local AudioEvent = game:GetService("ReplicatedStorage").Remotes.AudioEvent
local AudioRepo = require(game:GetService("ReplicatedStorage").Repos.AudioRepo)

local newPlayer = Player.new(RobloxPlayer)
local guiManager = GuiManager.new(newPlayer)
local audioHandler = AudioHandler.new()

guiManager.guis.MenuGui:show()

function playSound(audioSetting, audioData, delay)
	if audioSetting == AudioSettings.PLAY_SOUND then
		audioHandler:PlaySound(audioData)
	elseif audioSetting == AudioSettings.PLAY_MUSIC then
		audioHandler:PlayMusic(audioData, delay)
	end
end

AudioClientEvent.OnClientEvent:Connect(playSound)
AudioEvent.Event:Connect(playSound)

playSound(AudioSettings.PLAY_MUSIC, AudioRepo.Music.MainMenu)