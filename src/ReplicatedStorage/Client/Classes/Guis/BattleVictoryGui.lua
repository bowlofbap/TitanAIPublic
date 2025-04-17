local BaseGui = require(game:GetService("ReplicatedStorage").Client.Classes.Guis.BaseGui)

local RewardTypes = require(game:GetService("ReplicatedStorage").Enums.GameInstance.RewardTypes)
local GameDataRequests = require(game:GetService("ReplicatedStorage").Enums.GameDataRequests)
local GameActions = require(game:GetService("ReplicatedStorage").Enums.GameActions)
local rewardFrame = game:GetService("ReplicatedStorage").Models.UI.Reward

local player = game:GetService("Players").LocalPlayer

local BattleVictoryGui = setmetatable({}, { __index = BaseGui }) 
BattleVictoryGui.__index = BattleVictoryGui

function BattleVictoryGui.new(clientPlayer)
	local self = BaseGui.new(clientPlayer, script.Name)
	setmetatable(self, BattleVictoryGui)
	self:init()
	return self
end

function BattleVictoryGui:init()
	self.object.ContinueButton.MouseButton1Click:Connect(function()
		self:hide()
		self.clientPlayer:getEntity():getCurrentInstance():requestGameAction(GameActions.END_GAME)
	end)
end

function BattleVictoryGui:updateRewards(rewards)
	for _, reward in ipairs(rewards) do
		local frame = rewardFrame:Clone()
		frame.Parent = self.object.Frame
		local text = ""
		if reward.rewardType.class == RewardTypes.MONEY_SMALL.class then
			text = reward.value .. " "..reward.rewardType.label
		elseif reward.rewardType.class == RewardTypes.ECHO_COMMON.class then
			text = reward.echoName
		else
			text = reward.rewardType.label
		end
		frame.TextLabel.Text = text
		frame.ImageLabel.Image = reward.rewardType.image
		
		frame.MouseButton1Click:Connect(function()
			local response = self.clientPlayer:getEntity():getCurrentInstance():requestGameData(GameDataRequests.OPEN_REWARD, {id = reward.id})
			if response then
				print("Success")
				frame:Destroy()
			end
		end)
	end
end

function BattleVictoryGui:reset()
	for _, frame in ipairs(self.object.Frame:GetChildren()) do
		if frame.ClassName == "ImageButton" then
			frame:Destroy()
		end
	end
end

function BattleVictoryGui:show(rewards)
	--[[
	rewards = {
		{
			rewardType = REWARDTYPE,
			value = VALUE,
			id = REWARD_ID
		},
		
	}	
	]]
	self:reset()
	self:updateRewards(rewards)
	self.object.Enabled = true
end

return BattleVictoryGui