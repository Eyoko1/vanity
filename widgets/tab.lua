--- @class Vanity.Tab : Vanity.Widget
--- @field parent Vanity.Window?
--- @field children Vanity.Group[]
--- @
--- @field name string The name of this tab
--- @field index integer The index of this tab
--- @field accentalpha number The transparency of the accent bar at the top of active tabs - this is used for animations
--- @field accentprogress number
--- @
--- @field group fun(self: Vanity.Tab, data: Vanity.GroupData?): Vanity.Group
--- @field select fun(self: Vanity.Tab): nil
--- @field render Vanity.RenderFunction
--- @field invalidatelayout fun(self: Vanity.Tab): nil

--- @class Vanity.TabData
--- @field name string?

--- @type Vanity.Tab
local TabMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    name = "",
    index = 1,
    accentalpha = 0,
    accentprogress = 0,

    group = function() return {} end,
    select = function() end,
    render = function() end,
    invalidatelayout = function() end
}
vanity.metatables.tab = TabMT

local WindowMT = vanity.metatables.window

--- @param data Vanity.TabData
--- @return Vanity.Tab
function WindowMT:tab(data)
    --- @type Vanity.Tab
    local tab = vanity.inherit(data or {}, TabMT)

    local children = self.children
    local index = #children + 1

    tab.parent = self
    tab.children = tab.children or {}
    tab.index = index

    children[index] = tab

    if (index == 1) then
        tab:select()
        tab.accentprogress = 1
        tab.accentalpha = 255
    end

    tab:invalidatelayout()

    return tab
end

function TabMT:select()
    self.parent.activetab = self
    self.accentprogress = 0
end

--> Renders the tab
--- @param parentx number
--- @param parenty number
--- @param parentw number
--- @param parenth number
--- @param style Vanity.Style
--- @param parenthovered boolean
--- @return nil
function TabMT:render(parentx, parenty, parentw, parenth, parenthovered, style)
    --local inset1 = style.inset_1

    --local index = self.index
    local parent = self.parent --- @cast parent -nil
    local name = self.name
    local position = self.position

    local x = parentx + position[1]
    local y = parenty + position[2] + 2

    surface.SetFont(style.text_tab)
    local textwidth, _ = surface.GetTextSize(name)
    local _, textheight = surface.GetTextSize("Hg")
    local w = math.max(textwidth + 20, 50)
    local h = style.tab_height
    local textx = math.floor(x + (w * 0.5) - (textwidth * 0.5) + 0.5)
    local texty = math.floor((y - 3) + (h * 0.5) - (textheight * 0.5) + 1.5)

    --> Handle input
    if (not vanity.getfocus()) then
        if (vanity.ishovered(x, y, w, h) and vanity.didclick()) then
            vanity.focus(self)
            if (self.parent.activetab ~= self) then
                self:select()
            end
        end
    end

    --> Draw the secondary outline
    vanity.setdrawcolor(style.outline_2)
    surface.DrawOutlinedRect(x - 2, y - 5, w + 4, h + 2)

    --[[
    if (index ~= 1) then
        local yh = y + h - 3
        surface.DrawLine(x - inset1 + 1,  yh, x - 2, yh)
    end
    ]]

    --> Draw the primary outline
    vanity.setdrawcolor(style.outline_1)
    surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)

    local lerptarget
    if (parent.activetab == self) then
        --> Draw the background for this tab and remove the line below it
        vanity.setdrawcolor(style.tab_active)
        surface.DrawRect(x, y - 4, w, h + 2)

        --> Draw the gradient overlay
        vanity.drawgradientdown(x, y - 2, w, h, style.gradient)

        --> Draw the name
        surface.SetTextPos(textx, texty)
        vanity.settextcolor(style.text_color)
        surface.DrawText(name)

        local hovered = parenthovered and vanity.ishovered(x, y, parent.sectionstart, parent.sectionend - parent.sectionstart)
        for i, group in ipairs(self.children) do
            --- @cast group Vanity.Group
            group:render(x, y, w, h, hovered, style)
        end

        lerptarget = 1
    else
        --> Draw the background for this tab without removing the line below it
        vanity.setdrawcolor(style.tab_inactive)
        surface.DrawRect(x, y - 3, w, h + 1)

        --> Draw the name
        surface.SetTextPos(textx, texty)
        vanity.settextcolor(style.text_color_disabled)
        surface.DrawText(name)

        lerptarget = 0
    end

    local frametime = FrameTime()
    local accentalpha = Lerp(frametime * style.animation_speed, self.accentalpha, lerptarget * 255)
    self.accentalpha = accentalpha
    self.accentprogress = Lerp(frametime * style.animation_speed * 0.75, self.accentprogress, lerptarget)

    --> Draw the accent above the tab
    if (accentalpha >= 1) then
        vanity.setdrawcoloralpha(style.accent, accentalpha)
        surface.DrawRect(x, y - 4, w, 1)
    end
end

--> Invalidates the tab causing it to recalculate some internal values
function TabMT:invalidatelayout()
    local style = vanity.findstyle(self)
    local inset1 = style.inset_1

    --> Re-calculate group positions
    --- @type Vanity.Window
    local parent = self.parent
    local leftx = inset1
    local leftheight = parent.sectionend - parent.sectionstart - (inset1 * 2)
    local rightx = (inset1 * 2) + (parent.size[1] - (inset1 * 5)) * 0.5
    local rightheight = leftheight
    local originy = leftheight + style.tab_height + inset1

    for i, group in ipairs(self.children) do
        local groupposition = group.position
        local widgetheight = group.size[2]
        if (widgetheight <= leftheight) then
            groupposition[1] = leftx
            groupposition[2] = originy - leftheight
            leftheight = leftheight - widgetheight - inset1
        elseif (widgetheight <= rightheight) then
            groupposition[1] = rightx
            groupposition[2] = originy - rightheight
            rightheight = rightheight - widgetheight - inset1
        else
            --- @TODO: Handle overflowing by adding a property to windows called overflowsize, and then adding that to the actual size
            lje.con_printf("Window '%s' has overflowed as it's size is too small!", self.parent.name)
        end
    end

    self.parent:invalidatelayout()
end