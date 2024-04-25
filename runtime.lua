-- Required
rapidjson=require("rapidjson")
EzSVG = require "EzSVG"
SIMPLE_COMMANDS = {'Layout','Script','Source'}--,'Source'}
Controls = Controls
--********************************************************************************
--* Aliases
--********************************************************************************
EditWebAddr = Controls.WebAddress
EditAPI = Controls.APIkey
SelectWalls = Controls.AvailableWalls
BtnGetWalls = Controls.GetWalls
BtnGetSources = Controls.GetSources
EditStatus = Controls.Status
EditWallName = Controls.WallName
EditWallID = Controls.WallID
EditWall_X = Controls.Wall_X
EditWall_Y = Controls.Wall_Y
EditWall_Width = Controls.Wall_Width
EditWall_Height = Controls.Wall_Height
EditWall_VS = Controls.Wall_VS
EditLayouts = Controls.Wall_Layouts
EditTemplates = Controls.Wall_Templates
BtnVsSrcSelect = Controls.VS_SourceView_Select
BtnClearVS = Controls.ClearVS
BtnGetWallsources = Controls.GetWallSources
ListLoadedSources = Controls.LoadedSources
ListLayoutSources = Controls.LayoutSourceListTemp
BtnLoadLayout = Controls.LoadLayout
BtnClear = Controls.btnClear
EditLastCommands = Controls.Last_Commands
EditCalledCommand = Controls.CalledCommand
EditResponseData = Controls.ResponseData
EditResponseCode = Controls.ResponseCode
EditResponseError = Controls.ResponseError
EditResponseURL = Controls.ResponseURL
TxtDebug = Controls.debug
EditSendStr = Controls.SendString


--********************************************************************************
--* Dynamic Variables
--********************************************************************************
for k,type in ipairs(SIMPLE_COMMANDS) do
  _G['btn'..type..'Edit'] = Controls[pageDefs[type].edit]
  _G['btn'..type..'Call'] = Controls[pageDefs[type].call]
  _G['btn'..type..'Remove'] = Controls[pageDefs[type].remove]
  _G['edit'..type..'Def'] = Controls[pageDefs[type].callDef]
  _G['edit'..type..'ID'] = Controls[pageDefs[type].id]
  _G['edit'..type..'Legend'] = Controls[pageDefs[type].legend]
  _G['btn'..type..'UCIEdit'] = Controls[pageDefs[type].uciDefined]
  _G[type..'Preview'] = Controls[pageDefs[type].preview.name]
  _G['btnGet'..type..'s'] = Controls[pageDefs[type].get]

  _G['edit'..type..'_x'] = Controls[pageDefs[type].region.x]
  _G['edit'..type..'_y'] = Controls[pageDefs[type].region.y]
  _G['edit'..type..'_width'] = Controls[pageDefs[type].region.width]
  _G['edit'..type..'_height'] = Controls[pageDefs[type].region.height]
  _G['btn'..type..'_trigger'] = Controls[pageDefs[type].triggerAll]
end
----


--********************************************************************************
--* Constants
--********************************************************************************
OK = "0"
DEBUG_WINDOW_SIZE = -1500
ALL_SOURCE_LABEL = "ALL"
MANUAL_SORUCE_ID = "ManualSourceAdd"
TOTAL_DESTINATIONS = 30
UNIVERSAL_LABEL = "UNIVERSAL"
CLEARSOURCESTRING = "Clear Sources"
SOURCE_DROPDOWN_DEFAULT = "*Click to Change*"
INSTANCE_STRING = 'Instance_'..math.random(100000, 999999)..'_'
DEFAULT_WEBADDR = "https://<ipaddress>:59081"

STATUS_CODES = {
  {nil,"Fault","Fault"},
  {0,"MISSING","Connection Timeout"},
  {1,"MISSING","Disconnected"},
  {2,"INITIALIZING",""},
  {3,"MISSING","Missing IP Address"},
  {4,"MISSING","Missing API Key"},
  {200,"OK",""},
  {400,"FAULT","Bad Request"},
  {401,"FAULT","Unauthorized"},
  {406,"FAULT","Not Acceptable"},
  {500,"FAULT","Server Error"},
}

