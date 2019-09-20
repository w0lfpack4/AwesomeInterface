
----------------------------------------------------
-- HOOKS
----------------------------------------------------
-- take over this method.  It will crash the game if another addon uses it.
local oldSetFloatingMarkerInfo = SetFloatingMarkerInfo
SetFloatingMarkerInfo = function( ... ) end
local SetFloatingMarkerInfo = oldSetFloatingMarkerInfo


----------------------------------------------------
-- TEXTURES
----------------------------------------------------
AI.textures["Quests"] = {
	darkbrotherhood_target = AI.name.."/Textures/quests/darkbrotherhood_target.dds",
	quest_available_icon = AI.name.."/Textures/quests/quest_available_icon.dds",
	quest_ending_icon = AI.name.."/Textures/quests/quest_ending_icon.dds",
	quest_icon = AI.name.."/Textures/quests/quest_icon.dds",
	quest_icon_assisted = AI.name.."/Textures/quests/quest_icon_assisted.dds",
	quest_icon_door = AI.name.."/Textures/quests/quest_icon_door.dds",
	quest_icon_door_assisted = AI.name.."/Textures/quests/quest_icon_door_assisted.dds",
	repeatablequest_available_icon = AI.name.."/Textures/quests/repeatablequest_available_icon.dds",
	repeatablequest_ending_icon = AI.name.."/Textures/quests/repeatablequest_ending_icon.dds",
	repeatablequest_icon = AI.name.."/Textures/quests/repeatablequest_icon.dds",
	repeatablequest_icon_assisted = AI.name.."/Textures/quests/repeatablequest_icon_assisted.dds",
	repeatablequest_icon_door = AI.name.."/Textures/quests/repeatablequest_icon_door.dds",
	repeatablequest_icon_door_assisted = AI.name.."/Textures/quests/repeatablequest_icon_door_assisted.dds",
	timely_escape_npc = AI.name.."/Textures/quests/timely_escape_npc.dds",
	zonestoryquest_available_icon = AI.name.."/Textures/quests/zonestoryquest_available_icon.dds",
	zonestoryquest_ending_icon = AI.name.."/Textures/quests/zonestoryquest_ending_icon.dds",
	zonestoryquest_icon = AI.name.."/Textures/quests/zonestoryquest_icon.dds",
	zonestoryquest_icon_assisted = AI.name.."/Textures/quests/zonestoryquest_icon_assisted.dds",
	zonestoryquest_icon_door = AI.name.."/Textures/quests/zonestoryquest_icon_door.dds",
	zonestoryquest_icon_door_assisted = AI.name.."/Textures/quests/zonestoryquest_icon_door_assisted.dds",
	quest_hidden_icon = AI.name.."/Textures/quests/quest_hidden_icon.dds",
}

--[[
https://esoapi.uesp.net/100027/src/ingame/floatingmarkers/floatingmarkers.lua.html
	]]

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["Quests"] = {
	showQuestHeaders = true,
    showInWorld 	 = true,
	showInMap 		 = true,
	showInJournal 	 = true,
	replaceQuestMap  = true,
    questMarkerSize  = 32,
}

