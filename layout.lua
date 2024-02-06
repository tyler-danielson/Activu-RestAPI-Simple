layout   = {}
graphics = {}
local Colors = {
  White = {255, 255, 255},
  Black = {0, 0, 0},
  Red = {255, 0, 0},
  Green = {0, 255, 0},
  Yellow = {239,156,0},
  DarkGrey = {200,200,200}-- {70,70,70}
}
LOGO_WIDTH = 90
LOGO2_WIDTH = 100
LOGO_HEIGHT = 30
LOGO2_HEIGHT = 24
BORDER_MARGIN = 4
COMMON_MARGIN = BORDER_MARGIN*2
SETUP_PAGE_W = 450
SETUP_BLOCK_W = SETUP_PAGE_W-COMMON_MARGIN
SETUP_INPUT_W = SETUP_PAGE_W - COMMON_MARGIN * 4
DELTA_Y = 18
DEFAULT_INPUT_SIZE = {SETUP_INPUT_W,DELTA_Y}
SETUP_CENTER = SETUP_PAGE_W/2
DEFAULT_INPUT_X = COMMON_MARGIN*2
LABEL_SIZE = 11
INPUT_SIZE = 9
BACKGROUND_DEF = {
  Type = "GroupBox",
  CornerRadius = 8,
  Fill = Colors.DarkGrey,
  Position = {BORDER_MARGIN, BORDER_MARGIN},
  Size = {
    SETUP_BLOCK_W,
    DELTA_Y * 6
  },
  FontSize = LABEL_SIZE
}

-----------------------------------------------------------------
local function BuildPageNames()
  pagenames={ "Setup","Wall Config"}
  --if props["Touchpanel Mode"].Value == "Yes" then 
  local NumOfLayouts = props["Number of Layouts"].Value
  local NumOfScripts = props["Number of Scripts"].Value
  local NumOfSources = props["Number of Sources"].Value
  if NumOfLayouts > 0 then
    table.insert(pagenames,"Layouts")
  end
  if NumOfScripts > 0 then
    table.insert(pagenames,"Scripts")
  end
  if NumOfSources > 0 then
    table.insert(pagenames,"Sources")
  end
  return pagenames
end

TempY = COMMON_MARGIN + LOGO_HEIGHT + DELTA_Y
local CurrentPage = BuildPageNames()[props["page_index"].Value]

function LineBreak(d)
  if d == nil then d = 1 end
  TempY = TempY + DELTA_Y*d
  graphics[1].Size[2] = TempY + DELTA_Y*4
end

--*********************
--* Activu Logo *
--* uses 'LOGO' variable from logo.txt
--*********************
function AddLogo()
  table.insert(graphics,BACKGROUND_DEF)
  table.insert(graphics,{Type="Image",Image=LOGO,Position={COMMON_MARGIN,COMMON_MARGIN},Size={LOGO_WIDTH,LOGO_HEIGHT}})
  local rightAlign = SETUP_BLOCK_W - LOGO2_WIDTH
  table.insert(graphics,{Type="Image",Image=LOGO2,Position={rightAlign,COMMON_MARGIN},Size={LOGO2_WIDTH,LOGO2_HEIGHT}})
  table.insert(graphics,{Type="Label",Text=string.format("Plugin Version %s",PluginInfo.Version),FontSize=9,Position={rightAlign,COMMON_MARGIN+LOGO2_HEIGHT},Size={LOGO2_WIDTH,12},HTextAlign="Right"})

end

function AddHeader(heading)
  table.insert(graphics,{
    Type = "Header",
    Text = heading,
    FontStyle = "Roboto Mono",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = DEFAULT_INPUT_SIZE,
    FontSize = 12,
  })
  LineBreak(1.3)
end

function AddSubheading(subheading,percentX,percentW,size)
  --local x = DEFAULT_INPUT_X
  --if percentX > 0 then x = DEFAULT_INPUT_X + SETUP_INPUT_W * percentW / 100 end
  local fontSize = LABEL_SIZE
  local blockHeight = nil
  if size ~= nil then
    fontSize = 8
    blockHeight = 56
  end
  table.insert(graphics,{
    Type = "Text",
    Text = subheading,
    Position = {CustomPosX(percentX), TempY},
    Size = CustomSize(percentW,blockHeight),
    FontSize = fontSize,
  })
