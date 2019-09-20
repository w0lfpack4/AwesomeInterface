----------------------------------------------------
-- TEXTURES
----------------------------------------------------
AI.textures["Navigation"] = {
	on  = AI.name.."/Textures/navigation/arrow_on.dds",
	off = AI.name.."/Textures/navigation/arrow_off.dds",
	area = AI.name.."/Textures/navigation/arrow_area.dds"
}

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Navigation"] = {
	on 					= true,
	hideInCombat		= true,
    showDistance        = true,
    limitDistance       = true,
    distanceThreshold   = 75,
}

----------------------------------------------------
-- local VARS
----------------------------------------------------
AI.vars["Navigation"] = {
	isArea = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Navigation"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize 
	------------------------------------------------
	Initialize = function()
		if (AI.saved.account.Navigation.on) then
			AI_Navigation:SetHidden(false)		
			AI_NavigationTexture:SetTexture(AI.textures.Navigation.on)
			AI.plugins.Navigation.OnReticleHiddenUpdate()	
		end
    end,

	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function()
		local fragment = ZO_HUDFadeSceneFragment:New( AI_Navigation )
		if (AI.saved.account.Navigation.on) then
			SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )	
		else
			SCENE_MANAGER:GetScene('hud'):RemoveFragment( fragment )	
		end
	end,
    
	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.Navigation.on) then
			-- 50 is a time code in milliseconds for updates.  
			-- parent update method is set for 1 second, we need a faster update for the reticle.
			EVENT_MANAGER:RegisterForUpdate("AI_Navigation", 50, AI.plugins.Navigation.SetDirection)	
			EVENT_MANAGER:RegisterForEvent("AI_Navigation", EVENT_RETICLE_HIDDEN_UPDATE, AI.plugins.Navigation.OnReticleHiddenUpdate)
			EVENT_MANAGER:RegisterForEvent("AI_Navigation", EVENT_PLAYER_ACTIVATED, AI.plugins.Navigation.SetDirection)
		else
			EVENT_MANAGER:UnregisterForUpdate("AI_Navigation")	
			EVENT_MANAGER:UnregisterForEvent("AI_Navigation", EVENT_RETICLE_HIDDEN_UPDATE)
			EVENT_MANAGER:UnregisterForEvent("AI_Navigation", EVENT_PLAYER_ACTIVATED)
		end
	end,

	------------------------------------------------
	-- PARENT METHOD: OnEnteringCombat
	------------------------------------------------
    OnEnteringCombat = function()
		if (AI.saved.account.Navigation.hideInCombat) then
            AI_Navigation:SetHidden(true)
        end
	end,

	------------------------------------------------
	-- PARENT METHOD: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		if (AI.saved.account.Navigation.hideInCombat) then
			AI_Navigation:SetHidden(false)
		end
	end,
				
	------------------------------------------------
	-- EVENT: OnReticleHiddenUpdate
	------------------------------------------------
	OnReticleHiddenUpdate = function(eventCode, hidden)
		if (AI.saved.account.Navigation.on) then
			if(hidden == true) then
				AI_Navigation:SetHidden(true)
			else
				AI_Navigation:SetHidden(false)
			end
		end
	end,
		
	------------------------------------------------
	-- METHOD: ToggleQuestNavigation
	------------------------------------------------
	ToggleQuestNavigation = function()
		AI.saved.account.Navigation.on = not AI.saved.account.Navigation.on	
		AI.plugins.Navigation.SetFragments()
		AI.plugins.Navigation.RegisterEvents()
        if (AI.saved.account.Navigation.showDistance) then
            AI_NavigationDistance:SetHidden(not AI.saved.account.Navigation.on)
        end
	end,

	------------------------------------------------
	-- METHOD: SetDirection
	------------------------------------------------
	SetDirection = function()
		if (AI.saved.account.Navigation.on) then
			-- get the current heading
			local rads = AI.plugins.Navigation.GetAssistedQuestHeading() or AI.plugins.Navigation.GetWaypointHeading()

			-- hide if heading is nil
			if (rads) then
				if (AI.vars.Navigation.isArea) then
					AI_NavigationTexture:SetTexture(AI.textures.Navigation.area)
				else
					AI_NavigationTexture:SetTexture(AI.textures.Navigation.on)
				end
			else
				AI_NavigationTexture:SetTexture(AI.textures.Navigation.off)
				return
			end

			-- continue
			local heading = GetPlayerCameraHeading()
			local rotateHeading = rads +((2 * math.pi) - heading)			
			AI_NavigationTexture:SetTextureRotation(rotateHeading)	
		else
			AI_NavigationTexture:SetTexture(AI.textures.Navigation.off)
		end
	end,
	
	------------------------------------------------
	-- METHOD: GetAssistedQuestHeading
	------------------------------------------------
	GetAssistedQuestHeading = function()	
		-- iterate all possible quests
		for questIndex = 1, MAX_JOURNAL_QUESTS do		
			-- is this a valid quest?
			if IsValidQuestIndex(questIndex) then				
				-- is quest assisted
				if (ZO_Tracker:IsTrackTypeAssisted(TRACK_TYPE_QUEST, questIndex)) then	
					-- quest is in the same zone
					if (GetJournalQuestLocationInfo(questIndex) == GetPlayerActiveZoneName()) then
						local questSteps = WORLD_MAP_QUEST_BREADCRUMBS:GetSteps(questIndex)
						if questSteps then						
							-- get the quest conditions
							for stepIndex, questConditions in pairs(questSteps) do
								local closestX, closestY
								-- get condition data (contains coordinates)
								for conditionIndex, conditionData in pairs(questConditions) do
									local xLoc, yLoc = conditionData.xLoc, conditionData.yLoc
									-- location storage is empty, use condition as closest
									if (not closestX) then
										closestX = xLoc
										closestY = yLoc
										AI.vars.Navigation.isArea = (conditionData.areaRadius>0)
									-- compare
									else
										-- if condition is closer than location storage, replace
										if (AI.plugins.Navigation.GetDistanceToLocalCoords(xLoc, yLoc) < AI.plugins.Navigation.GetDistanceToLocalCoords(closestX, closestY)) then
											closestX = xLoc
											closestY = yLoc
											AI.vars.Navigation.isArea = (conditionData.areaRadius>0)
										end
									end
								end
								return AI.plugins.Navigation.GetWaypointHeading(closestX, closestY)
							end
						end
					else
                        AI_NavigationDistance:SetHidden(true)
					end
				end
			end
		end
	end,
	
	------------------------------------------------
	-- METHOD: GetWaypointHeading
	------------------------------------------------
	GetWaypointHeading = function(destNormX, destNormY)

		local x, y = GetMapPlayerWaypoint()
		
		-- override quest waypoint if player sets one manually
		if (x~=0 and y~=0) then
			destNormX = x
			destNormY = y
		end

		-- no destination, exit
		if (not destNormX) or (destNormX==0 and destNormY==0) then
			return nil
		end

        -- check distance
        local distance = AI.plugins.Navigation.GetDistanceToLocalCoords(destNormX, destNormY)

        -- distance display on
        if (AI.saved.account.Navigation.showDistance) then

            -- limit distance 
            if (AI.saved.account.Navigation.limitDistance) then
                -- distance under the threshold
                if (distance < AI.saved.account.Navigation.distanceThreshold) then	
                    -- too close, hide and return nil to hide the arrow
                    if (distance < 8) then 
                        AI_NavigationDistance:SetHidden(true)
                        return nil
                    -- show
                    else
                        AI_NavigationDistance:SetHidden(false)
                        AI_NavigationDistance:SetText(AI.colors.yellow..tostring(distance).."m")
                    end
                -- hide
                else
                    AI_NavigationDistance:SetHidden(true)
                end
            -- always show
            else
                AI_NavigationDistance:SetHidden(false)
                AI_NavigationDistance:SetText(AI.colors.yellow..tostring(distance).."m")
            end
        -- distance display is off but we need to hide the arrow under 8 meters
        else
            AI_NavigationDistance:SetHidden(true)
            -- too close, return nil to hide the arrow
            if (distance < 8) then 
                return nil
            end
        end
	
		-- get the player position
		local playerNormX, playerNormY = GetMapPlayerPosition("player")
	
		-- calculate
		local opp = playerNormY - destNormY
		local adj = destNormX - playerNormX
		local rads = math.atan2(opp, adj)
	
		rads = rads - math.pi / 2
	
		if rads < 0 then rads = rads + 2 * math.pi end
	
		return rads
	end,

	------------------------------------------------
	-- METHOD: GetDistanceToLocalCoords
	------------------------------------------------
	GetDistanceToLocalCoords = function(locX, locY, playerOffsetX, playerOffsetY)
		local locX, locY = LibGPS2:LocalToGlobal(locX, locY)

		if (not playerOffsetX) then
			playerOffsetX, playerOffsetY = LibGPS2:LocalToGlobal(GetMapPlayerPosition("player"))
		end
		
		if (locX and playerOffsetX) then
			local dx, dy = locX - playerOffsetX, locY - playerOffsetY
			local gameUnitDistance = math.sqrt(dx * dx + dy * dy)
		
			-- meters: 25603.2  feet: 84000
			return math.floor(gameUnitDistance * 25603.2), gameUnitDistance > 0.1952881
		else
			return 0
		end
	end,
	
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Navigation.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Navigation|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays a navigation arrow to the current quest in the target reticle.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.Navigation.on end, 
				setFunc = function(newValue) AI.saved.account.Navigation.on = newValue; AI.plugins.Navigation.ToggleQuestNavigation(); end, 
				default = AI.defaults.Navigation.on, 
			},
			{
				type = "checkbox", 
				name = "Hide navigation arrow in combat", 
				tooltip = "Hides navigation arrow and distance text when in combat", 
				getFunc = function() return AI.saved.account.Navigation.hideInCombat end, 
				setFunc = function(newValue) AI.saved.account.Navigation.hideInCombat = newValue end, 
				disabled = function() return not(AI.saved.account.Navigation.on) end,
				default = AI.defaults.Navigation.hideInCombat, 
			},
			{
				type = "checkbox", 
				name = "Show distance to current quest", 
				tooltip = "Displays distance to current quest under the current quest", 
				getFunc = function() return AI.saved.account.Navigation.showDistance end, 
				setFunc = function(newValue) AI.saved.account.Navigation.showDistance = newValue end, 
				disabled = function() return not(AI.saved.account.Navigation.on) end,
				default = AI.defaults.Navigation.showDistance, 
			},
			{
				type = "checkbox", 
				name = "Only Show distance when close to quest objective", 
				tooltip = "If checked, distance will only display if the distance threshold has been reached. If not checked, distance will always be displayed.",
				getFunc = function() return AI.saved.account.Navigation.limitDistance end, 
				setFunc = function(newValue) AI.saved.account.Navigation.limitDistance = newValue end, 
				disabled = function() return not(AI.saved.account.Navigation.showDistance and AI.saved.account.Navigation.on) end,
				default = AI.defaults.Navigation.limitDistance, 
			},
			{
				type = "slider",
				name = "Distance Threshold", 
				tooltip = "If the distance to the quest is this many meters or less, the distance will be displayed.",
				min  = 10,
				max = 100,
				getFunc = function() return AI.saved.account.Navigation.distanceThreshold end,
				setFunc = function(newValue) AI.saved.account.Navigation.distanceThreshold = newValue; end,
				disabled = function() return not(AI.saved.account.Navigation.limitDistance and AI.saved.account.Navigation.showDistance and AI.saved.account.Navigation.on) end,
				default = AI.defaults.Navigation.distanceThreshold,
			}
		}
	}
}

ZO_CreateStringId("SI_BINDING_NAME_AWESOME_INTERFACE_TOGGLE_NAVIGATION", "Toggle Reticle Quest Navigation")