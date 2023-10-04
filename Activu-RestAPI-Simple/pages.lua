local function BuildPageNames()
  pagenames={ "Setup","Wall Config"}
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
for ix,name in ipairs(BuildPageNames()) do
  table.insert(pages, {name = pagenames[ix]})
end