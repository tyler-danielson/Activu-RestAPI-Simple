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
BtnGetGroups = Controls.GetGroups
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
----
----


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

BtnLoadLayout = Controls.LoadLayout
BtnClear = Controls.btnClear
EditLastCommands = Controls.Last_Commands
EditResponseBody = Controls.ResponseBody


TxtDebug = Controls.debug
EditSendStr = Controls.SendString


--********************************************************************************
--* Constants
--********************************************************************************
OK = "0"
DEBUG_WINDOW_SIZE = -1500
LAYOUT_PREVIEW_BLOCK = {ListLayoutSources,LayoutPreview}
PREVIEW_BLOCKS = {}
for k,type in ipairs(SIMPLE_COMMANDS) do
  table.insert(PREVIEW_BLOCKS, _G['edit'..type..'ID'])
end
ALL_SOURCE_LABEL = "ALL"
MANUAL_SORUCE_ID = "ManualSourceAdd"
TOTAL_DESTINATIONS = 30
UNIVERSAL_LABEL = "UNIVERSAL"
CLEARSOURCESTRING = "Clear Sources"
SOURCE_DROPDOWN_DEFAULT = "*Click to Change*"
INSTANCE_STRING = 'Instance_'..math.random(100000, 999999)..'_'


STATUS_CODES = {
  {nil,"Fault","Fault"},
  {0,"Fault","Connection Timeout"},
  {200,"OK","Success"},
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
LayoutData = {}
LoadedSourceIndex = {}
SelectedArray = {}
LastResponses = {}

--********************************************************************************
--* Debug display/print functions
--********************************************************************************

--********************************************************************************
--* Function: Debug(response)
--* Description: prints data into console and debug window.
--********************************************************************************
function Debug(response)
  local newString = string.sub(TxtDebug.String..'\r\r'..response, DEBUG_WINDOW_SIZE)
  TxtDebug.String = newString
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
--* Function: LoadWalls()
--* Description: populate Discovered Walls based on pulled data
--********************************************************************************
function LoadWalls(data)
  AvailableWalls = qsc_json.decode(data)
  SelectWalls.Choices = OnlyNames(AvailableWalls)
  CheckIfPopulated(SelectWalls)
  UpdateWallInfo()
end


--********************************************************************************
--* Function: PopulateWallData()
--* Description: populate wall data
--********************************************************************************
function PopulateWallData(data)
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

  ButtonFlash(_btnGet)
end

--********************************************************************************
--* Function: ButtonFlash(btn)
--* Description: Flashes the button blue with "UPDATED" text
--********************************************************************************
function ButtonFlash(btn)
  local notifyColor = 'blue'
  local notifyStr = 'UPDATED'
  local legend = btn.Legend
  btn.Color = notifyColor
  btn.Legend = notifyStr
  Timer.CallAfter(function()
    btn.Color = '' 
    btn.Legend = legend
  end, 0.5)
end

--********************************************************************************
--* Function: CheckIfPopulated(object)
--* Description: checks if current object is populated.  
--* If not, sets to first choice
--********************************************************************************
function CheckIfPopulated(object,value)
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
--* Function: LoadPreviewWindow(i)
--* Description: Loads preview window in layout tab
--********************************************************************************
function LoadPreviewWindow(i)
  for key,object in ipairs(LAYOUT_PREVIEW_BLOCK) do
    object.IsInvisible = i < 1
  end
  for key,object in ipairs(PREVIEW_BLOCKS) do
    for k,o in ipairs(object) do
      o.IsInvisible = k ~= i
    end
  end
end


--********************************************************************************
--* Function: SourceEditSelect(i,tab,tabIndex)
--* Description: function for when a layout edit button is pressed
--********************************************************************************
function EditSelect(type,buttonID)
  print(buttonID)
  local _btnEdit = _G['btn'..type..'Edit']
  for key,object in ipairs(_btnEdit) do
    object.Boolean = key == buttonID
  end
  LoadPreviewWindow(buttonID)
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
function PopulateLayoutInfo()
  --LayoutData = qsc_json.decode(data)
  local sourceInstances = LayoutData.sourceInstances
  local sourceNames = OnlyNames(sourceInstances)

  ListLayoutSources.Choices = sourceNames
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
  local wallString = SelectWalls.String
  EditWallName.String = wallString
  EditWallID.String = GetID(AvailableWalls,wallString)
  GET("GetWallData")
  --GET("WallSources")
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
--* Function: TransformSource(sourceID,sourceInstanceId,x,y,w,h)
--* Description: add source to wall based on included info
--********************************************************************************
function TransformSource(sourceID,sourceInstanceId,x,y,width,height)
  local data = '{"sourceId": "'..sourceID..'"'
  ..',"apiRegion": '
    ..'{"x": '.. x
    ..',"y": '.. y
    ..',"width": '.. width
    ..',"height": '.. height
  ..'}}'
  PUT('TransformSource',data,sourceInstanceId)
end


--********************************************************************************
--* Function: RemoveSource(sourceInstanceId)
--* Description: removes the specific source instance from wall
--********************************************************************************
function RemoveSource(sourceInstanceId)
  DELETE('RemoveSource',sourceInstanceId)
end


--********************************************************************************
--* Function: AddCustomSource(key)
--* Description: add selected source from source tree to specified coordinates
--********************************************************************************
--[[
function AddCustomSource(key)
  local sourceID = EditSourceId[key].String
  local sourceInstanceId = EditSourceInstanceId[key].String
  local x = EditSourcePlaceCoordsX[key].String
  local y = EditSourcePlaceCoordsY[key].String
  local width = EditSourcePlaceCoordsW[key].String
  local height = EditSourcePlaceCoordsH[key].String
  --RemoveSource(sourceInstanceId)
  AddSource(sourceID,sourceInstanceId,x,y,width,height)
end


--********************************************************************************
--* Function: RemoveCustomSource()
--* Description: remove custom added source from videowall
--********************************************************************************
function RemoveCustomSource(key)
  local sourceInstanceId = EditSourceInstanceId[key].String
  RemoveSource(sourceInstanceId)
end
]]--

--********************************************************************************
--* Function: ClearViewscreen()
--* Description: clear first viewscreen
--********************************************************************************
function ClearViewscreen()
  CurrentSources.all = {} 
  DELETE("ClearVS",1)
end


function BuildCoordsFromLayout(sourceInfo,wallOnly)
  --if wallOnly == nil then wallOnly = false end
  local layoutCoords = {}
  for key,object in ipairs(sourceInfo) do
    local region = object.region
    --local wallWidth = EditWall_Width.Value
    --local wallHeight = EditWall_Height.Value
    local PctX = math.floor(region.x)--/wallWidth*100)
    local PctY = math.floor(region.y)--/wallHeight*100)
    local PctW = math.floor(region.width)--/wallWidth*100)
    local PctH = math.floor(region.height)--/wallHeight*100)
    local wall = EditWallName.String
    if wallOnly then
      if string.find(object.id,wall.."template") then
        table.insert(layoutCoords,{PctX,PctY,PctW,PctH,object.id,object.name,object.sourceId})
      end
    else
      table.insert(layoutCoords,{PctX,PctY,PctW,PctH,object.id,object.name,object.sourceId})
    end
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
function BuildGrid(layout,type,config)
  --if config == nil then config = GetGridConfig() end
  local svgWidth = EditWall_Width.String--AspectRatio[1]*192--*1920
  local svgHeight = EditWall_Height.String--AspectRatio[2]*108--*1080
  local layoutString = ""
  local backgroundColor = 'black'--config.defaultBackColor
  local borderColor = 'white'--config.defaultGridColor
  local strokeWidth = svgWidth*.01--config.defaultGridWidth
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
    local x = (o[1])--*svgWidth)--/100)
    local y = (o[2])--*svgHeight)--/100)
    local width = (o[3])--*svgWidth)--/100)
    local height = (o[4])--*svgHeight)--/100)
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


