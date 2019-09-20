
----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Clock"] = {
	on			 = true,
	hideInCombat = true,
	align        = "LEFT",
	military     = true,
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["Clock"] = {
	checkVisibility = true,
	fragment,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Clock"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()				
		PERFORMANCE_METERS.clockControl = AI_Clock
		PERFORMANCE_METERS.clockLabel = AI_ClockLabel
		if (AI.saved.account.Clock.on) then
			AI.saved.account.Clock.currentFrameTime = GetFrameTimeSeconds()
			AI_ClockLabel:SetFont("EsoUI/Common/Fonts/Univers67.otf|19|soft-shadow-thin")
			AI_ClockLabel:SetColor(0.77,0.76,0.61,1)
		end
	end,
		
	------------------------------------------------
	-- PARENT METHOD: SetFragments
	------------------------------------------------
	SetFragments = function() 	
		AI.vars.Clock.fragment = ZO_HUDFadeSceneFragment:New( AI_ClockLabel )
		SCENE_MANAGER:GetScene('hud'):AddFragment( AI.vars.Clock.fragment )	
		SCENE_MANAGER:GetScene('hudui'):AddFragment( AI.vars.Clock.fragment )	
		SCENE_MANAGER:GetScene('gameMenuInGame'):AddFragment( AI.vars.Clock.fragment )	
	end,
		
	------------------------------------------------
	-- PARENT METHOD: Update
	------------------------------------------------
	Update = function() 	
		if (AI.saved.account.Clock.on) then
			-- AI update runs in 1 second intervals
			PERFORMANCE_METERS.clockLabel:SetText(AI.plugins.Clock.GetTimeString())
		end	
	end,	
	
	------------------------------------------------
	-- PARENT EVENT: OnEnteringCombat 
	------------------------------------------------
	OnEnteringCombat = function()
		if (AI.saved.account.Clock.hideInCombat) then	
			local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
			local latencyOn   = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
			local anyOn       = framerateOn or latencyOn or AI.saved.account.Clock.on
			if (anyOn) then
				SCENE_MANAGER:GetScene("hud"):RemoveFragment(PERFORMANCE_METER_FRAGMENT)
				SCENE_MANAGER:GetScene("hudui"):RemoveFragment(PERFORMANCE_METER_FRAGMENT)
				SCENE_MANAGER:GetScene("hud"):RemoveFragment(AI.vars.Clock.fragment)
				SCENE_MANAGER:GetScene("hudui"):RemoveFragment(AI.vars.Clock.fragment)
			end
		end
	end,
	
	------------------------------------------------
	-- PARENT EVENT: OnExitingCombat
	------------------------------------------------
	OnExitingCombat = function()
		local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
		local latencyOn   = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
		local anyOn       = framerateOn or latencyOn or AI.saved.account.Clock.on
		if (anyOn) then
			SCENE_MANAGER:GetScene("hud"):AddFragment(PERFORMANCE_METER_FRAGMENT)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(PERFORMANCE_METER_FRAGMENT)
			SCENE_MANAGER:GetScene("hud"):AddFragment(AI.vars.Clock.fragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(AI.vars.Clock.fragment)
		end
	end,

	------------------------------------------------
	-- METHOD: getTimeString
	------------------------------------------------
	GetTimeString = function()
		local seconds   = GetSecondsSinceMidnight()
		if (AI.saved.account.Clock.military) then
			return FormatTimeSeconds(seconds, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
		else
			return FormatTimeSeconds(seconds, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWELVE_HOUR, TIME_FORMAT_DIRECTION_NONE)
		end
	end, -- AI.getTimeString
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Clock.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Clock|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays a clock next to the performance meters.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.Clock.on end,
				setFunc = function(newValue) AI.saved.account.Clock.on = newValue; AI.vars.Clock.checkVisibility=true; end,
				default = AI.defaults.Clock.on,
			},		
			{
				type = "checkbox",
				name = "Hide performance meters in combat", 
				tooltip = "Hides the framerate and latency meters in combat",
				getFunc = function() return AI.saved.account.Clock.hideInCombat end,
				setFunc = function(newValue) AI.saved.account.Clock.hideInCombat = newValue end,
				disabled = function() return not(AI.saved.account.Clock.on) end,
				default = AI.defaults.Clock.hideInCombat,
			},		
			{
				type = "dropdown",
				name = "Clock alignment", 
				tooltip = "The position of the clock in relation to the performance meters.",
				choices = {"LEFT","RIGHT"},
				setFunc = function(newValue) AI.saved.account.Clock.align = newValue; AI.vars.Clock.checkVisibility=true; end,
				getFunc = function() return AI.saved.account.Clock.align end,
				disabled = function() return not(AI.saved.account.Clock.on) end,
				default = AI.defaults.Clock.align,
			},		
			{
				type = "checkbox",
				name = "Clock format - 24 hour", 
				tooltip = "Display the clock in 24-hour/military format or in 12-hour AM/PM.",
				getFunc = function() return AI.saved.account.Clock.military end,
				setFunc = function(newValue) AI.saved.account.Clock.military = newValue end,
				disabled = function() return not(AI.saved.account.Clock.on) end,
				default = AI.defaults.Clock.military,
			}
		}
	}
}

