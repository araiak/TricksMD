-- TricksMD: Automatic Tricks of the Trade / Misdirection macro manager
-- Creates and updates a macro called "TankTricks" targeting the current tank

local addonName, addon = ...

-- Constants
local MACRO_NAME = "TankTricks"
local TRICKS_SPELL_ID = 57934  -- Tricks of the Trade (Rogue)
local MD_SPELL_ID = 34477      -- Misdirection (Hunter)

-- Addon namespace
TricksMD = {}
TricksMD.tanks = {}
TricksMD.currentTank = nil
TricksMD.spellName = nil

-- Initialize saved variables
TricksMDDB = TricksMDDB or {}

-- Create main frame for event handling
local frame = CreateFrame("Frame", "TricksMDFrame")

-- Create dropdown menu frame
local menuFrame = CreateFrame("Frame", "TricksMDMenu", UIParent, "UIDropDownMenuTemplate")

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function Print(msg)
    print("|cff00ff00[TricksMD]|r " .. msg)
end

local function GetSpellName()
    -- Check for Tricks of the Trade (Rogue)
    local tricksInfo = C_Spell.GetSpellInfo(TRICKS_SPELL_ID)
    if tricksInfo and IsSpellKnown(TRICKS_SPELL_ID) then
        return tricksInfo.name, TRICKS_SPELL_ID
    end

    -- Check for Misdirection (Hunter)
    local mdInfo = C_Spell.GetSpellInfo(MD_SPELL_ID)
    if mdInfo and IsSpellKnown(MD_SPELL_ID) then
        return mdInfo.name, MD_SPELL_ID
    end

    return nil, nil
end

--------------------------------------------------------------------------------
-- Tank Detection
--------------------------------------------------------------------------------

function TricksMD:GetTanks()
    local tanks = {}

    -- Check if in a group
    if not IsInGroup() then
        return tanks
    end

    local numMembers = GetNumGroupMembers()
    local isRaid = IsInRaid()

    for i = 1, numMembers do
        local unit
        if isRaid then
            unit = "raid" .. i
        else
            if i == numMembers then
                unit = "player"
            else
                unit = "party" .. i
            end
        end

        local role = UnitGroupRolesAssigned(unit)
        if role == "TANK" then
            local name = UnitName(unit)
            if name then
                table.insert(tanks, name)
            end
        end
    end

    -- Sort alphabetically
    table.sort(tanks)

    return tanks
end

function TricksMD:GetCurrentTank()
    local tanks = self:GetTanks()
    self.tanks = tanks

    if #tanks == 0 then
        return nil
    end

    -- Check if preferred tank is still valid
    local preferredTank = TricksMDDB.preferredTank
    if preferredTank then
        for _, tank in ipairs(tanks) do
            if tank == preferredTank then
                return preferredTank
            end
        end
    end

    -- Return first tank alphabetically
    return tanks[1]
end

--------------------------------------------------------------------------------
-- Macro Management
--------------------------------------------------------------------------------

function TricksMD:GetMacroIndex()
    -- Check general macros first (1-120), then character-specific (121-138)
    local index = GetMacroIndexByName(MACRO_NAME)
    return index > 0 and index or nil
end

function TricksMD:UpdateMacro()
    local spellName = GetSpellName()
    if not spellName then
        return false, "You don't have Tricks of the Trade or Misdirection"
    end

    local tank = self:GetCurrentTank()
    self.currentTank = tank

    local macroBody
    if tank then
        macroBody = string.format("/cast [@%s] %s", tank, spellName)
    else
        -- No tank - macro will just cast on current target
        macroBody = string.format("/cast %s", spellName)
    end

    local macroIndex = self:GetMacroIndex()

    if macroIndex then
        -- Update existing macro
        EditMacro(macroIndex, MACRO_NAME, nil, macroBody)
    else
        -- Create new macro
        local numGeneral, numChar = GetNumMacros()
        if numGeneral < 120 then
            CreateMacro(MACRO_NAME, "INV_MISC_QUESTIONMARK", macroBody, false)
        elseif numChar < 18 then
            CreateMacro(MACRO_NAME, "INV_MISC_QUESTIONMARK", macroBody, true)
        else
            return false, "Macro slots full! Delete a macro to use TricksMD."
        end
    end

    return true, tank
