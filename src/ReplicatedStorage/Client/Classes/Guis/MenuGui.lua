local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)
local GuiEvents = game:GetService("ReplicatedStorage").Client.BindableEvents
--THIS is wher ethe game is kicked off from
local StartEntity = game:GetService("ReplicatedStorage").Remotes.StartEntity

local AudioRepo = require(game:GetService("ReplicatedStorage").Repos.AudioRepo)
local AudioEvent = game:GetService("ReplicatedStorage").Remotes.AudioEvent
local AudioSettings = require(game:GetService("ReplicatedStorage").Enums.Client.AudioSettings)

local UserInputService = game:GetService("UserInputService")

local player = game:GetService("Players").LocalPlayer

local MenuGui = setmetatable({}, { __index = BaseGui }) 
MenuGui.__index = MenuGui

function MenuGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, MenuGui)
	
	self:init()
	return self
end

function MenuGui:init()
	local frame = self.object.Frame.Buttons
	local options = frame.OptionsButton
	local battle = frame.BattleButton
	
	battle.MouseButton1Click:Connect(function()
		AudioEvent:Fire(AudioSettings.PLAY_SOUND, AudioRepo.UI.Confirm)
		self:hide()
		local entityFolder = StartEntity:InvokeServer()
		if entityFolder then
			self.clientPlayer:initGameEntity(entityFolder)
		else
			warn("No entity returned")
		end
	end)
end


return MenuGui