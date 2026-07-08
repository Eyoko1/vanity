--- @class Vanity.Tab : Vanity.Widget
--- @field parent Vanity.Window?
--- @
--- @field name string The name of this tab
--- @field index integer The index of this tab
--- @field accentalpha number The transparency of the accent bar at the top of active tabs - this is used for animations
--- @
--- @field select fun(self: Vanity.Tab): nil
--- @field render fun(self: Vanity.Tab, x: number, y: number, w: number, h: number, style: Vanity.Style): nil
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

    select = function() end,
    render = function() end,
    invalidatelayout = function() end
}

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
        self.activetab = tab
    end

    tab:invalidatelayout()

    return tab
end

function TabMT:select()
    self.parent.activetab = self
end

--> Renders the tab
--- @param parentx number
--- @param parenty number
--- @param parentw number
--- @param parenth number
--- @param style Vanity.Style
--- @return nil
function TabMT:render(parentx, parenty, parentw, parenth, style)
    local inset1 = style.inset_1

    local index = self.index
    local parent = self.parent --- @cast parent -nil
    local name = self.name
    local position = self.position

    local x = parentx + position[1]
    local y = parenty + position[2]

    surface.SetFont(style.text_tab)
    local textwidth, _ = surface.GetTextSize(name)
    local _, textheight = surface.GetTextSize("Hg")
    local w = math.max(textwidth + 20, 50)
    local h = style.tab_height
    local textx = math.floor(x + (w * 0.5) - (textwidth * 0.5) + 0.5)
    local texty = math.floor((y - 3) + (h * 0.5) - (textheight * 0.5) + 1.5)

    if (not vanity.getfocus()) then
        if (vanity.ishovered(x, y, w, h) and vanity.didclick()) then
            vanity.focus(self)
            if (self.parent.activetab ~= self) then
                self:select()
            end
        end
    end

    vanity.setdrawcolor(style.outline_2)
    surface.DrawOutlinedRect(x - 2, y - 5, w + 4, h + 2)

    if (index ~= 1) then
        local yh1 = y + h
        local yh2 = yh1 - 3
        --local yh3 = yh1 - 2

        surface.DrawLine(x - inset1 + 1,  yh2, x - 2, yh2)

        vanity.setdrawcolor(style.outline_1)
        surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)

        --surface.DrawLine(x - inset1, yh3, x - 1, yh3)
    else
        vanity.setdrawcolor(style.outline_1)
        surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)
    end

    if (parent.activetab == self) then
        vanity.setdrawcolor(style.tab_active)
        surface.DrawRect(x, y - 3, w, h + 1)

        --vanity.setdrawcolor(style.background_1)
        --surface.DrawRect(x, y + h - 3, w, 2)

        vanity.drawgradientdown(x, y - 2, w, h, style.gradient)

        surface.SetTextPos(textx, texty)
        vanity.settextcolor(style.text_color)
        surface.DrawText(name)

        self.accentalpha = Lerp(FrameTime() * 16, self.accentalpha, 255)
    else
        vanity.setdrawcolor(style.tab_inactive)
        surface.DrawRect(x, y - 2, w, h)

        surface.SetTextPos(textx, texty)
        vanity.settextcolor(style.text_color_disabled)
        surface.DrawText(name)

        self.accentalpha = Lerp(FrameTime() * 16, self.accentalpha, 0)
    end

    local accentalpha = self.accentalpha
    if (accentalpha >= 1) then
        vanity.setdrawcoloralpha(style.accent, accentalpha)
        surface.DrawRect(x, y - 3, w, 1)
    end
end

--> Invalidates the tab causing it to recalculate some internal values
function TabMT:invalidatelayout()
    self.parent:invalidatelayout()
end