AI.QuestTypes = {
	[0] = {"Unknown",    "esoui/art/journal/journal_tabicon_quest_up.dds","esoui/art/mainmenu/menubar_crowncrates_up.dds"},	--QUEST_TYPE_NONE = 0
	[1] = {"Group",      "esoui/art/contacts/tabicon_friends_up.dds"},					--QUEST_TYPE_GROUP = 1			esoui/art/mainmenu/menubar_character_up.dds
	[2] = {"Main Story", "esoui/art/help/help_tabicon_overview_up.dds"},				--QUEST_TYPE_MAIN_STORY = 2		esoui/art/journal/journal_tabicon_lorelibrary_up.dds    
	[3] = {"Guild",      "esoui/art/guild/guildheraldry_indexicon_crest_up.dds"},		--QUEST_TYPE_GUILD = 3			
	[4] = {"Crafting",   "esoui/art/worldmap/map_ava_tabicon_oremine_up.dds"},			--QUEST_TYPE_CRAFTING = 4		
	[5] = {"Dungeon",    "esoui/art/journal/leaderboard_indexicon_challenge_up.dds"},	--QUEST_TYPE_DUNGEON = 5		
	[6] = {"Raid",       "esoui/art/journal/leaderboard_indexicon_raids_up.dds"},		--QUEST_TYPE_RAID = 6			
	[7] = {"AVA",        "esoui/art/journal/leaderboard_indexicon_ava_up.dds"},			--QUEST_TYPE_AVA = 7			
	[8] = {"Class",      "esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds"},	--QUEST_TYPE_CLASS = 8			
	[9] = {"Test",       "esoui/art/menubar/menubar_help_up.dds"},						--QUEST_TYPE_QA_TEST = 9		
	[10] = {"AVA Group", "esoui/art/journal/leaderboard_indexicon_ava_up.dds"},			--QUEST_TYPE_AVA_GROUP = 10		
	[11] = {"AVA Grand", "esoui/art/journal/leaderboard_indexicon_ava_up.dds"},			--QUEST_TYPE_AVA_GRAND = 11		
}

