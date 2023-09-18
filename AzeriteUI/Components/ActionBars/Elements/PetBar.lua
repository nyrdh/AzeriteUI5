--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
local _, ns = ...

if (ns.API.IsAddOnEnabled("ConsolePort_Bar")) then return end

local L = LibStub("AceLocale-3.0"):GetLocale((...))

local PetBarMod = ns:NewModule("PetBar", "LibMoreEvents-1.0", "LibFadingFrames-1.0", "AceConsole-3.0", "AceTimer-3.0")

local LFF = LibStub("LibFadingFrames-1.0")

local ButtonBar = ns.ButtonBar.prototype

local PetBar = setmetatable({}, { __index = ButtonBar })
local PetBar_MT = { __index = PetBar }

-- GLOBALS: InCombatLockdown, hooksecurefunc
-- GLOBALS: GetBindingKey, ClearOverrideBindings, SetOverrideBindingClick
-- GLOBALS: RegisterStateDriver, UnregisterStateDriver
-- GLOBALS: NUM_PET_ACTION_SLOTS

-- Lua API
local next = next
local select = select
local setmetatable = setmetatable
local unpack = unpack

-- Addon API
local Colors = ns.Colors
local GetMedia = ns.API.GetMedia
local RegisterCooldown = ns.Widgets.RegisterCooldown
local UIHider = ns.Hider
local noop = ns.Noop

local defaults = { profile = ns:Merge({
	enabled = true,
	enableBarFading = true, -- whether to enable non-combat/hover button fading
	fadeInCombat = true, -- whether to keep fading out even in combat
	fadeAlone = true,
	fadeFrom = 1, -- which button to start the button fading from
	numbuttons = NUM_PET_ACTION_SLOTS, -- total number of buttons on the bar
	layout = "grid", -- currently applied layout type
	startAt = 1, -- at which button the zigzag pattern should begin
	growth = "horizontal", -- which direction the bar goes in
	growthHorizontal = "RIGHT", -- the bar's horizontal growth direction
	growthVertical = "DOWN", -- the bar's vertical growth direction
	padding = 8, -- horizontal padding between the buttons
	breakpadding = 8, -- vertical padding between the buttons
	breakpoint = NUM_PET_ACTION_SLOTS, -- when to start a new grid row
	offset = 44/64, -- 44 -- relative offset in the growth direction for the alternate zigzag row as a fraction of button size.
	hitrects = { -10, -10, -10, -10 }
}, ns.Module.defaults) }

PetBarMod.GenerateDefaults = function(self)
	defaults.profile.savedPosition = {
		scale = ns.API.GetEffectiveScale(),
		[1] = "BOTTOM",
		[2] = 0,
		[3] = 200 * ns.API.GetEffectiveScale()
	}
	return defaults
end

local onEnter = function(self)
	self.icon.darken:SetAlpha(0)
	if (self.OnEnter) then
		self:OnEnter()
	end
end

local onLeave = function(self)
	self.icon.darken:SetAlpha(.1)
	if (self.OnLeave) then
		self:OnLeave()
	end
end

