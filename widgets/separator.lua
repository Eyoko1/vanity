--- @class Vanity.Separator : Vanity.Widget

--- @type Vanity.Separator
local SeparatorMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 3),

    render = function() end,
    invalidatelayout = function() end
}

local GroupMT = vanity.metatables.group

--- @return Vanity.Separator
function GroupMT:separator()
    local separator = vanity.inherit({}, SeparatorMT)
    self:addchild(separator)

    separator.parent = self
    separator:invalidatelayout()

    return separator
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function SeparatorMT:render(x, y, w, h, parenthovered, style)
    vanity.setdrawcolor(style.outline_1)
    surface.DrawRect(x + 1, y + 1, w - 1, 1)

    vanity.setdrawcolor(style.outline_2)
    surface.DrawOutlinedRect(x, y, w, h)
end

--- @return nil
function SeparatorMT:invalidatelayout()
    self.parent:invalidatelayout()
end