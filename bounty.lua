
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Bounty"] = {
	on			 = true,
	hideInCombat = true,
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["Bounty"] = {
	amount = 0,
	fragment,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Bounty"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()				
		if (AI.saved.account.Bounty.on) then
			AI_BountyLabel:SetFont("EsoUI/Common/Fonts/Univers67.otf|19|soft-shadow-thin")
			AI_BountyLabel:SetColor(0.77,0.76,0.61,1)
		end
	end,
		
	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function() 	
		AI.vars.Bounty.fragment = ZO_HUDFadeSceneFragment:New( AI_BountyLabel )
		SCENE_MANAGER:GetScene('hud'):AddFragment( AI.vars.Bounty.fragment )	
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.Bounty.on) then
			EVENT_MANAGER:RegisterForEvent("AI_Bounty", EVENT_JUSTICE_INFAMY_UPDATED, AI.plugins.Bounty.SetBounty)
			EVENT_MANAGER:RegisterForEvent("AI_Bounty", EVENT_LEVEL_UPDATE, AI.plugins.Bounty.SetBounty)
			EVENT_MANAGER:RegisterForEvent("AI_Bounty", EVENT_PLAYER_ACTIVATED, AI.plugins.Bounty.SetBounty)
		else
			EVENT_MANAGER:UnregisterForEvent("AI_Bounty", EVENT_JUSTICE_INFAMY_UPDATED)
			EVENT_MANAGER:UnregisterForEvent("AI_Bounty", EVENT_LEVEL_UPDATE)
			EVENT_MANAGER:UnregisterForEvent("AI_Bounty", EVENT_PLAYER_ACTIVATED)
		end
	end,
		
	------------------------------------------------
	-- PARENT METHOD: Update
	------------------------------------------------
	Update = function() 	
		if (AI.saved.account.Bounty.on and AI.vars.Bounty.amount > 0) then
			-- AI update runs in 1 second intervals
			AI.vars.Bounty.coolDownSeconds = AI.vars.Bounty.coolDownSeconds -1
			AI_BountyLabel:SetText(AI.plugins.Bounty.GetBountyTimeLeft())
		else
			AI_BountyLabel:SetText("")
		end	
	end,	
	
	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (AI.saved.account.Bounty.hideInCombat) then	
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(AI.vars.Bounty.fragment)
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		SCENE_MANAGER:GetScene("hud"):AddFragment(AI.vars.Bounty.fragment)
	end,
	
	------------------------------------------------
	-- EVENT: SetBounty
	------------------------------------------------
	SetBounty = function()
		local goldPerThreeMinutes = 22.5;
		AI.vars.Bounty.amount = GetFullBountyPayoffAmount() or 0
		if AI.vars.Bounty.amount > 0 then
			AI.vars.Bounty.coolDownSeconds = (AI.vars.Bounty.amount/goldPerThreeMinutes)*180
		else
			AI.vars.Bounty.coolDownSeconds = 0
		end
	end,

	------------------------------------------------
	-- METHOD: getBountyTimeLeft
	------------------------------------------------
	GetBountyTimeLeft = function()
		local text = ""
		local days = math.floor(AI.vars.Bounty.coolDownSeconds/86400)
		local hours = math.floor((AI.vars.Bounty.coolDownSeconds%86400)/3600)
		local minutes = math.floor(((AI.vars.Bounty.coolDownSeconds%86400)%3600)/60)
		local seconds = (((AI.vars.Bounty.coolDownSeconds%86400)%3600)%60)
	
		if (days>0) then	text = text..days.."d " end
		if (hours>0) then	text = text..hours.."h " end
		if (minutes>0) then	text = text..minutes.."m " end
		if (seconds>0) then	text = text..seconds.."s " end
		return text
	end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Bounty.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Bounty|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays a time remaining label above the bounty meter.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.Bounty.on end,
				setFunc = function(newValue) AI.saved.account.Bounty.on = newValue; end,
				default = AI.defaults.Bounty.on,
			},		
		}
	}
}
