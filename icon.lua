local ADDON, Addon = ...

Addon.IconAddon = LibStub('WildAddon-1.0'):NewAddon(ADDON, Addon)

local function OnClick()
    Addon:ToggleMainFrame()
end

local iconLDB = LibStub("LibDataBroker-1.1"):NewDataObject("RaccoonPointsIcon", {
    type = "data source",
    text = "RaccoonPointsIcon",
    icon = 'Interface/ICONS/INV_Jewelry_Ring_30.PNG',
    OnClick = OnClick,
})

local icon = LibStub("LibDBIcon-1.0")

function Addon.IconAddon:OnEnable()
    self.db = LibStub("AceDB-3.0"):New("RaccoonPointsDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    })
    icon:Register("RaccoonPointsIcon", iconLDB, self.db.profile.minimap)
end
