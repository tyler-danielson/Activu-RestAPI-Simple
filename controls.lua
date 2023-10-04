SIMPLE_COMMANDS = {'Layout','Script','Source'}--,'Source'}

controls ={
  {Name = "WebAddress",ControlType = "Text",UserPin=true,PinStyle="Both"},
  {Name = "APIkey",ControlType = "Text",UserPin=true,PinStyle="Both"},
  {Name= "GetWalls", ControlType="Button",ButtonType="Trigger",Count=1,UserPin=true,PinStyle="Both"},
  {Name= "GetGroups",ControlType="Button",ButtonType="Trigger",UserPin=true,PinStyle="Both"},
  {Name= "LayoutSourceListTemp", ControlType="Text",TextBoxType="ComboBox",Count=1,UserPin=true,PinStyle="Both"},
  {Name= "AvailableWalls",ControlType="Text",TextBoxType="ComboBox",Count=1,UserPin=true,PinStyle="Both"},
  {Name= "WallName",ControlType = "Text"},
  {Name= "WallID",ControlType = "Text"},
  {Name= "Wall_X",ControlType="Knob",ControlUnit="Integer",Min=0,Max=23040},
  {Name= "Wall_Y",ControlType="Knob",ControlUnit="Integer",Min=0,Max=6480},
  {Name= "Wall_Width",ControlType="Knob",ControlUnit="Integer",Min=1,Max=23040},
  {Name= "Wall_Height",ControlType="Knob",ControlUnit="Integer",Min=1,Max=6480},
  {Name= "Wall_VS",ControlType="Text",TextBoxType="ComboBox",Count=1,UserPin=true,PinStyle="Both"},
  {Name= "Wall_Layouts",ControlType="Text",TextBoxType="ComboBox",Count=1,UserPin=true,PinStyle="Both"},
  {Name= "Wall_Templates",ControlType="Text",TextBoxType="ComboBox",UserPin=true,PinStyle="Both"},
  {Name= "LoadedSources",ControlType="Text",TextBoxType="ComboBox",Count=5,UserPin=true,PinStyle="Output"},
  {Name= "VS_SourceView_Select",ControlType="Button",ButtonType="Toggle",Count=5,UserPin=true,PinStyle="Output"},
  {Name= "ClearVS",ControlType="Button",ButtonType="Trigger",UserPin=true,PinStyle="both"},
  {Name= "LoadLayout", ControlType="Button",ButtonType="Trigger",Count=1,UserPin=true,PinStyle="Both"},
  {Name="GetWallSources",ControlType="Button",ButtonType="Trigger",UserPin=true,PinStyle="Both"},
  {Name ="btnClear",ControlType="Button",ButtonType="Trigger",UserPin=true,PinStyle="Both"},
  {Name ="btnModeToggle",ControlType="Button",ButtonType="Toggle",UserPin=true,PinStyle="Both"},
  {Name= "Last_Commands",ControlType="Text",TextBoxType="ListBox",UserPin=true,PinStyle="Output"},
  {Name="ResponseBody",ControlType="Text",UserPin=true,PinStyle="Output"},
  {Name = "Status",ControlType = "Indicator",IndicatorType = "Status",PinStyle = "Output",UserPin = true}
}


for k,type in ipairs(SIMPLE_COMMANDS) do
  local qty = props["Number of "..type.."s"].Value
  table.insert(controls,{Name= pageDefs[type].edit, ControlType="Button",ButtonType="Toggle",Count=qty})
  table.insert(controls,{Name= pageDefs[type].legend, ControlType="Text",Count=qty})
  table.insert(controls,{Name= pageDefs[type].uciDefined, ControlType="Button",ButtonType="Toggle",Count=qty})
  table.insert(controls,{Name= pageDefs[type].call, ControlType="Button",ButtonType="Trigger",Count=qty,UserPin=true,PinStyle="Both"})
  table.insert(controls,{Name= pageDefs[type].remove, ControlType="Button",ButtonType="Trigger",Count=qty,UserPin=true,PinStyle="Both"})
  table.insert(controls,{Name= pageDefs[type].region.x, ControlType="Knob",ControlUnit="Integer",Min=0,Max=23040,Count=qty})
  table.insert(controls,{Name= pageDefs[type].region.y, ControlType="Knob",ControlUnit="Integer",Min=0,Max=6480,Count=qty})
  table.insert(controls,{Name= pageDefs[type].region.width,ControlType="Knob",ControlUnit="Integer",Min=0,Max=23040,Count=qty})
  table.insert(controls,{Name= pageDefs[type].region.height, ControlType="Knob",ControlUnit="Integer",Min=0,Max=6480,Count=qty})
  table.insert(controls,{Name= pageDefs[type].callDef, ControlType="Text",TextBoxType="ComboBox",Count=qty,UserPin=true,PinStyle="Both"})
  table.insert(controls,{Name= pageDefs[type].id, ControlType="Text",Count=qty,UserPin=true,PinStyle="Output"})
  table.insert(controls,{Name= pageDefs[type].preview.name,ControlType="Button",ButtonType="Toggle",Count=1,UserPin=false})
  table.insert(controls,{Name= pageDefs[type].get, ControlType="Button",ButtonType="Trigger",Count=1,UserPin=true,PinStyle="Both"})
  table.insert(controls,{Name= pageDefs[type].triggerAll, ControlType="Button",ButtonType="Trigger",Count=1,UserPin=true,PinStyle="Output"})
end
