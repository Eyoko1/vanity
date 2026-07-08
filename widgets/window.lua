--- @class Vanity.Window : Vanity.Widget
--- @field style Vanity.Style The style used by this window
--- @field name string The name of this window
--- @field hidden boolean Whether or not this window is hidden (does not draw)
--- @field activetab Vanity.Tab? The tab which is currently active, or nil if this window has no tabs
--- @field titleheight number The height of this window's title
--- @field sectionstart number The y coordinate where the main section begins
--- @field sectionend number The y coordinate where the main section ends
--- @field dragging boolean Whether or not the user is dragging this window
--- @field dragx number The offset on the y axis for dragging
--- @field dragy number The offset on the x axis for dragging
--- @field toplinex number
--- @
--- @field tab fun(self: Vanity.Window, data: Vanity.TabData): Vanity.Tab
--- @field render fun(self: Vanity.Window): nil
--- @field invalidatelayout fun(self: Vanity.Window): nil

--- @class Vanity.WindowData
--- @field name string?
--- @field hidden boolean?
--- @field style Vanity.Style?
--- @field position Vanity.Vector?
--- @field size Vanity.Vector?

--- @type Vanity.Window
local WindowMT = {
    parent = nil,
    children = {},
    position = vanity.vector(ScrW() * 0.5 - 250, ScrH() * 0.5 - 300),
    size = vanity.vector(500, 600),

    style = vanity.style(),
    name = "",
    hidden = false,
    activetab = nil,
    titleheight = 0,
    sectionstart = 0,
    sectionend = 0,
    dragging = false,
    dragx = 0,
    dragy = 0,
    toplinex = 0,

    tab = function() end, --- @diagnostic disable-line
    render = function() end,
    invalidatelayout = function() end
}
vanity.metatables.window = WindowMT

--> Creates a window with the given data
--- @param data Vanity.WindowData?
--- @return Vanity.Window
function vanity.window(data)
    --- @type Vanity.Window
    local window = vanity.inherit(data or {}, WindowMT)
    table.insert(vanity.windowlist, window)

    window:invalidatelayout()

    return window
end

--> Renders the window
function WindowMT:render()
    if (self.hidden) then
        return
    end

    local style = self.style
    local name = self.name
    local position = self.position
    local size = self.size
    local children = self.children
    local activetab = self.activetab

    local inset1 = style.inset_1

    local x, y = position[1], position[2]
    local w, h = size[1], size[2]

    local hovered = vanity.ishovered(x, y, w, h)

    vanity.setdrawcolor(style.accent)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    vanity.setdrawcolor(style.background_1)
    surface.DrawRect(x, y, w, h)

    vanity.drawgradient(x, y, w, h, style.gradient)

    surface.SetFont(style.text)
    surface.SetTextPos(x + inset1, y + inset1)
    vanity.settextcolor(style.text_color)
    surface.DrawText(name)

    if (activetab) then
        local _, textheight = surface.GetTextSize(self.name)
        local tabstartx = x + inset1 - 1 --> Good
        local sectionwidth = w - (inset1 * 2) --> Good
        local sectionheight = h - textheight - style.tab_height - (inset1 * 3) + 3
        local sectionstart = y + textheight + (inset1 * 2) + style.tab_height - 2
        local sectionend = sectionstart + sectionheight

        self.titleheight = textheight
        self.sectionstart = sectionstart
        self.sectionend = sectionend

        vanity.setdrawcolor(style.outline_2)
        surface.DrawOutlinedRect(
            tabstartx - 1,
            sectionstart - 1,
            sectionwidth + 2,
            sectionheight + 2
        )

        vanity.setdrawcolor(style.outline_1)
        surface.DrawLine(
            tabstartx,
            sectionend - 1,
            tabstartx + sectionwidth,
            sectionend - 1
        )
        surface.DrawLine(
            tabstartx,
            sectionstart,
            tabstartx,
            sectionend
        )
        surface.DrawLine(
            tabstartx + sectionwidth - 1,
            sectionstart,
            tabstartx + sectionwidth - 1,
            sectionend
        )

        local toplinex = Lerp(FrameTime() * 10, self.toplinex, activetab.position[1])
        self.toplinex = toplinex

        local tl1 = tabstartx + 1
        surface.DrawLine(
            tl1,
            sectionstart,
            x + toplinex,
            sectionstart
        )
        local tl2 = tabstartx + sectionwidth - 1
        surface.DrawLine(
            x + toplinex + activetab.size[1],
            sectionstart,
            tl2,
            sectionstart
        )

        --> Draw the tabs (and their contents)
        for i, v in ipairs(children) do
            v:render(x, y, w, h, style, hovered)
        end
    end

    --> Handle dragging
    if (self.dragging) then
        if (vanity.mousedown()) then
            local mousex, mousey = vanity.mousepos()
            x = mousex - self.dragx
            y = mousey - self.dragy
            position[1] = x
            position[2] = y
        else
            self.dragging = false
        end
    else
        --> If there is no other focused element, and the user clicked, and this window is hovered then let's allow dragging
        if (not vanity.getfocus() and vanity.didclick() and vanity.ishovered(x, y, w, h)) then
            local mousex, mousey = vanity.mousepos()
            self.dragx = mousex - x
            self.dragy = mousey - y
            self.dragging = true
            vanity.focus(self)
        end
    end
end

--> Invalidates the window's layout, causing it to recalculate some internal values
function WindowMT:invalidatelayout()
    local style = self.style
    local inset1 = style.inset_1
    local tabs = self.children
    local activetab = self.activetab
    local cumulativex = inset1

    surface.SetFont(self.style.text)

    local _, height = surface.GetTextSize(self.name)
    local taby = self.position[2] + height + (inset1 * 2) - 2
    
    self.titleheight = height
    self.sectionstart = taby + style.tab_height - 1
    self.sectionend = self.sectionstart + self.size[2] - 65

    surface.SetFont(style.text_tab)

    local tabheight = height + (inset1 * 2)
    for i, tab in ipairs(tabs) do
        --- @cast tab Vanity.Tab
        local w, _ = surface.GetTextSize(tab.name)
        w = math.max(w + 20, 50)
        tab.position[1] = cumulativex
        tab.position[2] = tabheight
        tab.size[1] = w
        tab.size[2] = style.tab_height
        cumulativex = cumulativex + w + inset1
    end

    if (activetab) then
        self.toplinex = activetab.position[1]
    end
end