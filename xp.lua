
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["XP"] = {
	on 			  = false,
	hideInCombat  = true,
	showPercent   = true,
	moveXPBar	  = false,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["XP"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()		
		-- load global defaults to character if missing
		if (AI.saved.character.XP == nil) then
            AI.saved.character.XP = AI.defaults.XP          
		end		
		
		if (AI.saved.character.XP.on or AI.saved.character.XP.showPercent) then

		  	-- IsChampion?
			if IsUnitChampion("player") then
				-- create the champion label if misssing
				if not AI.championLabel then
					AI.championLabel = AI.plugins.XP.NewBarLabel("AI_ChampionBarLabel", ZO_PlayerProgressBar, TEXT_ALIGN_RIGHT)
				end
				AI.championLabel:ClearAnchors()
				AI.championLabel:SetAnchor(RIGHT, ZO_PlayerProgressBarBar, RIGHT, -30, 0)

			-- IsPleeb?
			else
				-- create xp percent label if missing
				if not AI.experienceLabel then
					AI.experienceLabel = AI.plugins.XP.NewBarLabel("AI_ExperienceBarLabel", ZO_PlayerProgressBar, TEXT_ALIGN_CENTER)
				end
				-- anchor the label
				AI.experienceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
				AI.experienceLabel:ClearAnchors()
				AI.experienceLabel:SetAnchor(RIGHT, ZO_PlayerProgressBarBar, RIGHT, -20, 0)
			end
			
			-- get the first values
			AI.plugins.XP.OnExperienceGain()
		end
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		ZO_PreHookHandler(ZO_PlayerProgressBar, 'OnUpdate', AI.plugins.XP.OnExperienceGain)
	end,
		
	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function() 	
		if (AI.saved.character.XP.on) then
			SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		else
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)		
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (AI.saved.character.XP.hideInCombat and AI.saved.character.XP.on) then		
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)		
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		if (AI.saved.character.XP.on) then	
			SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
		end
	end,	
	
	------------------------------------------------
	-- PARENT METHOD: Update
	------------------------------------------------
	Update = function()
		if (AI.saved.character.XP.moveXPBar) then				
			ZO_PlayerProgress:ClearAnchors()
			ZO_PlayerProgress:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 10, 40)
		end
	end,

	------------------------------------------------
	-- EVENT: OnExperienceGain
	------------------------------------------------
	OnExperienceGain = function(...)
		-- if show XP percentage
		if (AI.saved.character.XP.showPercent) then

			-- show champion xp
			if AI.championLabel then
				AI.championLabel:SetText(AI.plugins.XP.FormatText(AI.plugins.XP.GetPlayerXP(), AI.plugins.XP.GetPlayerXPMax()))

			-- show normal xp
			else
				AI.experienceLabel:SetText(AI.plugins.XP.FormatText(AI.plugins.XP.GetPlayerXP(), AI.plugins.XP.GetPlayerXPMax()))
			end
			
		-- hide the label	
		else
			if AI.championLabel then
				AI.championLabel:SetText("")
				AI.championLabel:SetHeight( 0 )
				
			elseif AI.experienceLabel then
				AI.experienceLabel:SetText("")
				AI.experienceLabel:SetHeight( 0 )
			end		
		end
	end, -- AI.UpdateXP

	----------------------------------------------------
	-- METHOD: GetPlayerXP
	----------------------------------------------------
	GetPlayerXP = function()
		if IsUnitChampion("player") then
			return GetPlayerChampionXP()
		else
			return GetUnitXP("player")
		end
	end, -- AI.GetPlayerXP

	----------------------------------------------------
	-- METHOD: GetPlayerXPMax 
	----------------------------------------------------
	GetPlayerXPMax = function()
		if IsUnitChampion("player") then
			local cp = GetUnitChampionPoints("player")
			return GetNumChampionXPInChampionPoint(cp)
		else
			return GetUnitXPMax("player")
		end
	end, -- AI.GetPlayerXPMax

	----------------------------------------------------
	-- METHOD: FormatText
	----------------------------------------------------
	FormatText = function(current, max)
		local percent = 0
		if max > 0 then
			percent = math.floor((current/max) * 100)
		else
			max = "MAX"
		end
		return percent .. "%"
	end, -- AI.FormatText


	----------------------------------------------------
	-- METHOD: NewBarLabel
	----------------------------------------------------
	NewBarLabel = function(name, parent, horizontalAlign)
		-- Create a one line text label for placing over an attribute or experience bar
		local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
		label:SetDimensions(200, 20)
		label:SetAnchor(CENTER, parent, CENTER, 0, -1)
		label:SetFont("EsoUI/Common/Fonts/Univers67.otf|15|soft-shadow-thick")
		label:SetColor(0.9, 0.9, 0.9, 1)
		label:SetHorizontalAlignment(horizontalAlign)
		label:SetVerticalAlignment(CENTER)
		return label
	end, -- AI.NewBarLabel

}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.XP.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Experience Bar|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays experience bar in the HUD and adds a percent label.|r",
			},
			{
				type = "checkbox", 
				name = "Turn on experience bar during gameplay", 
				tooltip = "Displays the XP bar on the HUD", 
				getFunc = function() return AI.saved.character.XP.on end, 
				setFunc = function(newValue) AI.saved.character.XP.on = newValue end, 
				requiresReload = true,
				default = AI.defaults.XP.on, 
			},
			{
				type = "checkbox",
				name = "Hide experience bar in combat", 
				tooltip = "Hides the experience bar in combat",
				getFunc = function() return AI.saved.character.XP.hideInCombat end,
				setFunc = function(newValue) AI.saved.character.XP.hideInCombat = newValue end,
				disabled = function() return not(AI.saved.character.XP.on) end,
				default = AI.defaults.XP.hideInCombat,
			},
			{
				type = "checkbox", 
				name = "Move experience bar down to make room for Awesome InfoBar", 
				tooltip = "Nudges the XP bar down a bit.", 
				getFunc = function() return AI.saved.character.XP.moveXPBar end, 
				setFunc = function(newValue) AI.saved.character.XP.moveXPBar = newValue end, 
				disabled = function() return not(AI.saved.character.XP.on) end,
				default = AI.defaults.XP.moveXPBar, 
			},
			{
				type = "checkbox", 
				name = "Add percent label to experience bar", 
				tooltip = "Adds percentage text to the XP bar.", 
				getFunc = function() return AI.saved.character.XP.showPercent end, 
				setFunc = function(newValue) AI.saved.character.XP.showPercent = newValue end, 
				requiresReload = true,
				default = AI.defaults.XP.showPercent, 
			}
		}
	}
}