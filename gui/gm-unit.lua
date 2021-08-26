-- Interface powered, user friendly, unit editor
--@ module = true

--[====[

gui/gm-unit
===========
An editor for various unit attributes.

]====]
local gui = require 'gui'
local widgets = require 'gui.widgets'
local args = {...}

Editor = defclass(Editor, gui.FramedScreen)
Editor.ATTRS = {
    frame_style = gui.GREY_LINE_FRAME,
    target_unit = DEFAULT_NIL
}

rng = rng or dfhack.random.new(nil, 10)

local target
--TODO: add more ways to guess what unit you want to edit
if args[1] ~= nil then
    target = df.units.find(args[1])
else
    target = dfhack.gui.getSelectedUnit(true)
end

if target == nil then
    qerror("No unit to edit") --TODO: better error message
end
local editors = {}
function add_editor(editor_class)
    local title = editor_class.ATTRS.frame_title
    table.insert(editors, {text=title, search_key=title:lower(), on_submit=function(unit)
        editor_class{target_unit=unit}:show()
    end})
end

function weightedRoll(weightedTable)
  local maxWeight = 0
  for index, result in ipairs(weightedTable) do
    maxWeight = maxWeight + result.weight
  end

  local roll = rng:random(maxWeight) + 1
  local currentNum = roll
  local result

  for index, currentResult in ipairs(weightedTable) do
    currentNum = currentNum - currentResult.weight
    if currentNum <= 0 then
      result = currentResult.id
      break
    end
  end

  return result
end


-------------------------------various subeditors---------
------- skill editor
editor_skills = reqscript("gui/editor_skills")
add_editor(editor_skills.Editor_Skills)

------- civilization editor
editor_civ = reqscript("gui/editor_civilization")
add_editor(editor_civ.Editor_Civ)

------- counters editor
editor_counters = reqscript("gui/editor_counters")
add_editor(editor_counters.Editor_Counters)

------- profession editor
editor_prof = reqscript("gui/editor_profession")
add_editor(editor_prof.Editor_Prof)

------- wounds editor
editor_wounds = reqscript("gui/editor_wounds")
add_editor(editor_wounds.Editor_Wounds)

------- attributes editor
editor_attrs = reqscript("gui/editor_attributes")
add_editor(editor_attrs.Editor_Attrs)

------- orientation editor
editor_orientation = reqscript("gui/editor_orientation")
add_editor(editor_orientation.Editor_Orientation)

------- body / body part editor
editor_body = reqscript("gui/editor_body")
add_editor(editor_body.Editor_Body)

------- colors editor
editor_colors = reqscript("gui/editor_colors")
add_editor(editor_colors.Editor_Colors)

------- beliefs editor
editor_beliefs = reqscript("gui/editor_beliefs")
add_editor(editor_beliefs.Editor_Beliefs)

------- personality editor
editor_personality = reqscript("gui/editor_personality")
add_editor(editor_personality.Editor_Personality)

-------------------------------main window----------------
Editor_Unit = defclass(Editor_Unit, Editor)
Editor_Unit.ATTRS = {
    frame_title = "GameMaster's unit editor"
}

function Editor_Unit:init(args)
    self:addviews{
        widgets.FilteredList{
            frame = {l=1, t=1},
            choices=editors,
            on_submit=function (idx,choice)
                if choice.on_submit then
                    choice.on_submit(self.target_unit)
                end
            end
        },
        widgets.Label{
            frame = { b=0,l=1},
            text = {{
                text = ": exit editor",
                key = "LEAVESCREEN",
                on_activate = self:callback("dismiss")
            }},
        }
    }
end


Editor_Unit{target_unit=target}:show()
