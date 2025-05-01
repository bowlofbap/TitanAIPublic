local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiModules = ReplicatedStorage.Client.Classes.Guis
local Object = require(ReplicatedStorage.Helpers.Classes.Object)

local GuiService = Object:extend()

export type GuiService = {
    clearSubscriptions: ()->(),
    setSubscriptions: (clientPlayer: any, guis: any)->(), 
    invoke: (guiName: string, methodName: string, ...any)->any
}

function GuiService.get() : GuiService
    if GuiService._object then
        return GuiService._object 
    end
    GuiService._object = GuiService._new()
    return GuiService._object
end

function GuiService._new()
	local self = setmetatable({}, GuiService)
	self._listeners = {}
	self._nextId = 0
	return self
end

function GuiService:clearSubscriptions()
    self._listeners = {}
    self._nextId = 0
end

function GuiService:getGui(guiName: string)
    assert(type(guiName) == "string", "guiName must be a string")
    local gui = self._listeners[guiName]
    if not gui then 
        warn("Gui "..guiName.. "not found")
    end
    return gui
end

function GuiService:setSubscriptions(clientPlayer, guis)
    self:clearSubscriptions()
    for _, gui in ipairs(guis) do
		local newGuiModule = require(GuiModules[gui.Name])
		local newGui = newGuiModule.new(clientPlayer)
		self._listeners[gui.Name] = newGui
    end
end

function GuiService:invoke(guiName, methodName, ...)
    local gui = self._listeners[guiName]
    if not gui[methodName] then
        warn("Method "..methodName.." in "..guiName.." not found")
    end
    return gui[methodName](gui, ...)
end

function GuiService:showOnly(showGuiName, ...)
    for guiName, gui in pairs(self._listeners) do
        if showGuiName == guiName then
            gui:show(...)
        else
            gui:hide()
        end
    end
end

return GuiService