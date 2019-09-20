----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Reticle"] = {
	on 					= true,
-- "N" => N / E / S / W
-- "NE" => N / NE / E / SE / S / SW / W / NW
-- "ENE" => N / NNW / NW / WNW / W / WSW / SW / SSW / S / SSE / SE / ESE / E / ENE / NE / NNE
	COMPASS_TYPE 		= "NE",
	showColor 			= true,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Reticle"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize 
	------------------------------------------------
	Initialize = function()
		if (AI.saved.account.Reticle.on) then
			ZO_TargetUnitFramereticleover:SetAnchor(TOP,GuiRoot,TOP,0,40)
			AI_Reticle:SetParent(RETICLE.control)
			AI_ReticleUI:SetFont("EsoUI/Common/Fonts/Univers67.otf|10|soft-shadow-thin")
			AI.plugins.Reticle.OnReticleHiddenUpdate()			
		end
	end,
	
	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.Reticle.on) then
			EVENT_MANAGER:RegisterForEvent("AI_Reticle", EVENT_RETICLE_HIDDEN_UPDATE, AI.plugins.Reticle.OnReticleHiddenUpdate)
			EVENT_MANAGER:RegisterForEvent("AI_Reticle", EVENT_RETICLE_TARGET_CHANGED, AI.plugins.Reticle.OnReticleTargetChanged)
			EVENT_MANAGER:RegisterForUpdate("AI_Reticle", 50, AI.plugins.Reticle.OnReticleTargetChanged)	
		else
			EVENT_MANAGER:UnregisterForEvent("AI_Reticle", EVENT_RETICLE_HIDDEN_UPDATE)
			EVENT_MANAGER:UnregisterForEvent("AI_Reticle", EVENT_RETICLE_TARGET_CHANGED)
			EVENT_MANAGER:UnregisterForUpdate("AI_Reticle")	
		end
	end,
				
	------------------------------------------------
	-- EVENT: OnReticleHiddenUpdate
	------------------------------------------------
	OnReticleHiddenUpdate = function(eventCode, hidden)
		if (AI.saved.account.Reticle.on) then
			if(hidden == true) then
				AI_ReticleUI:SetHidden(true)
			else
				AI_ReticleUI:SetHidden(false)
			end
		end
	end,

	------------------------------------------------
	-- EVENT: OnReticleTargetChanged
	------------------------------------------------
	OnReticleTargetChanged = function()
		if (AI.saved.account.Reticle.on) then
			
			-- make sure the alpha is 1
			ZO_ReticleContainerReticle:SetAlpha(1)
			
			-- set the color
			AI.plugins.Reticle.SetReactionColor()
						
			-- get some info
			local targeting        = ( GetUnitNameHighlightedByReticle() ~= "" )
			local targetingMonster = ( GetUnitNameHighlightedByReticle() ~= "" and IsGameCameraUnitHighlightedAttackable() )
			local stealthed        = (GetUnitStealthState( "player" ) > 0)
			local inCombat         = IsUnitInCombat( "player" )
					
			-- if in combat then color, set X, small font
			if (inCombat) then	
				AI_ReticleUI:SetText("|cffffffX")
				
			-- if stealthed hide text, set color
			elseif (stealthed) then
				AI_ReticleUI:SetText("")
			
			-- need direction
			else
				-- get the direction
				local orientation = GetPlayerCameraHeading() * 57.2957795 -- ZOS function * convert rad
				local direction = AI.plugins.Reticle.GetReticleDirection(orientation)
				
				-- if targeting, small font, x for monsters
				if (targeting) then
					if (targetingMonster) then
						AI_ReticleUI:SetText("|cffffffX")		
					else
						AI_ReticleUI:SetText(direction)
					end
				
				-- everything else, large font
				else
					AI_ReticleUI:SetText(direction)
				end
			end
		end
	end,	
	
	------------------------------------------------
	-- METHOD: GetReticleDirection
	------------------------------------------------
	GetReticleDirection = function(orientation)

		if(AI.saved.account.Reticle.COMPASS_TYPE == "N") then

			if((orientation >= 0 and orientation < 45) or (orientation >= 315)) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION) 											-- "N"
			elseif(orientation >= 45 and orientation < 135) then
				return GetString(SI_COMPASS_WEST_ABBREVIATION) 												-- "W"
			elseif(orientation >= 135 and orientation < 225) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION) 											-- "S"
			elseif(orientation >= 225 and orientation < 315) then
				return GetString(SI_COMPASS_EAST_ABBREVIATION) 												-- "E"
			end

		elseif(AI.saved.account.Reticle.COMPASS_TYPE == "NE") then

			if((orientation >= 0 and orientation < 22.50) or (orientation >= 337.50)) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION) 											-- "N"
			elseif(orientation >= 22.50 and orientation < 67.50) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION) 	-- "NW"
			elseif(orientation >= 67.50 and orientation < 112.50) then
				return GetString(SI_COMPASS_WEST_ABBREVIATION) 												-- "W"
			elseif(orientation >= 112.50 and orientation < 157.50) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION) 	-- "SW"
			elseif(orientation >= 157.50 and orientation < 202.50) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION) 											-- "S"
			elseif(orientation >= 202.50 and orientation < 247.50) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 	-- "SE"
			elseif(orientation >= 247.50 and orientation < 292.50) then
				return GetString(SI_COMPASS_EAST_ABBREVIATION) 												-- "E"
			elseif(orientation >= 292.50 and orientation < 337.50) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 	-- "NE"
			end

		elseif(AI.saved.account.Reticle.COMPASS_TYPE == "ENE") then

			if((orientation >= 0 and orientation < 11.25) or (orientation >= 348.75)) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION) 																					-- "N"
			elseif(orientation >= 11.25 and orientation < 33.75) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION) 	-- "NNW"
			elseif(orientation >= 33.75 and orientation < 56.25) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION) 											-- "NW"
			elseif(orientation >= 56.25 and orientation < 78.75) then
				return GetString(SI_COMPASS_WEST_ABBREVIATION) ..GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION)	-- "WNW"
			elseif(orientation >= 78.75 and orientation < 101.25) then
				return GetString(SI_COMPASS_WEST_ABBREVIATION)																						-- "W"
			elseif(orientation >= 101.25 and orientation < 123.75) then
				return GetString(SI_COMPASS_WEST_ABBREVIATION)..GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION)	-- "WSW"
			elseif(orientation >= 123.75 and orientation < 146.25) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION) 											-- "SW"
			elseif(orientation >= 146.25 and orientation < 168.75) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_WEST_ABBREVIATION)	-- "SSW"
			elseif(orientation >= 168.75 and orientation < 191.25) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION) 																					-- "S"
			elseif(orientation >= 191.25 and orientation < 213.75) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION)	-- "SSE"
			elseif(orientation >= 213.75 and orientation < 236.25) then
				return GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 											-- "SE"
			elseif(orientation >= 236.25 and orientation < 258.75) then
				return GetString(SI_COMPASS_EAST_ABBREVIATION)..GetString(SI_COMPASS_SOUTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION)	-- "ESE"
			elseif(orientation >= 258.75 and orientation < 281.25) then
				return GetString(SI_COMPASS_EAST_ABBREVIATION) 																						-- "E"
			elseif(orientation >= 281.25 and orientation < 303.75) then
				return GetString(SI_COMPASS_EAST_ABBREVIATION)..GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 	-- "ENE"
			elseif(orientation >= 303.75 and orientation < 326.25) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 											-- "NE"
			elseif(orientation >= 326.25 and orientation < 348.75) then
				return GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_NORTH_ABBREVIATION)..GetString(SI_COMPASS_EAST_ABBREVIATION) 	-- "NNE"
			end
		end	
	end,
	
	------------------------------------------------
	-- METHOD: SetReactionColor
	------------------------------------------------
	SetReactionColor = function()
		if (GetUnitReactionColor( "reticleover" ) > 0 and AI.saved.account.Reticle.showColor) then
			ZO_ReticleContainerReticle:SetColor( GetUnitReactionColor( "reticleover" ) )
			ZO_ReticleContainerStealthIconStealthEye:SetColor( GetUnitReactionColor( "reticleover" ) )
		else
			ZO_ReticleContainerReticle:SetColor( 1,1,1,1 )
			ZO_ReticleContainerStealthIconStealthEye:SetColor( 1,1,1,1 )
		end
	end,	
	
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Reticle.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Reticle|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Displays compass directions in the target reticle.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.Reticle.on end, 
				setFunc = function(newValue) AI.saved.account.Reticle.on = newValue; AI.plugins.Reticle.RegisterEvents(); end, 
				default = AI.defaults.Reticle.on, 
			},
			{
				type = "dropdown",
				name = "Compass direction detail", 
				tooltip = "The amount of detail applied to the compass directions in the target reticle",
				choices = {"N","NE","ENE"},
				setFunc = function(newValue) AI.saved.account.Reticle.COMPASS_TYPE = newValue end,
				getFunc = function() return AI.saved.account.Reticle.COMPASS_TYPE end,
				disabled = function() return not(AI.saved.account.Reticle.on) end,
				default = AI.defaults.COMPASS_TYPE,
			},		
			{
				type = "checkbox", 
				name = "Change reticle color on target", 
				tooltip = "Changes the compass reticle color based on target. "..AI.colors.blue.."(Player|r, "..AI.colors.green.."NPC|r, "..AI.colors.yellow.."NPC|r, "..AI.colors.red.."Monster|r)", 
				getFunc = function() return AI.saved.account.Reticle.showColor end, 
				setFunc = function(newValue) AI.saved.account.Reticle.showColor = newValue end, 
				disabled = function() return not(AI.saved.account.Reticle.on) end,
				default = AI.defaults.Reticle.showColor, 
			}
		}
	}
}
