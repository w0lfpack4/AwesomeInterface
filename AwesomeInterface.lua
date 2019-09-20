AI = {}

-- addon info
AI.name 		= "AwesomeInterface"
AI.displayName	= "|cFF6060Awesome |cffffffInterface|r"		-- Menu Display
AI.version		= "3.2"
AI.author  		= "Keg"
AI.Initialized 	= false

-- define plugins
AI.plugins = {}

-- define saved vars
AI.saved = {}

-- define textures
AI.textures = {}

-- addons to search for
AI.findAddon = {}

-- defin local vars
AI.vars = {}

-- define standard icons
AI.icons = {}

-- define standard colors
AI.colors = {
	red             = "|cFF6060",
	yellow          = "|cFFFF60",
	green           = "|c60FF60",
	blue            = "|c45D7F7",
	cyan            = "|c4a8ee6",
	darkcyan        = "|c377cb8",
	orange          = "|cffa500",
	white           = "|cffffff",
	gray            = "|ccfcfcf",
	olive           = "|c65875c",
	purple			= "|c9B30FF",
	brown			= "|c964B00",
	header          = "|cc2c29c",
	normal          = "|cffffff",
	safe            = "|c60FF60",
	warning         = "|cFFFF60",
	imminent        = "|cffa500",
	critical        = "|cFF6060",
}

AI.quality = {
	[1] = "|cffffff", -- white
	[2] = "|c00ff00", -- green
	[3] = "|c3995fd", -- blue
	[4] = "|c9B30FF", -- purple
	[5] = "|cff7700", -- orange
}

----------------------------------------------------
-- Set-up the defaults options for saved variables.
----------------------------------------------------
AI.defaults = {}


----------------------------------------------------
-- addon: Initialize
----------------------------------------------------
function AI.Initialize(eventCode, addOnName)
	
	-- other addons to track
	if (AI.findAddon[addOnName] ~= nil) then
		AI.findAddon[addOnName] = true
	end
	
	-- Only initialize our own addon
	if (AI.name ~= addOnName) then return end
	
    -- Load the saved variables.  per character defaults are set within the plugin
    AI.saved.account = ZO_SavedVars:NewAccountWide("AI_SavedVariables", 1, nil, AI.defaults)	
	AI.saved.character = ZO_SavedVars:New("AI_SavedVariables", 1, nil)	
		
	-- Initialize plugins
	for key,value in pairs(AI.plugins) do 
		if (AI.plugins[key].Initialize ~= nil) then
			AI.plugins[key].Initialize()
		end
	end

	-- set fragments
    AI.SetFragments()

    -- Invoke config menu set-up
    AI.CreateConfigMenu()

    -- The rest of the event registration is here, rather than with ADD_ON_LOADED because I don't want any of them being
    -- called until after initialization is complete.
	AI.RegisterEvents()	
	
	-- done here
    AI.Initialized = true
end -- AI.Initialize

----------------------------------------------------
-- addon: lock fragments to hud and hudui
----------------------------------------------------
function AI.SetFragments()	
	-- loop through plugins
	for key,value in pairs(AI.plugins) do 
		if (AI.plugins[key].SetFragments ~= nil) then
			AI.plugins[key].SetFragments()
		end
	end
end --AI.SetFragments

----------------------------------------------------
-- addon: register events
----------------------------------------------------
function AI.RegisterEvents()
	-- core will handle combat event and loop through plugins
	EVENT_MANAGER:RegisterForEvent("AI", EVENT_PLAYER_COMBAT_STATE, AI.OnCombatState)	
	
	-- loop through plugins
	for key,value in pairs(AI.plugins) do 
		if (AI.plugins[key].RegisterEvents ~= nil) then
			AI.plugins[key].RegisterEvents()
		end
	end
end --AI.RegisterEvents

----------------------------------------------------
-- addon: posthook handler
----------------------------------------------------
AI.PostHookHandler = function(funcName, callback)
	local tmp = _G[funcName]
	_G[funcName] = function(...)
		tmp(...)
		callback()
	end
end

----------------------------------------------------
-- addon: merge tables
----------------------------------------------------
function AI.Merge(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

----------------------------------------------------
-- EVENT: OnUpdate, addon's update call
----------------------------------------------------
function AI.OnUpdate()
    -- Bail if we haven't completed the initialization routine yet.
    if (not AI.Initialized) then return end
		
    -- Only run this update if a full second has elapsed since last time we did so.
    local curSeconds = GetSecondsSinceMidnight()
    if ( curSeconds ~= AI.lastOnUpdate ) then
		-- reset the last update value
        AI.lastOnUpdate = curSeconds
		
		-- loop through plugins
		for key,value in pairs(AI.plugins) do 
			if (AI.plugins[key].Update ~= nil) then
				AI.plugins[key].Update()
			end
		end        
    end
end -- AI.OnUpdate

----------------------------------------------------
-- EVENT: OnCombatState, hide elements in combat
----------------------------------------------------
function AI.OnCombatState(eventCode, inCombat)
    -- Bail if we haven't completed the initialization routine yet.
    if (not AI.Initialized) then return end
		
	-- in combat
	if (inCombat) then
		-- check each plugin
		for key,value in pairs(AI.plugins) do 
			if (AI.saved.account[key].hideInCombat) then
				if (AI.plugins[key].OnEnteringCombat ~= nil) then
					AI.plugins[key].OnEnteringCombat()
				end
			end
		end
	-- not in combat
	else
		-- check each plugin
		for key,value in pairs(AI.plugins) do 
			if (AI.saved.account[key].hideInCombat) then
				if (AI.plugins[key].OnExitingCombat ~= nil) then
					AI.plugins[key].OnExitingCombat()
				end
			end
		end
	end	
end --AI.OnCombatState

----------------------------------------------------
-- Initialize has been defined so register the event
----------------------------------------------------
EVENT_MANAGER:RegisterForEvent("AI", EVENT_ADD_ON_LOADED, AI.Initialize)

