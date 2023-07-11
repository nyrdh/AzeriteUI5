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
local Addon, ns = ...

if (ns.IsClassic) then return end

local oUF = ns.oUF

local L = LibStub("AceLocale-3.0"):GetLocale(Addon)

local ArenaFrameMod = ns:NewModule("ArenaFrames", ns.UnitFrameModule, "LibMoreEvents-1.0")

-- GLOBALS: CreateFrame, InCombatLockdown, Enum
-- GLOBALS: UnitIsUnit, UnitHasVehicleUI, UnitPowerType

-- Lua API
local math_abs = math.abs
local next = next
local setmetatable = setmetatable
local string_gsub = string.gsub
local unpack = unpack

local defaults = { profile = ns:Merge({
	enabled = true,
	yOffset = -12
}, ns.Module.defaults) }

ArenaFrameMod.GenerateDefaults = function(self)
	defaults.profile.savedPosition = {
		scale = ns.API.GetEffectiveScale(),
		[1] = "CENTER",
		[2] = 300 * ns.API.GetEffectiveScale(),
		[3] = 0 * ns.API.GetEffectiveScale()
	}
	return defaults
end


-- Utility Functions
--------------------------------------------
-- Simplify the tagging process a little.
local prefix = function(msg)
	return string_gsub(msg, "*", ns.Prefix)
end

-- Element Callbacks
--------------------------------------------
-- Forceupdate health prediction on health updates,
-- to assure our smoothed elements are properly aligned.
local Health_PostUpdate = function(element, unit, cur, max)
	local predict = element.__owner.HealthPrediction
	if (predict) then
		predict:ForceUpdate()
	end
end

-- Update the health preview color on health color updates.
local Health_PostUpdateColor = function(element, unit, r, g, b)
	local preview = element.Preview
	if (preview and g) then
		preview:SetStatusBarColor(r * .7, g * .7, b * .7)
	end
end

-- Align our custom health prediction texture
-- based on the plugin's provided values.
local HealPredict_PostUpdate = function(element, unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb, curHealth, maxHealth)

	local allIncomingHeal = myIncomingHeal + otherIncomingHeal
	local allNegativeHeals = healAbsorb
	local showPrediction, change

	if ((allIncomingHeal > 0) or (allNegativeHeals > 0)) and (maxHealth > 0) then
		local startPoint = curHealth/maxHealth

		-- Dev switch to test absorbs with normal healing
		--allIncomingHeal, allNegativeHeals = allNegativeHeals, allIncomingHeal

		-- Hide predictions if the change is very small, or if the unit is at max health.
		change = (allIncomingHeal - allNegativeHeals)/maxHealth
		if ((curHealth < maxHealth) and (change > (element.health.predictThreshold or .05))) then
			local endPoint = startPoint + change

			-- Crop heal prediction overflows
			if (endPoint > 1) then
				endPoint = 1
				change = endPoint - startPoint
			end

			-- Crop heal absorb overflows
			if (endPoint < 0) then
				endPoint = 0
				change = -startPoint
			end

			-- This shouldn't happen, but let's do it anyway.
			if (startPoint ~= endPoint) then
				showPrediction = true
			end
		end
	end

	if (showPrediction) then

		local preview = element.preview
		local growth = preview:GetGrowth()
		local _,max = preview:GetMinMaxValues()
		local value = preview:GetValue() / max
		local previewTexture = preview:GetStatusBarTexture()
		local previewWidth, previewHeight = preview:GetSize()
		local left, right, top, bottom = preview:GetTexCoord()
		local isFlipped = preview:IsFlippedHorizontally()

		if (growth == "RIGHT") then

			local texValue, texChange = value, change
			local rangeH

			rangeH = right - left
			texChange = change*value
			texValue = left + value*rangeH

			if (change > 0) then
				element:ClearAllPoints()
				element:SetPoint("BOTTOMLEFT", previewTexture, "BOTTOMRIGHT", 0, 0)
				element:SetSize(change*previewWidth, previewHeight)
				if (isFlipped) then
					element:SetTexCoord(texValue + texChange, texValue, top, bottom)
				else
					element:SetTexCoord(texValue, texValue + texChange, top, bottom)
				end
				element:SetVertexColor(0, .7, 0, .25)
				element:Show()

			elseif (change < 0) then
				element:ClearAllPoints()
				element:SetPoint("BOTTOMRIGHT", previewTexture, "BOTTOMRIGHT", 0, 0)
				element:SetSize((-change)*previewWidth, previewHeight)
				if (isFlipped) then
					element:SetTexCoord(texValue, texValue + texChange, top, bottom)
				else
					element:SetTexCoord(texValue + texChange, texValue, top, bottom)
				end
				element:SetVertexColor(.5, 0, 0, .75)
				element:Show()

			else
				element:Hide()
			end

		elseif (growth == "LEFT") then
			local texValue, texChange = value, change
			local rangeH

			rangeH = right - left
			texChange = change*value
			texValue = left + value*rangeH

			if (change > 0) then
				element:ClearAllPoints()
				element:SetPoint("BOTTOMRIGHT", previewTexture, "BOTTOMLEFT", 0, 0)
				element:SetSize(change*previewWidth, previewHeight)
				if (isFlipped) then
					element:SetTexCoord(texValue, texValue + texChange, top, bottom)
				else
					element:SetTexCoord(texValue + texChange, texValue, top, bottom)
				end
				element:SetVertexColor(0, .7, 0, .25)
				element:Show()

			elseif (change < 0) then
				element:ClearAllPoints()
				element:SetPoint("BOTTOMLEFT", previewTexture, "BOTTOMLEFT", 0, 0)
				element:SetSize((-change)*previewWidth, previewHeight)
				if (isFlipped) then
					element:SetTexCoord(texValue + texChange, texValue, top, bottom)
				else
					element:SetTexCoord(texValue, texValue + texChange, top, bottom)
				end
				element:SetVertexColor(.5, 0, 0, .75)
				element:Show()

			else
				element:Hide()
			end
		end
	else
		element:Hide()
	end

	local absorb = element.Absorb
	if (absorb) then
		local fraction = absorb/maxHealth
		if (fraction > .6) then
			absorb = maxHealth * .6
		end
		absorb:SetMinMaxValues(0, maxHealth)
		absorb:SetValue(absorb)
	end

