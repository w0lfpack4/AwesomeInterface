local LAM = LibStub("LibAddonMenu-2.0")

function AI.CreateConfigMenu()

	----------------------------------------------------
	-- Set up panel info for Awesome Interface
	----------------------------------------------------
	local AwesomeInterfacePanel = {
		 type = "panel",
		 name = AI.displayName,
		 registerForRefresh  = true,
		 registerForDefaults = true,
		 author = AI.colors.red..AI.author.."|r",
		 version = AI.colors.green..AI.version.."|r",
	}
	
	----------------------------------------------------
	-- Register panel for Awesome Interface
	----------------------------------------------------
	LAM:RegisterAddonPanel(AI.displayName, AwesomeInterfacePanel)
	
	----------------------------------------------------
	-- Set up options info for Awesome Interface
	----------------------------------------------------
	local AwesomeInterfaceOptions = {
		{
			type = "description",
			text = AI.colors.orange.."There are many ways you can customise your AI experience, so don't forget to scroll down the options page.|r",
		},
	}
	
	----------------------------------------------------
	-- Merge plugin menus for Awesome Interface
	----------------------------------------------------
	for key,value in pairs(AI.plugins) do 
		if (AI.plugins[key].Menu ~= nil) then
			AwesomeInterfaceOptions = AI.Merge(AwesomeInterfaceOptions, AI.plugins[key].Menu)
		end
	end
	
	----------------------------------------------------
	-- Register option controls for Awesome Interface
	----------------------------------------------------
	LAM:RegisterOptionControls(AI.displayName, AwesomeInterfaceOptions)
	
end -- AI.CreateConfigMenu

