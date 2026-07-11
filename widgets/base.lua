--> This file's only purpose is to be copied and pasted into new widget files to save time
--> This should not be included in main.lua

--- @class Vanity.Base : Vanity.Widget

--- @class Vanity.Group
--- @field base fun(self: Vanity.Group): Vanity.Base

--- @type Vanity.Base
local BaseMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    render = function() end,
    invalidatelayout = function() end
}

local GroupMT = vanity.metatables.group

--- @return Vanity.Base
function GroupMT:base()
    local base = vanity.inherit({}, BaseMT)
    self:addchild(base)

    base.parent = self
    base:invalidatelayout()
    self:invalidatelayout()

    return base
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function BaseMT:render(x, y, w, h, parenthovered, style)

end

--- @return nil
function BaseMT:invalidatelayout()
    
end