end

local Power_PostUpdate = function(element, unit, cur, min, max)

	local shouldShow = not UnitHasVehicleUI("player") and UnitPowerType(unit) == Enum.PowerType.Mana

	if (not shouldShow or cur == 0 or max == 0) then
		element:SetAlpha(0)
	else
		local _,class = UnitClass(unit)
		if (class == "DRUID" or class == "PALADIN" or class == "PRIEST" or class == "SHAMAN") then
			if (cur/max < .9) then
				element:SetAlpha(.75)
			else
				element:SetAlpha(0)
			end
		elseif (class == "MAGE" or class == "WARLOCK") then
			if (cur/max < .5) then
				element:SetAlpha(.75)
			else
				element:SetAlpha(0)
			end
		else
			-- The threshold for the "oom" message is .25 (not yet added!)
			if (cur/max < .25) then
				element:SetAlpha(.75)
			else
				element:SetAlpha(0)
			end
		end
	end
end

-- Make the portrait look better for offline or invisible units.
local Portrait_PostUpdate = function(element, unit, hasStateChanged)
	if (not element.state) then
		element:ClearModel()
		if (not element.fallback2DTexture) then
			element.fallback2DTexture = element:CreateTexture()
			element.fallback2DTexture:SetDrawLayer("ARTWORK")
			element.fallback2DTexture:SetAllPoints()
			element.fallback2DTexture:SetTexCoord(.1, .9, .1, .9)
		end
		SetPortraitTexture(element.fallback2DTexture, unit)
		element.fallback2DTexture:Show()
	else
		if (element.fallback2DTexture) then
			element.fallback2DTexture:Hide()
		end
		element:SetCamDistanceScale(element.distanceScale or 1)
		element:SetPortraitZoom(1)
		element:SetPosition(element.positionX or 0, element.positionY or 0, element.positionZ or 0)
		element:SetRotation(element.rotation and element.rotation*(2*math_pi)/180 or 0)
		element:ClearModel()
		element:SetUnit(unit)
		element.guid = UnitGUID(unit)
	end
end