--********************************************************************************
--* Enumerated types
--********************************************************************************
CONN_COLOR   = {GREY = 0, RED = 1, YELLOW = 2, GREEN = 3}
              --Green   Orange           Red        Grey            Red          Blue
STATUS_STATE = {OK = 0, COMPROMISED = 1, FAULT = 2, NOTPRESENT = 3, MISSING = 4, INITIALIZING = 5}


--********************************************************************************
--* Global objects/variables
--********************************************************************************
SendQueue = {}
DebugFunction=false
AvailableWalls = {}
AvailableSources = {}
AvailableLayouts = {}
AvailableScripts = {}
AvailableTemplates = {}
AvailableViewscreens = {}
CurrentSources = {
  all = {},
}
CurrentPosition = 0
LoadedSourceIndex = {}
SelectedArray = {}
LastResponses = {}

--********************************************************************************
--* Debug display/print functions
--********************************************************************************

--********************************************************************************
--* Function: PrintDebug(level,debut)
--* Description: prints data into console and debug window.
--********************************************************************************
function PrintDebug( level, debug )
	if Properties["Debug Print"].Value == level then
		print(debug)
	elseif level == "Tx" and Properties["Debug Print"].Value == "Tx/Rx" then
		print(debug)
	elseif level == "Rx" and Properties["Debug Print"].Value == "Tx/Rx" then
		print(debug)
	elseif Properties["Debug Print"].Value == "All" then
		print(debug)
	end
	
end


--********************************************************************************
--* Discovery Functions
--********************************************************************************

--********************************************************************************
--* General Functions
--********************************************************************************


--********************************************************************************
--* Function: ReportStatus(state, msg, debugStr)
--* Description: Update status message and state to given values
--********************************************************************************
function ReportStatus(state, msg, debugStr)
  EditStatus.Value = STATUS_STATE[state]
  EditStatus.String = msg
  if (STATUS_STATE[state] > 0) then
    if debugStr ~= nil then
      if debugStr ~= "" then
        if DebugFunction then print(debugStr.."-"..msg) end
      else
        if DebugFunction then print(msg) end
      end
    else
      if DebugFunction then print(msg) end
    end
  end
end


--********************************************************************************
--* Function: ParseCode(code)
--* Description: parses return code and updates status if needed
--********************************************************************************
function ParseCode(code)
  for key,object in ipairs(STATUS_CODES) do
    local status_code = object[1]
    local status = object[2]
    local message = object[3]
    if code == status_code then ReportStatus(status,message) end
  end
end


--********************************************************************************
--* Function: LoadWalls(data)
--* Description: populate Discovered Walls based on pulled data
--********************************************************************************
function LoadWalls(data)
  printFunction(debug.getinfo(1, "n").name, data);
  AvailableWalls = qsc_json.decode(data)
  SelectWalls.Choices = OnlyNames(AvailableWalls)
  CheckIfPopulated(SelectWalls)
  UpdateWallInfo()
end


--********************************************************************************
--* Function: printFunction(name,content)
--* Description: takes function name and content, converts it, and sends to debug
--********************************************************************************
function printFunction(name,content)
  if content == nil then content = "" end
  if type(content) == "userdata" then content = "" end
  if type(content) == "table" then content = table_to_string(content) end
  PrintDebug("Function Calls",name.."("..content..")")
end


function table_to_string(tbl)
  local result = "{"
  for k, v in pairs(tbl) do
    -- Check the key type (ignore any numerical keys - assume its an array)
    if type(k) == "string" then
        result = result.."\""..k.."\""..":"
    end

    -- Check the value type
    if type(v) == "table" then
        result = result..table_to_string(v)
    elseif type(v) == "boolean" then
        result = result..tostring(v)
    else
        result = result.."\""..v.."\""
    end
    result = result..","
  end
  -- Remove leading commas from the result
  if result ~= "{" then
    result = result:sub(1, result:len()-1)
  end
  return result.."}"
end