local style = function(button)

	local db = ns.GetConfig("PetActionButton")

	-- Clean up the button template
	for _,i in next,{ --[["AutoCastShine",]] "Border", "Name", "NewActionTexture", "NormalTexture", "SpellHighlightAnim", "SpellHighlightTexture",
		--[[ WoW10 ]] "CheckedTexture", "HighlightTexture", "BottomDivider", "RightDivider", "SlotArt", "SlotBackground" } do
		if (button[i] and button[i].Stop) then button[i]:Stop() elseif button[i] then button[i]:SetParent(UIHider) end
	end

	-- Wrath overwrites the default texture
	if (ns.IsWrath) then
		button.AutoCastable = _G[button:GetName().."AutoCastable"]
		button.AutoCastShine = _G[button:GetName().."Shine"]
	end

	local m = db.ButtonMaskTexture
	local b = "" -- GetMedia("blank")

	button:SetAttribute("buttonLock", true)
	button:SetSize(unpack(db.ButtonSize))
	button:SetHitRectInsets(unpack(db.ButtonHitRects))
	button:SetNormalTexture("")
	button:SetHighlightTexture("")
	button:SetCheckedTexture("")
	button:GetHighlightTexture():Hide()
	button:GetCheckedTexture():Hide()

	-- New 3.4.1 checked texture keeps being reset.
	hooksecurefunc(button, "SetChecked", function() button:GetCheckedTexture():Hide() end)

	-- Custom slot texture
	local backdrop = button:CreateTexture(nil, "BACKGROUND", nil, -7)
	backdrop:SetSize(unpack(db.ButtonBackdropSize))
	backdrop:SetPoint(unpack(db.ButtonBackdropPosition))
	backdrop:SetTexture(db.ButtonBackdropTexture)
	backdrop:SetVertexColor(unpack(db.ButtonBackdropColor))
	button.backdrop = backdrop

	-- Icon
	local icon = button.icon
	icon:SetDrawLayer("BACKGROUND", 1)
	icon:ClearAllPoints()
	icon:SetPoint(unpack(db.ButtonIconPosition))
	icon:SetSize(unpack(db.ButtonIconSize))

	local i = 1
	while button.icon:GetMaskTexture(i) do
		button.icon:RemoveMaskTexture(button.icon:GetMaskTexture(i))
		i = i + 1
	end
	if (button.IconMask) then
		icon:RemoveMaskTexture(button.IconMask)
	end
	icon:SetMask(m)

	-- Custom icon darkener
	local darken = button:CreateTexture(nil, "BACKGROUND", nil, 2)
	darken:SetAllPoints(button.icon)
	darken:SetTexture(m)
	darken:SetVertexColor(0, 0, 0, .1)
	button.icon.darken = darken

	button.OnEnter = button:GetScript("OnEnter")
	button.OnLeave = button:GetScript("OnLeave")

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)

	-- Some crap WoW10 border I can't figure out how to remove right now.
	button:DisableDrawLayer("ARTWORK")

	-- Button is pushed
	-- Responds to mouse and keybinds
	-- if we allow blizzard to handle it.
	local pushedTexture = button:CreateTexture(nil, "OVERLAY", nil, 1)
	pushedTexture:SetVertexColor(1, 1, 1, .05)
	pushedTexture:SetTexture(m)
	pushedTexture:SetAllPoints(button.icon)
	button.pushedTexture = pushedTexture

	button:SetPushedTexture(button.pushedTexture)
	button:GetPushedTexture():SetBlendMode("ADD")
	button:GetPushedTexture():SetDrawLayer("OVERLAY", 1)

	-- Autoattack flash
	local flash = button.Flash
	flash:SetDrawLayer("OVERLAY", 2)
	flash:SetAllPoints(icon)
	flash:SetVertexColor(1, 0, 0, .25)
	flash:SetTexture(m)
	flash:Hide()

	-- Button cooldown frame
	local cooldown = button.cooldown
	cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
	cooldown:ClearAllPoints()
	cooldown:SetAllPoints(button.icon)
	cooldown:SetReverse(false)
	cooldown:SetSwipeTexture(m)
	cooldown:SetDrawSwipe(true)
	cooldown:SetBlingTexture(b, 0, 0, 0, 0)
	cooldown:SetDrawBling(false)
	cooldown:SetEdgeTexture(b)
	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)

	-- Custom overlay frame
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetFrameLevel(button:GetFrameLevel() + 3)
	overlay:SetAllPoints()
	button.overlay = overlay

	local border = overlay:CreateTexture(nil, "BORDER", nil, 1)
	border:SetPoint(unpack(db.ButtonBorderPosition))
	border:SetSize(unpack(db.ButtonBorderSize))
	border:SetTexture(db.ButtonBorderTexture)
	border:SetVertexColor(unpack(db.ButtonBorderColor))
	button.iconBorder = border

	-- Custom spell highlight
	local spellHighlight = overlay:CreateTexture(nil, "ARTWORK", nil, -7)
	spellHighlight:SetTexture(db.ButtonSpellHighlightTexture)
	spellHighlight:SetSize(unpack(db.ButtonSpellHighlightSize))
	spellHighlight:SetPoint(unpack(db.ButtonSpellHighlightPosition))
	spellHighlight:Hide()
	button.spellHighlight = spellHighlight

	-- Custom cooldown count
	local cooldownCount = overlay:CreateFontString(nil, "ARTWORK", nil, 1)
	cooldownCount:SetPoint(unpack(db.ButtonCooldownCountPosition))
	cooldownCount:SetFontObject(db.ButtonCooldownCountFont)
	cooldownCount:SetJustifyH(db.ButtonCooldownCountJustifyH)
	cooldownCount:SetJustifyV(db.ButtonCooldownCountJustifyV)
	cooldownCount:SetTextColor(unpack(db.ButtonCooldownCountColor))
	button.cooldownCount = cooldownCount

	-- Button charge/stack count
	local count = button.Count
	count:SetParent(overlay)
	count:SetDrawLayer("OVERLAY", 1)
	count:ClearAllPoints()
	count:SetPoint(unpack(db.ButtonCountPosition))
	count:SetFontObject(db.ButtonCountFont)
	count:SetJustifyH(db.ButtonCountJustifyH)
	count:SetJustifyV(db.ButtonCountJustifyV)

	-- Button keybind
	local hotkey = button.HotKey
	hotkey:SetParent(overlay)
	hotkey:SetDrawLayer("OVERLAY", 1)
	hotkey:ClearAllPoints()
	hotkey:SetPoint(unpack(db.ButtonKeybindPosition))
	hotkey:SetJustifyH(db.ButtonKeybindJustifyH)
	hotkey:SetJustifyV(db.ButtonKeybindJustifyV)
	hotkey:SetFontObject(db.ButtonKeybindFont)
	hotkey:SetTextColor(unpack(db.ButtonKeybindColor))

	-- Todo: Adjust size of this.
	local autoCastable = button.AutoCastable
	autoCastable:SetParent(overlay)
	autoCastable:ClearAllPoints()
	autoCastable:SetPoint("TOPLEFT", -db.ButtonAutoCastableOffset, db.ButtonAutoCastableOffset)
	autoCastable:SetPoint("BOTTOMRIGHT", db.ButtonAutoCastableOffset, -db.ButtonAutoCastableOffset)

	-- Todo: Check if I should add a round texture here
	local autoCastShine = button.AutoCastShine
	autoCastShine:SetParent(overlay)
	autoCastShine:ClearAllPoints()
	autoCastShine:SetPoint("TOPLEFT", -db.ButtonAutoCastShineOffset, db.ButtonAutoCastShineOffset)
	autoCastShine:SetPoint("BOTTOMRIGHT", db.ButtonAutoCastShineOffset, -db.ButtonAutoCastShineOffset)

	RegisterCooldown(button.cooldown, button.cooldownCount)

	hooksecurefunc(cooldown, "SetSwipeTexture", function(c,t) if t ~= m then c:SetSwipeTexture(m) end end)
	hooksecurefunc(cooldown, "SetBlingTexture", function(c,t) if t ~= b then c:SetBlingTexture(b,0,0,0,0) end end)
	hooksecurefunc(cooldown, "SetEdgeTexture", function(c,t) if t ~= b then c:SetEdgeTexture(b) end end)
	hooksecurefunc(cooldown, "SetSwipeColor", function(c,r,g,b,a) if not a or a>.76 then c:SetSwipeColor(r,g,b,.75) end end)
	hooksecurefunc(cooldown, "SetDrawSwipe", function(c,h) if not h then c:SetDrawSwipe(true) end end)
	hooksecurefunc(cooldown, "SetDrawBling", function(c,h) if h then c:SetDrawBling(false) end end)
	hooksecurefunc(cooldown, "SetDrawEdge", function(c,h) if h then c:SetDrawEdge(false) end end)
	hooksecurefunc(cooldown, "SetHideCountdownNumbers", function(c,h) if not h then c:SetHideCountdownNumbers(true) end end)
	hooksecurefunc(cooldown, "SetCooldown", function(c) c:SetAlpha(.75) end)

	hooksecurefunc(button, "SetNormalTexture", function(b,...) if(...~="")then b:SetNormalTexture("") end end)
	hooksecurefunc(button, "SetHighlightTexture", function(b,...) if(...~="")then b:SetHighlightTexture("") end end)
	hooksecurefunc(button, "SetCheckedTexture", function(b,...) if(...~="")then b:SetCheckedTexture("") end end)

	-- Disable masque for our buttons,
	-- they are not compatible.
	button.AddToMasque = noop
	button.AddToButtonFacade = noop
	button.LBFSkinned = nil
	button.MasqueSkinned = nil

	return button
