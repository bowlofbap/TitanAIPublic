local GuiModules = script.Parent.Guis
local PCGuis = game:GetService("StarterGui").PC:GetChildren()
--Change this when getting mobile
local BindableEvents = game:GetService("ReplicatedStorage").Client.BindableEvents
local BindableFunctions = game:GetService("ReplicatedStorage").Client.BindableFunctions

local UserInputService = game:GetService("UserInputService")

local GuiManager = {}
GuiManager.__index = GuiManager

function GuiManager.new(clientPlayer)
	local newManager = {}
	setmetatable(newManager, GuiManager)
	
	newManager.guis = {}
	for _, gui in ipairs(PCGuis) do
		local newGuiModule = require(GuiModules[gui.Name])
		local newGui = newGuiModule.new(clientPlayer)
		local indexName = gui.Name
		newManager.guis[indexName] = newGui
	end
	
	newManager:bindEvents()
	print("GuiManager Loaded")
	return newManager
end

function GuiManager:bindEvents()
	
	BindableEvents.GuiEvent.Event:Connect(function(guiName, methodName, ...)
		if guiName == "ALL" then
			self:hideAll()
			return
		elseif methodName == "EXCEPT" then
			self:hideAllBut(guiName)
			return
		end
		
		local gui = self.guis[guiName]
		if gui and gui[methodName] then
			gui[methodName](gui, ...)
		elseif not gui then
			warn("Invalid Gui:", guiName)
		else
			warn("Invalid method:", guiName, methodName)
		end
	end)

	BindableFunctions.GuiFunction.OnInvoke = function(guiName, methodName, ...)
		local gui = self.guis[guiName]
		if gui and gui[methodName] then
			return gui[methodName](gui, ...)
		elseif not gui then
			warn("Invalid Gui:", guiName)
		else
			warn("Invalid method:", guiName, methodName)
		end
	end
end

function GuiManager:hideAll()
	for _, gui in pairs(self.guis) do
		gui:hide()
	end
end

function GuiManager:hideAllBut(guiName)
	self:hideAll()
	self.guis[guiName]:show()
end

return GuiManager