local Addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(Addon, "zhCN")
if (not L) then return end

L["<Ctrl and Right-Click to undo last change>"] = true
L["<Left-Click and drag to move>"] = true
L["<MouseWheel to change scale>"] = true
L["<Shift-Click to reset to default>"] = true
L["|cff44cc88/azerite|r to toggle options menu."] = true
L["|cff44cc88/lock|r to toggle movable frames."] = true
L["24 Hour Mode"] = "24小时模式"
L["Action Bar %d"] = "动作条 %d"
L["Action Bar Settings"] = "动作条设定"
L["Action Bars"] = "动作条"
L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."] = "动作条是一排用来放置快捷键的位置，可以使你快速使用技能和物品。你可以在这里开启额外的动作条并对它们进行设定。"
L["Alerts"] = true
L["Anchor Point"] = "锚点"
L["Apply"] = "应用"
L["Arcane Charges"] = "奥术充能"
L["Are you sure you want to delete the preset '%s'? This cannot be undone."] = true
L["Arena Enemy Frames"] = "竞技场对手框体"
L["Arena Frames"] = "竞技场框体"
L["Aura Settings"] = true
L["Automatically load an Edit Mode layout."] = true
L["Bag Settings"] = true
L["Bags"] = true
L["Banners"] = true
L["Bar Layout"] = true
L["Boss Frames"] = "首领框体"
L["Bottom Center"] = true
L["Bottom-Left Corner"] = true
L["Bottom-Right Corner"] = true
L["Button Lock"] = true
L["Button Padding"] = true
L["Buttons Per Row"] = true
L["Cancel"] = "取消"
L["Cast action keybinds on key down"] = "按下快捷键时施法"
L["Cast Bar"] = "施法条"
L["Cast on Down"] = true
L["Center"] = true
L["Chi"] = "真气"
L["Choose an Edit Mode layout to automaically load when enabling this profile."] = true
L["Choose from which side new items are inserted into your bags."] = true
L["Choose how your auras are displayed."] = true
L["Choose how your bar is displayed."] = true
L["Choose in which direction items in your bags are sorted."] = true
L["Choose the action bar layout type."] = true
L["Choose when your auras will be visible."] = true
L["Choose whether the bar initially should expand horizontally or vertically."] = true
L["Choose which button to start the fading from."] = true
L["Choose which horizontal direction the aura buttons should expand in."] = true
L["Choose which horizontal direction the bar should expand in."] = true
L["Choose which modifier key to hold  down to show the aura buttons."] = true
L["Choose which vertical direction the aura buttons should expand in."] = true
L["Choose which vertical direction the bar should expand in."] = true
L["Click the button below to create an EditMode preset named '%s'."] = true
L["Click the button below to reset the currently selected EditMode preset to positions matching the default layout."] = true
L["Clock Settings"] = true
L["Combo Points"] = "连击点数"
L["Copy"] = "复制"
L["Create a new profile with the chosen name and copy the settings from the currently active one."] = true
L["Create a new profile with the chosen name."] = true
L["Create a new settings profile."] = true
L["Create EditMode Layout"] = true
L["Create New Profile"] = true
L["Create"] = "创建"
L["Delete"] = "删除"
L["Don't fade in other bars"] = true
L["Down"] = "下"
L["Edit Mode Layout"] = "编辑模式布局"
L["Edit Mode"] = "编辑模式"
L["Enable Aura Fading"] = true
L["Enable Aura Sorting"] = true
L["Enable Bar Fading"] = true
L["Enable Modifier Key"] = true
L["Enable this to only show faded bars on mouseover, and not force them visible in combat."] = true
L["Enable to use a 24 hour clock, disable to show a 12 hour clock with %s/%s suffixes."] = true
L["Enable"] = "启用"
L["Essence"] = "精华"
L["First ZigZag Button"] = true
L["Focus"] = true
L["Frame Fade Settings"] = true
L["Frame Fading"] = true
L["Grid Layout"] = true
L["Here you can change settings related to the aura buttons appearing at each unitframe."] = true
L["Here you can change settings related to the aura buttons appearing by default in the top right corner of the screen. None of these settings apply to the aura buttons found at the unitframes."] = true
L["Hide when targeting player."] = true
L["Hide when targeting self."] = true
L["Hide"] = "隐藏"
L["Holy Power"] = "神圣能量"
L["Horizontal Growth"] = true
L["Horizontal Layout"] = true
L["Horizontal Padding"] = true
L["HUD Edit Mode"] = "HUD编辑模式"
L["Ignore current target"] = true
L["Initial Growth"] = true
L["Insert Point"] = true
L["Layout:"] = "布局："
L["Left to Right"] = true
L["Left"] = "左"
L["Line Break"] = true
L["Line Padding"] = true
L["Makes the ToT frame transparent when its target is itself."] = true
L["Makes the ToT frame transparent when its target is you."] = true
L["Middle Left Side"] = true
L["Middle Right Side"] = true
L["Minimap Settings"] = true
L["Minimap"] = "小地图"
L["Modifier Key"] = true
L["Movable Frames Manager"] = true
L["Name of new profile:"] = true
L["Name the New Layout"] = "给新布局起名"
L["Nameplate Settings"] = true
L["Nameplates"] = "姓名板"
L["Normally auras will be hidden when you have a target, as their position directly conflicts with the position of the target frame. By enabling this the auras will ignore your target and remain visible."] = true
L["Number of buttons"] = true
L["Only show buttons from this specific bar when hovering it."] = true
L["Only show on mouseover"] = true
L["Party Frames"] = "小队框体"
L["Pet Bar"] = "宠物条"
L["Pet"] = true
L["Player Auras"] = true
L["Player"] = true
L["Position"] = true
L["Profile already exists."] = true
L["Raid Frames"] = "团队框体"
L["Require a modifier key to show the auras."] = true
L["Reset EditMode Layout"] = true
L["Reset"] = "重置"
L["Right to Left"] = true
L["Right"] = "右"
L["Runes"] = "符文"
L["Save"] = "保存"
L["Scale"] = true
L["Set the clock to your computer's local time, disable to show the server time instead."] = true
L["Sets the anchor point."] = true
L["Sets the horizontal offset from your chosen anchor point. Positive values means right, negative values means left."] = true
L["Sets the horizontal padding between your aura buttons."] = true
L["Sets the maximum number of aura buttons per row."] = true
L["Sets the number of action buttons on the action bar."] = true
L["Sets the padding between buttons on the same line."] = true
L["Sets the padding between multiple lines of buttons."] = true
L["Sets the relative scale of this element. Default scale is set to match the ideal size."] = true
L["Sets the vertical offset from your chosen anchor point. Positive values means up, negative values means down."] = true
L["Sets when a new line of buttons should begin."] = true
L["Sets which button the zigzag pattern should begin at."] = true
L["Show Auras"] = true
L["Show Auras only on current target."] = true
L["Show in parties."] = true
L["Show in party sized raid groups (1-5 Players)."] = true
L["Show in raids."] = true
L["Show itemID"] = true
L["Show player"] = true
L["Show spellID"] = true
L["Show Unit Name"] = true
L["Sort Direction"] = true
L["Soul Shards"] = "灵魂碎片"
L["Stagger"] = "醉拳"
L["Stance Bar"] = "姿态栏"
L["Start Fading from"] = true
L["Target of Target"] = true
L["Target"] = "目标"
L["Texture Variations"] = true
L["The new profile needs a name."] = true
L["to %s"] = true
L["to level %s"] = true
L["to next level"] = true
L["Toggle whether to add itemID to item tooltips or not."] = true
L["Toggle whether to add spellIDs and auraIDs in tooltips containing actions, spells or auras."] = true
L["Toggle whether to enable the buttons of this action bar to fade out."] = true
L["Toggle whether to enable the player aura buttons to fade out when not moused over."] = true
L["Toggle whether to enable this action bar or not."] = true
L["Toggle whether to enable this element or not."] = true
L["Toggle whether to show a larger texture for bosses."] = true
L["Toggle whether to show a smaller texture for critters."] = true
L["Toggle whether to show auras on this unit frame."] = true
L["Toggle whether to show the name of the unit."] = true
L["Toggle whether to show the party frames while in a raid group.\n\nIt is not possible to show both the Raid Frames and the Party Frames at the same time. Setting this option will disable the raid frames from being shown in party sized raid groups."] = true
L["Toggle whether to show the party frames while in parties.\n\nIt is not possible to show both the Raid Frames and the Party Frames at the same time. Setting this option will disable the raid frames from being shown in parties."] = true
L["Toggle whether to show the player aura buttons or not."] = true
L["Toggle whether to show the player while in a party."] = true
L["Toggle whether to show the raid frames while in a raid groups of five members or more."] = true
L["Toggle whether to show the raid frames while in parties.\n\nIt is not possible to show both the Raid Frames and the Party Frames at the same time. Setting this option will disable the party frames when in parties."] = true
L["Toggle whether to show the raid frames while in party sized raid groups.\n\nIt is not possible to show both the Raid Frames and the Party Frames at the same time. Setting this option will disable the party frames from being shown in party sized raid groups."] = true
L["Toggle whether to show the ice power crystal or the regular power crystal colored by resource type."] = true
L["Tooltip Settings"] = true
L["Tooltips"] = true
L["Top Center"] = true
L["Top-Left Corner"] = true
L["Top-Right Corner"] = true
L["Totem Bar"] = "图腾栏"
L["Unit Frames"] = "单位框体"
L["UnitFrame Settings"] = true
L["Up"] = "上"
L["Use Ice Crystal"] = true
L["Use Large Boss Texture"] = true
L["Use Local Time"] = "使用本地时间"
L["Use Small Critter Texture"] = true
L["Vertical Growth"] = true
L["Vertical Layout"] = true
L["Vertical Padding"] = true
L["Visibility"] = "可见性"
L["Welcome to %s"] = true
L["When enabled, unitframe auras will be sorted depending on time left and who cast the aura. When disabled, unitframe auras will appear in the order they were applied, like in the default user interface."] = true
L["X Offset"] = "X 偏移量"
L["Y Offset"] = "Y 偏移量"
L["You can now enter a new battleground, right-click the eye icon on the minimap to enter or leave!"] = true
L["ZigZag Layout"] = true
