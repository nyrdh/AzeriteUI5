local Addon, ns = ...

local L = LibStub("AceLocale-3.0"):NewLocale(Addon, "itIT")
if (not L) then return end

-- General all-purpose words
--------------------------------------------------
L["Create"] = "Crea"
L["Copy"] = "Copia"
L["Delete"] = "Elimina"
L["Save"] = "Salva"
L["Apply"] = "Applica"
L["Cancel"] = "Annulla"
L["Hide"] = "Nascondi"
L["Enable"] = "Attiva"
L["Right"] = "A destra"
L["Left"] = "A sinistra"
L["Down"] = "In alto"
L["Up"] = "In basso"

-- Movable Frames & EditMode interaction
--------------------------------------------------
L["Layout:"] = "Interfaccia:"
L["Name the New Layout"] = "Nome nuova interfaccia"
L["HUD Edit Mode"] = "Modalità modifica interfaccia"
L["Click the button below to reset the currently selected EditMode preset to positions matching the default AzeriteUI layout."] = true
L["Reset EditMode Layout"] = true
L["Click the button below to create an EditMode preset named 'Azerite'."] = true
L["Create EditMode Layout"] = true
L["<Left-Click and drag to move>"] = true
L["<MouseWheel to change scale>"] = true
L["<Ctrl and Right-Click to undo last change>"] = true
L["<Shift-Click to reset to default>"] = true

-- Intro Tutorials
--------------------------------------------------
L["Welcome to %s"] = true
L["Congratulations, you are now running AzeriteUI for Retail!|n|nTo create or reset an editmode layout named 'Azerite' and switch to it, click the '|cffffd200%s|r' button. To hide this window for now, click the '|cffffd200%s|r' button. To cancel this tutorial, click the '|cffffd200%s|r' button."] = true
L["You are now running AzeriteUI for %s!|n|nTo set the game's general interface scale to AzeriteUI defaults and position the chat frames to match, click the '|cffffd200%s|r' button. To hide this window for now, click the '|cffffd200%s|r' button. To cancel this tutorial and handle interface scaling yourself, click the '|cffffd200%s|r' button."] = true

-- Misc
--------------------------------------------------
-- Classic Era Battleground Ready message
L["You can now enter a new battleground, right-click the eye icon on the minimap to enter or leave!"] = true

-- Options Menu
--------------------------------------------------
-- Action Bar Settings
L["Action Bar Settings"] = "Impostazioni Barra delle azioni"
L["Action Bars"] = "Barre delle azioni"
L["Action Bar %d"] = "Barra delle azioni %d"
L["Toggle whether to enable this action bar or not."] = true
L["Enable Bar Fading"] = true
L["Toggle whether to enable the buttons of this action bar to fade out."] = true
L["Start Fading from"] = true
L["Choose which button to start the fading from."] = true
L["Bar Layout"] = true
L["Choose the action bar layout type."] = true
L["Grid Layout"] = true
L["ZigZag Layout"] = true
L["First ZigZag Button"] = true
L["Sets which button the zigzag pattern should begin at."] = true
L["Number of buttons"] = true
L["Sets the number of action buttons on the action bar."] = true
L["Button Padding"] = true
L["Sets the padding between buttons on the same line."] = true
L["Line Padding"] = true
L["Sets the padding between multiple lines of buttons."] = true
L["Line Break"] = true
L["Sets when a new line of buttons should begin."] = true
L["Initial Growth"] = true
L["Choose whether the bar initially should expand horizontally or vertically."] = true
L["Horizontal Layout"] = true
L["Vertical Layout"] = true
L["Horizontal Growth"] = true
L["Choose which horizontal direction the bar should expand in."] = true
L["Vertical Growth"] = true
L["Choose which vertical direction the bar should expand in."] = true
L["Anchor Point"] = true
L["Sets the anchor point of your actionbar."] = true
L["Top-Left Corner"] = true
L["Top Center"] = true
L["Top-Right Corner"] = true
L["Middle Right Side"] = true
L["Bottom-Right Corner"] = true
L["Bottom Center"] = true
L["Bottom-Left Corner"] = true
L["Middle Left Side"] = true
L["Center"] = true
L["Offset X"] = true
L["Sets the horizontal offset from your chosen point. Positive values means right, negative values means left."] = true
L["Offset Y"] = true
L["Sets the vertical offset from your chosen point. Positive values means up, negative values means down."] = true

-- Unit Frame Settings
L["Unit Frames"] = true
L["UnitFrame Settings"] = true

-- Tooltip Settings
L["Tooltips"] = true
L["Tooltip Settings"] = true
L["Show itemID"] = true
L["Toggle whether to add itemID to item tooltips or not."] = true
L["Show spellID"] = true
L["Toggle whether to add spellIDs and auraIDs in tooltips containing actions, spells or auras."] = true

-- Player Aura Settings
L["Player Auras"] = true
L["Aura Settings"] = true

-- Fading & Explorer Mode Settings
L["Frame Fading"] = true
L["Frame Fade Settings"] = true