end

function CustomSize(percentX,percentY)
  if percentY == nil then percentY = 100 end
  local width = SETUP_INPUT_W * percentX/100
  local height = DELTA_Y * percentY/100
  return {width,height}
end

function CustomPosX(percent)
  local x = DEFAULT_INPUT_X + SETUP_INPUT_W * percent/100
  return x
end


function BuildEditPage(pageType)
  local defs = pageDefs[pageType]
  local pretty = defs.pretty
  local prettyPlural = pretty.."s"
  local numOfButtons = props["Number of "..pageType.."s"].Value
  local previewBoxSize = 500
  AddLogo()
  if defs.preview.type == "image" then previewBoxSize = 900 end
  table.insert(graphics, {
    Type = "GroupBox",
    CornerRadius = 4,
    StrokeColor = Colors.Yellow,
    StrokeWidth=1,
    Position = {CustomPosX(-2.5), TempY},
    Size = CustomSize(105,previewBoxSize),
    FontSize = LABEL_SIZE
  })
  LineBreak()
  AddHeader(string.upper(defs.heading1))
  AddSubheading(string.upper(pageType).." ID",0,45)
  if defs.preview.type == "image" then
    AddSubheading("PREVIEW",55,45)
  end
  LineBreak()
  
  for i = 1,numOfButtons do
    layout[defs.id.." "..i] = {
      PrettyName = prettyPlural.."~Definition~"..pretty.." "..i.."~ID",
      Style = "Text",
      Position = {DEFAULT_INPUT_X, TempY},
      Size = CustomSize(45,100)
    }
  end
  if defs.preview.type == "image" then
    layout[defs.preview.name] = {
      PrettyName = prettyPlural.."~Preview",
      Style = "Button",
      ButtonStyle = "Trigger",
      Legend= "",
      ButtonVisualStyle = "Flat",
      Position = {CustomPosX(55), TempY},
      Size = CustomSize(45,450)}
      LineBreak()
  elseif defs.preview.type == "text" then
    layout[defs.preview.name] = {
      Style = "TextBox",
      Position = {CustomPosX(55), TempY},
      Size = CustomSize(45,700)}
  end

  if pageType == "Layout" then 
    AddSubheading("LAYOUT SOURCES",0,45)
    LineBreak()
    layout["LayoutSourceListTemp"] = {
      Style="ComboBox",
      PrettyName = prettyPlural.."~Definition~Layout Sources",
      Position = {CustomPosX(0), TempY},
      Size = CustomSize(45,100),
    }
    LineBreak(2)
  end


  LineBreak(2)
  layout[defs.get] = {
    PrettyName = prettyPlural.."~Get "..prettyPlural,
    Style="Button",
    ButtonStyle = "Trigger",
    Legend = "GET LATEST "..string.upper(pageType).."S ↺",
    Position = {CustomPosX(30), TempY},
    Size = CustomSize(40),
  }
  layout[defs.triggerAll] = {
    PrettyName = prettyPlural.."~Any "..pretty.." Trigger",
    Style = "LED",
    Legend = "ANY",
    Position = {CustomPosX(88), TempY},
    Size = CustomSize(12),
  }
  LineBreak()
  AddSubheading("🔍",0,5)
  AddSubheading(string.upper(pageType).." DEFINITION",5,40)
  if pageType == "Source" then
    AddSubheading("X",47,7)
    AddSubheading("Y",54,7)
    AddSubheading("W",61,7)
    AddSubheading("H",68,7)
    AddSubheading("ADD",76,12)
    AddSubheading("REMOVE",88,12)
  else
    AddSubheading("UCI?",48,7)
    AddSubheading("LEGEND",55,30)
    AddSubheading("TRIGGER",88,12)
  end
  
  LineBreak()
  for i = 1, numOfButtons do
    layout[defs.edit.." "..i] = {
      PrettyName = prettyPlural.."~Edit "..pretty.." Select~"..pretty.." "..i,
      Style = "Button",
      ButtonStyle = "Toggle",
      StrokeColor = Colors.Yellow,
      Legend= tostring(i),
      ButtonVisualStyle = "Gloss",
      Position = {CustomPosX(0), TempY},
      Size = CustomSize(5)
    }
    layout[defs.callDef.." "..i] = {
      PrettyName = prettyPlural.."~Definition~"..pretty.." "..i.."~Name",
      Style = "ComboBox",
      StrokeColor = Colors.Yellow,
      Position = {CustomPosX(5), TempY},
      Size = CustomSize(40,100)
    }
    ----
    if pageType == "Source" then
      layout[defs.region.x.." "..i] = {
        Position = {CustomPosX(47), TempY},
        Size = CustomSize(7,100),
        PrettyName = "Sources~Definition~Source "..i.."~X",
        Style="Text"
      }
      layout[defs.region.y.." "..i] = {
        Position = {CustomPosX(54), TempY},
        Size = CustomSize(7,100),
        PrettyName = "Sources~Definition~Source "..i.."~Y",
        Style="Text"
      }
      layout[defs.region.width.." "..i] = {
        Position = {CustomPosX(61), TempY},
        Size = CustomSize(7,100),
        PrettyName = "Sources~Definition~Source "..i.."~Width",
        Style="Text"
      }
      layout[defs.region.height.." "..i] = {
        Position = {CustomPosX(68), TempY},
        Size = CustomSize(7,100),
        PrettyName = "Sources~Definition~Source "..i.."~Height",
        Style="Text"
      }
      -----
      layout[defs.call.." "..i] = {
        PrettyName = prettyPlural.."~Load "..pretty.." Trigger~"..pretty.." "..i,
        Style = "Button",
        ButtonStyle = "Trigger",
        ButtonVisualStyle = "Gloss",
        FontSize = 8,
        Position = {CustomPosX(76), TempY},
        Size = CustomSize(12)
      }
      layout[defs.remove.." "..i] = {
        PrettyName = prettyPlural.."~Remove "..pretty.." Trigger~"..pretty.." "..i,
        Style = "Button",
        ButtonStyle = "Trigger",
        ButtonVisualStyle = "Gloss",
        FontSize = 8,
        Position = {CustomPosX(88), TempY},
        Size = CustomSize(12)
      }
    else
      layout[defs.uciDefined.." "..i] = {
        PrettyName = prettyPlural.."~Definition~"..pretty.." "..i.."~UCI Defined",
        Style = "Button",
        ButtonStyle = "Toggle",
        StrokeColor = Colors.Yellow,
        Position = {CustomPosX(49), TempY},
        Size = CustomSize(5,100)
      }
      layout[defs.legend.." "..i] = {
        PrettyName = prettyPlural.."~Definition~"..pretty.." "..i.."~Legend",
        Style = "Text",
        StrokeColor = Colors.Yellow,
        Position = {CustomPosX(55), TempY},
        Size = CustomSize(30,100)
      }
      layout[defs.call.." "..i] = {
        PrettyName = prettyPlural.."~Load "..pretty.."~"..pretty.." "..i,
        Style = "Button",
        ButtonStyle = "Trigger",
        ButtonVisualStyle = "Gloss",
        FontSize = 8,
        Position = {CustomPosX(88), TempY},
        Size = CustomSize(12)
      }
    end
    
      LineBreak(1.5)
  end
  LineBreak(-3.5)
  ------
  
