
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Buffs"] = {
	on			    = true,
	hideInCombat    = true,
	showHiddenBuffs = false,
	hide		    = {},
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["Buffs"] = {
	container,
	buttonPool,
	fragment,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Buffs"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()		
		-- load global defaults to character if missing
		if (AI.saved.character.Buffs == nil) then
			AI.saved.character.Buffs = AI.defaults.Buffs
		end		
		-- new (made up name to use, parent control, container control name in quotes)
		AI.vars.Buffs.container = CreateControlFromVirtual("AI_BuffsContainer", AI_Buffs, "AI_Buffs_Container")
		if (AI.saved.character.Buffs.on) then
			-- new (template control name in quotes, container control)
			AI.vars.Buffs.buttonPool = ZO_ControlPool:New("AI_Buffs_Template", AI.vars.Buffs.container)
			AI.plugins.Buffs.ToggleBuffs()
		end
	end,
		
	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function() 	
		AI.vars.Buffs.fragment = ZO_HUDFadeSceneFragment:New( AI_Buffs )
		if (AI.saved.character.Buffs.on) then
			SCENE_MANAGER:GetScene('hud'):AddFragment( AI.vars.Buffs.fragment )	
			SCENE_MANAGER:GetScene('hudui'):AddFragment( AI.vars.Buffs.fragment )	
		else
			SCENE_MANAGER:GetScene('hud'):RemoveFragment( AI.vars.Buffs.fragment )	
			SCENE_MANAGER:GetScene('hudui'):RemoveFragment( AI.vars.Buffs.fragment )	
		end	
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.character.Buffs.on) then
			EVENT_MANAGER:RegisterForEvent("AI_Buffs", EVENT_EFFECT_CHANGED, AI.plugins.Buffs.OnEffectChanged)
			EVENT_MANAGER:AddFilterForEvent("AI_Buffs", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
			EVENT_MANAGER:RegisterForEvent("AI_Buffs", EVENT_EFFECTS_FULL_UPDATE, AI.plugins.Buffs.UpdateEffects)
			EVENT_MANAGER:RegisterForEvent("AI_Buffs", EVENT_ARTIFICIAL_EFFECT_ADDED, AI.plugins.Buffs.UpdateEffects)
			EVENT_MANAGER:RegisterForEvent("AI_Buffs", EVENT_ARTIFICIAL_EFFECT_REMOVED, AI.plugins.Buffs.UpdateEffects)
		else
			EVENT_MANAGER:UnregisterForEvent("AI_Buffs", EVENT_EFFECT_CHANGED)
			EVENT_MANAGER:UnregisterForEvent("AI_Buffs", EVENT_EFFECTS_FULL_UPDATE)
			EVENT_MANAGER:UnregisterForEvent("AI_Buffs", EVENT_ARTIFICIAL_EFFECT_ADDED)
			EVENT_MANAGER:UnregisterForEvent("AI_Buffs", EVENT_ARTIFICIAL_EFFECT_REMOVED)
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (AI.saved.character.Buffs.hideInCombat) then	
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(AI.vars.Buffs.fragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(AI.vars.Buffs.fragment)
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		if (AI.saved.character.Buffs.hideInCombat) then	
			SCENE_MANAGER:GetScene('hud'):AddFragment( AI.vars.Buffs.fragment )	
			SCENE_MANAGER:GetScene('hudui'):AddFragment( AI.vars.Buffs.fragment )	
		end
	end,

	------------------------------------------------
	-- METHOD: ToggleBuffs
	------------------------------------------------
	ToggleBuffs = function()
		if (AI.saved.character.Buffs.on) then
			AI_Buffs:SetHidden(false)
			AI_BuffsBG:SetAlpha(1)
			AI.vars.Buffs.container:SetHidden(false)
			AI.plugins.Buffs.SetFragments()
			AI.plugins.Buffs.RegisterEvents()
			AI.plugins.Buffs.UpdateEffects()
		else
			AI_Buffs:SetHidden(true)
			AI_BuffsBG:SetAlpha(0)
			AI.vars.Buffs.container:SetHidden(true)
			AI.plugins.Buffs.SetFragments()
			AI.plugins.Buffs.RegisterEvents()
		end
	end,

	------------------------------------------------
	-- EVENT: OnEffectChanged
	------------------------------------------------
	OnEffectChanged = function(eventCode, changeType, buffSlot, buffName, unitTag)
		AI.plugins.Buffs.UpdateEffects()
	end,

	------------------------------------------------
	-- METHOD: UpdateEffects
	------------------------------------------------
	UpdateEffects = function()
		if (AI.saved.character.Buffs.on) then
			AI.vars.Buffs.buttonPool:ReleaseAllObjects()
			local effectsRows = {}
			local count = 0

			--Artificial effects--
			for effectId in ZO_GetNextActiveArtificialEffectIdIter do
				local displayName, iconFile, effectType, sortOrder, startTime, endTime = GetArtificialEffectInfo(effectId)
				-- not hidden, or show all is selected
				if ((not AI.saved.character.Buffs.hide[displayName]) or AI.saved.character.Buffs.showHiddenBuffs) then
					-- get the control set from the pool
					local effectsRow = AI.vars.Buffs.buttonPool:AcquireObject()
					-- set the display name used to show/hide buffs
					effectsRow.displayName = displayName
					-- set the icon texture (icon set as control in xml init)
					effectsRow.icon:SetTexture(iconFile)
					-- set the timer as hidden if the clock ran out or permanent effect
					local duration = startTime - endTime
					effectsRow.time:SetHidden(duration == 0)
					effectsRow.time.endTime = endTime
					-- set the tooltip title (tooltips handled in xml mouseover)
					effectsRow.tooltipTitle = displayName
					effectsRow.effectType = effectType
					effectsRow.effectId = effectId
					effectsRow.isArtificial = true					
					effectsRow.sortOrder = sortOrder
					-- display a red semi-trans backdrop on hidden items
					if (AI.saved.character.Buffs.hide[displayName] and AI.saved.character.Buffs.showHiddenBuffs) then
						effectsRow.backdrop:SetAlpha(.4)
					else
						effectsRow.backdrop:SetAlpha(0)
					end
					table.insert(effectsRows, effectsRow)
					count = count + 1
				end
			end

			-- player buffs, food/drink, boons, werewolf, etc..
			for i = 1, GetNumBuffs("player") do
				local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType = GetUnitBuffInfo("player", i)
				if buffSlot > 0 and buffName ~= "" then
					-- not hidden, or show all is selected
					if ((not AI.saved.character.Buffs.hide[buffName]) or AI.saved.character.Buffs.showHiddenBuffs) then
						-- get the control set from the pool
						local effectsRow = AI.vars.Buffs.buttonPool:AcquireObject()
						-- set the display name used to show/hide buffs
						effectsRow.displayName = buffName
						-- set the icon texture (icon set as control in xml init)
						effectsRow.icon:SetTexture(iconFile)
						-- set the timer as hidden if the clock ran out or permanent effect
						local duration = startTime - endTime
						effectsRow.time:SetHidden(duration == 0)
						effectsRow.time.endTime = endTime
						-- set the tooltip title (tooltips handled in xml mouseover)
						effectsRow.tooltipTitle = buffName
						effectsRow.buffSlot = buffSlot
						effectsRow.isArtificial = false
						effectsRow.effectType = effectType
						-- display a red semi-trans backdrop on hidden items
						if (AI.saved.character.Buffs.hide[buffName] and AI.saved.character.Buffs.showHiddenBuffs) then
							effectsRow.backdrop:SetAlpha(.4)
						else
							effectsRow.backdrop:SetAlpha(0)
						end
						table.insert(effectsRows, effectsRow)
						count = count + 1
					end
				end
			end
			-- sort
			table.sort(effectsRows, AI.plugins.Buffs.EffectsRowComparator)

			-- set anchors
			local prevRow
			for i, effectsRow in ipairs(effectsRows) do
				if prevRow then
					effectsRow:SetAnchor(TOPLEFT, prevRow, TOPRIGHT, 5, 0)
				else
					effectsRow:SetAnchor(LEFT, AI_Buffs, LEFT, 15, 20)
				end
				effectsRow:SetHidden(false)
				prevRow = effectsRow
			end

			-- set control and backdrop width based ont he number of buffs
			AI_Buffs:SetWidth((count*40)+30)
			AI_BuffsBG:SetWidth(AI_Buffs:GetWidth()*1.76)
		end
	end,
	
	------------------------------------------------
	-- METHOD: EffectsRowComparator
	------------------------------------------------
	EffectsRowComparator = function(left, right)
		local leftIsArtificial, rightIsArtificial = left.isArtificial, right.isArtificial
		if leftIsArtificial ~= rightIsArtificial then
			--Artificial before real
			return leftIsArtificial
		else
			if leftIsArtificial then
				--Both artificial, use def defined sort order
				return left.sortOrder < right.sortOrder
			else
				--Both real, use time
				return left.time.endTime < right.time.endTime
			end
		end
	end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Buffs.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Buff Bar|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays a buff bar next to the performance meters. These settings are per character.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.character.Buffs.on end,
				setFunc = function(newValue) AI.saved.character.Buffs.on = newValue; AI.plugins.Buffs.ToggleBuffs() end,
				default = AI.defaults.Buffs.on,
			},		
			{
				type = "checkbox",
				name = "Hide buffs in combat", 
				tooltip = "Hides the buff frame in combat",
				getFunc = function() return AI.saved.character.Buffs.hideInCombat end,
				setFunc = function(newValue) AI.saved.character.Buffs.hideInCombat = newValue end,
				disabled = function() return not(AI.saved.character.Buffs.on) end,
				default = AI.defaults.Buffs.hideInCombat,
			},		
			{
				type = "checkbox",
				name = "Show hidden buffs", 
				tooltip = "Show buffs that have previously been hidden by clicking on the buff.  Clicking again will restore it.",
				getFunc = function() return AI.saved.character.Buffs.showHiddenBuffs end,
				setFunc = function(newValue) AI.saved.character.Buffs.showHiddenBuffs = newValue; AI.plugins.Buffs.UpdateEffects() end,
				disabled = function() return not(AI.saved.character.Buffs.on) end,
				default = AI.defaults.Buffs.showHiddenBuffs,
			}

		}
	}
}
