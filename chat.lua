
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Chat"] = {
	hideInCombat = true,
	doNotHideInGroup = true,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Chat"] = {

	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (AI.saved.account.Chat.hideInCombat) then
			if (AI.saved.account.Chat.doNotHideInGroup and IsUnitGrouped("player")) then return end
			for i = 1, #CHAT_SYSTEM.containers do
				CHAT_SYSTEM.containers[i].control:SetHidden(true)
			end
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		if (AI.saved.account.Chat.hideInCombat) then
			if (AI.saved.account.Chat.doNotHideInGroup and IsUnitGrouped("player")) then return end
			for i = 1, #CHAT_SYSTEM.containers do
				CHAT_SYSTEM.containers[i].control:SetHidden(false)
			end
		end
	end,
	
}	

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Chat.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Chat|r",
		controls = {
			{
				type = "checkbox", 
				name = "Hide Chat in combat", 
				tooltip = "Hides chat windows when in combat", 
				getFunc = function() return AI.saved.account.Chat.hideInCombat end, 
				setFunc = function(newValue) AI.saved.account.Chat.hideInCombat = newValue end, 
				default = AI.defaults.Chat.hideInCombat, 
			},
			{
				type = "checkbox", 
				name = "Do not hide if grouped", 
				tooltip = "Will not hide chat windows if grouped", 
				getFunc = function() return AI.saved.account.Chat.doNotHideInGroup end, 
				setFunc = function(newValue) AI.saved.account.Chat.doNotHideInGroup = newValue end, 
				disabled = function() return not(AI.saved.account.Chat.hideInCombat) end,
				default = AI.defaults.Chat.doNotHideInGroup, 
			}
		}
	}
}