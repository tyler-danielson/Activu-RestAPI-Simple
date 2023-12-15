local pages = {"Layout","Script","Source"}

pageDefs = {}

for i = 1, #pages do
  local type = pages[i]
  pageDefs[type] = {
    pretty = type,
    edit = type.."_Edit",
    heading1 = type.." DEFINITION",
    heading2 = "DEFINE "..type.."s",
    callDef = type.."_CallDefinition",
    preview = {
      name = type.."_Preview",
      type = "none"
    },
    get = "Get"..type,
    call = type.."_Call",
    id = type.."_ID",
    legend = type.."_Legend",
    uciDefined = type.."_uciDefined",
    layoutDefs = {
      uciOption = true
    },
    remove = "Remove_"..type,
    region = {
      x = type..'_x',
      y = type..'_y',
      width = type..'_width',
      height = type..'_height',
    },
    triggerAll = "Trigger_"..type
  }
end

pageDefs.Layout.preview.type = "image"
pageDefs.Source.layoutDefs.uciOption = false