end

PetBar.CreateButton = function(self, buttonConfig)

	local id = #self.buttons + 1
	local button = ns.PetButton.Create(id, self:GetName().."Button"..id, self, buttonConfig)
	button.header = self

	self:SetFrameRef("Button"..id, button)
	self.buttons[id] = button

	local keyBoundTarget = "BONUSACTIONBUTTON"..id
	button.keyBoundTarget = keyBoundTarget

	local buttonConfig = buttonConfig or button.config or {}
	buttonConfig.keyBoundTarget = keyBoundTarget
	buttonConfig.clickOnDown = self.config.clickOnDown

	button:UpdateConfig(buttonConfig)

	return button
end

PetBar.Enable = function(self)
	ButtonBar.Enable(self)
	self:Update()
end

PetBar.Disable = function(self)
	ButtonBar.Disable(self)
	self:Update()
end

PetBar.Update = function(self)
	if (InCombatLockdown()) then return end

	self:UpdateButtonConfig()
	self:UpdateButtons()
	self:UpdateButtonLayout()
	self:UpdateVisibilityDriver()
	self:UpdateBindings()
	self:UpdateFading()

	for id,button in next,self.buttons do
		button:Update()
	end
end

PetBar.UpdateFading = function(self)

	local config, buttons = self.config, self.buttons

	if (config.enabled and config.enableBarFading) then

		-- Remove any previous fade registrations.
		for id = 1, #buttons do
			LFF:UnregisterFrameForFading(buttons[id])
		end

		-- Register fading for selected buttons.
		for id = config.fadeFrom or 1, #buttons do
			LFF:RegisterFrameForFading(buttons[id], config.fadeAlone and self:GetName() or "actionbuttons", unpack(config.hitrects))
		end

	else

		-- Unregister all fading.
		for id, button in next,buttons do
			LFF:UnregisterFrameForFading(buttons[id])
		end
	end

