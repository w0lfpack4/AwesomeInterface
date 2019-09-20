
AI.icons["gold"] = " |t14:14:EsoUI/Art/currency/currency_gold.dds|t"

----------------------------------------------------
-- SAVED VARS
----------------------------------------------------
AI.defaults["AutoRepair"] = {
	on 			 = true,
	inventory 	 = true,
	confirmation = true,
}

----------------------------------------------------
-- METHODS CALLED FROM PARENT
----------------------------------------------------
AI.plugins["AutoRepair"] = {

	------------------------------------------------
	-- PARENT METHOD: RegisterEvents
	------------------------------------------------
	RegisterEvents = function()
		if (AI.saved.account.AutoRepair.on) then
			EVENT_MANAGER:RegisterForEvent("AI_Repair", EVENT_OPEN_STORE, AI.plugins.AutoRepair.OnOpenStore)
			EVENT_MANAGER:RegisterForEvent("AI_Repair", EVENT_ITEM_REPAIR_FAILURE, AI.plugins.AutoRepair.OnRepairFail)
		else
			EVENT_MANAGER:UnregisterForEvent("AI_Repair", EVENT_OPEN_STORE)
			EVENT_MANAGER:UnregisterForEvent("AI_Repair", EVENT_ITEM_REPAIR_FAILURE)
		end
	end,
			
	------------------------------------------------
	-- EVENT: OnRepairFail
	------------------------------------------------
	OnRepairFail = function (eventCode, reason)
		CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(AI.colors.yellow.."Repair Failed: "..AI.colors.white..reason.."|r\n")
	end,

	------------------------------------------------
	-- EVENT: OnOpenStore
	------------------------------------------------
	OnOpenStore = function()
		if (AI.saved.account.AutoRepair.on and CanStoreRepair() and GetRepairAllCost() > 0) then
			local totalItemCount = 0
			local totalRepairCost = 0
			local totalSkippedItemCount = 0
			local totalSkippedRepairCost = 0
			
			-- scan equipped
			local bagsToScan = { BAG_WORN }
			
			-- scan inventory
			if (AI.saved.account.AutoRepair.inventory) then
				table.insert(bagsToScan, BAG_BACKPACK)
			end
			
			-- iterate items
			for _,bagID in pairs(bagsToScan) do
				for slotID = 0, GetBagSize(bagID) do
					local itemName      = GetItemName(bagID, slotID)
					local itemCondition = GetItemCondition(bagID, slotID)
					
					-- found repairable items
					if itemName ~= '' and itemCondition < 100 then
						local repairCost = GetItemRepairCost(bagID, slotID)
						local itemLink   = GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)

						-- calculate totals						
						if (repairCost > tonumber(GetCurrentMoney())) then
							totalSkippedItemCount  = totalSkippedItemCount  + 1
							totalSkippedRepairCost = totalSkippedRepairCost + repairCost
						else
							totalItemCount  = totalItemCount  + 1
							totalRepairCost = totalRepairCost + repairCost		
							-- repair it
							RepairItem(bagID, slotID)				
						end									
					end
				end
			end		
			
			-- send message to chat
			if (totalItemCount > 0 and AI.saved.account.AutoRepair.confirmation) then
				CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(AI.colors.white..totalItemCount..AI.colors.yellow.." items repaired for "..AI.colors.white..totalRepairCost..AI.icons.gold.."|r\n")
			end
			-- send skipped message to chat
			if (totalSkippedItemCount > 0 and AI.saved.account.AutoRepair.confirmation) then
				CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(AI.colors.yellow.."Unable to repair "..AI.colors.white..totalItemCount..AI.colors.yellow.." items due to lack of funds ("..AI.colors.white..totalRepairCost..AI.icons.gold..")|r\n")
			end
		end
	end -- AI.OnOpenStore
}

----------------------------------------------------
-- SETTINGS MENU
----------------------------------------------------
AI.plugins.AutoRepair.Menu = {
	{
		type = "submenu",
		name = AI.colors.blue.."Auto-Repair|r",
		controls = {
			{
				type = "description",
				text = AIB.colors.orange.."Automatically repairs armor when a merchant window is opened.|r",
			},
			{
				type = "checkbox",
				name = "Enabled", 
				tooltip = "Enables this plugin when checked", 
				getFunc = function() return AI.saved.account.AutoRepair.on end, 
				setFunc = function(newValue) AI.saved.account.AutoRepair.on = newValue; AI.plugins.AutoRepair.RegisterEvents() end, 
				default = AI.defaults.AutoRepair.on, 
			},
			{
				type = "checkbox", 
				name = "Include equipment in inventory", 
				tooltip = "Automatically repairs armor in inventory when a merchant window is opened.", 
				getFunc = function() return AI.saved.account.AutoRepair.inventory end, 
				setFunc = function(newValue) AI.saved.account.AutoRepair.inventory = newValue end, 
				disabled = function() return not(AI.saved.account.AutoRepair.on) end,
				default = AI.defaults.AutoRepair.inventory, 
			},
			{
				type = "checkbox", 
				name = "Send confirmation of repair cost to chat", 
				tooltip = "Displays how many items were repaired and for what cost in the chat window.", 
				getFunc = function() return AI.saved.account.AutoRepair.confirmation end, 
				setFunc = function(newValue) AI.saved.account.AutoRepair.confirmation = newValue end, 
				disabled = function() return not(AI.saved.account.AutoRepair.on) end,
				default = AI.defaults.AutoRepair.confirmation, 
			}
		}
	}
}
