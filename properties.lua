SIMPLE_COMMANDS = {'Layout','Script','Source'}
props={}

for k,type in ipairs(SIMPLE_COMMANDS) do
  table.insert(props,{Name = "Number of "..type.."s",Type = "integer",Min = 2,Max = 25,Value = 5})
  table.insert(props,{Name = type.." Load Timeout",Type = "integer",Min = 1,Max = 30,Value = 3})
end

table.insert(props,{Name ="Debug Print",Type = "enum", Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},Value = "None"})