--********************************************************************************
--* Function: PopulateWallData()
--* Description: populate wall data
--********************************************************************************
function PopulateWallData(data)
  printFunction(debug.getinfo(1, "n").name,data);
  local wallData = qsc_json.decode(data)
  local geometry = wallData.geometry
  AvailableLayouts = wallData.layouts
  AvailableTemplates = wallData.templates
  AvailableViewscreens = wallData.viewScreens
  EditWall_X.Value = geometry.x
  EditWall_Y.Value = geometry.y
  EditWall_Width.Value = geometry.width
  EditWall_Height.Value = geometry.height
  EditWall_VS.Choices = AvailableViewscreens
  for key,obj in ipairs (BtnVsSrcSelect) do
    if AvailableViewscreens[key] ~= nil then
      obj.Legend = AvailableViewscreens[key]
      obj.IsInvisible = false
    else
      obj.IsInvisible = true
    end
  end
  EditLayouts.Choices = OnlyNames(AvailableLayouts)
  EditTemplates.Choices = OnlyNames(AvailableTemplates)
  CheckIfPopulated(EditWall_VS)
end



--********************************************************************************
--* Function: PopulateData(type,data)
--* Description: updates available layouts/script/sources based on incoming data
--********************************************************************************
function PopulateData(type,data)
  printFunction(debug.getinfo(1, "n").name,type..','..data);
  local available = qsc_json.decode(data)
  local types = type..'s'
  local _editDef = _G['edit'..type..'Def']
  local _btnGet = _G['btnGet'..types]
  local options = {}
  local changeString = "* Click to Change *"


  _G['Available'..types] = available

  table.insert(options,changeString)
  table.insert(options,'')
  
  for key,object in ipairs(available) do
    if object.target == nil or object.target == EditWallID.String then
      table.insert(options,object.name)
    end
  end

  for key,object in ipairs(_editDef) do
    object.Choices = options
    if object.String == "" then object.String = changeString end
  end
end


--********************************************************************************
--* Function: CheckIfPopulated(object)
--* Description: checks if current object is populated.  
--* If not, sets to first choice
--********************************************************************************
function CheckIfPopulated(object)
  if object.String == "" then
    object.String = object.Choices[1]
  end
end


--********************************************************************************
--* Function: OnlyNames(table)
--* Description: takes a table of data and returns an array of just the names
--********************************************************************************
function OnlyNames(data)
  local options = {}
  for key,object in ipairs(data) do
    table.insert(options,object.name)
  end
  table.sort(options)
  return options
end


--********************************************************************************
--* Function: SourceEditSelect(i,tab,tabIndex)
--* Description: function for when a layout edit button is pressed
--********************************************************************************
function EditSelect(type,buttonID)
  local _btnEdit = _G['btn'..type..'Edit']
  for key,object in ipairs(_btnEdit) do
    object.Boolean = key == buttonID
  end
  GetPreview(type,buttonID)
end


--********************************************************************************
--* Function: GetPreview(type,key)
--* Description: populate preview and other data when selection changes
--********************************************************************************
function GetPreview(type,key)
  local name = _G['edit'..type..'Def'][key].String
  local id = GetID(_G['Available'..type..'s'],name)
  local _uci = _G['btn'..type..'UCIEdit']
  local _legend = _G['edit'..type..'Legend']
  
  if not _uci[key].Boolean and type ~= 'Source' then
    _G['btn'..type..'Call'][key].Legend = name
  end
  _legend[key].String = name
  _G['edit'..type..'ID'][key].String = id
  
  if type == 'Layout' then
    GET("GetLayoutInfo",id)
  end
end


--********************************************************************************
--* Function: UpdateLegend(button,string)
--* Description: updates touch panel button based on defined string
--********************************************************************************
function UpdateLegend(button,string1)
  button.Legend = string1
end


function EnableUCIEdit(type,i,bool)
  printFunction(debug.getinfo(1, "n").name,type..','..i..","..bool);
  local legend = _G['edit'..type..'Legend'][i]
  local button = _G['btn'..type..'Call'][i]
  legend.IsDisabled = bool
  if bool then 
    button.Legend = ""
  else
    button.Legend = legend.String
  end
