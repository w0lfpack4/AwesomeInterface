
----------------------------------------------------
-- ICONS
----------------------------------------------------
AI.icons["player"]              = "|t24:24:esoui/art/miscellaneous/gamepad/gp_charnameicon.dds|t"
AI.icons["friend"]              = "|t24:24:esoui/art/campaign/campaignbrowser_friends.dds|t"
AI.icons["guild"]               = "|t24:24:esoui/art/campaign/campaignbrowser_guild.dds|t"
AI.icons["ignore"]              = "|t24:24:esoui/art/contacts/tabicon_ignored_up.dds|t"
AI.icons["leader"]              = "|t24:24:esoui/art/unitframes/groupicon_leader.dds|t"
AI.icons["groupleader"]         = "|t24:24:esoui/art/icons/mapkey/mapkey_groupleader.dds|t"
AI.icons["groupmember"]         = "|t24:24:esoui/art/icons/mapkey/mapkey_groupmember.dds|t"
AI.icons["Daggerfall Covenant"] = "|t24:24:esoui/art/icons/heraldrycrests_alliance_daggerfall_02.dds|t"
AI.icons["Ebonheart Pact"]      = "|t24:24:esoui/art/icons/heraldrycrests_alliance_ebonheart_02.dds|t"
AI.icons["Aldmeri Dominion"]    = "|t24:24:esoui/art/icons/heraldrycrests_alliance_aldmeri_02.dds|t"


----------------------------------------------------
-- COLORS
----------------------------------------------------
-- class
AI.colors["Dragonknight"]        = "|ce17320" -- orange
AI.colors["Sorcerer"]            = "|c8e60ba" -- purple
AI.colors["Nightblade"]          = "|cac1922" -- red
AI.colors["Templar"]             = "|ce7dda2" -- tan
AI.colors["Warden"]              = "|c6cbb4f" -- green
AI.colors["Necromancer"]         = "|c5e95f4" -- blue
-- gender
AI.colors["Male"]                = "|c51b7ff"
AI.colors["Female"]              = "|cfe07ca"
-- alliance
AI.colors["Daggerfall Covenant"] = "|c5b7fc9"
AI.colors["Ebonheart Pact"]      = "|c963324"
AI.colors["Aldmeri Dominion"]    = "|cb09e58"
AI.colors["Other"]               = "|cffffff"