end

function TricksMD:SelectTank(name)
    TricksMDDB.preferredTank = name
    local success, result = self:UpdateMacro()

    if success then
        if result then
            Print("Now targeting: " .. result)
        else
            Print("No tanks in group")
        end
    else
        Print(result)
    end
end

--------------------------------------------------------------------------------
-- Popup Menu
--------------------------------------------------------------------------------

local function MenuInitialize(self, level)
    level = level or 1

    local tanks = TricksMD.tanks
    local currentTank = TricksMD.currentTank

    if #tanks == 0 then
        local info = UIDropDownMenu_CreateInfo()
        info.text = "No tanks in group"
        info.disabled = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    -- Add title
    local titleInfo = UIDropDownMenu_CreateInfo()
    titleInfo.text = "Select Tank"
    titleInfo.isTitle = true
    titleInfo.notCheckable = true
    UIDropDownMenu_AddButton(titleInfo, level)

    -- Add tank options
    for _, tank in ipairs(tanks) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = tank
        info.checked = (tank == currentTank)
        info.func = function()
            TricksMD:SelectTank(tank)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info, level)
    end

    -- Add separator and cancel
    local sepInfo = UIDropDownMenu_CreateInfo()
    sepInfo.text = ""
    sepInfo.disabled = true
    sepInfo.notCheckable = true
    UIDropDownMenu_AddButton(sepInfo, level)

    local cancelInfo = UIDropDownMenu_CreateInfo()
    cancelInfo.text = "Cancel"
    cancelInfo.notCheckable = true
    cancelInfo.func = function() CloseDropDownMenus() end
    UIDropDownMenu_AddButton(cancelInfo, level)
end

function TricksMD:ShowMenu()
    -- Refresh tank list before showing menu
    self.currentTank = self:GetCurrentTank()

    UIDropDownMenu_Initialize(menuFrame, MenuInitialize, "MENU")
    ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
end

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------

SLASH_TRICKSMD1 = "/md"
SlashCmdList["TRICKSMD"] = function(msg)
    local spellName = GetSpellName()
    if not spellName then
        Print("This addon requires a Rogue (Tricks of the Trade) or Hunter (Misdirection)")
        return
    end

    msg = strtrim(msg or "")

    if msg == "" then
        -- Show popup menu
        TricksMD:ShowMenu()
    else
        -- Direct tank selection
        local tanks = TricksMD:GetTanks()
        local found = false

        -- Case-insensitive search
        local msgLower = strlower(msg)
        for _, tank in ipairs(tanks) do
            if strlower(tank) == msgLower or strlower(tank):find(msgLower, 1, true) then
                TricksMD:SelectTank(tank)
                found = true
                break
            end
        end

        if not found then
            if #tanks == 0 then
                Print("No tanks in group")
            else
                Print("Tank '" .. msg .. "' not found. Available tanks: " .. table.concat(tanks, ", "))
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            -- Initialize saved variables
            TricksMDDB = TricksMDDB or {}

            -- Check for valid class
            local spellName = GetSpellName()
            if spellName then
                Print("Loaded. Use /md to select tank. Spell: " .. spellName)
                -- Initial macro update
                C_Timer.After(1, function()
                    TricksMD:UpdateMacro()
                end)
            end

            frame:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "GROUP_ROSTER_UPDATE" or
           event == "ROLE_CHANGED_INFORM" or
           event == "PLAYER_ROLES_ASSIGNED" then
        -- Update macro when group composition changes
        local success, result = TricksMD:UpdateMacro()
        if success and result then
            -- Only print if tank changed
            if result ~= TricksMD.lastAnnouncedTank then
                Print("Tank target: " .. result)
                TricksMD.lastAnnouncedTank = result
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Delay to ensure group info is available
        C_Timer.After(2, function()
            TricksMD:UpdateMacro()
        end)

    elseif event == "GROUP_LEFT" then
        -- Clear preferred tank when leaving group
        TricksMDDB.preferredTank = nil
        TricksMD.lastAnnouncedTank = nil
        Print("Left group - tank preference cleared")
    end
end

-- Register events
frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ROLE_CHANGED_INFORM")
frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
frame:RegisterEvent("GROUP_LEFT")