-- Update targeting highlight outline
local TargetHighlight_Update = function(self, event, unit, ...)
	if (unit and unit ~= self.unit) then return end

	local element = self.TargetHighlight
	unit = unit or self.unit

	if (UnitIsUnit(unit, "focus")) then
		element:SetVertexColor(unpack(element.colorFocus))
		element:Show()
	elseif (UnitIsUnit(unit, "target")) then
		element:SetVertexColor(unpack(element.colorTarget))
		element:Show()
	else
		element:Hide()
	end
end

local UnitFrame_PostUpdate = function(self)
	--TargetHighlight_Update(self)
end

local UnitFrame_OnEvent = function(self, event, unit, ...)
	UnitFrame_PostUpdate(self)
end

local style = function(self, unit)

	local db = ns.GetConfig("ArenaFrames")

	self:SetSize(unpack(db.UnitSize))

	-- Apply common scripts and member values.
	ns.UnitFrame.InitializeUnitFrame(self)
	ns.UnitFrames[self] = true -- add to our registry

	-- Overlay for icons and text
	--------------------------------------------
	local overlay = CreateFrame("Frame", nil, self)
	overlay:SetFrameLevel(self:GetFrameLevel() + 7)
	overlay:SetAllPoints()

	self.Overlay = overlay

	-- Health
	--------------------------------------------
	local health = self:CreateBar()
	health:SetFrameLevel(health:GetFrameLevel() + 2)
	health:SetPoint(unpack(db.HealthBarPosition))
	health:SetSize(unpack(db.HealthBarSize))
	health:SetStatusBarTexture(db.HealthBarTexture)
	health:SetOrientation(db.HealthBarOrientation)
	health:SetSparkMap(db.HealthBarSparkMap)
	health.predictThreshold = .01
	health.colorDisconnected = true
	health.colorClass = true
	health.colorClassPet = true
	health.colorReaction = true
	health.colorHealth = true

	self.Health = health
	self.Health.Override = ns.API.UpdateHealth
	self.Health.PostUpdate = Health_PostUpdate
	self.Health.PostUpdateColor = Health_PostUpdateColor

	local healthOverlay = CreateFrame("Frame", nil, health)
	healthOverlay:SetFrameLevel(overlay:GetFrameLevel() - 1)
	healthOverlay:SetAllPoints()

	self.Health.Overlay = healthOverlay

	local healthBackdrop = health:CreateTexture(nil, "BACKGROUND", nil, -1)
	healthBackdrop:SetPoint(unpack(db.HealthBackdropPosition))
	healthBackdrop:SetSize(unpack(db.HealthBackdropSize))
	healthBackdrop:SetTexture(db.HealthBackdropTexture)
	healthBackdrop:SetVertexColor(unpack(db.HealthBackdropColor))

	self.Health.Backdrop = healthBackdrop

	local healthPreview = self:CreateBar(nil, health)
	healthPreview:SetAllPoints(health)
	healthPreview:SetFrameLevel(health:GetFrameLevel() - 1)
	healthPreview:SetStatusBarTexture(db.HealthBarTexture)
	healthPreview:SetOrientation(db.HealthBarOrientation)
	healthPreview:SetSparkTexture("")
	healthPreview:SetAlpha(.5)
	healthPreview:DisableSmoothing(true)

	self.Health.Preview = healthPreview

	-- Health Prediction
	--------------------------------------------
	local healPredictFrame = CreateFrame("Frame", nil, health)
	healPredictFrame:SetFrameLevel(health:GetFrameLevel() + 2)

	local healPredict = healPredictFrame:CreateTexture(nil, "OVERLAY", nil, 1)
	healPredict:SetTexture(db.HealthBarTexture)
	healPredict.health = health
	healPredict.preview = healthPreview
	healPredict.maxOverflow = 1

	self.HealthPrediction = healPredict
	self.HealthPrediction.PostUpdate = HealPredict_PostUpdate

	-- Cast Overlay
	--------------------------------------------
	local castbar = self:CreateBar()
	castbar:SetAllPoints(health)
	castbar:SetFrameLevel(self:GetFrameLevel() + 5)
	castbar:SetSparkMap(db.HealthBarSparkMap)
	castbar:SetStatusBarTexture(db.HealthBarTexture)
	castbar:SetStatusBarColor(unpack(db.HealthCastOverlayColor))
	castbar:DisableSmoothing(true)

	self.Castbar = castbar

	-- Health Value
	--------------------------------------------
	local healthValue = healthOverlay:CreateFontString(nil, "OVERLAY", nil, 1)
	healthValue:SetPoint(unpack(db.HealthValuePosition))
	healthValue:SetFontObject(db.HealthValueFont)
	healthValue:SetTextColor(unpack(db.HealthValueColor))
	healthValue:SetJustifyH(db.HealthValueJustifyH)
	healthValue:SetJustifyV(db.HealthValueJustifyV)
	self:Tag(healthValue, prefix("[*:Health(true,false,false,true)]"))

	self.Health.Value = healthValue

	-- Power
	--------------------------------------------
	local power = self:CreateBar()
	power:SetFrameLevel(health:GetFrameLevel() + 2)
	power:SetPoint(unpack(db.PowerBarPosition))
	power:SetSize(unpack(db.PowerBarSize))
	power:SetStatusBarTexture(db.PowerBarTexture)
	power:SetOrientation(db.PowerBarOrientation)
	power:SetAlpha(db.PowerBarAlpha)
	power.frequentUpdates = true
	power.colorPower = true

	self.Power = power
	self.Power.Override = ns.API.UpdatePower
	--self.Power.PostUpdate = Power_PostUpdate

	local powerBackdrop = power:CreateTexture(nil, "BACKGROUND", nil, -5)
	powerBackdrop:SetPoint(unpack(db.PowerBackdropPosition))
	powerBackdrop:SetSize(unpack(db.PowerBackdropSize))
	powerBackdrop:SetTexture(db.PowerBackdropTexture)
	powerBackdrop:SetVertexColor(unpack(db.PowerBackdropColor))

	self.Power.Backdrop = powerBackdrop

	-- Portrait
	--------------------------------------------
	local portraitFrame = CreateFrame("Frame", nil, self)
	portraitFrame:SetFrameLevel(self:GetFrameLevel() - 2)
	portraitFrame:SetAllPoints()

	local portrait = CreateFrame("PlayerModel", nil, portraitFrame)
	portrait:SetFrameLevel(portraitFrame:GetFrameLevel())
	portrait:SetPoint(unpack(db.PortraitPosition))
	portrait:SetSize(unpack(db.PortraitSize))
	portrait:SetAlpha(db.PortraitAlpha)
	portrait.distanceScale = db.PortraitDistanceScale
	portrait.positionX = db.PortraitPositionX
	portrait.positionY = db.PortraitPositionY
	portrait.positionZ = db.PortraitPositionZ
	portrait.rotation = db.PortraitRotation
	portrait.showFallback2D = db.PortraitShowFallback2D

	self.Portrait = portrait
	self.Portrait.PostUpdate = Portrait_PostUpdate

	local portraitBg = portraitFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
	portraitBg:SetPoint(unpack(db.PortraitBackgroundPosition))
	portraitBg:SetSize(unpack(db.PortraitBackgroundSize))
	portraitBg:SetTexture(db.PortraitBackgroundTexture)
	portraitBg:SetVertexColor(unpack(db.PortraitBackgroundColor))

	self.Portrait.Bg = portraitBg

	local portraitOverlayFrame = CreateFrame("Frame", nil, self)
	portraitOverlayFrame:SetFrameLevel(portraitFrame:GetFrameLevel() + 1)
	portraitOverlayFrame:SetAllPoints()

	local portraitShade = portraitOverlayFrame:CreateTexture(nil, "BACKGROUND", nil, -1)
	portraitShade:SetPoint(unpack(db.PortraitShadePosition))
	portraitShade:SetSize(unpack(db.PortraitShadeSize))
	portraitShade:SetTexture(db.PortraitShadeTexture)

	self.Portrait.Shade = portraitShade

	local portraitBorder = portraitOverlayFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
	portraitBorder:SetPoint(unpack(db.PortraitBorderPosition))
	portraitBorder:SetSize(unpack(db.PortraitBorderSize))
	portraitBorder:SetTexture(db.PortraitBorderTexture)
	portraitBorder:SetVertexColor(unpack(db.PortraitBorderColor))

	self.Portrait.Border = portraitBorder

	-- Absorb Bar (Retail)
	--------------------------------------------
	if (ns.IsRetail) then
		local absorb = self:CreateBar()
		absorb:SetAllPoints(health)
		absorb:SetFrameLevel(health:GetFrameLevel() + 3)
		absorb:SetStatusBarTexture(db.HealthBarTexture)
		absorb:SetStatusBarColor(unpack(db.HealthAbsorbColor))
		absorb:SetSparkMap(db.HealthBarSparkMap)

		local orientation
		if (db.HealthBarOrientation == "UP") then
			orientation = "DOWN"
		elseif (db.HealthBarOrientation == "DOWN") then
			orientation = "UP"
		elseif (db.HealthBarOrientation == "LEFT") then
			orientation = "RIGHT"
		else
			orientation = "LEFT"
		end
		absorb:SetOrientation(orientation)

		self.Health.Absorb = absorb
	end

	-- Dispellable Debuffs
	--------------------------------------------
	--[[
	local dispellable = {}
	dispellable.disableMouse = true

	local dispelIcon = CreateFrame("Button", dispellable:GetDebugName() .. "Button", healthOverlay)
	--dispelIcon:Hide()
	dispelIcon:SetFrameLevel(overlay:GetFrameLevel() + 2)
	dispelIcon:SetSize(24,24)
	dispelIcon:SetPoint("CENTER")
	dispellable.dispellIcon = dispelIcon

	local dispelIconTexture = dispelIcon:CreateTexture(nil, "BACKGROUND", nil, 1)
	dispelIconTexture:SetAllPoints()
	dispelIconTexture:SetMask(GetMedia("actionbutton-mask-square"))
	dispelIcon.icon = dispelIconTexture

	local dispelIconCount = dispelIcon.Border:CreateFontString(nil, "OVERLAY")
	dispelIconCount:SetFontObject(GetFont(12,true))
	dispelIconCount:SetTextColor(Colors.offwhite[1], Colors.offwhite[2], Colors.offwhite[3])
	dispelIconCount:SetPoint("BOTTOMRIGHT", dispelIcon, "BOTTOMRIGHT", -2, 3)
	dispelIcon.count = dispelIconCount

	local dispelIconBorder = CreateFrame("Frame", nil, dispelIcon, ns.BackdropTemplate)
	dispelIconBorder:SetBackdrop({ edgeFile = GetMedia("border-aura"), edgeSize = 12 })
	dispelIconBorder:SetBackdropBorderColor(Colors.aura[1], Colors.aura[2], Colors.aura[3])
	dispelIconBorder:SetPoint("TOPLEFT", -6, 6)
	dispelIconBorder:SetPoint("BOTTOMRIGHT", 6, -6)
	dispelIconBorder:SetFrameLevel(dispelIcon:GetFrameLevel() + 2)
	dispelIcon.overlay = dispelIconBorder

	local dispelIconTime = dispelIcon.overlay:CreateFontString(nil, "OVERLAY")
	dispelIconTime:SetFontObject(GetFont(14,true))
	dispelIconTime:SetTextColor(Colors.offwhite[1], Colors.offwhite[2], Colors.offwhite[3])
	dispelIconTime:SetPoint("TOPLEFT", dispelIcon, "TOPLEFT", -4, 4)
	dispelIcon.time = dispelIconTime

	-- Using a virtual cooldown element with the timer attached,
	-- allowing them to piggyback on the back-end's cooldown updates.
	dispelIcon.cd = ns.Widgets.RegisterCooldown(dispelIcon.time)

	--self.Dispellable = dispellable
	--]]

	-- Readycheck
	--------------------------------------------
	local readyCheckIndicator = overlay:CreateTexture(nil, "OVERLAY", nil, 7)
	readyCheckIndicator:SetSize(unpack(db.ReadyCheckSize))
	readyCheckIndicator:SetPoint(unpack(db.ReadyCheckPosition))
	readyCheckIndicator.readyTexture = db.ReadyCheckReadyTexture
	readyCheckIndicator.notReadyTexture = db.ReadyCheckNotReadyTexture
	readyCheckIndicator.waitingTexture = db.ReadyCheckWaitingTexture

	self.ReadyCheckIndicator = readyCheckIndicator

	-- CombatFeedback Text
	--------------------------------------------
	local feedbackText = overlay:CreateFontString(nil, "OVERLAY")
	feedbackText:SetPoint(db.CombatFeedbackPosition[1], self[db.CombatFeedbackAnchorElement], unpack(db.CombatFeedbackPosition))
	feedbackText:SetFontObject(db.CombatFeedbackFont)
	feedbackText.feedbackFont = db.CombatFeedbackFont
	feedbackText.feedbackFontLarge = db.CombatFeedbackFontLarge
	feedbackText.feedbackFontSmall = db.CombatFeedbackFontSmall

	self.CombatFeedback = feedbackText

	-- Target Highlight
	--------------------------------------------
	--local targetHighlight = healthOverlay:CreateTexture(nil, "BACKGROUND", nil, -2)
	--targetHighlight:SetPoint(unpack(db.TargetHighlightPosition))
	--targetHighlight:SetSize(unpack(db.TargetHighlightSize))
	--targetHighlight:SetTexture(db.TargetHighlightTexture)
	--targetHighlight.colorTarget = db.TargetHighlightTargetColor
	--targetHighlight.colorFocus = db.TargetHighlightFocusColor

	--self.TargetHighlight = targetHighlight

	-- Unit Name
	--------------------------------------------
	local name = overlay:CreateFontString(nil, "OVERLAY", nil, 1)
	name:SetPoint(unpack(db.NamePosition))
	name:SetFontObject(db.NameFont)
	name:SetTextColor(unpack(db.NameColor))
	name:SetJustifyH(db.NameJustifyH)
	name:SetJustifyV(db.NameJustifyV)
	self:Tag(name, prefix("[*:Name(12,nil,nil,true)]"))

	self.Name = name


	-- PvP Spec Icon
	--------------------------------------------

	-- Trinket
	--------------------------------------------

	-- Auras
	--------------------------------------------
	local auras = CreateFrame("Frame", nil, self)
	auras:SetSize(unpack(db.AurasSize))
	auras:SetPoint(unpack(db.AurasPosition))
	auras.size = db.AuraSize
	auras.spacing = db.AuraSpacing
	auras.numTotal = db.AurasNumTotal
	auras.disableMouse = db.AurasDisableMouse
	auras.disableCooldown = db.AurasDisableCooldown
	auras.onlyShowPlayer = db.AurasOnlyShowPlayer
	auras.showStealableBuffs = db.AurasShowStealableBuffs
	auras.initialAnchor = db.AurasInitialAnchor
	auras["spacing-x"] = db.AurasSpacingX
	auras["spacing-y"] = db.AurasSpacingY
	auras["growth-x"] = db.AurasGrowthX
	auras["growth-y"] = db.AurasGrowthY
	auras.tooltipAnchor = db.AurasTooltipAnchor
	auras.sortMethod = db.AurasSortMethod
	auras.sortDirection = db.AurasSortDirection
	auras.reanchorIfVisibleChanged = true
	auras.CreateButton = ns.AuraStyles.CreateButton
	auras.PostUpdateButton = ns.AuraStyles.ArenaPostUpdateButton
	auras.CustomFilter = ns.AuraFilters.ArenaAuraFilter -- classic
	auras.FilterAura = ns.AuraFilters.ArenaAuraFilter -- retail

	if (ns:GetModule("UnitFrames").db.global.disableAuraSorting) then
		auras.PreSetPosition = ns.AuraSorts.Alternate -- only in classic
		auras.SortAuras = ns.AuraSorts.AlternateFuncton -- only in retail
	else
		auras.PreSetPosition = ns.AuraSorts.Default -- only in classic
		auras.SortAuras = ns.AuraSorts.DefaultFunction -- only in retail
	end

	self.Auras = auras

	-- Range Opacity
	-----------------------------------------------------------
	self.Range = { outsideAlpha = .6 }

	-- Textures need an update when frame is displayed.
	self.PostUpdate = UnitFrame_PostUpdate

	-- Register events to handle additional texture updates.
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UnitFrame_OnEvent, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UnitFrame_OnEvent, true)


