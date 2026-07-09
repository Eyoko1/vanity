--- @TODO: Allow for markup

--- @class Vanity.Label : Vanity.Widget
--- @field parent Vanity.Group?
--- @
--- @field disable fun(self: Vanity.Label): nil
--- @field enable fun(self: Vanity.Label): nil

--- @class Vanity.LabelData
--- @field text string?
--- @field disabled boolean?

--- @type Vanity.Label
local LabelMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 3),

    text = "",
    blocks = {},
    disabled = false,

    disable = function() end,
    enable = function() end,
    render = function() end,
    invalidatelayout = function() end
}

local GroupMT = vanity.metatables.group

--- @param data Vanity.LabelData?
--- @return Vanity.Label
function GroupMT:label(data)
    local label = vanity.inherit(data or {}, LabelMT)
    self:addchild(label)

    label.parent = self
    label:invalidatelayout()

    return label
end

function LabelMT:disable()
    self.disabled = true
end

function LabelMT:enable()
    self.disabled = false
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function LabelMT:render(x, y, w, h, parenthovered, style)
    vanity.settextcolor(style.text_color)
    surface.SetFont(style.text)
    surface.SetTextPos(x, y)
    surface.DrawText(self.text)
end

--- @return nil
function LabelMT:invalidatelayout()
    surface.SetFont(vanity.findstyle(self).text)
    local textwidth, textheight = surface.GetTextSize(self.text)
    --- @type Vanity.Group
    local parent = self.parent
    local width = parent:getwidth()
    local text = self.text
    local blocks = self.blocks
    local nextnewline = string.find(text, "\n")

    if (not nextnewline and textwidth <= width) then
        --> We can cleanly fit the text on one line
        self.size[2] = textheight
        table.insert(blocks, text)
    else
        --> We are going to need to split this text across lines
    end

    parent:invalidatelayout()

    lje.con_printf("%s", self.size[2])
end