end


--********************************************************************************
--* Function: PopulateLayoutInfo()
--* Description: populate preview window with relevant layout data
--********************************************************************************
function PopulateLayoutInfo(data)
  printFunction(debug.getinfo(1, "n").name,data);
  local layoutData = qsc_json.decode(data)
  local sourceInstances = layoutData.sourceInstances
  local sourceNames = {"*click to show*"}
  for key,object in ipairs(OnlyNames(sourceInstances)) do
    table.insert(sourceNames,object)
  end
  ListLayoutSources.Choices = sourceNames
  ListLayoutSources.String = "*click to show*"
  --ListLayoutSources.String = sourceStr
  local gridCoords = BuildCoordsFromLayout(sourceInstances)
  local grid = BuildGrid(gridCoords)
  Draw(grid,LayoutPreview)
end


--********************************************************************************
--* Function: LoadCommand(key)
--* Description: sends the load layout command using wall definition and key
--********************************************************************************
function LoadCommand(type,key)
  local ID = _G['edit'..type..'ID'][key].String
  local sharedTrigger = _G['btn'..type..'_trigger']
  if type == 'Source' then
    local x = editSource_x[key].String
    local y = editSource_y[key].String
    local width = editSource_width[key].String
    local height = editSource_height[key].String
    AddSource(ID,INSTANCE_STRING..key,x,y,width,height)
  else
    POST('load'..type,ID)
  end
  sharedTrigger:Trigger()
end




--*********************************************************************************************************************************
--*********************************************************************************************************************************


--********************************************************************************
--* Function: GetID(table,name)
--* Description: determines the ID based on a name/only list
--********************************************************************************
function GetID(table,name)
  local ID = ""
  for key,object in ipairs(table) do
    if name == object.name then ID = object.id end
  end
  return ID
end


--********************************************************************************
--* Function: updateWallInfo()
--* Description: updates wall definition based on selected wall
--********************************************************************************
function UpdateWallInfo()
  printFunction("UpdateWallInfo")
  local wallString = SelectWalls.String
  EditWallName.String = wallString
  EditWallID.String = GetID(AvailableWalls,wallString)
  GET("GetWallData")
  GET("WallSources")
end



--********************************************************************************
--* Function: ComboSelect(key,array)
--* Description: 
--********************************************************************************
function ComboSelect(key,array)
  for k,o in ipairs(array) do
    o.Boolean = key == k
  end
end


--********************************************************************************
--* Function: PopulateLoadedSources(data)
--* Description: populate the currently loaded sources into tables
--********************************************************************************
function PopulateLoadedSources(data)
  printFunction(debug.getinfo(1, "n").name,data)
  CurrentSources.all = qsc_json.decode(data)
  CurrentSources.template = {}
  CurrentSources.other = {}
  for k,vs in ipairs(AvailableViewscreens) do
    local currentVS = {}
    for key,source in ipairs(CurrentSources.all) do
      if source.viewScreen == vs then
        if source.sourceType == "WIDGET" then source.sourceId = "n/a" end
        local tableData = ""
        if source.adHoc ~= true then
          tableData = source.name.." ["..source.sourceId.."] "..source.id
        else
          tableData = source.name.." [adhoc/unknown]"
        end
        table.insert(currentVS,tableData)
      end
    end
    ListLoadedSources[k].Choices = currentVS
  end
end


--********************************************************************************
--* Function: HideSourceLists(key)
--* Description: hide all lists but the one selected
--********************************************************************************
function HideSourceLists(selectedCtl)
  for key,object in ipairs(BtnVsSrcSelect) do
    object.Boolean = selectedCtl == key
  end
  for key,object in ipairs(ListLoadedSources) do
    object.IsInvisible = selectedCtl ~= key
  end
end