end

function BuildCustomPage(pageType)
  AddLogo()
  AddHeader("Custom "..pageType.." Commands")
  LineBreak()
  for i = 1,5 do
    layout[pageType.."Str "..i] = {
      PrettyName = "Custom~"..pageType.."~Command "..i,
      Style="Text",
      Position = {DEFAULT_INPUT_X, TempY},
      Size = CustomSize(80,100),
    }
    layout[pageType.."Btn "..i] = {
      PrettyName = "Custom~"..pageType.."~Send "..i,
      Style="Button",ButtonStyle = "Trigger",
      Legend="SEND",
      Position = {CustomPosX(80), TempY},
      Size = CustomSize(20,100),
    }
    LineBreak(1.2)
    AddSubheading("RESPONSE",0,100)
    LineBreak()
    layout[pageType.."Code "..i] = {
      PrettyName = "Custom~"..pageType.."~Code "..i,
      Style="Text",
      Position = {DEFAULT_INPUT_X, TempY},
      Size = CustomSize(20,100),
    }
    layout[pageType.."Response "..i] = {
      PrettyName = "Custom~"..pageType.."~Response "..i,
      Style="Text",
      Position = {CustomPosX(22), TempY},
      Size = CustomSize(78,100),
    }
    LineBreak(1.5)
  end
