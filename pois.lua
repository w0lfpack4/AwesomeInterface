local OldGetFastTravelNodeInfo = GetFastTravelNodeInfo

----------------------------------------------------
-- TEXTURES
----------------------------------------------------
AI.textures["POIS"] = {
    unowned  = "/esoui/art/icons/poi/poi_group_house_unowned.dds",
    owned    = "/esoui/art/icons/poi/poi_group_house_owned.dds",
}

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["POIS"] = {
    on = true,	
    hideOwned    = false,
    hideUnowned  = false,
    hideTrials   = false,
    hideDungeons = false,
    hideInZones  = false,
    onlyCapitals = false,
}

----------------------------------------------------
-- LOCAL VARS
----------------------------------------------------
AI.vars["POIS"] = {
    isCapitalWayshrine = {
		-- Aldmeri Dominion
		[142] = true, -- Khenarthi's Roost: Mistral (v)
		[121] = true, -- Auridon: Skywatch (v)
		[177] = true, -- Auridon: Vulkhel Guard (v)
		[214] = true, -- Grahtwood: Elden Root (v)
		[143] = true, -- Greenshade: Marbruk (v)
		[102] = true, -- Malabal Tor: Velyn Harbor (v)
		[106] = true, -- Malabal Tor: Baandari Trading Post (v)
		[162] = true, -- Reaper's March: Rawl'kha (v)
		[158] = true, -- Reaper's March: Arenthia (v)

		-- Ebonheart Pact
		[173] = true,	-- Bal Foyen: Dhalmora (v)
		[172] = true,	-- Bleakrock Isle (v)
		[67]  = true,	-- Stonefalls: Ebonheart (v)
		[28]  = true,	-- Deshaan: Mournhold (v)
		[48]  = true,	-- Shadowfen: Stormhold (v)
		[87]  = true,	-- Eastmarch: Windhelm (v)
		[109] = true,	-- The Rift: Riften (v)

		-- Daggerfall Covenant
		[181] = true,	-- Betnickh (v)
		[138] = true,	-- Stros M'Kai: Port Hunding (v)
		[62]  = true,	-- Glenumbra: Daggerfall (v)
		[56]  = true,	-- Stormhaven: Wayrest (v)
		[55]  = true,	-- Rivenspire: Shornhelm (v)
		[43]  = true,	-- Alik'r Desert: Sentinel (v)
		[33]  = true,	-- Bangkorai: Evermore (v)

		-- All Alliances

		-- DLCs
		[244] = true, -- Wrothgar: Orsinium (v)
		[246] = true, -- Wrothgar: Merchant's Gate (v)
		[374] = true, -- Murkmire: Lilmoth (v)
		[251] = true, -- Gold Coast: Anvil (v)
		[252] = true, -- Gold Coast: Kvatch (v)
		[255] = true, -- Hew's Bane: Abah's Landing (v)

		-- Expansions
		[284] = true, -- Vvardenfell: Vivec City (v)
		[355] = true, -- Summerset: Alinor (v)
		[350] = true, -- Summerset: Shimmerene (v)
		[382] = true, -- Elsweyr: Rimmen (v)
		[220] = true, -- Craglorn: Belkarth (v)

		-- The Aurbis
		[360] = true, -- Artaeum (v)
		[338] = true, -- Clockwork City
					  -- Coldharbour: Hollow City

		 -- Mages Guild
		[215] = true, -- Eyévéa
    },	
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["POIS"] = {

	------------------------------------------------
	-- PARENT METHOD: Initialize
	------------------------------------------------
	Initialize = function()
		GetFastTravelNodeInfo = AI.plugins.POIS.GetFastTravelNodeInfo
	end,

	------------------------------------------------
	-- METHOD: GetFastTravelNodeInfo
	------------------------------------------------
    GetFastTravelNodeInfo = function(nodeIndex, ...)
        local known, name, x, y, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = OldGetFastTravelNodeInfo(nodeIndex, ...)
        if (AI.saved.account.POIS.on) then
    
            -- tamriel showing
            if GetMapType() == MAPTYPE_WORLD then
    
                -- show only Capital Wayshrines
                if (AI.saved.account.POIS.onlyCapitals and poiType == POI_TYPE_WAYSHRINE and (not AI.vars.POIS.isCapitalWayshrine[nodeIndex])) then 
                    known = false
                end

                -- hide trials
                if (AI.saved.account.POIS.hideTrials and poiType == POI_TYPE_ACHIEVEMENT) then
                    known = false
                end

                -- hide  dungeons
                if (AI.saved.account.POIS.hideTrials and poiType == POI_TYPE_GROUP_DUNGEON) then
                    known = false
                end
    
                -- hide owned houses
				if (AI.saved.account.POIS.hideOwned and (poiType == POI_TYPE_HOUSE and icon == AI.textures.POIS.owned)) then
                    known = false
                end
                
                -- hide unowned houses
                if (AI.saved.account.POIS.hideUnowned and (poiType == POI_TYPE_HOUSE and icon == AI.textures.POIS.unowned)) then
                    known = false
                end

            -- zone showing (affects housing only)
            else
    
                -- hide owned houses
                if (AI.saved.account.POIS.hideOwned and (poiType == POI_TYPE_HOUSE and icon == AI.textures.POIS.owned)) then
                    known = false
                end
                
                -- hide unowned houses
                if (AI.saved.account.POIS.hideUnowned and (poiType == POI_TYPE_HOUSE and icon == AI.textures.POIS.unowned)) then
                    known = false
                end
    
            end
        end
        return known, name, x, y, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
	end,		
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.POIS.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Houses and Wayshrines|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Hide wayshrine, housing, and trial icons on the worldmap and wayshrines map.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.POIS.on end, 
				setFunc = function(newValue) AI.saved.account.POIS.on = newValue end, 
				default = AI.defaults.POIS.on, 
			},
			{
				type = "checkbox", 
				name = "Only show Capital wayshrines", 
				tooltip = "Hides all wayshrine icons on the worldmap and wayshrines map, except the capital cities.", 
				getFunc = function() return AI.saved.account.POIS.onlyCapitals end, 
				setFunc = function(newValue) AI.saved.account.POIS.onlyCapitals = newValue end, 
				disabled = function() return not AI.saved.account.POIS.on end,
				default = AI.defaults.POIS.onlyCapitals, 
			},
			{
				type = "checkbox", 
				name = "Hide Unowned Houses", 
				tooltip = "Hides unowned housing icons on the worldmap and wayshrines map.", 
				getFunc = function() return AI.saved.account.POIS.hideUnowned end, 
				setFunc = function(newValue) AI.saved.account.POIS.hideUnowned = newValue end, 
				disabled = function() return not AI.saved.account.POIS.on end,
				default = AI.defaults.POIS.hideUnowned, 
			},
			{
				type = "checkbox", 
				name = "Hide Owned Houses", 
				tooltip = "Hides owned housing icons on the worldmap and wayshrines map.", 
				getFunc = function() return AI.saved.account.POIS.hideOwned end, 
				setFunc = function(newValue) AI.saved.account.POIS.hideOwned = newValue end, 
				disabled = function() return not AI.saved.account.POIS.on end,
				default = AI.defaults.POIS.hideOwned, 
			},
			{
				type = "checkbox", 
				name = "Hide housing icons in zones", 
				tooltip = "Hides housing icons in zones.", 
				getFunc = function() return AI.saved.account.POIS.hideInZones end, 
				setFunc = function(newValue) AI.saved.account.POIS.hideInZones = newValue end, 
				disabled = function() return not (AI.saved.account.POIS.hideOwned or AI.saved.account.POIS.hideUnowned) end,
				default = AI.defaults.POIS.hideInZones, 
			},
			{
				type = "checkbox", 
				name = "Hide Trials", 
				tooltip = "Hides trial icons on the worldmap and wayshrines map.", 
				getFunc = function() return AI.saved.account.POIS.hideTrials end, 
				setFunc = function(newValue) AI.saved.account.POIS.hideTrials = newValue end, 
				disabled = function() return not AI.saved.account.POIS.on end,
				default = AI.defaults.POIS.hideTrials, 
			},
			{
				type = "checkbox", 
				name = "Hide Dungeons", 
				tooltip = "Hides dungeon icons on the worldmap and wayshrines map.", 
				getFunc = function() return AI.saved.account.POIS.hideDungeons end, 
				setFunc = function(newValue) AI.saved.account.POIS.hideDungeons = newValue end, 
				disabled = function() return not AI.saved.account.POIS.on end,
				default = AI.defaults.POIS.hideDungeons, 
			}
		}
	}
}