--********************************************************************************
--* Function: AddSource(sourceID,sourceInstanceId,x,y,w,h)
--* Description: add source to wall based on included info.  If in Touch Panel mode
--* will temporarily add a source to the wall representation. 
--********************************************************************************
function AddSource(sourceID,sourceInstanceId,x,y,width,height) --add VS?
  printFunction(debug.getinfo(1, "n").name,sourceID..','..sourceInstanceId..','..x..','..y..','..width..','..height);
  local vsIndex = GetVsNumber()
  for key,object in ipairs(EditWall_VS.Choices) do
    if EditWall_VS.String == object then
      vsIndex = key
    end
  end
  local data = '{"sourceId": "'..sourceID..'"'
  ..',"sourceInstanceId": "'..sourceInstanceId..'"'
  ..',"viewScreenId": '..vsIndex
  ..',"region": '
  ..'{"x": '.. x
  ..',"y": '.. y
  ..',"width": '.. width
  ..',"height": '.. height
  ..'}}'
  POST('AddSource',data)
  --GET("WallSources")
end


--********************************************************************************
--* Function: GetVsNumber()
--* Description: get and return selected viewscreen index number
--********************************************************************************
function GetVsNumber()
  local vs = 1
  for key,object in ipairs(EditWall_VS.Choices) do
    if EditWall_VS.String == object then
      vs = key
    end
  end
  return vs
end


--********************************************************************************
--* Function: RemoveSource(sourceInstanceId)
--* Description: removes the specific source instance from wall
--********************************************************************************
function RemoveSource(sourceInstanceId)
  printFunction(debug.getinfo(1, "n").name,sourceInstanceId)
  DELETE('RemoveSource',sourceInstanceId)
end


--********************************************************************************
--* Function: ClearViewscreen()
--* Description: clear first viewscreen
--********************************************************************************
function ClearViewscreen()
  printFunction(debug.getinfo(1, "n").name)
  CurrentSources.all = {} 
  local selectedVS = 1
  for key,obj in ipairs(EditWall_VS.Choices) do
    if obj == EditWall_VS.String then selectedVS = key end
  end
  DELETE("ClearVS",selectedVS)
end


--********************************************************************************
--* Function: BuildCoordsFromLayout(sourceInfo)
--* Description: creates a table of xywh settings for list of sources
--********************************************************************************
function BuildCoordsFromLayout(sourceInfo)
  printFunction(debug.getinfo(1, "n").name,sourceInfo)
  local layoutCoords = {}
  for key,object in ipairs(sourceInfo) do
    local region = object.region
    local PctX = math.floor(region.x)
    local PctY = math.floor(region.y)
    local PctW = math.floor(region.width)
    local PctH = math.floor(region.height)
    local wall = EditWallName.String
    
    --if wallOnly then
    --  if string.find(object.id,wall.."template") then
    --    table.insert(layoutCoords,{PctX,PctY,PctW,PctH,object.id,object.name,object.sourceId})
    --  end
    --else
      table.insert(layoutCoords,{PctX,PctY,PctW,PctH,object.id,object.name,object.sourceId})
    --end
  end
  return layoutCoords
end


--********************************************************************************
--* Function: Draw(template,object)
--* Description: builds and returns template grid icon
--********************************************************************************
function Draw(iconData,object)
  local legend = {
    DrawChrome = false,
    IconData = Crypto.Base64Encode(iconData)
  }
  object.Legend = rapidjson.encode(legend)
end


--********************************************************************************
--* Function: BuildGrid(layout)
--* Description: Utilize SVG to build template select buttons
--********************************************************************************
function BuildGrid(layout)
  local svgWidth = EditWall_Width.String
  local svgHeight = EditWall_Height.String
  local layoutString = ""
  local backgroundColor = 'black'
  local borderColor = 'white'
  local strokeWidth = svgWidth*.01
  EzSVG.setStyle({
    stroke_width= strokeWidth,
    stroke= borderColor,
    fill = backgroundColor
  })
  layoutString = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
  ..'<svg width="'..svgWidth
  ..'" height="'..svgHeight..'">'
  ..'<g style="'
  ..'fill:'..backgroundColor..';'
  ..'stroke:'..borderColor
  ..';stroke-width:'..strokeWidth..';">'

  for k,o in ipairs(layout) do
    local x = (o[1])
    local y = (o[2])
    local width = (o[3])
    local height = (o[4])
    local newString = '<rect '..
      'x="'..x..'" '..
      'y="'..y..'" '..
      'width="'..width..'" '..
      'height="'..height..'"/>'
      layoutString = layoutString..newString
    end
  layoutString = layoutString..'</g>   </svg>'
  return layoutString