end

function ConvertToArray(x)
  t={}
  obj = {}
  x:gsub("{[^{}]*}",function(c) table.insert(t,c) end)
  for k,v in ipairs(t) do
    table.insert(obj,CommaToTable(v))
  end
  return obj
end

function CommaToTable(x)
  t = {}
  str = string.sub(x,2,string.len(x)-1)
  for word in string.gmatch(str, '([^,]+)') do
    table.insert(t,word)
  end
  return t
end


--Connection Setup Page
if CurrentPage == "Setup" then
  AddLogo()
  AddHeader("CONNECTION")
  table.insert(graphics,{
    Type = "Text",
    Text = "Web Address",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = DEFAULT_INPUT_SIZE,
    FontSize = INPUT_SIZE,
  })
  LineBreak()
  layout["WebAddress"] = {
    PrettyName = "ASM Web Address",
    Style = "Text",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = DEFAULT_INPUT_SIZE,
    FontSize = 10,
    StrokeColor = Colors.Yellow
  }
  -- api key input
  LineBreak()
  table.insert(graphics,{
    Type = "Text",
    Text = "API Key",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = DEFAULT_INPUT_SIZE,
    FontSize = LABEL_SIZE,
  })
  LineBreak()
  layout["APIkey"] = {
    PrettyName = "API Key",
    Style = "Text",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = DEFAULT_INPUT_SIZE,
    FontSize = INPUT_SIZE,
    StrokeColor = Colors.Yellow
  }
  LineBreak()
  LineBreak()
  AddHeader("STATUS")
  layout["Status"] = {
    PrettyName="Status",
    Style = "Indicator",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = CustomSize(100,120),
    FontSize = 15
  }
  LineBreak(2)
  AddHeader("Previous Commands (Click to Change)")
  layout['Last_Commands'] = {
    PrettyName="Last Commands",
    Style="ComboBox",
    Position = {DEFAULT_INPUT_X,TempY},
    Size = CustomSize(100),
    StrokeColor = Colors.Yellow
  }
  LineBreak(1.5)
  AddSubheading("COMMAND",0,30)
  AddSubheading("CODE",32,10)
  AddSubheading("ERROR",45,55)
  LineBreak()  
  layout['CalledCommand'] =  {
    PrettyName="Debug~Last Command",
    Style = "TextBox",
    Position = {CustomPosX(0), TempY},
    Size = CustomSize(30)
  }
  layout['ResponseCode'] =  {
    PrettyName="Debug~Last Code",
    Style = "TextBox",
    Position = {CustomPosX(32), TempY},
    Size = CustomSize(10)
  }
  layout['ResponseError'] =  {
    PrettyName="Debug~Last Error",
    Style = "TextBox",
    Position = {CustomPosX(45), TempY},
    Size = CustomSize(55)
  }
  LineBreak(1)
  AddSubheading("LAST URL CALLED",0,100)
  LineBreak()
  layout['ResponseURL'] =  {
    PrettyName="Debug~Last URL",
    Style = "TextBox",
    Position = {DEFAULT_INPUT_X,TempY},
    Size = CustomSize(100),
    WordWrap = true
  }
  LineBreak()
  AddSubheading("RESPONSE DATA",0,100)
  LineBreak()
  layout['ResponseData'] =  {
    PrettyName="Debug~Last Data",
    Style = "TextBox",
    Position = {DEFAULT_INPUT_X,TempY},
    Size = CustomSize(100,600),
    WordWrap = true
  }
  LineBreak(2)
--------------------------------