end

PetBar.UpdateBindings = function(self)
	if (InCombatLockdown()) then return end
	if (not next(self.buttons)) then return end

	ClearOverrideBindings(self)

	if (not self:IsEnabled()) then return end

	if (ns.IsRetail) then
		for id,button in next,self.buttons do
			local bindingAction = button.keyBoundTarget
			if (bindingAction) then

				-- iterate through the registered keys for the action
				local buttonName = button:GetName()
				for keyNumber = 1,select("#", GetBindingKey(bindingAction)) do

					-- get a key for the action
					local key = select(keyNumber, GetBindingKey(bindingAction))
					if (key and (key ~= "")) then

						-- this is why we need named buttons
						SetOverrideBindingClick(self, false, key, buttonName) -- assign the key to our own button

					end
				end
			end
		end
	else
		for id,button in next,self.buttons do
			local bindingAction = button.keyBoundTarget
			if (bindingAction) then

				-- iterate through the registered keys for the action
				local buttonName = "CLICK "..button:GetName()..":LeftButton"
				for keyNumber = 1,select("#", GetBindingKey(buttonName)) do

					-- get a key for the action
					local key = select(keyNumber, GetBindingKey(buttonName))
					if (key and (key ~= "")) then
						SetOverrideBinding(self, false, key, bindingAction) -- assign the key to our own button
					end
				end
			end
		end

	end

end

PetBar.UpdateVisibilityDriver = function(self)
	if (InCombatLockdown()) then return end

	local config = self.config

	local visdriver
	if (config.enabled) then

		visdriver = "[petbattle]hide;"

		if (ns.IsClassic or ns.IsTBC) then
			visdriver = visdriver.."[@pet,exists]show;"

		elseif (ns.IsWrath) then
			-- UNTESTED!
			visdriver = visdriver.."[@pet,exists,nopossessbar,nooverridebar,noshapeshift,novehicleui]show;"

		elseif (ns.IsRetail) then
			-- Experimental change to avoid duplicate bars on some world quests.
			visdriver = visdriver.."[@pet,exists,nopossessbar,nooverridebar,noshapeshift,novehicleui]show;"
		end

		visdriver = visdriver.."hide"
	end

	UnregisterStateDriver(self, "vis")
	self:SetAttribute("state-vis", "0")
	RegisterStateDriver(self, "vis", visdriver or "hide")
end

PetBarMod.CreateBar = function(self)
	if (self.bar) then return end

	local config = ns.GetConfig("PetActionButton")

	local bar = setmetatable(ns.ButtonBar:Create("PetBar", self.db.profile, ns.Prefix.."PetBar"), PetBar_MT)
	bar.buttonWidth, bar.buttonHeight = unpack(config.ButtonSize)
	bar.defaults = defaults.profile
	bar.config = self.db.profile

	if (ns.WoW10) then
		bar.config.clickOnDown = GetCVarBool("ActionButtonUseKeyDown")
	end

	bar:SetAttribute("UpdateVisibility", [[
		local visibility = self:GetAttribute("visibility");
		local userhidden = self:GetAttribute("userhidden");
		if (visibility == "show") then
			if (userhidden) then
				self:Hide();
			else
				self:Show();
			end
		elseif (visibility == "hide") then
			self:Hide();
		end
	]])

	bar:SetAttribute("_onstate-vis", [[
		if (not newstate) then
			return
		end
		self:SetAttribute("visibility", newstate);
		self:RunAttribute("UpdateVisibility");
	]])

	for id= 1,NUM_PET_ACTION_SLOTS do
		style(bar:CreateButton())
	end

	self.bar = bar