end


--********************************************************************************
--* Function: HideControl(control,mode)
--* Description: Hide and Unhide controls based on value
--********************************************************************************
function HideControl(control,show)
  if control.IsIndeterminate ~= false then
    for key,object in ipairs(control) do
        object.IsInvisible = show
    end
  else
    control.IsInvisible = show
  end
end


--********************************************************************************
--* Function: DisableControl(control,disable)
--* Description: Enable/Disable controls based on value
--********************************************************************************
function DisableControl(control,disabled)
  if control.IsIndeterminate ~= false then
    for key,object in ipairs(control) do
      object.IsDisabled = disabled
    end
  else
    control.IsDisabled = disabled
  end
end


--********************************************************************************
--* Function: GetCommandURL(command)
--* Description: builds Post URL based on given string
--********************************************************************************
function GetCommandURL(command,params)
  local webAddr = EditWebAddr.String.."/api/v1/"
  local apiStr = "key="..EditAPI.String
  local url = webAddr
  if command == "AddSource" then
    url = url.."walls/"..EditWallID.String.."/sources?"
  elseif command == "GetWalls" then
    url = url.."walls?"
  elseif command == "GetWallData" then
    url = url.."walls/"..EditWallID.String.."?"
  elseif command == "loadLayout" then
    url = url.."walls/"..EditWallID.String.."/loadlayout?layoutId="..params.."&"
  elseif command == "loadScript" then
    url = url.."scripts/"..params.."/execute?queryScriptParameters=none&"
  elseif command == "WallSources" then
    url = url.."walls/"..EditWallID.String.."/sources?"
  elseif command == "ClearVS" then
    url = url.."walls/"..EditWallID.String.."/viewscreen/"..params.."?"
  elseif command == "GetLayouts" then
    url = url.."layouts?"
  elseif command == "GetScripts" then
    url = url.."scripts?"
  elseif command == "GetLayoutInfo" then
    url = url.."layouts/"..params.."?"
  elseif command == "GetSources" then
    url = url.."sources?"
  elseif command == "RemoveSource" then
    url = url.."walls/"..EditWallID.String.."/sources/"..params.."?"
  end
  url = url..apiStr
  return url
end


--********************************************************************************
--* Function: POST(command,dataString)
--* Description: sends post command with relevant data
--********************************************************************************
function POST(command,data)
  local url = GetCommandURL(command,data)
  if command == 'loadScript' then data = "true" end
  PrintDebug("Tx","HTTP Post \n URL: "..url.."\n Data: "..data)
  HttpClient.Post {
    Url = url,
    Data = data,
    Auth = "basic",
    Timeout = 30,
    CalledCommand = command,
    Headers = {
      ["Content-Type"] = "application/json"
    },
    EventHandler = done --(done) The function to call upon response
  }
end


--********************************************************************************
--* Function: PUT(command,data,data2)
--* Description: sends post command with relevant data
--********************************************************************************
function PUT(command,data)
  local url = GetCommandURL(command,data)
  PrintDebug("Tx","HTTP PUT \n URL: "..url.."\n Data: "..data)
  HttpClient.Put {
    Url = url,
    Data = data,
    Auth = "basic",
    Timeout = 30,
    CalledCommand = command,
    Headers = {
      ["Content-Type"] = "application/json"
    },
    EventHandler = done --(done) The function to call upon response
  }
end


--********************************************************************************
--* Function: DELETE(command,dataString)
--* Description: sends post command with relevant data
--********************************************************************************
function DELETE(command,data)
  local url = GetCommandURL(command,data)
  PrintDebug("Tx","HTTP Delete \n URL: "..url.."\n Data: "..data)
  HttpClient.Upload {
    Url = url,
    Method = "DELETE",
    Data = "",
    Auth = "basic",
    Timeout = 30,
    CalledCommand = command,
    Headers = {
      ["Content-Type"] = "application/json"
    },
    EventHandler = done --(done) The function to call upon response
  }
