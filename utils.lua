--[[
	utils.lua
		Some additional functions, they are not related explicitly related
		to the main addon functionality
--]]

local ADDON, Addon = ...

Addon.debug = false

local string = string
local SendChatMessage = SendChatMessage
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME


function Addon:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|c006969FFRaccoonPoints: " .. msg .. "|r")
end

function Addon:DebugMsg(msg)
    if Addon.debug then
        self:Print(msg)
    end
end

function Addon:WriteGuild(msg)
    SendChatMessage(msg, 'GUILD');
end


function Addon:CleanName(name)
	if not name then return; end
	local dash_position = string.find(name, '-');
	if dash_position then
		name = string.sub(name, 0, dash_position - 1);
	end
	return name;
end