---###################

--********************************************************************************
--* Function: GetCommandURL(command)
--* Description: builds Post URL based on given string
--********************************************************************************
function GetCommandURL(command,params,params2)
  local webAddr = EditWebAddr.String.."/api/v1/"
  local apiStr = "key="..EditAPI.String
  local url = webAddr
  if command == "AddSource" then
    url = url.."walls/"..EditWallID.String.."/sources?"
  elseif command == "TransformSource" then
    url = url.."walls/"..EditWallID.String.."/sources/"..params2.."/transform?"
  elseif command == "GetWalls" then
    url = url.."walls?"
  elseif command == "GetWallData" then
    url = url.."walls/"..EditWallID.String.."?"
  elseif command == "loadLayout" then
    url = url.."walls/"..EditWallID.String.."/loadlayout?layoutId="..params.."&"
  elseif command == "loadScript" then
    url = url.."scripts/"..params.."/execute?"
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
  elseif command == "GetGroups" then
    url = url.."groups?"
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
function POST(command,data,data2)
  local url = GetCommandURL(command,data,data2)
  print('post',data,data2)
  HttpClient.Post {
    Url = url,
    --Method = "POST",
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
--* Function: PUT(command,dataString)
--* Description: sends post command with relevant data
--********************************************************************************
function PUT(command,data,data2)
  local url = GetCommandURL(command,data,data2)
  print('put',url,data,data2)
  HttpClient.Put {
    Url = url,
    --Method = "POST",
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
  print('delete',url)
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
--* Function: done(tbl, code, data, e)
--* Description: organizes return code and data
--********************************************************************************
function done(tbl, code, data, e)
  print( string.format("Response Code: %i\t\tErrors: %s\rData: %s",code, e or "None", data))
  local response = {tbl, code, data, e}
  ParseCode(code)
  local url = tbl.Url
  local CalledCommand = tbl.CalledCommand
  if CalledCommand == "GetWalls" then LoadWalls(data)
  elseif CalledCommand == "GetWallData" then PopulateWallData(data)
  elseif CalledCommand == "GetLayouts" then PopulateData('Layout',data)
  elseif CalledCommand == "GetScripts" then PopulateData('Script',data)--PopulateScriptData(data)
  elseif CalledCommand == "loadLayout" then EditLayouts.String = ""
  elseif CalledCommand == "WallSources" then PopulateLoadedSources(data)
  elseif CalledCommand == "GetLayoutInfo" then
    LayoutData = qsc_json.decode(data)
    PopulateLayoutInfo()
  elseif CalledCommand == "GetSources" then PopulateData('Source',data)--PopulateSources(data)
  end
  
  table.insert(LastResponses,1,response)
  if #LastResponses > 15 then
    table.remove(LastResponses)--,#LastResponses)
  end
  local lastCommands = {}
  local responses = LastResponses
  for key,object in ipairs(responses) do
    table.insert(lastCommands,key..' - '..object[1].CalledCommand)
  end
  table.sort(lastCommands)
  EditLastCommands.Choices = lastCommands
end

---need to update
function ShowResponse()
  local key
  for k,choice in ipairs(EditLastCommands.Choices) do
    if choice == EditLastCommands.String then key = k end 
  end
  local response = LastResponses[key]
  local code = response[2]
  local e = response[3]
  local data = response[4]
  EditResponseBody.String = string.format("Response Code: %i\t\tErrors: %s\rData: %s",code, e or "None", data)
end


--********************************************************************************
--* Function: PopulateDefaults
--* Description: runs through a list of potentially undefined controls and populates
--* them with a default value
--********************************************************************************
function PopulateDefaults()
  local function AddStrIfBlank(object,defaultStr)
    if object.String == "" then object.String = defaultStr end
  end
  AddStrIfBlank(EditWebAddr,"https://<ipaddress>:59081")
end


--********************************************************************************
--* Event Handlers for Controls
--********************************************************************************
SelectWalls.EventHandler = UpdateWallInfo
BtnGetWalls.EventHandler = function() GET("GetWalls") end
--BtnGetSources.EventHandler = function() GET("GetSources") end
--btnGetLayouts.EventHandler = function() GET("GetLayouts") end
--btnGetScripts.EventHandler = function() GET("GetScripts") end


BtnClearVS.EventHandler = ClearViewscreen

--ListAvailSources.EventHandler = UpdateSourceInfo
--ListSourceFilter.EventHandler = FilterSources



BtnGetWallsources.EventHandler = UpdateWallInfo


for key,object in ipairs(BtnVsSrcSelect) do
  object.EventHandler = function() HideSourceLists(key) end
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
      LoadPreviewWindow(key)
      GetPreview(type,key)
    end
  end
  _btnGet.EventHandler = function() GET("Get"..types) end
end


---- this is part of the layout section of the wall.  edit immediately
BtnLoadLayout.EventHandler = function(obj)
  local layoutID = GetID(AvailableLayouts,EditLayouts.String)
  POST('loadLayout',layoutID)
end

EditLastCommands.EventHandler = ShowResponse

--********************************************************************************
--* Function: Initialize()
--* Description: Initialization code for the plugin
--********************************************************************************
function Initialize()
  if EditAPI.String ~= "" and EditWebAddr ~= "" then
    GET("GetWalls")
  end
  HideSourceLists(1)
  LoadPreviewWindow(1)

  PopulateDefaults()    
  for k,type in ipairs(SIMPLE_COMMANDS) do
    local call = _G['btn'..type..'Call']
    local legend = _G['edit'..type..'Legend']
    local uciEdit = _G['btn'..type..'UCIEdit']
    ---
    for key,object in ipairs(call) do
      if uciEdit[key].Boolean then
        legend[key].IsDisabled = true  
      else
        object.Legend = legend[key].String
      end
    end
    -----
  end
  

end
Initialize()