AI.InstanceTypes = {
	[1]  = {"Solo",				"EsoUI/Art/Journal/journal_Quest_Instance.dds"},
	[2]  = {"Dungeon", 			"EsoUI/Art/Journal/journal_Quest_Group_Instance.dds"},
	[3]  = {"Raid", 			"EsoUI/Art/Journal/journal_Quest_Trial.dds"},
	[4]  = {"Group Delve", 		"EsoUI/Art/Journal/journal_Quest_Group_Delve.dds"},
	[5]  = {"Group Area", 		"EsoUI/Art/Journal/journal_Quest_Group_Area.dds"},
	[6]  = {"Public Dungeon", 	"EsoUI/Art/Journal/journal_Quest_Dungeon.dds"},
	[7]  = {"Delve", 			"EsoUI/Art/Journal/journal_Quest_Delve.dds"},
	[8]  = {"Housing", 			"EsoUI/Art/Journal/journal_Quest_Housing.dds"},
	[10] = {"Zone Story", 		"EsoUI/Art/Journal/journal_Quest_ZoneStory.dds"},
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["Quests"] = {
	questCount = 0,
	esoRoot = "esoui/art/",
	aiRoot  = AI.name.."/",
	texturesToRedirect = {
		{"darkbrotherhood_target.dds"},
		{"quest_available_icon.dds"},
		{"quest_icon.dds"},
		{"quest_icon_assisted.dds"},
		{"quest_icon_door.dds"},
		{"quest_icon_door_assisted.dds"},
		{"repeatablequest_available_icon.dds"},
		{"repeatablequest_icon.dds"},
		{"repeatablequest_icon_assisted.dds"},
		{"repeatablequest_icon_door.dds"},
		{"repeatablequest_icon_door_assisted.dds"},
		{"zonestoryquest_available_icon.dds"},
		{"zonestoryquest_icon.dds"},
		{"zonestoryquest_icon_assisted.dds"},
		{"zonestoryquest_icon_door.dds"},
		{"zonestoryquest_icon_door_assisted.dds"},
		{"timely_escape_npc.dds"},
	}
}

----------------------------------------------------
-- Addons to change
----------------------------------------------------
AI.findAddon["QuestMap"] = false

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["Quests"] = {
	
	------------------------------------------------
	-- PARENT METHOD: Initialize 
	------------------------------------------------
	Initialize = function()
	
		-- override methods for world map quest tab
		if (AI.saved.account.Quests.showQuestHeaders) then
			-- always show all quests in world map
			ZO_WorldMapQuestsData_Singleton.ShouldMapShowQuestsInList = function(...) return true end			
			
			-- takeover mouse clicks so that clicking a quest will change map to the quests zone and zoom in
			ZO_WorldMapQuestHeader_OnMouseUp = AI.plugins.Quests.OnMouseUp
			
			-- adds categories, icons, header color, mouse events
			WORLD_MAP_QUESTS.SetupQuestHeader = AI.plugins.Quests.SetupQuestHeader
						
			-- rebuild master list with new quest type headers and send to setupquestheader
			WORLD_MAP_QUESTS.RefreshHeaders = AI.plugins.Quests.RefreshHeaders
			
			-- no quests label
			ZO_WorldMapQuests_Shared.RefreshNoQuestsLabel = AI.plugins.Quests.RefreshNoQuestsLabel
			
			-- tooltip
			ZO_WorldMapQuests_Shared_SetupQuestDetails = AI.plugins.Quests.SetupQuestDetails
			
		end
		
		-- override methods for journal quests
		if (AI.saved.account.Quests.showInJournal) then
			-- changes assisted zone story icon from white to green
			ZO_QuestJournal_Keyboard.SetIconTexture = AI.plugins.Quests.SetIconTexture
			
			-- intercepts the name and colors blue for daily or green for zone story
			GetJournalQuestName = AI.plugins.Quests.GetJournalQuestName
		end
		
		-- redirect textures from esoui/art to awesomeinterface/textures/quests
		-- AI.vars.Quests.texturesToRedirect contains the texture list to redirect so that 
		-- the rest of esoui/art remains unchanged
		if (AI.saved.account.Quests.showInWorld) then
		    AI.plugins.Quests.redirectTextures("floatingmarkers/", "Textures/quests/")
		end
		
		if (AI.saved.account.Quests.showInMap) then
			AI.plugins.Quests.redirectTextures("compass/", "Textures/quests/")		
		end		
			
	end,

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		EVENT_MANAGER:RegisterForEvent("AI_Quests", EVENT_PLAYER_ACTIVATED, AI.plugins.Quests.OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent("AI_Quests", EVENT_ZONE_CHANGED, AI.plugins.Quests.OnZoneChanged)	
	end,
	
	------------------------------------------------
	-- EVENT: OnZoneChanged
	------------------------------------------------
	OnZoneChanged = function()	
		AI.plugins.Quests.swapQuestMapPins()
		AI.plugins.Quests.setFloatingMarkers()		
	end,
	
	------------------------------------------------
	-- EVENT: OnPlayerActivated
	------------------------------------------------
	OnPlayerActivated = function()	
		AI.plugins.Quests.swapQuestMapPins()
		AI.plugins.Quests.setFloatingMarkers()		
	end,
		
	------------------------------------------------
	-- METHOD: swapQuestMapPins
	------------------------------------------------
	swapQuestMapPins = function()
		-- QuestMap Replace Icons (Initialize is too early)
		if (AI.saved.account.Quests.replaceQuestMap and AI.findAddon["QuestMap"]) then
			RedirectTexture("QuestMap/icons/pinQuestUncompleted.dds", AI.textures.Quests.quest_available_icon)
			RedirectTexture("QuestMap/icons/pinQuestCompleted.dds", AI.textures.Quests.quest_hidden_icon)
		end
	end,
	
	------------------------------------------------
	-- METHOD: setFloatingMarkers
	------------------------------------------------
	setFloatingMarkers = function()		
		if (AI.saved.account.Quests.showInWorld) then			
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon_assisted, AI.textures.Quests.quest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon_assisted, AI.textures.Quests.quest_icon__door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_ending_icon, quest_icon__door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon_assisted, AI.textures.Quests.repeatablequest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon_assisted, AI.textures.Quests.repeatablequest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_ending_icon, AI.textures.Quests.repeatablequest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon_assisted, AI.textures.Quests.zonestoryquest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon_assisted, AI.textures.Quests.zonestoryquest_icon_door_assisted)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_ending_icon, AI.textures.Quests.zonestoryquest_icon_door_assisted)
			
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_ending_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_ending_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon, AI.textures.Quests.zonestoryquest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon, AI.textures.Quests.zonestoryquest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_ending_icon, AI.textures.Quests.zonestoryquest_icon_door)
			
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_ending_icon, AI.textures.Quests.quest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatablequest_ending_icon, AI.textures.Quests.repeatablequest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon, AI.textures.Quests.zonestoryquest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_icon, AI.textures.Quests.zonestoryquest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_ending_icon, AI.textures.Quests.zonestoryquest_icon_door)
			
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_available_icon, AI.textures.Quests.zonestoryquest_icon_door)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.timely_escape_npc, AI.textures.Quests.timely_escape_npc)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.darkbrotherhood_target, AI.textures.Quests.darkbrotherhood_target)
			local PULSES = true
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.quest_available_icon, "", PULSES)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.repeatableQuest_available_icon, "", PULSES)
			SetFloatingMarkerInfo(MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY, AI.saved.account.Quests.questMarkerSize, AI.textures.Quests.zonestoryquest_available_icon, "", PULSES)
		end
	
	end,
		
	------------------------------------------------
	-- METHOD: redirectTextures
	------------------------------------------------
	redirectTextures = function(redirectFrom, redirectTo)
	    for i = 1, #AI.vars.Quests.texturesToRedirect do
			local textureFrom = AI.vars.Quests.esoRoot..redirectFrom..AI.vars.Quests.texturesToRedirect[i][1]
			local textureTo = AI.vars.Quests.aiRoot..redirectTo..AI.vars.Quests.texturesToRedirect[i][1]
	        RedirectTexture(textureFrom, textureTo)
	    end
	end,
	
	------------------------------------------------
	-- OVERRIDE EVENT: ZO_WorldMapQuestHeader_OnMouseUp
	------------------------------------------------
	OnMouseUp = function(header, button, upInside)
		local name = GetControl(header, "Name")
		name:SetAnchor(TOPLEFT, nil, TOPLEFT, 26, 0)
		-- all of these things are not like the other
		local zoneID = GetZoneId(header.data.zoneIndex)
		local mapIndex = GetMapIndexByZoneId(zoneID)
		--d("questIndex: "..header.data.questIndex)
		--d("zoneIndex: "..header.data.zoneIndex)
		--d("zoneID: "..zoneID)
		--d("mapIndex: "..mapIndex)
		--d("|cffffff---------------|r")
		
		if (header.data.zoneIndex ~= GetCurrentMapZoneIndex()) then
			ZO_WorldMap_SetMapByIndex(mapIndex)
			--SetMapToQuestZone(header.data.questIndex)
			ZO_WorldMap_PanToQuest(header.data.questIndex)
			ZO_ZoneStories_Manager.StopZoneStoryTracking()
			FOCUSED_QUEST_TRACKER:ForceAssist(header.data.questIndex)
			PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
		else
			WORLD_MAP_QUESTS:QuestHeader_OnClicked(header, button)
			PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
		end
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: WORLD_MAP_QUESTS.SetupQuestHeader
	------------------------------------------------
	SetupQuestHeader = function(self, control, data)
		-- nothing to work with, exit
		if (data == nil) then return end
		if (control == nil) then return end
		
		-- Quest or Header Name
		local nameControl = GetControl(control, "Name")
		
		-- this is a header
		if (data.isHeader) then
			nameControl:SetText(" "..AI.colors.header..data.name.."|r")
			nameControl:SetMouseEnabled(false)
			nameControl:SetFont("EsoUI/Common/Fonts/Univers67.otf|22|soft-shadow-thick")
		
		-- this is a quest
		else
			nameControl:SetText("  "..data.name)
			nameControl:SetMouseEnabled(true)
			nameControl:SetFont("EsoUI/Common/Fonts/Univers67.otf|16|soft-shadow-thick")
		end
		
		-- setting color based on level which is now useless		
		
		-- assisted icon control
		local assistedTexture = GetControl(control, "AssistedIcon")
		local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains = assistedTexture:GetAnchor(0)
		
		-- this is a header, change the icon
		if (data.icon) then
			assistedTexture:SetTexture(data.icon)
			assistedTexture:SetDimensions(28,28)
			assistedTexture:SetHidden(false)
			assistedTexture:SetAnchor(point, relativeTo, relativePoint, -3, offsetY, anchorConstrains)
			ZO_SelectableLabel_SetNormalColor(nameControl, ZO_NORMAL_TEXT)	
			
		-- this is a quest
		else
			-- get the Assisted State
			local isAssisted = ZO_Tracker:IsTrackTypeAssisted(TRACK_TYPE_QUEST, data.questIndex)
			assistedTexture:SetDimensions(20,20)
			assistedTexture:SetHidden(not isAssisted)
			assistedTexture:SetAnchor(point, relativeTo, relativePoint, 10, offsetY, anchorConstrains)
			
			-- instance type
			if (data.displayType > 0 and data.displayType < 9) then
				nameControl:SetText("  "..data.name.."  |t18:18:"..AI.InstanceTypes[data.displayType][2].."|t")
			end			
						
			-- daily
			if data.daily == 1 then
				ZO_SelectableLabel_SetNormalColor(nameControl, ZO_ColorDef:New(.07, .85, .92, 1))	
				assistedTexture:SetTexture("esoui/art/floatingmarkers/repeatablequest_icon_assisted.dds")
				
			-- zoneStory
			elseif data.displayType==10 then
				ZO_SelectableLabel_SetNormalColor(nameControl, ZO_ColorDef:New(0, 1, 0, 1))	
				assistedTexture:SetTexture("esoui/art/floatingmarkers/zonestoryquest_icon_assisted.dds")
				
			-- normal
			else
				ZO_SelectableLabel_SetNormalColor(nameControl, ZO_ColorDef:New(GetColorForCon(GetCon(data.level))))	
				assistedTexture:SetTexture("esoui/art/floatingmarkers/quest_icon_assisted.dds")
			end				
		end
		
		-- pass the data to the control
		control.data = data
		
		-- get the text height, width
		local nameWidth, nameHeight = nameControl:GetTextDimensions()
		
		-- this is a header
		if (data.icon) then
			control:SetHeight(zo_max(28, nameHeight))
			
		-- this is a quest
		else
			control:SetHeight(zo_max(20, nameHeight))
		end
	
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: WORLD_MAP_QUESTS:RefreshHeaders
	------------------------------------------------
	RefreshHeaders = function(self)
		-- set the no quest label
		--self:RefreshNoQuestsLabel()
		self.noQuestsLabel:SetHidden(true)
		-- reset the header pool
		self.headerPool:ReleaseAllObjects()
		-- get all quests
		self.questList = AI.plugins.Quests.GetQuestList(self)
		-- pre-define the new master list
		self.newMasterList = {}
		
		-- iterate all quest types in order to build the new master list
		for numType=0,11 do	
			AI.plugins.Quests.BuildMasterList(self, numType)
		end
		
		-- iterate the new master list to create headers
		local prevHeader 
		for i, data in ipairs(self.newMasterList) do
			-- create the header
			local header = self.headerPool:AcquireObject(i)
			-- anchor it
			if(prevHeader) then
				header:SetAnchor(TOPLEFT, prevHeader, BOTTOMLEFT, 0, 4)
			else
				header:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
			end
			-- build it
			self:SetupQuestHeader(header, self.newMasterList[i])
			prevHeader = header
		end
	end,
	
	------------------------------------------------
	-- METHOD: GetQuestList
	------------------------------------------------
	GetQuestList = function(self)
		AI.vars.Quests.questCount = 0
		local list = {}
		-- iterate all possible quests
		for questIndex = 1, MAX_JOURNAL_QUESTS do
		
			-- is this a valid quest?
			if IsValidQuestIndex(questIndex) then
				AI.vars.Quests.questCount = AI.vars.Quests.questCount + 1
				-- get quest data
				local name, description, stepText, stepType, stepOverrideText, completed, tracked, level, pushed, questType, displayType = GetJournalQuestInfo(questIndex)
				local questIsLocal = IsJournalQuestInCurrentMapZone(questIndex)
				local zoneIndex = GetJournalQuestStartingZone(questIndex)
				
				-- create the table for this quest type
				if not list[questType] then list[questType] = {} end
				
				-- insert the data
				table.insert(list[questType], {
					questIndex = questIndex,
					name = name,
					level = level,
					questType = questType,
					displayType = displayType,
					questIsLocal = questIsLocal,
					zoneIndex = zoneIndex,
					daily = GetJournalQuestRepeatType(questIndex),
				})				
			end
		end
		return list
	end,
	
	------------------------------------------------
	-- METHOD: BuildMasterList
	------------------------------------------------
	BuildMasterList = function(self, numType)
		-- no quests for this type, exit	
		if not numType then return end
		if not self.questList[numType] then return end
		
		-- zone quests
		if numType == 0 then
			local zType
			-- sort by zone index
			table.sort(self.questList[numType], function(a, b) return a.zoneIndex < b.zoneIndex end)
			
			-- iterate the quests for this type
			for i, data in ipairs(self.questList[numType]) do
				-- new zone found
				if data.zoneIndex ~= zType then		
					
					-- create the header for this zone
					table.insert(self.newMasterList, {
						questIndex = nil,
						name  = GetZoneNameByIndex(data.zoneIndex),
						level = GetUnitLevel("player"),
						questType = numType,
						isHeader = true,
						icon = AI.QuestTypes[numType][2],
					})
					zType = data.zoneIndex
				end		
				-- add zone quest to master list
				table.insert(self.newMasterList, data)
			end	
			
		-- everything else
		else
			-- sort by name
			table.sort(self.questList[numType], function(a, b) return a.name < b.name end)
			
			-- create the header for this type
			table.insert(self.newMasterList, {
				questIndex = nil,
				name  = AI.QuestTypes[numType][1],
				level = GetUnitLevel("player"),
				isHeader = true,
				questType = numType,
				icon = AI.QuestTypes[numType][2],
			})	
		
			-- iterate the quests for this type and add to master list
			for i, data in ipairs(self.questList[numType]) do
				table.insert(self.newMasterList, data)
			end	
			
		end		
		
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: ZO_WorldMapQuests_Shared.RefreshNoQuestsLabel
	------------------------------------------------
	RefreshNoQuestsLabel = function(self)
		if AI.vars.Quests.questCount > 0 then
			self.noQuestsLabel:SetHidden(true)    
		else
			self.noQuestsLabel:SetHidden(false)
			if ZO_WorldMapQuestsData_Singleton.ShouldMapShowQuestsInList() then
				self.noQuestsLabel:SetText(GetString(SI_WORLD_MAP_NO_QUESTS))
			else
				self.noQuestsLabel:SetText(GetString(SI_WORLD_MAP_DOESNT_SHOW_QUESTS_DISTANCE))
			end
		end
		
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: ZO_WorldMapQuests_Shared_SetupQuestDetails
	------------------------------------------------
	SetupQuestDetails = function(self, questIndex)
		local AddConditionLine = function(self, labels, text, nobullet)
			local conditionLabel = self.labelPool:AcquireObject()
			conditionLabel:SetWidth(0)
			if nobullet then
				conditionLabel:SetText(text)
			else
				zo_bulletFormat(conditionLabel, AI.colors.white..text)
			end
			table.insert(labels, conditionLabel)
		end
		local labels = {}
		local questName, bgText, stepText, stepType, stepOverrideText, completed, tracked = GetJournalQuestInfo(questIndex)
		local history = AI.colors.orange..bgText.."|r\n"
		AddConditionLine(self, labels, history, true)
		if completed then
			AddConditionLine(self, labels, GetJournalQuestEnding(questIndex))
		else
			local tasks = {}
			QUEST_JOURNAL_MANAGER:BuildTextForTasks(stepOverrideText, questIndex, tasks)
			for i = 1, #tasks do
				AddConditionLine(self, labels, tasks[i].name)
			end
		end
		local width = 0
		for i = 1, #labels do
			local labelWidth = labels[i]:GetTextDimensions() 
			width = zo_max(width, labelWidth)
		end
		local MAX_WIDTH = 250
		width = zo_min(width, MAX_WIDTH)
		return labels, width
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: ZO_QuestJournal_Keyboard.SetIconTexture
	------------------------------------------------
	SetIconTexture = function(self, iconControl, iconData, selected)
		local texture = GetControl(iconControl, "Icon")
		texture.selected = selected		
		if selected then		
			if (iconData.displayType == 10) then
				texture:SetTexture(AI.textures.Quests.zonestoryquest_icon_assisted)
			else
				texture:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
			end
			texture:SetAlpha(1)
			texture:SetHidden(false)
		else
			local texturePath = self:GetIconTexture(iconData.questType, iconData.displayType)
			if texturePath then
				texture:SetTexture(texturePath)
				texture.tooltipText = self:GetTooltipText(iconData.questType, iconData.displayType)
				texture:SetAlpha(0.50)
				texture:SetHidden(false)
			else
				texture:SetHidden(true)
			end
		end
	end,
	
	------------------------------------------------
	-- OVERRIDE METHOD: GetJournalQuestName
	------------------------------------------------
	GetJournalQuestName = function(questIndex)
		local daily = (GetJournalQuestRepeatType(questIndex)==1)
		local name, description, stepText, stepType, stepOverrideText, completed, tracked, level, pushed, questType, displayType = GetJournalQuestInfo(questIndex)
		local zoneStory = (displayType==10)
		if daily then
			name = AI.colors.blue..name
		elseif zoneStory then 
			name = AI.colors.green..name
		end
		return name
	end,
} -- close AI.plugins["Quests"]

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.Quests.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Quest Icons|r",
		controls = {
			{
				type = "description",
				text = AI.colors.orange.."Using this feature will show the list of quests in the world map.|r",
			},
			{
				type = "checkbox", 
				name = "Turn on world map custom quest headers", 
				tooltip = "Displays the list of quests in the world map by quest type.", 
				getFunc = function() return AI.saved.account.Quests.showQuestHeaders end, 
				setFunc = function(newValue) AI.saved.account.Quests.showQuestHeaders = newValue end, 
				requiresReload = true,
				default = AI.defaults.Quests.showQuestHeaders, 
			},
			{
				type = "description",
				text = AI.colors.orange.."Using these features will replace quest icons.|r",
			},
			{
				type = "checkbox", 
				name = "Replace in-game floating quest icons", 
				tooltip = "Displays custom quest icons in-game", 
				getFunc = function() return AI.saved.account.Quests.showInWorld end, 
				setFunc = function(newValue) AI.saved.account.Quests.showInWorld = newValue end, 
				requiresReload = true,
				default = AI.defaults.Quests.showInWorld, 
			},
			{
				type = "checkbox", 
				name = "Replace world map and compass quest icons", 
				tooltip = "Displays custom quest icons in the world map and compass", 
				getFunc = function() return AI.saved.account.Quests.showInMap end, 
				setFunc = function(newValue) AI.saved.account.Quests.showInMap = newValue end, 
				requiresReload = true,
				default = AI.defaults.Quests.showInMap, 
			},
			{
				type = "checkbox", 
				name = "Replace journal and quest tracker icons", 
				tooltip = "Displays custom quest icons in the journal and quest tracker", 
				getFunc = function() return AI.saved.account.Quests.showInJournal end, 
				setFunc = function(newValue) AI.saved.account.Quests.showInJournal = newValue end, 
				requiresReload = true,
				default = AI.defaults.Quests.showInJournal, 
			},
			{
				type = "slider",
				name = "In-game Quest Marker Size",
				tooltip = "Select the size of the in-world quest markers.",
				min = 32,
				max = 96,
				step = 1,
				getFunc = function() return AI.saved.account.Quests.questMarkerSize end,
				setFunc = function(newValue) AI.saved.account.Quests.questMarkerSize = newValue end, 
				requiresReload = true,
				default = AI.defaults.Quests.questMarkerSize,
			},
			{
				type = "description",
				text = AI.colors.orange.."Using this feature will require a restart.|r",
			},
			{
				type = "checkbox", 
				name = "Replace quest icons in QuestMap.", 
				tooltip = "Replace quest icons in the QuestMap AddOn New: |t26:26:"..AI.textures.Quests.quest_icon.."|t Current: |t26:26:"..AI.textures.Quests.quest_icon_assisted.."|t Old/Hidden: |t26:26:"..AI.textures.Quests.quest_hidden_icon.."|t", 
				getFunc = function() return AI.saved.account.Quests.replaceQuestMap end, 
				setFunc = function(newValue) AI.saved.account.Quests.replaceQuestMap = newValue end, 
				disabled = function() return not AI.findAddon["QuestMap"] end,
				default = AI.defaults.Quests.replaceQuestMap, 
			}
		}
	}
}