--- @class Vanity.Group : Vanity.Widget
--- @field name string
--- @field groupaccentalpha number
--- @
--- @field addchild fun(self: Vanity.Group, child: Vanity.Widget): nil
--- @field getwidth fun(self: Vanity.Group): number

--- @class Vanity.Group.Data
--- @field name string?

--- @diagnostic disable
--- @type Vanity.Group
local GroupMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    name = "",
    groupaccentalpha = 255,

    addchild = function() end,
    getwidth = function() return 0 end,
    render = function() end,
    invalidatelayout = function() end
}
--- @diagnostic enable
vanity.metatables.group = GroupMT

local TabMT = vanity.metatables.tab

--- @param data Vanity.Group.Data?
--- @return nil
function TabMT:group(data)
    --- @type Vanity.Group
    local group = vanity.inherit(data or {}, GroupMT)
    table.insert(self.children, group)

    group.parent = self
    group:invalidatelayout()
    self:invalidatelayout()
    group:separator()

    return group
end

--- @param child Vanity.Widget
--- @return nil
function GroupMT:addchild(child)
    table.insert(self.children, child)
    self:invalidatelayout()
end

--- @return number
function GroupMT:getwidth()
    return self.size[1] - (vanity.findstyle(self).inset_1 * 2)
end

--- @param parentx number
--- @param parenty number
--- @param parentw number
--- @param parenth number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function GroupMT:render(parentx, parenty, parentw, parenth, parenthovered, style)
    local inset1 = style.inset_1
    local inset2 = style.inset_2
    local parent = self.parent --- @cast parent Vanity.Tab
    local position = self.position
    local size = self.size
    local x = parentx + position[1]
    local y = parenty + position[2]
    local w, h = size[1], size[2]

    vanity.setdrawcolor(style.background_1)
    surface.DrawRect(x, y, w, h)
    vanity.drawgradient(x, y, w, h, style.gradient)

    vanity.setdrawcolor(style.outline_1)
    surface.DrawOutlinedRect(x, y, w, h)

    vanity.setdrawcolor(style.outline_2)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    local hw = w * 0.5
    local accentcenterx = x + hw

    vanity.setdrawcoloralpha(style.accent, math.max(self.groupaccentalpha, 0))
    surface.DrawLine(
        accentcenterx - hw + 2,
        y + 2,
        accentcenterx + hw - 2,
        y + 2
    )
    --[[
    surface.DrawLine(
        x + 2,
        y + 2,
        x + w - 2,
        y + 2
    )
    ]]

    surface.SetFont(style.text_group)
    surface.SetTextPos(x + inset1, y + inset1)
    vanity.settextcolor(style.text_color)
    surface.DrawText(self.name)

    --local childx = x + inset1
    local childy = y + vanity.fontdata(style.text).size + inset1 + inset2
    local hovered = parenthovered and vanity.ishovered(x, y, w, h)
    vanity.pushscissorrect(x, y, x + w, y + h)
    for i, widget in ipairs(self.children) do
        local widgetposition = widget.position
        local widgetsize = widget.size
        local height = widgetsize[2]
        widget:render(x + widgetposition[1], y + widgetposition[2], widgetsize[1], height, hovered, style)
        childy = childy + height + inset2
    end
    vanity.popscissorrect()

    self.groupaccentalpha = Lerp(FrameTime() * style.animation_speed * 0.125, self.groupaccentalpha, 255)
end

--- @return nil
function GroupMT:invalidatelayout()
    local style = vanity.findstyle(self)
    local inset1 = style.inset_1
    local inset2 = style.inset_2

    --- @type Vanity.Widget
    local window = self.parent.parent

    local w = (window.size[1] - (inset1 * 5)) * 0.5
    local h = vanity.fontdata(style.text).size + inset1 + inset2
    
    local childwidth = self:getwidth()

    for i, widget in ipairs(self.children) do
        local widgetposition = widget.position
        local widgetsize = widget.size
        widgetposition[1] = inset1
        widgetposition[2] = h
        widgetsize[1] = childwidth
        h = h + widgetsize[2] + inset2
    end
    self.size = vanity.vector(w, math.max(h - inset2 + inset1, 25))
end