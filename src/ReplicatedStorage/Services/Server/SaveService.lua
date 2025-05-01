local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Object = require(ReplicatedStorage.Helpers.Classes.Object)
local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)

local PROFILE_TEMPLATE = {
    data = {}
 }

 local function getStoreName()
   return RunService:IsStudio() and "Test" or "Live"
 end
 
 local PlayerStore = ProfileStore.New(getStoreName(), PROFILE_TEMPLATE)
 local Profiles: {[Player]: typeof(PlayerStore:StartSessionAsync())} = {}
 
local SaveService = Object:extend()

export type SaveService = {
    saveData: (data: any)->boolean,
    loadData: ()->table,
    initSession: (player: Player)->()
}

function SaveService.get() : SaveService
    if SaveService._object then
        return SaveService._object 
    end
    SaveService._object = SaveService._new()
    return SaveService._object
end

function SaveService._new()
	local self = setmetatable({}, SaveService)
	return self
end

function SaveService:initSession(player)
    local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
           return player.Parent ~= Players
        end,
     })
  
     -- Handling new profile session or failure to start it:
  
     if profile ~= nil then
  
        profile:AddUserId(player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)
  
        profile.OnSessionEnd:Connect(function()
           Profiles[player] = nil
           player:Kick(`Profile session end - Please rejoin`)
        end)
  
        if player.Parent == Players then
           Profiles[player] = profile
           print(`Profile loaded for {player.DisplayName}!`)
           -- EXAMPLE: Grant the player 100 coins for joining:
           -- profile.Data.Cash += 100
           -- You should set "Cash" in PROFILE_TEMPLATE and use "Profile:Reconcile()",
           -- otherwise you'll have to check whether "Data.Cash" is not nil
        else
           -- The player has left before the profile session started
           profile:EndSession()
        end
  
     else
        -- This condition should only happen when the Roblox server is shutting down
        player:Kick(`Profile load fail - Please rejoin`)
     end
end

function SaveService:saveData(player, dataTable)
   local profile = Profiles[player]
   if not profile then
      warn("No profile for", player)
      return false
   end

   for key, data in pairs(dataTable) do
      profile.Data[key] = data
   end
   print(dataTable)
   profile:Save()
   print("Profile for "..player.Name.." is saved")
   return true
end

function SaveService:loadData(player)
   local profile = Profiles[player]
   if not profile then
      warn("No profile for", player)
      return nil
   end
   print("Retrieved data for "..player.Name, profile.Data)
   return profile.Data
end

return SaveService