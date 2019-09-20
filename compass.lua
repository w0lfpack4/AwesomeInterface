
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Compass"] = {
	hideInCombat 		= true,
	hideCompass 		= true,
	hideCompassInCombat = true,	
    showDescription 	= true,
}

----------------------------------------------------
-- local VARS
----------------------------------------------------
AI.vars["Compass"] = {
	nextLabelUpdateTime = 0,
	bestPinIndices = {},
	bestPinDistances = {},
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Compass"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize 
	------------------------------------------------
	Initialize = function()
		if (AI.saved.account.Compass.hideCompass) then
			ZO_CompassFrame:SetHidden(true)			
		end
	end,
	
	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function()
		local fragment = ZO_HUDFadeSceneFragment:New( AI_Compass )		
		if (AI.saved.account.Compass.showDescription) then
			SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )	
		else
			SCENE_MANAGER:GetScene('hud'):RemoveFragment( fragment )	
		end
	end,
	
	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.Compass.hideCompass) then
			HUD_SCENE:RegisterCallback("StateChange", AI.plugins.Compass.OnStateChanged)
			EVENT_MANAGER:RegisterForEvent("AI_Compass", EVENT_PLAYER_ACTIVATED, AI.plugins.Compass.OnPlayerActivated)
			EVENT_MANAGER:RegisterForEvent("AI_Compass", EVENT_ZONE_CHANGED, AI.plugins.Compass.OnZoneChanged)
		else
			HUD_SCENE:UnregisterCallback("StateChange", AI.plugins.Compass.OnStateChanged)
			EVENT_MANAGER:RegisterForEvent("AI_Compass", EVENT_PLAYER_ACTIVATED)
			EVENT_MANAGER:RegisterForEvent("AI_Compass", EVENT_ZONE_CHANGED)
		end
		
		if (AI.saved.account.Compass.showDescription) then
			EVENT_MANAGER:RegisterForUpdate("AI_Compass", 750, AI.plugins.Compass.SetDescription)	
		else
			EVENT_MANAGER:UnregisterForUpdate("AI_Compass")	
		end
	end,

	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (not AI.saved.account.Compass.hideCompass) then
			if (AI.saved.account.Compass.hideCompassInCombat) then
				ZO_CompassFrame:SetHidden(true)
			end		
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		if (not AI.saved.account.Compass.hideCompass) then
			if (AI.saved.account.Compass.hideCompassInCombat) then
				ZO_CompassFrame:SetHidden(false)
			end		
		end
	end,
	
	------------------------------------------------
	-- EVENT: OnStateChanged
	------------------------------------------------
	OnStateChanged = function(oldState, newState)
		if (AI.saved.account.Compass.hideCompass) then
			-- showing the hud
			if (newState == SCENE_FRAGMENT_SHOWING) then
				EVENT_MANAGER:RegisterForUpdate("AI_Compass_Hide", 0, AI.plugins.Compass.HideCompass)		
				-- 0 is timecode to fire update.  
				AI.plugins.Compass.HideCompass()	
			
			-- hud shown
			elseif (newState == SCENE_FRAGMENT_SHOWN) then
				--EVENT_MANAGER:UnregisterForUpdate("AI_Compass_Hide")
				AI.plugins.Compass.HideCompass()	
			end
		end		
	end, -- AI.OnStateChanged
	
	------------------------------------------------
	-- EVENT: OnPlayerActivated
	------------------------------------------------
	OnPlayerActivated = function()
		AI.plugins.Compass.HideCompass()	
	end,

	------------------------------------------------
	-- EVENT: OnZoneChanged
	------------------------------------------------
	OnZoneChanged = function()
		AI.plugins.Compass.HideCompass()	
	end,
	
	------------------------------------------------
	-- Method: HideCompass
	------------------------------------------------
	HideCompass = function()
		if (AI.saved.account.Compass.hideCompass) then
			ZO_CompassFrame:SetHidden(true)	
		end
	end,	
	
	------------------------------------------------
	-- METHOD: SetDescription
	------------------------------------------------
	SetDescription = function()
		-- description of current compass point quest poi
		if (AI.saved.account.Compass.showDescription) then
			local description = AI.plugins.Compass.GetQuestDescription()
			if (description) then
				AI_CompassDescription:SetText("|cFFFF60"..description)
			else
				AI_CompassDescription:SetText("")
			end
		end
	end,

	------------------------------------------------
	-- METHOD: GetQuestDescription
	------------------------------------------------
	GetQuestDescription = function()
		local now = GetFrameTimeMilliseconds()
		if now < AI.vars.Compass.nextLabelUpdateTime then
			return
		end	
		AI.vars.Compass.nextLabelUpdateTime = now + 100
		local bestPinDescription
		local bestPinType   
		local pinTypeToFormatId =
		{
			[MAP_PIN_TYPE_POI_SEEN] = SI_COMPASS_LOCATION_NAME_FORMAT,
			[MAP_PIN_TYPE_POI_COMPLETE] = SI_COMPASS_LOCATION_NAME_FORMAT,
		}
		if not (DoesUnitExist("boss1") or DoesUnitExist("boss2")) then
			ZO_ClearNumericallyIndexedTable(AI.vars.Compass.bestPinIndices)
			ZO_ClearNumericallyIndexedTable(AI.vars.Compass.bestPinDistances)
			for i = 1, COMPASS.container:GetNumCenterOveredPins() do
				if not COMPASS.container:IsCenterOveredPinSuppressed(i) then
					local drawLayer, drawLevel = COMPASS.container:GetCenterOveredPinLayerAndLevel(i)
					local layerInformedDistance = AI.plugins.Compass.CalculateLayerInformedDistance(drawLayer, drawLevel)
					local insertIndex
					for bestPinIndex = 1, #AI.vars.Compass.bestPinIndices do
						if layerInformedDistance < AI.vars.Compass.bestPinDistances[bestPinIndex] then
							insertIndex = bestPinIndex
							break
						end
					end
					if not insertIndex then
						insertIndex = #AI.vars.Compass.bestPinIndices + 1
					end
					table.insert(AI.vars.Compass.bestPinIndices, insertIndex, i)
					table.insert(AI.vars.Compass.bestPinDistances, insertIndex, layerInformedDistance)
				end
			end
			for i, centeredPinIndex in ipairs(AI.vars.Compass.bestPinIndices) do
				local description = COMPASS.container:GetCenterOveredPinDescription(centeredPinIndex)
				if description ~= "" then
					bestPinDescription = description
					bestPinType = COMPASS.container:GetCenterOveredPinType(centeredPinIndex)
					break
				end
			end
		end
		if bestPinDescription then
			local formatId = pinTypeToFormatId[bestPinType]
			--The first 3 types are the player pins (self, group, leader)
			if bestPinType < 3 then
				bestPinDescription = ZO_FormatUserFacingCharacterOrDisplayName(bestPinDescription)
			end
			if(formatId) then
				return zo_strformat(formatId, bestPinDescription)
			else
				return bestPinDescription
			end
		else
			return ""
		end
    end,    

	------------------------------------------------
	-- METHOD: CalculateLayerInformedDistance
	------------------------------------------------
	CalculateLayerInformedDistance = function(drawLayer, drawLevel)
		return (1.0 - (drawLevel / 0xFFFFFFFF)) - drawLayer
	end, 
	
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Compass.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Compass|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Original compass options.|r",
			},
			{
				type = "checkbox", 
				name = "Hide Original Compass", 
				tooltip = "Hides the original compass", 
				getFunc = function() return AI.saved.account.Compass.hideCompass end, 
				setFunc = function(newValue) AI.saved.account.Compass.hideCompass = newValue; AI.plugins.Compass.RegisterEvents();  end, 
				default = AI.defaults.Compass.hideCompass, 
			},
			{
				type = "checkbox", 
				name = "Hide Original Compass in combat", 
				tooltip = "Hides the compass when in combat", 
				getFunc = function() return AI.saved.account.Compass.hideInCombat end, 
				setFunc = function(newValue) AI.saved.account.Compass.hideInCombat = newValue end, 
				disabled = function() return AI.saved.account.Compass.hideCompass end,
				default = AI.defaults.Compass.hideInCombat, 
			},
			{
				type = "checkbox", 
				name = "Show Original Compass objective text", 
				tooltip = "Shows the original compass objective text at the top of the screen", 
				getFunc = function() return AI.saved.account.Compass.showDescription end, 
				setFunc = function(newValue) AI.saved.account.Compass.showDescription = newValue; AI.plugins.Compass.SetFragments(); AI.plugins.Compass.RegisterEvents(); end, 
				default = AI.defaults.Compass.showDescription, 
			}
		}
	}
}