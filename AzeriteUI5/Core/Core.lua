--[[

	The MIT License (MIT)

	Copyright (c) 2022 Lars Norberg

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
local Addon, AzeriteUI5 = ...
AzeriteUI5 = LibStub("AceAddon-3.0"):NewAddon(AzeriteUI5, Addon, "AceConsole-3.0")
AzeriteUI5.L = LibStub("AceLocale-3.0"):GetLocale(Addon, true) -- Addon localization
AzeriteUI5.callbacks = LibStub("CallbackHandler-1.0"):New(AzeriteUI5, nil, nil, false) -- Addon callback handler
AzeriteUI5.Hider = CreateFrame("Frame"); AzeriteUI5.Hider:Hide()
AzeriteUI5.Noop = function() end

_G[Addon] = AzeriteUI5

-- Default settings
local defaults = {
	char = {
	},
	global = {
		core = {
			enableDevelopmentMode = false,
			relativeScale = 1
		},
		chatframes = {
			enableChat = true
		},
		chatbubbles = {
			enableChatBubbles = true,
			visibility = {
				world = true,
				worldcombat = true,
				instance = true,
				instancecombat = false
			}
		}
	}
}

-- Lua API
local ipairs = ipairs
local math_max = math.max
local math_min = math.min
local next = next
local string_lower = string.lower
local tonumber = tonumber

-- WoW API
local EnableAddOn = EnableAddOn
local DisableAddOn = DisableAddOn
local InCombatLockdown = InCombatLockdown
local LoadAddOn = LoadAddOn
local ReloadUI = ReloadUI

-- Purge deprecated settings,
-- translate to new where applicable,
-- make sure important ones are within bounds.
local SanitizeSettings = function(db)
	if (not db) then
		return
	end
	local scale = db.global.core.relativeScale
	if (scale) then
		scale = math_min(1.25, math_max(.75, scale))
		db.global.core.relativeScale = scale
	end
	return db
end

-- Proxy method to avoid modules using the callback object directly
AzeriteUI5.Fire = function(self, name, ...)
	self.callbacks:Fire(name, ...)
end

AzeriteUI5.ResetScale = function(self)
	if (InCombatLockdown()) then
		return
	end
	local db = self.db
	local scale = db.global.core.relativeScale
	local defaultScale = defaults.global.core.relativeScale
	if (scale and scale ~= defaultScale) then
		db.global.core.relativeScale = defaultScale -- Store the saved setting
		self.API.SetRelativeScale(defaultScale) -- Store it in the addon namespace
		self.API.UpdateObjectScales() -- Apply it to existing objects
		-- Fire callbacks to submodules.
		self.callbacks:Fire("Relative_Scale_Updated", db.global.core.relativeScale)
	end
end

AzeriteUI5.SetScale = function(self, input)
	if (InCombatLockdown()) then
		return
	end
	local scale = tonumber((self:GetArgs(string_lower(input))))
	if (scale) then
		local db = self.db
		local oldScale = db.global.core.relativeScale
		-- Sanitize it, don't want crazy values
		scale = math_min(1.25, math_max(.75, scale))
		if (oldScale ~= scale) then
			-- Store and apply new relative user scale
			db.global.core.relativeScale = scale -- Store the saved setting
			self.API.SetRelativeScale(scale) -- Store it in the addon namespace
			self.API.UpdateObjectScales() -- Apply it to existing objects
			-- Fire callbacks to submodules.
			self.callbacks:Fire("Relative_Scale_Updated", db.global.core.relativeScale)
		end
	end
end

AzeriteUI5.UpdateSettings = function(self, event, ...)
	-- Fire callbacks to submodules.
	self.callbacks:Fire("Saved_Settings_Updated")
end

AzeriteUI5.OnInitialize = function(self)

	self.db = SanitizeSettings(LibStub("AceDB-3.0"):New("AzeriteUI5_DB", defaults, true))
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateSettings")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateSettings")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateSettings")

	-- Apply user scale to all elements
	if (self.db.global.core.relativeScale) then
		self.API.SetRelativeScale(self.db.global.core.relativeScale)
	end

	-- Add a command to clear all chat frames.
	-- I mainly use this to remove clutter before taking screenshots.
	-- You could theoretically put this in a macro and clear chat then screenshot.
	self:RegisterChatCommand("clear", function()
		for _,frameName in pairs(_G.CHAT_FRAMES) do
			local frame = _G[frameName]
			if (frame and frame:IsShown()) then
				frame:Clear()
			end
		end
	end)

	-- Fully experimental
	--self:RegisterChatCommand("setscale", "SetScale")
	--self:RegisterChatCommand("resetscale", "ResetScale")
	--self:RegisterChatCommand("lock", self.Widgets.HideMovableFrameAnchors)
	--self:RegisterChatCommand("unlock", self.Widgets.ShowMovableFrameAnchors)
	--self:RegisterChatCommand("togglelock", self.Widgets.ToggleMovableFrameAnchors)

	-- In case some other jokers have disabled these, we add them back to avoid a World of Bugs.
	-- RothUI used to remove the two first, and a lot of people missed his documentation on how to get them back.
	-- I personally removed the objective's tracker for a while in DiabolicUI, which led to pain. Lots of pain.
	for _,v in ipairs({ "Blizzard_CUFProfiles", "Blizzard_CompactRaidFrames", "Blizzard_ObjectiveTracker" }) do
		if (not self.API.IsAddOnEnabled(v)) then
			EnableAddOn(v)
			LoadAddOn(v)
		end
	end

end
