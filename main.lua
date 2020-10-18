--[[
	main.lua
		File with the addon
--]]

local ADDON, Addon = ...

local MainFrame = LibStub('Poncho-2.0'):NewClass('Frame', 'MainFrame', 'InsetFrameTemplate')

local pairs, tonumber = pairs, tonumber
local GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote, C_ChatInfo = GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote, C_ChatInfo
local LibStub = LibStub

function MainFrame:Construct()
    local frame = self:Super(MainFrame):Construct()

    frame.submitButton = LibStub('Sushi-3.1').RedButton(frame)
    frame.submitButton:SetText('Выдать очки')
    frame.submitButton:SetPoint('BOTTOM', 0, 10)
    frame.submitButton:SetCall('OnClick', Addon.AddPoints)

    frame.closeButton = LibStub('Sushi-3.1').RedButton(frame)
    frame.closeButton:SetText('X')
    frame.closeButton:SetPoint('TOPRIGHT', -10, -10)
    frame.closeButton:SetCall('OnClick', function(button) button:GetParent():Hide() end)
    frame.closeButton:SetSize(16, 16)


    frame.editBox = LibStub('Sushi-3.1').DarkEdit(frame)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetText('Пиши сюда')
    frame.editBox:SetPoint('TOPLEFT', 10, -10)
    frame.editBox:SetAutoFocus(true)

    frame.cachedText = nil

    frame:SetSize(200, 500)
    frame:SetPoint('TOP', 0, -200)
    frame:Show()

    return frame
end


function Addon.AddPoints(button, value)
    local frame = button:GetParent()
    local text = frame.editBox:GetText()

    if frame.cachedText ~= nil and text == frame.cachedText then
        Addon:Print('Ты пытаешься еще раз те же логи загрузить. Если реально надо - поменяй местами строки')
        return
    end
    frame.cachedText = text

    local name_x_points_map = {}

    for row in text:gmatch('[^\r\n]+') do
        local name, extra_ep = row:match('([^,]+),([^,]+)')
        extra_ep = tonumber(extra_ep)
        name_x_points_map[name] = extra_ep
    end

    Addon.IgnoreUpdates()

	for i = 1, GetNumGuildMembers() do
		local name, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
		name = Addon:CleanName(name)
        local extra_points = name_x_points_map[name]
        if extra_points ~= nil then
            local EP, GP = frame:GetEPGP(officerNote)
            EP = EP + extra_points
            frame:SetEPGP(i, EP, GP)

            name_x_points_map[name] = nil
		end
    end

    Addon.StopIgnoreUpdates()

    for name, _ in pairs(name_x_points_map) do
        Addon:Print('Игрок ' .. name .. ' не найден в гильде')
    end
end

function MainFrame:GetEPGP(officerNote)
    local data = {}

    for i in officerNote:gmatch("([^,%s]+)") do
		data[#data + 1] = tonumber(i) or 0
	end

    Addon:DebugMsg(officerNote .. ' Парсится в EP - ' .. data[1] .. ' GP - ' .. data[2])
    return data[1], data[2]
end

function MainFrame:SetEPGP(index, EP, GP)
    Addon:DebugMsg('Поменял заметку на  ' .. EP .. ', ' .. GP)
    GuildRosterSetOfficerNote(index, EP .. "," .. GP)
end

function Addon.IgnoreUpdates()
    Addon.SendCEPGPAddonMsg('?IgnoreUpdates;true');
end

function Addon.StopIgnoreUpdates()
    Addon.SendCEPGPAddonMsg('?IgnoreUpdates;false');
end


function Addon.SendCEPGPAddonMsg(msg)
	local prefix = 'CEPGP'
    C_ChatInfo.SendAddonMessage(prefix, msg, 'GUILD')
end


function Addon:ShowMainFrame()
    if self.mainFrame == nil then
        self.mainFrame = MainFrame(UIParent)
        self.mainFrame:SetPoint('TOPRIGHT', -150, -25)
    end

    self.mainFrame:Show()
end

function Addon:HideMainFrame()
    self.mainFrame:Hide()
end


function Addon:ToggleMainFrame()
    if self.mainFrame == nil then
        self:ShowMainFrame()
        return
    end

    if self.mainFrame:IsVisible() then
        self:HideMainFrame()
    else
        self:ShowMainFrame()
    end
end