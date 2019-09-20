
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Durability"] = {
	on 			= true,
	alpha 		= .4,
	showBetter  = true,
	showLevel   = true,
	showType    = true,
	showEnchant = true,
}

----------------------------------------------------
-- TEXTURES
----------------------------------------------------
AI.textures["Durability"] = {
	frame = AI.name.."/Textures/durability/DurabilityFrame.dds",
	good  = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds",
	bad   = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds"
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["Durability"] = {
	-- Weapon slots
	WeaponSlots = {
		[EQUIP_SLOT_MAIN_HAND]   = true,
		[EQUIP_SLOT_OFF_HAND]    = true,
		[EQUIP_SLOT_BACKUP_MAIN] = true,
		[EQUIP_SLOT_BACKUP_OFF]  = true,
	},

	-- armor slots
	ArmorSlots = {
		["EQUIP_SLOT_BACKUP_MAIN"] = "ZO_CharacterEquipmentSlotsBackupMain",
		["EQUIP_SLOT_BACKUP_OFF"]  = "ZO_CharacterEquipmentSlotsBackupOff",
		["EQUIP_SLOT_CHEST"]       = "ZO_CharacterEquipmentSlotsChest",
		["EQUIP_SLOT_COSTUME"]     = "ZO_CharacterEquipmentSlotsCostume",
		["EQUIP_SLOT_FEET"]        = "ZO_CharacterEquipmentSlotsFoot",
		["EQUIP_SLOT_HAND"]        = "ZO_CharacterEquipmentSlotsGlove",
		["EQUIP_SLOT_HEAD"]        = "ZO_CharacterEquipmentSlotsHead",
		["EQUIP_SLOT_LEGS"]        = "ZO_CharacterEquipmentSlotsLeg",
		["EQUIP_SLOT_MAIN_HAND"]   = "ZO_CharacterEquipmentSlotsMainHand",
		["EQUIP_SLOT_NECK"]        = "ZO_CharacterEquipmentSlotsNeck",
		["EQUIP_SLOT_OFF_HAND"]    = "ZO_CharacterEquipmentSlotsOffHand",
		["EQUIP_SLOT_RING1"]       = "ZO_CharacterEquipmentSlotsRing1",
		["EQUIP_SLOT_RING2"]       = "ZO_CharacterEquipmentSlotsRing2",
		["EQUIP_SLOT_SHOULDERS"]   = "ZO_CharacterEquipmentSlotsShoulder",
		["EQUIP_SLOT_WAIST"]       = "ZO_CharacterEquipmentSlotsBelt",
	},
	Frames = {},
	FramesBySlot = {},
	LevelLabelsBySlot = {},
	TypeLabelsBySlot = {},
	DB = {},
}
		
----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Durability"] = {
	
	------------------------------------------------
	-- PARENT METHOD: Initialize 
	------------------------------------------------
	Initialize = function()
		if (AI.saved.account.Durability.on) then				
			-- create durability frames
			for slotName, frameName in pairs(AI.vars.Durability.ArmorSlots) do
				AI.plugins.Durability.AddFrame(_G[frameName], _G[slotName])
			end	
		end
			
		-- init weapon highlight alpha
		AI.plugins.Durability.OnActiveWeaponPairChanged("Init",ACTIVE_WEAPON_PAIR_MAIN)
		
		if (AI.saved.account.Durability.showBetter) then		
			-- hook to inventories
			for k,v in pairs(PLAYER_INVENTORY.inventories) do
				local listView = v.listView
				if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
					ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
						local ItemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
						AI.plugins.Durability.AddIconToSlot(control, ItemLink, control.dataEntry.data.slotIndex)
					end)
				end
			end
		end
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.Durability.on) then	
			EVENT_MANAGER:RegisterForEvent("AI_Durability", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AI.plugins.Durability.OnChange)		
			ZO_PreHookHandler(ZO_Character, 'OnShow', AI.plugins.Durability.OnShow)
		end
		EVENT_MANAGER:RegisterForEvent("AI_Durability", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, AI.plugins.Durability.OnActiveWeaponPairChanged)	
	end,
	
	------------------------------------------------
	-- EVENT: OnChange
	------------------------------------------------
	OnChange = function(eventCode, bagId, slotId)
		if AI.saved.account.Durability.on and bagId == 0 then
			AI.plugins.Durability.UpdateFrame(slotId)
			AI.plugins.Durability.UpdateLabel(slotId)
			AI.plugins.Durability.UpdateType(slotId)
			AI.plugins.Durability.UpdateDB(slotId)
		end
	end, -- OnChange

	------------------------------------------------
	-- EVENT: OnShow
	------------------------------------------------
	OnShow = function(frame, ...)
		if (AI.saved.account.Durability.on) then		
			for i=1, #AI.vars.Durability.Frames do
				AI.plugins.Durability.UpdateFrame(AI.vars.Durability.Frames[i])
				AI.plugins.Durability.UpdateLabel(AI.vars.Durability.Frames[i])
				AI.plugins.Durability.UpdateType(AI.vars.Durability.Frames[i])
				AI.plugins.Durability.UpdateDB(AI.vars.Durability.Frames[i])
			end
		end
	end, -- OnShow
	
	------------------------------------------------
	-- EVENT: OnActiveWeaponPairChanged
	------------------------------------------------
	OnActiveWeaponPairChanged = function(event, activeWeaponPair)
		ZO_CharacterEquipmentSlotsMainHandHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
		ZO_CharacterEquipmentSlotsOffHandHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
		ZO_CharacterEquipmentSlotsPoisonHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
		ZO_CharacterEquipmentSlotsBackupMainHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
		ZO_CharacterEquipmentSlotsBackupOffHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
		ZO_CharacterEquipmentSlotsBackupPoisonHighlight:SetAlpha(AI.saved.account.Durability.alpha) --SetHidden(true)
    end,
	
	------------------------------------------------
	-- METHOD: AddFrame
	------------------------------------------------
	AddFrame = function(parent, slot)
		-- durability frame
		local frame = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
			frame:SetDimensions(46,46)
			frame:SetAnchor(BOTTOM, parent, BOTTOM, 0,1)
			frame:SetTexture(AI.textures.Durability.frame)
			frame:SetDrawLayer(0)
			local frameEmpty = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
				frameEmpty:SetDimensions(46,46)
				frameEmpty:SetAnchor(BOTTOM, frame, TOP, 0,0)
				frameEmpty:SetTexture(AI.textures.Durability.frame)
				frameEmpty:SetDrawLayer(0)
			frame.emptypart = frameEmpty
		AI.vars.Durability.FramesBySlot[slot] = frame
		
		-- item level label
		if AI.saved.account.Durability.showLevel then
			local levelLabel = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
			levelLabel:SetDimensions(50, 16)
			levelLabel:SetAnchor(BOTTOMLEFT, parent, TOPRIGHT, -20,16)
			levelLabel:SetFont("EsoUI/Common/Fonts/Univers67.otf|14|soft-shadow-thick")
			levelLabel:SetColor(0.9, 0.9, 0.9, 1)
			levelLabel:SetHorizontalAlignment(CENTER)
			levelLabel:SetVerticalAlignment(CENTER)
			AI.vars.Durability.LevelLabelsBySlot[slot] = levelLabel
		end

		-- item type label
		if AI.saved.account.Durability.showType or AI.saved.account.Durability.showEnchant then
			local typeLabel = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
			typeLabel:SetDimensions(50, 16)
			typeLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 4, 0)
			typeLabel:SetFont("EsoUI/Common/Fonts/Univers67.otf|14|soft-shadow-thick")
			typeLabel:SetColor(0.9, 0.9, 0.9, 1)
			typeLabel:SetHorizontalAlignment(CENTER)
			typeLabel:SetVerticalAlignment(CENTER)
			AI.vars.Durability.TypeLabelsBySlot[slot] = typeLabel
		end
		
		AI.vars.Durability.Frames[#AI.vars.Durability.Frames + 1] = slot
		AI.plugins.Durability.UpdateFrame(slot)
		AI.plugins.Durability.UpdateLabel(slot)
		AI.plugins.Durability.UpdateType(slot)
	end, -- AddFrame	

	------------------------------------------------
	-- METHOD: UpdateFrame
	------------------------------------------------
	UpdateFrame = function(slot)
		if (slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON) then return end -- poison
		local frame = AI.vars.Durability.FramesBySlot[slot]
		local frameEmpty = frame.emptypart
		local equipable = IsEquipable(0, slot)
		
		-- hide if not equipped
		frame:SetHidden(not equipable)
		frameEmpty:SetHidden(not equipable)
		
		-- get info
		if equipable then
			local c = GetItemQualityColor(select(8, GetItemInfo(0, slot)))
			local percentage = 0

			if AI.vars.Durability.WeaponSlots[slot] then
				local charge, max_charge = GetChargeInfoForItem(0, slot)
				percentage = charge/max_charge
				frame:SetColor(c.r, c.g, c.b, 1)
			else
				percentage = GetItemCondition(0, slot)/100
				frame:SetColor(c.r, c.g, c.b, .8)
			end
			frame:SetTextureCoords(0,1,1-percentage,1)
			frame:SetHeight(44*percentage)
			frameEmpty:SetColor(c.r/3, c.g/3, c.b/3, .8)
			frameEmpty:SetTextureCoords(0,1,0,1-percentage)
			frameEmpty:SetHeight(44*(1-percentage))			
		end
	end, -- UpdateFrame
	
	------------------------------------------------
	-- METHOD: UpdateLabel
	------------------------------------------------
	UpdateLabel = function(slot)
		if not AI.saved.account.Durability.showLevel then return end
		if (slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON) then  return end -- poison
		local levelLabel = AI.vars.Durability.LevelLabelsBySlot[slot]
		local equipable = IsEquipable(0, slot)
		
		-- hide if not equipped
		levelLabel:SetHidden(not equipable)
		
		if equipable then
			
			-- champion and gear level == 50
			if (IsUnitChampion("player") and (GetItemRequiredLevel(0, slot) == 50)) then
				-- get the items ACTUAL level
				local l = GetItemRequiredChampionPoints(0, slot)
				
				local p = GetPlayerChampionPointsEarned()

				-- max gear
				if (l==160) then
					levelLabel:SetText(AI.colors.green..l)

				-- bad gear
				else

					-- 30 levels red
					if (p-l > 30) then
						levelLabel:SetText(AI.colors.red..l)

					-- 20 levels orange
					elseif (p-l > 20) then
						levelLabel:SetText(AI.colors.orange..l)

					-- 10 levels yellow
					elseif (p-l > 10) then
						levelLabel:SetText(AI.colors.yellow..l)

					-- up to 10 green
					else
						levelLabel:SetText(AI.colors.green..l)

					end
				end

			else
		
				-- get the items ACTUAL level
				local l = GetItemRequiredLevel(0, slot) 
				
				-- get the items EFFECTIVE level (Based on quality, enchants?)
				local el = GetItemLevel(0, slot)
				
				-- get the players level
				local pl = GetUnitLevel("player")
				
				-- get how many levels this item is good for
				local gl = ((el-l)-5)
				
				-- new effective level
				local tl = l + gl
				
				-- new effective level < current player level = bad
				if (tl < pl) then
					levelLabel:SetText(AI.colors.red..l)
				
				-- new effective level = current player level = ok, not great
				elseif (tl == pl) then
					levelLabel:SetText(AI.colors.orange..l)
				
				-- new effective level > current player level, good to go
				else
					local diff = tl-pl
					if ( diff == 1 ) then
						levelLabel:SetText(AI.colors.yellow..l)			
					elseif (gl == 2 ) then
						levelLabel:SetText(AI.colors.green..l)
					else
						levelLabel:SetText(AI.colors.green..l)
					end
				end
			end
		end
	
	end, 
	
	
	------------------------------------------------
	-- METHOD: UpdateType
	------------------------------------------------
	UpdateType = function(slot)
		if not AI.saved.account.Durability.showType and not AI.saved.account.Durability.showEnchant then return end
		if (slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON) then  return end -- poison
		local typeLabel = AI.vars.Durability.TypeLabelsBySlot[slot]
		local equipable = IsEquipable(0, slot)
		
		-- hide if not equipped
		typeLabel:SetHidden(not equipable)
		typeLabel:SetText("")
		
		if equipable then

			local color, armor, enchant = "", "", ""
						
			-- get the link
			local link = GetItemLink(0, slot, LINK_STYLE_DEFAULT)

			-- is there an enchant?
			local hasEnchant, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(link)
			if (hasEnchant) then
				if (string.find(enchantHeader, "Magicka")) then color = AI.colors.cyan;  enchant = "M" end
				if (string.find(enchantHeader, "Health"))  then color = AI.colors.red;   enchant = "H" end
				if (string.find(enchantHeader, "Stamina")) then color = AI.colors.green; enchant = "S" end
			else
				color = AI.colors.normal;  enchant = ""
			end

			-- armor only
			if not AI.vars.Durability.WeaponSlots[slot] then
				-- neck, rings
				if (slot == EQUIP_SLOT_NECK or slot == EQUIP_SLOT_RING1 or slot == EQUIP_SLOT_RING2) then
					if (AI.saved.account.Durability.showEnchant) then
						typeLabel:SetText(color..enchant)
					end	
				-- main set
				else
					local armorType = GetItemArmorType(0, slot)
					if armorType == ARMORTYPE_HEAVY then
						armor = "H"
					elseif armorType == ARMORTYPE_MEDIUM then
						armor = "M"
					elseif armorType == ARMORTYPE_LIGHT then
						armor = "L"
					end

					if (AI.saved.account.Durability.showEnchant and AI.saved.account.Durability.showType) then
						typeLabel:SetText(color..armor..enchant)

					elseif (AI.saved.account.Durability.showEnchant) then
						typeLabel:SetText(color..enchant)

					elseif (AI.saved.account.Durability.showType) then
						typeLabel:SetText(color..armor)
					end	
				end	
			end			
		end	
	end, 

	------------------------------------------------
	-- METHOD: UpdateDB
	------------------------------------------------
	UpdateDB = function(slot)
		if (slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON) then return end -- poison
		local equipable = IsEquipable(0, slot)
		
		-- get the link
		local link = GetItemLink(0, slot, LINK_STYLE_DEFAULT)
		
		-- get the slot
		local equipSlot = GetItemLinkEquipType(link)
		
		
		if equipable then
		
			-- create the entry if it does not exist
			if AI.vars.Durability.DB[equipSlot] == nil then
				AI.vars.Durability.DB[equipSlot] = {}
			end
			
			-- name
			AI.vars.Durability.DB[equipSlot]["name"] = GetItemName(0, slot)
			
			-- level
			if (IsUnitChampion("player")) then
				AI.vars.Durability.DB[equipSlot]["level"] = GetItemRequiredChampionPoints(0, slot)
			else
				AI.vars.Durability.DB[equipSlot]["level"] = GetItemRequiredLevel(0, slot)
			end			
			
			-- quality
			AI.vars.Durability.DB[equipSlot]["quality"] = GetItemLinkQuality(link)		

			-- enchant
			local hasEnchant, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(link)
			if (hasEnchant) then
				AI.vars.Durability.DB[equipSlot]["enchant"] = enchantHeader	
			end

			-- trait
			local itemTrait = GetItemLinkTraitInfo(link)
			if (itemTrait) then
				AI.vars.Durability.DB[equipSlot]["trait"] = GetString("SI_ITEMTRAITTYPE", itemTrait)
			end

			-- is this a weapon?
			if AI.vars.Durability.WeaponSlots[slot] then
				-- power rating
				AI.vars.Durability.DB[equipSlot]["power"] = GetItemLinkWeaponPower(link)
				
				-- weapon type
				AI.vars.Durability.DB[equipSlot]["type"] = GetItemWeaponType(0, slot)
				--[[
					WEAPONTYPE_AXE
					WEAPONTYPE_TWO_HANDED_AXE
					WEAPONTYPE_BOW
					WEAPONTYPE_DAGGER
					WEAPONTYPE_HAMMER
					WEAPONTYPE_TWO_HANDED_HAMMER
					WEAPONTYPE_SHIELD
					WEAPONTYPE_HEALING_STAFF
					WEAPONTYPE_FIRE_STAFF
					WEAPONTYPE_FROST_STAFF
					WEAPONTYPE_LIGHTNING_STAFF
					WEAPONTYPE_SWORD
					WEAPONTYPE_TWO_HANDED_SWORD
				--]]
			
			-- must be armor
			else
				-- armor rating
				AI.vars.Durability.DB[equipSlot]["rating"] = GetItemLinkArmorRating(link, false)
				
				-- armor type
				AI.vars.Durability.DB[equipSlot]["type"] = GetItemArmorType(0, slot)
				--[[
					ARMORTYPE_HEAVY
					ARMORTYPE_MEDIUM
					ARMORTYPE_LIGHT
				--]]
			end
		end
		AI.saved.account.Durability.DB = AI.vars.Durability.DB
	end, -- UpdateDB
	
	------------------------------------------------
	-- METHOD: IsItemBetter
	------------------------------------------------
	IsItemBetter = function(slot)
		-- get the link
		local link = GetItemLink(1, slot, LINK_STYLE_DEFAULT)
		local itemtype, spectype = GetItemLinkItemType(link)
		
		-- only if slot is armor or weapon
		if itemtype == ITEMTYPE_ARMOR or itemtype == ITEMTYPE_WEAPON then
		
			-- what slot to compare
			local equipSlot = GetItemLinkEquipType(link)
			
			-- no data on equipped item, return
			if AI.vars.Durability.DB[equipSlot] == nil then return false end
			
			-- name (debug purposes only)
			local name = GetItemName(1, slot)
			
			-- level
			local level = GetItemRequiredLevel(1, slot)
			local levelCP = GetItemRequiredChampionPoints(1, slot)	
			
			-- champion?
			local cp = (GetUnitChampionPoints("player") > 0)
			
			-- is champion
			if cp then
				-- equipped is not cp
				if AI.vars.Durability.DB[equipSlot].level == 0 then
					-- item is not cp, test
					if level == 0 then
						-- old gear, exit
						if level < AI.vars.Durability.DB[equipSlot].level then return false end
					end
				-- equipped is cp
				else
					-- old gear, or non cp, exit
					if levelCP < AI.vars.Durability.DB[equipSlot].level then return false end
				end
			else
				-- old gear, exit
				if level < AI.vars.Durability.DB[equipSlot].level then return false end
			end
	
			
			-- quality
			local quality = GetItemLinkQuality(link)	
			
			-- junk or white, exit
			if quality == ITEM_QUALITY_TRASH or quality == ITEM_QUALITY_NORMAL then return false end
			
			-- quality is not the same
			if quality ~= AI.vars.Durability.DB[equipSlot].quality then 
			
				-- lower quality
				if quality < AI.vars.Durability.DB[equipSlot].quality then
				
					-- lets not drop more than 2 quality levels
					if AI.vars.Durability.DB[equipSlot].quality - quality > 1 then
					
						-- if the level of the item is 3 levels higher, we'll allow it
						if level - AI.vars.Durability.DB[equipSlot].level < 3 then
							return false
						end
						
					end
					
				end
				
			end
			
			-- weapons
			if itemtype == ITEMTYPE_WEAPON then
				
				-- not what we're using, exit
				if GetItemWeaponType(1, slot) ~= AI.vars.Durability.DB[equipSlot].type then return false end
								
				-- lesser power, exit
				if GetItemLinkWeaponPower(link) < AI.vars.Durability.DB[equipSlot].power then return false end
				
				return true
			
			end
			
			-- armor
			if itemtype == ITEMTYPE_ARMOR then
							
				-- not what we're using, exit
				if GetItemArmorType(1, slot) ~= AI.vars.Durability.DB[equipSlot].type then return false end
			
				-- lesser armor rating, exit
				if GetItemLinkArmorRating(link, false) < AI.vars.Durability.DB[equipSlot].rating then return false end
								
				return true
				
			end	
		
		end
	end, -- IsItemBetter	
		
	------------------------------------------------
	-- METHOD: CreateIconControl
	------------------------------------------------
	CreateIconControl = function(parent)
		local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "AICON", parent, CT_TEXTURE)
		control:SetHidden(true)
		return control
	end, --  CreateIconControl
	
	
	------------------------------------------------
	-- METHOD: AddIconToSlot
	------------------------------------------------
	AddIconToSlot = function(control, ItemLink, slot)
	
		-- hook status icon control
		local StatusControl = control:GetNamedChild("StatusTexture")
		
		-- reset color
		StatusControl:SetColor(1,1,1,1)		
		
		-- is there a texture file?
		local StatusTexture = (StatusControl:GetTextureFileName() ~= "")
	
		-- check if icon is added already, if not add one, make invisible for now
		local IconControl = control:GetNamedChild("AICON")
		if ( not IconControl ) then
			IconControl = AI.plugins.Durability.CreateIconControl(control)
		end

		-- check if item is armor or if grid mode enabled, hide if not
		if ( control.isGrid or ( control:GetWidth() - control:GetHeight() < 5 ) ) then
			IconControl:SetHidden(true)
			return
		end
		
		-- get the item type
		local itemtype, spectype = GetItemLinkItemType(ItemLink)
		
		-- only if slot is armor or weapon
		if itemtype ~= ITEMTYPE_ARMOR and itemtype ~= ITEMTYPE_WEAPON then
			IconControl:SetHidden(true)
			return
		end
		
		-- only if the item is better
		if not AI.plugins.Durability.IsItemBetter(slot) then
			IconControl:SetHidden(true)
			return
		end
		
		-- positioning
		local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. "Status")
		IconControl:ClearAnchors()
		IconControl:SetAnchor(TOP, controlName, TOP, 23, 5 )

		-- add tooltip and make it visible
		IconControl:SetMouseEnabled(true)
		IconControl:SetHandler("OnMouseEnter", function(self)
				ZO_Tooltips_ShowTextTooltip(self, TOP, "This item is potentially better than what is currently equipped")
			end)
		IconControl:SetHandler("OnMouseExit", function(self)
				ZO_Tooltips_HideTextTooltip()
			end)
		IconControl:SetDimensions(24,24)
		IconControl:SetTexture(AI.textures.Durability.good)
		IconControl:SetColor(0,1,0,1)
		
		if (not StatusTexture) then
			IconControl:SetHidden(false)
		else
			StatusControl:SetColor(0,1,0,1)		
		end
	end, --AddIconToSlot

} --AI.plugins.Durability

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Durability.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Durability|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Adds a box around a piece of gear colored by the quality.  The height of the box indicates durability. Other options display the level, type, and enchantment of the gear piece at a glance.|r",
			},
			{
				type = "checkbox", 
				name = "Indicate durability on character sheet", 
				tooltip = "Displays an indicator over each piece of gear on the character sheet", 
				getFunc = function() return AI.saved.account.Durability.on end, 
				setFunc = function(newValue) AI.saved.account.Durability.on = newValue end, 
				requiresReload = true,
				default = AI.defaults.Durability.on, 
			},
			{
				type = "checkbox", 
				name = "Show gear level on character sheet", 
				tooltip = "Displays a level label over each piece of gear on the character sheet", 
				getFunc = function() return AI.saved.account.Durability.showLevel end, 
				setFunc = function(newValue) AI.saved.account.Durability.showLevel = newValue end, 
				disabled = function() return not AI.saved.account.Durability.on end, 
				requiresReload = true,
				default = AI.defaults.Durability.showLevel, 
			},
			{
				type = "checkbox", 
				name = "Show gear type on character sheet", 
				tooltip = "Displays an armor type label over each piece of armor on the character sheet", 
				getFunc = function() return AI.saved.account.Durability.showType end, 
				setFunc = function(newValue) AI.saved.account.Durability.showType = newValue end, 
				disabled = function() return not AI.saved.account.Durability.on end, 
				requiresReload = true,
				default = AI.defaults.Durability.showType, 
			},
			{
				type = "checkbox", 
				name = "Show gear enchant on character sheet", 
				tooltip = "Displays an enchantment label over each piece of armor on the character sheet", 
				getFunc = function() return AI.saved.account.Durability.showEnchant end, 
				setFunc = function(newValue) AI.saved.account.Durability.showEnchant = newValue end, 
				disabled = function() return not AI.saved.account.Durability.on end, 
				requiresReload = true,
				default = AI.defaults.Durability.showEnchant, 
			},
			{
				type = "slider",
				name = "Dim selected weapon highlight on character sheet", 
				tooltip = "Dims the overly bright highlight on selected weapon rows to the selected value", 
				min  = 0,
				max = 100,
				step = 1,
				getFunc = function() return AI.saved.account.Durability.alpha * 100 end,
				setFunc = function(newValue) AI.saved.account.Durability.alpha = newValue / 100; end,
				default = AI.defaults.Durability.alpha * 100,		
			},
			{
				type = "description",
				text = AIB.colors.orange.."Display an indicator next to each piece of better gear in your inventory.|r",
			},
			{
				type = "checkbox", 
				name = "Indicate better gear in inventory", 
				tooltip = "Displays an indicator next to each piece of better gear in your inventory. Compares item level, quality, gear type, weapon power or armor rating.", 
				getFunc = function() return AI.saved.account.Durability.showBetter end, 
				setFunc = function(newValue) AI.saved.account.Durability.showBetter = newValue end, 
				requiresReload = true,
				default = AI.defaults.Durability.showBetter, 
			}
		}
	}
}