----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Target"] = {
	on = true,
	fixTargetColor   = true,
	showAlliance     = true,
	showAllianceIcon = true,
	showRace         = true,
	showClass        = true,
	showGender       = true,
	showLevel        = true,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Target"] = {

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		EVENT_MANAGER:RegisterForEvent("AI_Target", EVENT_RETICLE_TARGET_CHANGED, AI.plugins.Target.OnReticleTargetChanged)
		EVENT_MANAGER:RegisterForUpdate("AI_Target", 50, AI.plugins.Target.OnReticleTargetChanged)	
	end,
	
	----------------------------------------------------
	-- EVENT: OnReticleTargetChanged
	----------------------------------------------------
	OnReticleTargetChanged = function(Event, Unit)
		AI.plugins.Target.UpdateTargetColor()
		AI.plugins.Target.UpdateTargetName()
	end,
	
	----------------------------------------------------
	-- METHOD: UpdateTargetColor
	----------------------------------------------------
	UpdateTargetColor = function()
		if (AI.saved.account.Target.fixTargetColor) then
			local react1, react2, react3 = GetUnitReactionColor("reticleover")
			ZO_TargetUnitFramereticleoverBarLeft:SetColor(react1, react2, react3, 1)
			ZO_TargetUnitFramereticleoverBarRight:SetColor(react1, react2, react3, 1)
		end
	end, -- AI.UpdateTargetColor


	----------------------------------------------------
	-- METHOD: UpdateTargetName
	----------------------------------------------------
	UpdateTargetName = function()
		if (AI.saved.account.Target.on) then
		
			local target = {
				["type"] = 0,
				["name"] = "",
				["level"] = "",
				["caption"] = "",
			}
			
			-- get the basic target info
			local unitTag = "reticleover"	
			target.type = GetUnitType(unitTag)
			target.name = GetUnitName(unitTag)
			
			-- no target, wipe and exit
			if target.name == nil or target.name == "" then 
				ZO_TargetUnitFramereticleover:SetHidden(true)
				ZO_TargetUnitFramereticleoverBarLeft:SetHidden(true)
				ZO_TargetUnitFramereticleoverBarRight:SetHidden(true)
				return
			else
				ZO_TargetUnitFramereticleover:SetHidden(false)
				ZO_TargetUnitFramereticleoverBarLeft:SetHidden(false)
				ZO_TargetUnitFramereticleoverBarRight:SetHidden(false)
			end
			
			-- still here? get more data
			local player = GetUnitDisplayName(unitTag)
			local reaction = GetUnitReaction(unitTag)
			local preferredNameSetting = tonumber(GetSetting(SETTING_TYPE_UI,((not IsInGamepadPreferredMode()) and UI_SETTING_PRIMARY_PLAYER_NAME_KEYBOARD) or UI_SETTING_PRIMARY_PLAYER_NAME_GAMEPAD)) == PRIMARY_PLAYER_NAME_SETTING_PREFER_CHARACTER
			
			--get the level
			target.level = AI.plugins.Target.GetTargetLevel(unitTag)

			
			-- NPCs are type 2, Players are type 1, invalid is 0
			if target.type == UNIT_TYPE_PLAYER then
					
				local icon = ""
				
				-- get the title
				local title = GetUnitTitle(unitTag)
			  
				-- get the race			
				local race = GetUnitRace(unitTag).." "
				
				-- get the class
				local class = AI.colors[GetUnitClass(unitTag)]..GetUnitClass(unitTag).."|r "				
							  
				local primary = target.name
				
				local secondary = GetUnitDisplayName(unitTag)
			  
				-- is target on the ignore list?
				if IsUnitIgnored(unitTag) then
					icon = AI.icons.ignore
					primary = AI.colors.gray..primary.."|r"
					target.name = zo_strformat("<<1>><<2>> (<<3>>) ",icon,primary,secondary)
					target.caption = ""
				else
					
					-- is target in a party?
					if IsUnitGrouped(unitTag) then					
						if (not AI.saved.account.Target.showGender) then
							primary = AI.colors.olive..primary.."|r"
						end
						-- is target the leader?
						if IsUnitGroupLeader(unitTag) then 
							icon = AI.icons.groupleader
						else 
							icon = AI.icons.groupmember
						end
					-- is target a friend?
					elseif IsUnitFriend(unitTag) then
						if (not AI.saved.account.Target.showGender) then
							primary = AI.colors.cyan..primary.."|r"
						end
						icon = AI.icons.friend
					-- target is no one
					else
						if (AI.saved.account.Target.showGender) then
							primary = AI.colors[AI.plugins.Target.GetGender(unitTag)]..primary.."|r"
						else
							primary = AI.colors.darkcyan..primary.."|r"
						end
					end
					
					-- set up the caption
					local caption = ""					
					if (AI.saved.account.Target.showAlliance) then
						caption = AI.plugins.Target.GetAlliance(unitTag)
					end
					if (AI.saved.account.Target.showRace) then
						caption = caption..race
					end
					if (AI.saved.account.Target.showClass) then
						caption = caption..class
					end
					
					-- using a UI setting for nameplates
					if preferredNameSetting then
						if title ~= "" and AI.saved.account.Target.showTitle then
							target.name = zo_strformat("<<1>><<2>>, <<3>> ",icon,primary,title)
						else
							target.name = zo_strformat("<<1>><<2>> ",icon,primary)
						end
						target.caption = caption
					else
						if title ~= "" and AI.saved.account.Target.showTitle then
							target.name = zo_strformat("<<1>><<2>>, <<3>> ",icon,primary,title)
						else
							target.name = zo_strformat("<<1>><<2>> ",icon,primary)
						end
						target.caption = zo_strformat("(<<1>>) <<2>>",secondary,caption)
					end
				end
				  
			elseif target.type == UNIT_TYPE_MONSTER then
						
				-- shopkeepers and other non-combat units just show name
				if reaction == UNIT_REACTION_NEUTRAL or reaction == UNIT_REACTION_HOSTILE or reaction == UNIT_REACTION_DEAD then
					
					if reaction == UNIT_REACTION_NEUTRAL then
						target.name = AI.colors.yellow..target.name.."|r"
					elseif reaction == UNIT_REACTION_HOSTILE then
						target.name = AI.colors.red..target.name.."|r"
					elseif reaction == UNIT_REACTION_DEAD then
						target.name = AI.colors.gray..target.name.."|r"
					end
				else
					target.level = ""
						target.name = AI.colors.green..target.name.."|r"	
				end
			end
			AI.plugins.Target.UpdateTargetText(target)
		end
	end, -- AI.UpdateTargetName

	----------------------------------------------------
	-- METHOD: UpdateTargetText
	----------------------------------------------------
	UpdateTargetText = function(target)
		if (target.type==UNIT_TYPE_PLAYER) then
			ZO_TargetUnitFramereticleoverName:SetText(target.name)
			ZO_TargetUnitFramereticleoverLevel:SetText(target.level)
			ZO_TargetUnitFramereticleoverCaption:SetHidden(false)
			ZO_TargetUnitFramereticleoverCaption:SetText(target.caption)
		elseif (target.type==UNIT_TYPE_MONSTER) then 
			ZO_TargetUnitFramereticleoverName:SetText(target.name)
			ZO_TargetUnitFramereticleoverLevel:SetText(target.level)
		elseif (target.type==UNIT_TYPE_INVALID) then 
			ZO_TargetUnitFramereticleoverName:SetText("")
			ZO_TargetUnitFramereticleoverLevel:SetText("")
			ZO_TargetUnitFramereticleoverCaption:SetText("")
		end
	end, -- AI.UpdateTargetText

	----------------------------------------------------
	-- METHOD: GetTargetLevel
	----------------------------------------------------
	GetTargetLevel = function(unitTag)
		if (AI.saved.account.Target.showLevel) then
			local out = "Level " .. GetUnitLevel(unitTag)
			
			-- set the level to rank if champion
			local rank = GetUnitChampionPoints(unitTag)
		  
			if rank > 0 then
				out = rank .. "CP"
			end
			return out
		else
			return ""
		end
	end,
	
	----------------------------------------------------
	-- METHOD: GetGender
	----------------------------------------------------
	GetGender = function(unitTag)	
		local genders = { "Female" , "Male" }
		local gendernum = GetUnitGender(unitTag)
		if gendernum > 0 and gendernum < 3 then
			 return genders[gendernum]
		end      
		return "Male"
	end,
	
	----------------------------------------------------
	-- METHOD: GetAlliance
	----------------------------------------------------
	GetAlliance = function(unitTag)	
		local alliancename = GetAllianceName(GetUnitAlliance(unitTag))
		if (alliancename ~= "" and alliancename ~= nil and alliancename ~= "None") then
			if (AI.saved.account.Target.showAllianceIcon) then
				return AI.icons[alliancename]
			else
				return "("..AI.colors[alliancename]..alliancename.."|r) "
			end
		end
		return ""
	end,
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Target.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Target Bar|r",
		controls = {
			{
				type = "description",
				text = AI.colors.orange.."Target bar color:|r",
			},
			{
				type = "checkbox", 
				name = "Turn on improved target bar colors", 
				tooltip = "Changes the target health color based on the type of target. "..AI.colors.blue.."(Player|r, "..AI.colors.green.."NPC|r, "..AI.colors.yellow.."NPC|r, "..AI.colors.red.."Monster|r)", 
				getFunc = function() return AI.saved.account.Target.fixTargetColor end, 
				setFunc = function(newValue) AI.saved.account.Target.fixTargetColor = newValue end, 
				default = AI.defaults.Target.fixTargetColor, 
			},
			{
				type = "description",
				text = AI.colors.orange.."Target bar information:|r",
			},
			{
				type = "checkbox", 
				name = "Turn on improved target information", 
				tooltip = "Alters the target health bar under the compass to display alliance, race, class, and level.", 
				getFunc = function() return AI.saved.account.Target.on end, 
				setFunc = function(newValue) AI.saved.account.Target.on = newValue end, 
				default = AI.defaults.Target.on, 
			},
			{
				type = "checkbox", 
				name = "Show alliance on player target", 
				tooltip = "Display the target player's alliance under the target bar", 
				getFunc = function() return AI.saved.account.Target.showAlliance end, 
				setFunc = function(newValue) AI.saved.account.Target.showAlliance = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on) end,
				default = AI.defaults.Target.showAlliance, 
			},
			{
				type = "checkbox", 
				name = "Show alliance icon instead of name on player target", 
				tooltip = "Replaces the alliance name with the alliance icon", 
				getFunc = function() return AI.saved.account.Target.showAllianceIcon end, 
				setFunc = function(newValue) AI.saved.account.Target.showAllianceIcon = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on and AI.saved.account.Target.showAlliance) end,
				default = AI.defaults.Target.showAllianceIcon, 
			},
			{
				type = "checkbox", 
				name = "Show race on player target", 
				tooltip = "Display the target player's race under the target bar", 
				getFunc = function() return AI.saved.account.Target.showRace end, 
				setFunc = function(newValue) AI.saved.account.Target.showRace = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on) end,
				default = AI.defaults.Target.showRace, 
			},
			{
				type = "checkbox", 
				name = "Show class on player target", 
				tooltip = "Display the target player's class under the target bar", 
				getFunc = function() return AI.saved.account.Target.showClass end, 
				setFunc = function(newValue) AI.saved.account.Target.showClass = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on) end,
				default = AI.defaults.Target.showClass, 
			},
			{
				type = "checkbox", 
				name = "Indicate gender on player target", 
				tooltip = "Color the target player's name blue or pink under the target bar", 
				getFunc = function() return AI.saved.account.Target.showGender end, 
				setFunc = function(newValue) AI.saved.account.Target.showGender = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on) end,
				default = AI.defaults.Target.showGender, 
			},
			{
				type = "checkbox", 
				name = "Show Level or Champion Points on player target", 
				tooltip = "Display the target player's level or champion points under the target bar", 
				getFunc = function() return AI.saved.account.Target.showLevel end, 
				setFunc = function(newValue) AI.saved.account.Target.showLevel = newValue end, 
				disabled = function() return not(AI.saved.account.Target.on) end,
				default = AI.defaults.Target.showLevel, 
			}
		}
	}
}