elseif CurrentPage == "Wall Config" then
  AddLogo()
  AddSubheading("Discovered Walls",0,100)
  layout["GetWalls"] = {PrettyName = "Wall Config~Get Walls",Style="Button",ButtonStyle = "Trigger",Legend = "REFRESH",Position = {CustomPosX(80), TempY},Size = CustomSize(20),}
  LineBreak(1.2)
  layout["AvailableWalls"] = {PrettyName = "Wall Config~Available Walls",Style="ComboBox",StrokeColor = Colors.Yellow,Position = {DEFAULT_INPUT_X, TempY},Size = DEFAULT_INPUT_SIZE,}
  ---
  LineBreak(2)
  AddHeader("WALL DEFINITION")
  AddSubheading("WALL ID",0,45)
  AddSubheading("WALL NAME",55,45)
  LineBreak()
  layout["WallID"] = {
    PrettyName = "Wall Config~Definition~Wall ID",
    Style="Text",
    Position = {DEFAULT_INPUT_X, TempY},
    Size = CustomSize(45,100),
  }
  layout["WallName"] = {
    PrettyName = "Wall Config~Definition~Wall Name",
    Style="Text",
    Position = {CustomPosX(55), TempY},
    Size = CustomSize(45,100),
  }
  LineBreak(1)
  AddSubheading("x",0,20)
  AddSubheading("y",25,20)
  AddSubheading("width",55,20)
  AddSubheading("height",80,20)
  LineBreak()
  layout["Wall_X"] = {PrettyName = "Wall Config~Definition~Wall X",Style="Text",Position = {DEFAULT_INPUT_X, TempY},Size = CustomSize(20,100),}
  layout["Wall_Y"] = {PrettyName = "Wall Config~Definition~Wall Y",Style="Text",Position = {CustomPosX(25), TempY},Size = CustomSize(20,100),}
  layout["Wall_Width"] = {PrettyName = "Wall Config~Definition~Wall Width",Style="Text",Position = {CustomPosX(55), TempY},Size = CustomSize(20,100),}
  layout["Wall_Height"] = {PrettyName = "Wall Config~Definition~Wall Height",Style="Text",Position = {CustomPosX(80), TempY},Size = CustomSize(20,100),}
  LineBreak(2)
  AddSubheading("Select Default ViewScreen:",0,50)
  layout["Wall_VS"] = {
    PrettyName = "Wall Config~Definition~Default ViewScreen",
    Style="ComboBox",
    StrokeColor = Colors.Yellow,
    CornerRadius = 5,
    Position = {CustomPosX(55), TempY},
    Size = CustomSize(20,100),
  }
  layout["ClearVS"] = {
    Style="Button",
    PrettyName = "Wall Config~Clear ViewScreen",
    ButtonStyle = "Trigger",
    CornerRadius = 5,
    StrokeColor = Colors.Red,
    Position =  {CustomPosX(80), TempY},
    Size = CustomSize(20,100),
    Legend = "CLEAR"
  }
  LineBreak(1.5)
  
  AddSubheading("Wall Layouts",0,45)
  AddSubheading("Wall Templates",55,45)
  LineBreak()
  layout["Wall_Layouts"] = {PrettyName = "Wall Config~Available Layouts",Style="ListBox",Position = {DEFAULT_INPUT_X, TempY},Size = CustomSize(45,500),}
  layout["Wall_Templates"] = {
    PrettyName = "Wall Config~Available Templates",
    Style="ListBox",
    Position = {CustomPosX(55), TempY},
    Size = CustomSize(45,500),
  }
  LineBreak(5)
  layout["LoadLayout"] = {PrettyName = "Wall Config~Load Selected Layout",Style="Button",ButtonStyle = "Trigger",Legend = "LOAD SELECTED LAYOUT",Position = {DEFAULT_INPUT_X, TempY},Size = CustomSize(45,100),}
  LineBreak()
  AddHeader("CURRENT CONTENT")
  for i = 1,5 do
    layout["VS_SourceView_Select "..i] = {
      PrettyName = "Wall Config~ViewScreen Select~VS "..i,
      Style="Button",
      ButtonStyle = "Toggle",
      CornerRadius = 5,
      Position = {CustomPosX((i-1)*10), TempY},
      Size = CustomSize(10,100),
    }
  end
  layout['GetWallSources'] = {PrettyName = "Wall Config~Get Wall Content",Style="Button",ButtonStyle="Trigger",Legend = "Refresh",Position = {CustomPosX(80), TempY},Size = CustomSize(20),}
  LineBreak()
  for i = 1,5 do
    layout["LoadedSources "..i] = {
      PrettyName = "Wall Config~Loaded Sources~ViewScreen "..i,
      Style="ListBox",
      Position = {DEFAULT_INPUT_X, TempY},
      Size = CustomSize(100,600),
    }
  end
  LineBreak(2)
elseif CurrentPage == "Layouts" then
  BuildEditPage("Layout")
elseif CurrentPage == "Scripts" then
  BuildEditPage("Script")
elseif CurrentPage == "Sources" then
  BuildEditPage("Source")
end

