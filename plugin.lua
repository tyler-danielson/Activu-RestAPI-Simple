-- Vis|Ability Interface Server Connect Plugin
-- by Activu
-- December 2023


-- Information block for the plugin
--[[ #include "info.lua" ]]

-- Define the color of the plugin object in the design
function GetColor(props)
  return {70,70,70 }
end

local Colors = {
  White = {255, 255, 255},
  Black = {0, 0, 0},
  Red = {255, 0, 0},
  Green = {0, 255, 0},
  Yellow = {239,156,0},
  DarkGrey = {200,200,200}-- {70,70,70}
}

--*****************************************************************************
--* this is a custom string added to pull and encode a logo in a seperate file
--* by moving to a txt file, it hides the error in vscode
--*****************************************************************************
  --[[ #include "logo.txt" ]]

-------********add note for this
--Pull templates from a separate file
  --[[ #include "pageDefs.lua" ]]



-- The name that will initially display when dragged into a design
function GetPrettyName(props)
  return "Activu RestAPI, version " .. PluginInfo.Version
end

-- Optional function used if plugin has multiple pages
function GetPages(props)
  local pages = {}
  --[[ #include "pages.lua" ]]
  return pages
end

-- Define User configurable Properties of the plugin
function GetProperties()
  local props = {}
  --[[ #include "properties.lua" ]]
  return props
end

-- Optional function to update available properties when properties are altered by the user
function RectifyProperties(props)
  --[[ #include "rectify_properties.lua" ]]
  return props
end

-- Defines the Controls used within the plugin
function GetControls(props)
  local controls = {}
  --[[ #include "controls.lua" ]]
  return controls
end

--Layout of controls and graphics for the plugin UI to display
function GetControlLayout(props)
  local layout = {}
  local graphics = {}
  --[[ #include "layout.lua" ]]
  return layout, graphics
end

--Start event based logic
if Controls then
  --[[ #include "runtime.lua" ]]
end