----------------------------------------------------
-- Make a backup of the perf meters update vis
----------------------------------------------------
local OldPerformanceMetersUpdateVisibility = PERFORMANCE_METERS.UpdateVisibility
local OldPerformanceMetersOnUpdate = PERFORMANCE_METERS.OnUpdate

----------------------------------------------------
-- Hijack PERFORMANCE_METERS.OnUpdate
----------------------------------------------------
-- new code in OnUpdate will call self:UpdateVisibility().  
-- Would love to use a posthook but it seems impossible
-- as I can't find the global var for the update method (_G[])
function PERFORMANCE_METERS:OnUpdate()
    if not PERFORMANCE_METER_FRAGMENT:IsHiddenForReason("AnyOn") then
        if not self.framerateControl:IsHidden() then
            self:SetFramerate(GetFramerate())
        end
        if not self.latencyControl:IsHidden() then
            self:SetLatency(GetLatency())
        end	
		-- AI isn't loaded yet, exit
		if (AI.saved.account == nil) then 
			return 		
		end
	
		-- AI is loaded, clock is on, and the update flag is tripped
		if (AI.vars.Clock.checkVisibility) then
			-- call updatevisibility passing self
			self:UpdateVisibility()
		end
    end
end

----------------------------------------------------
-- Hijack PERFORMANCE_METERS.UpdateVisibility
----------------------------------------------------
function PERFORMANCE_METERS:UpdateVisibility()
	
	-- this addon not loaded yet, forward back to the original method
	if (AI.saved == nil) then 
		--PerformanceMeters:OldPerformanceMetersUpdateVisibility()
		return 
	elseif (AI.saved.account == nil) then
		return
	end
	
	-- check the UI settings to see if the meters are on
    local framerateOn = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE)
    local latencyOn   = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY)
	local clockOn     = AI.saved.account.Clock.on
		
	-- are any meters on?
    local anyOn = framerateOn or latencyOn or clockOn
	
	-- something is on
    if anyOn then
		-- clear anchors
        self.framerateControl:ClearAnchors()
        self.latencyControl:ClearAnchors()
		self.clockControl:ClearAnchors()
		
		if (clockOn) then
			-- both meters showing
			if framerateOn and latencyOn then		
				if (AI.saved.account.Clock.align=="LEFT") then
					self.clockControl:SetAnchor(RIGHT, self.framerateControl, LEFT, 0, 0)
					self.framerateControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
					self.latencyControl:SetAnchor(LEFT, self.framerateControl, RIGHT, 0, 0)
				else
					self.framerateControl:SetAnchor(RIGHT, self.latencyControl, LEFT, 0, 0)
					self.latencyControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
					self.clockControl:SetAnchor(LEFT, self.latencyControl, RIGHT, -5, 0)
				end
				
			-- only framerate showing
			elseif framerateOn and not latencyOn then
				if (AI.saved.account.Clock.align=="LEFT") then
					self.clockControl:SetAnchor(RIGHT, self.control, CENTER, 0, 0)
					self.framerateControl:SetAnchor(LEFT, self.control, CENTER, 0, 0)
				else
					self.clockControl:SetAnchor(LEFT, self.control, CENTER, 0, 0)
					self.framerateControl:SetAnchor(RIGHT, self.control, CENTER, 0, 0)
				end
				
			-- only latency showing
			elseif not framerateOn and latencyOn then
				if (AI.saved.account.Clock.align=="LEFT") then
					self.clockControl:SetAnchor(RIGHT, self.control, CENTER, 0, 0)
					self.latencyControl:SetAnchor(LEFT, self.control, CENTER, 0, 0)
				else
					self.clockControl:SetAnchor(LEFT, self.control, CENTER, 0, 0)
					self.latencyControl:SetAnchor(RIGHT, self.control, CENTER, 0, 0)
				end
				
			-- only clock showing
			else
				self.framerateControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
				self.latencyControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
				self.clockControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)	
			end
		else
			-- both meters showing
			if framerateOn and latencyOn then
				self.framerateControl:SetAnchor(RIGHT, self.control, CENTER, 0, 0)
				self.latencyControl:SetAnchor(LEFT, self.control, CENTER, 0, 0)

			-- just one meter showing
			else
				self.framerateControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
				self.latencyControl:SetAnchor(CENTER, self.control, CENTER, 0, 0)
			end
		end
		
		-- set the background width
		local numMeters = 0
		if framerateOn then numMeters = numMeters + 1 end
		if latencyOn   then numMeters = numMeters + 1 end
		if clockOn     then numMeters = numMeters + 1 end
		ZO_PerformanceMetersBg:SetWidth(128*numMeters)		
		
		-- hide controls that aren't on
        self.framerateControl:SetHidden(not framerateOn)
        self.latencyControl:SetHidden(not latencyOn)
		self.clockControl:SetHidden(not clockOn)
    end
	-- none are on, hide the fragment
    PERFORMANCE_METER_FRAGMENT:SetHiddenForReason("AnyOn", not anyOn, 0, 0)
	
	-- reset the update flag so hijacked update does not call this again
	AI.vars.Clock.checkVisibility = false
	
	-- run an update
    self:OnUpdate()
end