end


--********************************************************************************
--* Function: GET(command,params)
--* Description: sends post command with relevant data
--********************************************************************************
function GET(command,params)
  if params == nil then params = "" end
  local url = GetCommandURL(command,params)
  PrintDebug("Tx","HTTP Get \n URL: "..url)
  HttpClient.Download {
    Url = url,
    Auth = "basic",
    Timeout = 30,
    CalledCommand = command,
    Headers = {
      ["Content-Type"] = "application/json"
    },
    EventHandler = done --(done) The function to call upon response
  }
end


--********************************************************************************
--* Function: CheckIfOlder(time,qty, units)
--* Description: Checks a specific time to see if it is older and QTY*UNTS.  
--* returns true or false.  Example:  Current time, 5, hours.
--********************************************************************************
function CheckIfOlder(time,qty, units)
  local expired = false
  local secondsFrom = math.floor(os.difftime(os.time(), time))
  local minutesFrom = math.floor(secondsFrom/60)
  local hoursFrom = math.floor(secondsFrom/60 / 60)
  local daysFrom = math.floor(secondsFrom/60 / 60 / 24)
  if units == "seconds" then expired = secondsFrom > qty
  elseif units == "minutes" then expired = minutesFrom > qty
  elseif units == "hours" then expired = hoursFrom > qty
  elseif units == "days" then expired = daysFrom > qty
  end
  return expired
end



--********************************************************************************
--* Function: done(tbl, code, data, e)
--* Description: organizes return code and data
--********************************************************************************
function done(tbl, code, data, e)
  ParseCode(code)
  local url = tbl.Url
  local CalledCommand = tbl.CalledCommand
  local response = {tbl, code, data, e, CalledCommand}
  local lastCommands = {}
  local formatTime = os.date ("%Y-%m-%d %H:%M:%S")
  
  if e then --if there is an error, skip to next
  elseif CalledCommand == "GetWalls" then LoadWalls(data)
  elseif CalledCommand == "GetWallData" then PopulateWallData(data)
  elseif CalledCommand == "GetLayouts" then PopulateData('Layout',data)
  elseif CalledCommand == "GetScripts" then PopulateData('Script',data)
  elseif CalledCommand == "loadLayout" then EditLayouts.String = ""
  elseif CalledCommand == "WallSources" then PopulateLoadedSources(data)
  elseif CalledCommand == "GetLayoutInfo" then PopulateLayoutInfo(data)
  elseif CalledCommand == "GetSources" then PopulateData('Source',data)
  end


  LastResponses[formatTime] = response
  LastResponses[formatTime].command = CalledCommand
  LastResponses[formatTime].time = os.time()
  
  for time,object in pairs(LastResponses) do
    local expired = CheckIfOlder(object.time, 14, "days")
    if expired then
      LastResponses[time] = nil
    end
  end
  
  for key,object in pairs(LastResponses) do
    table.insert(lastCommands,key..' ['..object.command..']')
  end

  table.sort(lastCommands, function(a, b) return a > b end)
  EditLastCommands.Choices = lastCommands
  EditLastCommands.String = EditLastCommands.Choices[1]
  PrintDebug("Rx", string.format("Response Code: %i\t\tErrors: %s\rData: %s",code, e or "None", data))
  ShowResponse()
end


--********************************************************************************
--* Function: ShowResponse()
--* Description: populates response data fields based on selected command
--********************************************************************************
function ShowResponse()
  local timestamp,command = EditLastCommands.String:match("(.+) %[(.+)%]")
  printFunction(debug.getinfo(1, "n").name,timestamp..','..command)
  local response = LastResponses[timestamp]
  local code = response[2]
  local data = response[3]
  local e = response[4]
  local url = response[1].Url
  local dataString = tostring(data)
  EditCalledCommand.String = command
  EditResponseData.String = dataString
  EditResponseCode.String = math.floor(code)
  EditResponseError.String = e or "None"
  EditResponseURL.String = url
end