end

PetBarMod.CreateAnchor = function(self)
	if (self.anchor) then return end
	if (not self.bar) then return end

	local defaults = self:GetDefaults()
	local config = defaults.profile

	local anchor = ns:GetModule("MovableFramesManager"):RequestAnchor()
	anchor:SetScalable(true)
	anchor:SetSize(2,2)
	anchor:SetPoint(config.savedPosition[1], config.savedPosition[2], config.savedPosition[3])
	anchor:SetScale(config.savedPosition.scale)
	anchor:SetTitle(L["Pet Bar"])

	anchor:SetDefaultScale(ns.API.GetEffectiveScale())

	anchor.PreUpdate = function()
		self:UpdateAnchor()
	end

	local r, g, b = unpack(Colors.anchor.actionbars)
	anchor.Overlay:SetBackdropColor(r, g, b, .75)
	anchor.Overlay:SetBackdropBorderColor(r, g, b, 1)

	self.anchor = anchor

end

PetBarMod.GetDefaults = function(self)
	if (self.GenerateDefaults) then
		return self:GenerateDefaults()
	end
	return self.defaults
end

PetBarMod.SetDefaults = function(self, defaults)
	self.db:RegisterDefaults(defaults)
end

PetBarMod.UpdateAnchor = function(self)
	if (not self.anchor) then return end
	if (not self.bar) then return end

	local config = self.db.profile.savedPosition
	if (config) then
		self.anchor:SetSize(self.bar:GetSize())
		self.anchor:SetScale(config.scale)
		self.anchor:ClearAllPoints()
		self.anchor:SetPoint(config[1], UIParent, config[1], config[2], config[3])
	end
end

PetBarMod.UpdateBar = function(self)
	if (not self.bar) then return end

	if (InCombatLockdown()) then
		self.needupdate = true
		return
	end
	self.bar:Update()
end

PetBarMod.UpdateBindings = function(self)
	if (not self.bar) then return end

	if (self.bar:IsEnabled()) then
		self.bar:UpdateBindings()
	end
end

-- Called by the movable frame manager
-- when defaults somehow are changed,
-- like when the user interface scale is modified.
PetBarMod.UpdateDefaults = function(self)
	if (not self.anchor) then return end

	local defaults = self:GetDefaults()
	local config = defaults.profile.savedPosition

	config.scale = self.anchor:GetDefaultScale()
	config[1], config[2], config[3] = self.anchor:GetDefaultPosition()

	self:SetDefaults(defaults)
end

PetBarMod.UpdatePositionAndScale = function(self)
	if (not self.bar) then return end

	if (InCombatLockdown()) then
		self.updateneeded = true
		return
	end

	self.updateneeded = nil

	local config = self.bar.config.savedPosition
	if (config) then

		self.bar:SetScale(config.scale)
		self.bar:ClearAllPoints()
		self.bar:SetPoint(config[1], UIParent, config[1], config[2]/config.scale, config[3]/config.scale)
	end
end

PetBarMod.UpdateEnabled = function(self)
	if (not self.bar) then return end
	if (InCombatLockdown()) then
		self.needupdate = true
		return
	end
	if (self.bar.config.enabled) then
		self.bar:Enable()
	else
		self.bar:Disable()
	end
end

PetBarMod.UpdateSettings = function(self)
	if (InCombatLockdown()) then
		self.needupdate = true
		return
	end

	local clickOnDown = ns:GetModule("ActionBars").db.profile.clickOnDown
	self.db.profile.clickOnDown = clickOnDown
	self.bar.config.clickOnDown = clickOnDown

	self:UpdateEnabled()
	self:UpdateBar()
	self:UpdateBindings()
	self:UpdatePositionAndScale()
	self:UpdateAnchor()
end

PetBarMod.RefreshConfig = function(self)
	self.bar.config = self.db.profile
	self:UpdateSettings()
end