end

-- Fake GroupHeader
---------------------------------------------------
local GroupHeader = CreateFrame("Frame")
local GroupHeader_MT = { __index = GroupHeader }

GroupHeader.Enable = function(self)
	if (InCombatLockdown()) then return end
	for i,frame in next,self.units do
		frame:Enable()
	end
end

GroupHeader.Disable = function(self)
	if (InCombatLockdown()) then return end
	for i,frame in next,self.units do
		frame:Disable()
	end
end

GroupHeader.IsEnabled = function(self)
	return self.units[1]:IsEnabled()
end

ArenaFrameMod.GetHeaderSize = function(self)
	local config = ns.GetConfig("ArenaFrames")
	return
		config.UnitSize[1], config.UnitSize[2]*5 + math_abs(self.db.profile.yOffset * 4)
end

ArenaFrameMod.CreateUnitFrames = function(self)

	local unit, name = "arena", "Arena"

	oUF:RegisterStyle(ns.Prefix..name, style)
	oUF:SetActiveStyle(ns.Prefix..name)

	local frame = setmetatable(CreateFrame("Frame", nil, UIParent), GroupHeader_MT)
	frame:SetSize(self:GetHeaderSize())
	frame.units = {}

	for i = 1,5 do
		local unitFrame = ns.UnitFrame.Spawn(unit..i, ns.Prefix.."UnitFrame"..name..i)
		--local unitFrame = ns.UnitFrame.Spawn(i == 1 and "targettarget" or i == 3 and "player" or i == 4 and "target" or unit..i, ns.Prefix.."UnitFrame"..name..i)
		frame.units[i] = unitFrame
	end

	if true then

		local config = ns.GetConfig("ArenaFrames")

		local layoutManager = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		layoutManager:SetAllPoints(frame)
		layoutManager:SetAttribute("unitWidth", config.UnitSize[1])
		layoutManager:SetAttribute("unitHeight", config.UnitSize[2])
		layoutManager:SetAttribute("yOffset", self.db.profile.yOffset)

		layoutManager:SetAttribute("UpdateLayout", [[

			-- count visible units
			local visible = 0;
			for i = 1,5 do
				local unit = self:GetFrameRef("Frame"..i):GetAttribute("unit");
				if (unit and UnitExists(unit)) then
					visible = visible + 1;
				end
			end

			-- do the calculations
			local unitHeight = self:GetAttribute("unitHeight");
			local unitSpacing = abs(self:GetAttribute("yOffset"));
			local fullHeight = unitHeight*5 + unitSpacing*4;
			local groupHeight = (visible > 1) and (visible*unitHeight + (visible-1)*unitSpacing) or unitHeight;
			local offsetY = -(fullHeight - groupHeight)/2;

			-- do the layout
			local count = 0;
			for i = 1,5 do
				local unit = self:GetFrameRef("Frame"..i):GetAttribute("unit");
				if (unit and UnitExists(unit)) then
					local unitFrame = self:GetFrameRef("Frame"..i);
					unitFrame:ClearAllPoints();
					unitFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, offsetY - (count * (unitHeight + unitSpacing)));
					count = count + 1;
				end
			end
		]])

		for i = 1,5 do
			layoutManager:SetFrameRef("Frame"..i, frame.units[i])
		end

		local onLayoutChange = [[
			self:GetFrameRef("Updater"):RunAttribute("UpdateLayout");
		]]

		for i = 1,5 do
			local listener = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			listener:SetFrameRef("Updater", layoutManager)
			listener:SetAttribute("_onstate-layout", onLayoutChange)
			RegisterStateDriver(listener, "layout", "[@arena"..i..",exists]arena"..i.."on;arena"..i.."off")
		end

		-- Debugging
		if (false) then
			local listener = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			listener:SetFrameRef("Updater", layoutManager)
			listener:SetAttribute("_onstate-layout", onLayoutChange)
			RegisterStateDriver(listener, "layout", "[@target,exists]targeton;targetoff")

			local listener = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			listener:SetFrameRef("Updater", layoutManager)
			listener:SetAttribute("_onstate-layout", onLayoutChange)
			RegisterStateDriver(listener, "layout", "[@targettarget,exists]toton;totoff")
		end

	end

	self.frame = frame
end

ArenaFrameMod.OnEnable = function(self)

	-- Disable Blizzard arena enemy frames.
	for i = 1,5 do
		oUF:DisableBlizzard("arena"..i)
	end

	self:CreateUnitFrames()
	self:CreateAnchor(L["Arena Enemy Frames"])

	ns.Module.OnEnable(self)
end