--********************************************************************************
--* Function: PopulateDefaults()
--* Description: runs through a list of potentially undefined controls and populates
--* them with a default value
--********************************************************************************
function PopulateDefaults()
  local function AddStrIfBlank(object,defaultStr)
    if object.String == "" then object.String = defaultStr end
  end
  AddStrIfBlank(EditWebAddr,DEFAULT_WEBADDR)
end


--********************************************************************************
--* Function: EstablishConnection()
--* Description: check if web address and API are populated.  If they are
--* run GetWalls command to test API key
--********************************************************************************
function EstablishConnection()
  printFunction("EstablishConnection")
  if EditAPI.String ~= "" and EditWebAddr.String ~= "" then
    GET("GetWalls")
  elseif EditWebAddr.String == "" or EditWebAddr.String == DEFAULT_WEBADDR then
    ParseCode(3)
  elseif EditAPI.String == "" then
    ParseCode(4)
  end
end


--********************************************************************************
--* Event Handlers for Controls
--********************************************************************************
SelectWalls.EventHandler = UpdateWallInfo
BtnGetWalls.EventHandler = function() GET("GetWalls") end
BtnClearVS.EventHandler = ClearViewscreen
BtnGetWallsources.EventHandler = UpdateWallInfo
EditLastCommands.EventHandler = ShowResponse
EditWebAddr.EventHandler = EstablishConnection
EditAPI.EventHandler = EstablishConnection

for key,object in ipairs(BtnVsSrcSelect) do
  object.EventHandler = function() HideSourceLists(key) end
end

BtnLoadLayout.EventHandler = function()
  local layoutID = GetID(AvailableLayouts,EditLayouts.String)
  POST('loadLayout',layoutID)
end

for k,type in ipairs(SIMPLE_COMMANDS) do
  local types = type..'s'
  local _btnGet = _G['btnGet'..types]
  local _btnUCIEdit = _G['btn'..type..'UCIEdit']
  local _editSelect = _G[type..'EditSelect']
  local _btnEdit =_G['btn'..type..'Edit']
  local _editLegend = _G['edit'..type..'Legend']
  local _btnCall = _G['btn'..type..'Call']
  local _btnRemove = _G['btn'..type..'Remove']
  local _editDef = _G['edit'..type..'Def']
  local _editID = _G['edit'..type..'ID']
  for key,object in ipairs (_btnUCIEdit) do
    object.EventHandler = function() EnableUCIEdit(type,key,object.Boolean) end
  end
  for key,object in ipairs(_btnEdit) do
    object.EventHandler = function() EditSelect(type,key) end
  end
  for key,object in ipairs(_editLegend) do
    object.EventHandler = function() UpdateLegend(_btnCall[key],object.String) end
  end
  for key,object in ipairs(_btnCall) do --trigger load command
    object.EventHandler = function() LoadCommand(type,key) end
  end
  for key,object in ipairs(_btnRemove) do --trigger load command
    object.EventHandler = function() RemoveSource(INSTANCE_STRING..key) end
  end
  for key,object in ipairs(_editDef) do
    object.EventHandler = function() 
      ComboSelect(key,_btnEdit)
      GetPreview(type,key)
      for j,o in ipairs(_editID) do --hide ID buttons based on selection
        o.IsInvisible = j ~= key
      end
    end
  end
  _btnGet.EventHandler = function() GET("Get"..types) end
end


--********************************************************************************
--* Function: Initialize()
--* Description: Initialization code for the plugin
--********************************************************************************
function Initialize()
  -- ParseCode(2) --Comment out for Certification Standards
  HideSourceLists(1)
  PopulateDefaults()    
  for k,type in ipairs(SIMPLE_COMMANDS) do
    local call = _G['btn'..type..'Call']
    local legend = _G['edit'..type..'Legend']
    local uciEdit = _G['btn'..type..'UCIEdit']
    for key,object in ipairs(call) do
      if uciEdit[key].Boolean then
        legend[key].IsDisabled = true  
      else
        object.Legend = legend[key].String
      end
    end
  end
  EstablishConnection()
end
Initialize()