PetBarMod.OnEvent = function(self, event, arg1)
	if (event == "PLAYER_ENTERING_WORLD") then
		self:UpdateSettings()

	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (InCombatLockdown()) then return end
		if (self.needupdate) then
			self.needupdate = nil
			self:UpdateSettings()
		end

	elseif (event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") or event == "PET_UI_UPDATE" or event == "UPDATE_VEHICLE_ACTIONBAR") then
		for id,button in next,self.bar.buttons do
			button:Update()
		end

	elseif (event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "PET_BAR_UPDATE_USABLE" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED") then
		for id,button in next,self.bar.buttons do
			button:Update()
		end

	elseif (event == "UNIT_FLAGS" or event == "UNIT_AURA") and (arg1 == "pet") then
		for id,button in next,self.bar.buttons do
			button:Update()
		end

	elseif (event =="PET_BAR_UPDATE_COOLDOWN") then
		for id,button in next,self.bar.buttons do
			button:UpdateCooldown()
		end

	elseif (event == "PET_BAR_SHOWGRID") then
		for id,button in next,self.bar.buttons do
			button:ShowGrid()
		end

	elseif (event == "PET_BAR_HIDEGRID") then
		for id,button in next,self.bar.buttons do
			button:HideGrid()
		end

	elseif (event == "UPDATE_BINDINGS") then
		self:UpdateBindings()
	end
end

PetBarMod.OnAnchorEvent = function(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED") then
		self.incombat = nil

		self:UpdatePositionAndScale()
		self:UpdateAnchor()

	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (InCombatLockdown()) then return end

		self.incombat = nil

		if (self.updateneeded) then
			self:UpdatePositionAndScale()
			self:UpdateAnchor()
		end

	elseif (event == "PLAYER_REGEN_DISABLED") then
		self.incombat = true

	elseif (event == "MFM_PositionUpdated") then
		local anchor, point, x, y = ...

		if (anchor ~= self.anchor) then return end

		self.bar.config.savedPosition[1] = point
		self.bar.config.savedPosition[2] = x
		self.bar.config.savedPosition[3] = y

		self:UpdatePositionAndScale()

	elseif (event == "MFM_ScaleUpdated") then
		local anchor, scale = ...
		if (anchor ~= self.anchor) then return end

		self.bar.config.savedPosition.scale = scale

		self:UpdatePositionAndScale()

	elseif (event == "MFM_Dragging") then
		if (not self.incombat) then

			local anchor = ...
			if (anchor ~= self.anchor) then return end

			self:OnAnchorEvent("MFM_PositionUpdated", ...)
		end

	elseif (event == "MFM_UIScaleChanged") then
		self:UpdateDefaults()
	end
end

PetBarMod.OnEnable = function(self)

	self.db.profile.clickOnDown = ns:GetModule("ActionBars").db.profile.clickOnDown

	self:CreateBar()
	self:CreateAnchor()
	self:UpdateSettings()

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

	self:RegisterEvent("PET_BAR_UPDATE", "OnEvent")
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", "OnEvent")
	self:RegisterEvent("PET_BAR_UPDATE_USABLE", "OnEvent")
	self:RegisterEvent("PET_BAR_SHOWGRID", "OnEvent")
	self:RegisterEvent("PET_BAR_HIDEGRID", "OnEvent")
	self:RegisterEvent("PLAYER_CONTROL_LOST", "OnEvent")
	self:RegisterEvent("PLAYER_CONTROL_GAINED", "OnEvent")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
	self:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnEvent")
	self:RegisterEvent("UPDATE_BINDINGS", "OnEvent")
	self:RegisterEvent("UNIT_AURA", "OnEvent")
	self:RegisterEvent("UNIT_FLAGS", "OnEvent")
	self:RegisterEvent("UNIT_PET", "OnEvent")

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnAnchorEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnAnchorEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnAnchorEvent")

	ns.RegisterCallback(self, "MFM_PositionUpdated", "OnAnchorEvent")
	ns.RegisterCallback(self, "MFM_AnchorShown", "OnAnchorEvent")
	ns.RegisterCallback(self, "MFM_ScaleUpdated", "OnAnchorEvent")
	ns.RegisterCallback(self, "MFM_Dragging", "OnAnchorEvent")
	ns.RegisterCallback(self, "MFM_UIScaleChanged", "OnAnchorEvent")

	self:UpdateBindings()
end

PetBarMod.OnInitialize = function(self)
	self.db = ns.db:RegisterNamespace(self:GetName(), self:GetDefaults())
end
