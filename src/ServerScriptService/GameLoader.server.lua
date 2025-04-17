local EntityManager = require(game:GetService("ServerScriptService").GameEntity.EntityManager)
local AudioRepo = require(game:GetService("ReplicatedStorage").Repos.AudioRepo)
local AudioClientEvent = game:GetService("ReplicatedStorage").Remotes.AudioClientEvent
local AudioSettings = require(game:GetService("ReplicatedStorage").Enums.Client.AudioSettings)

local StartEntity = game:GetService("ReplicatedStorage").Remotes.StartEntity --apparently this is bad practice lol?
local EndEntity = game:GetService("ReplicatedStorage").Remotes.EndEntity --apparently this is bad practice lol?

local manager = EntityManager.new()

StartEntity.OnServerInvoke = function(player)
	local data = require(game:GetService("ReplicatedStorage").Repos.StarterRepos.Ze)
	local newEntity = manager:initPlayerEntity(player, data)
	AudioClientEvent:FireClient(player, AudioSettings.PLAY_MUSIC, AudioRepo.Music.Game, 0)
	return newEntity.entityFolder
end

EndEntity.OnServerInvoke = function(player)
	local success = manager:removePlayerEntity(player)
	--TODO: remove the player entity from the client 
	return success
end