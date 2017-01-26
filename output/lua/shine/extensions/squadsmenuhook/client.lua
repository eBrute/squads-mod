--[[
    Shine wonitor plugin
]]

local Shine = Shine
local Plugin = {}

Plugin.Version = "1.0"
Plugin.DefaultState = true -- Should the plugin be enabled when it is first added to the config?
Plugin.NS2Only = false -- Set to true to disable the plugin in NS2: Combat if you want to use the same code for both games in a mod.
Plugin.HasConfig = false -- Does this plugin have a config file?
Plugin.ConfigName = "squadsmenu.json" -- What's the name of the file?
Plugin.DefaultConfig = {}
Plugin.CheckConfig = false -- Should we check for missing/unused entries when loading?
Plugin.CheckConfigTypes = false -- Should we check the types of values in the config to make sure they match our default's types?

function Plugin:Initialise()
	Shine.VoteMenu:EditPage( "Main",
        function( Menu )
            self.MenuEntry = Menu:AddSideButton( "Select Squad",
                function()
                    Menu.GenericClick( "squad_menu" )
                end
            )
            self.MenuEntry:SetIsVisible( true )
        end
    )
	self.Enabled = true
	return self.Enabled
end

Shine:RegisterExtension( "squadsmenuhook", Plugin )
Shine:EnableExtension( "squadsmenuhook" )
