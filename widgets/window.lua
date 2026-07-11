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
--- @field dragvx number The x velocity of the window after the user has released their mouse when dragging it
--- @field dragvy number The y velocity of the window after the user has released their mouse when dragging it
--- @field toplinelx number The relative x offset for the left side of the line below the tabs - used for animations
--- @field toplinerx number The relative x offset for the right side of the line below the tabs - used for animations
--- @
--- @field tab fun(self: Vanity.Window, data: Vanity.Tab.Data): Vanity.Tab
--- @field render fun(self: Vanity.Window): nil
--- @field invalidatelayout fun(self: Vanity.Window): nil

--- @class Vanity.Window.Data
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
    dragvx = 0,
    dragvy = 0,
    toplinelx = 0,
    toplinerx = 0,

    tab = function() end, --- @diagnostic disable-line
    render = function() end,
    invalidatelayout = function() end
}
vanity.metatables.window = WindowMT

--> Creates a window with the given data
--- @param data Vanity.Window.Data?
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

    local x, y = position:floor()
    local w, h = size[1], size[2]

    local hovered = vanity.ishovered(x, y, w, h)

    --> Draw the accent outline around the window
    vanity.setdrawcolor(style.accent)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    --> Draw the window's background
    vanity.setdrawcolor(style.background_1)
    surface.DrawRect(x, y, w, h)

    local tilematerial = style.background_tile_material
    if (tilematerial) then
        local tilesize = style.background_tile_size
        surface.SetMaterial(tilematerial)
        vanity.setdrawcolor(style.background_tile_color)
        surface.DrawTexturedRectUV(x, y, w, h, 0, 0, w / tilesize, h / tilesize)
        draw.NoTexture()
    end

    --> Draw the gradient overlay
    vanity.drawgradient(x, y, w, h, style.gradient)

    --> Draw the name of the window
    surface.SetFont(style.text)
    surface.SetTextPos(x + inset1, y + inset1)
    vanity.settextcolor(style.text_color)
    surface.DrawText(name)

    if (activetab) then
        local _, textheight = surface.GetTextSize(self.name)
        local tabstartx = x + inset1 - 1
        local sectionwidth = w - (inset1 * 2)
        local sectionheight = h - textheight - style.tab_height - (inset1 * 3) + 3
        local sectionstart = y + textheight + (inset1 * 2) + style.tab_height
        local sectionend = sectionstart + sectionheight - 2

        self.titleheight = textheight
        self.sectionstart = sectionstart
        self.sectionend = sectionend

        --> Draw the secondary outline
        vanity.setdrawcolor(style.outline_2)
        surface.DrawOutlinedRect(
            tabstartx - 1,
            sectionstart - 1,
            sectionwidth + 2,
            sectionheight
        )

        --> Draw the primary outline
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

        --> Draw the lines at the top with animations
        local activetabx = activetab.position[1]
        local time = FrameTime() * style.animation_speed
        local toplinelx = Lerp(time, self.toplinelx, activetabx)
        local toplinerx = Lerp(time, self.toplinerx, activetabx + activetab.size[1])
        self.toplinelx = toplinelx
        self.toplinerx = toplinerx

        local tl1 = tabstartx + 1
        surface.DrawLine(
            tl1,
            sectionstart,
            x + math.floor(toplinelx) + 1,
            sectionstart
        )
        local tl2 = tabstartx + sectionwidth - 1
        surface.DrawLine(
            x + math.floor(toplinerx) + 1,
            sectionstart,
            tl2,
            sectionstart
        )

        --> Draw the tabs (and their contents)
        for i, v in ipairs(children) do
            v:render(x, y, w, h, hovered, style)
        end
    end

    --> Handle dragging
    local rx, ry = position:raw()
    if (self.dragging) then
        local mousex, mousey = vanity.mousepos()
        if (vanity.mousedown() and not (mousex == 0 and mousey == 0)) then
            --> Move the window towards the user's mouse
            local time = FrameTime() * 30
            position[1] = Lerp(time, rx, mousex - self.dragx)
            position[2] = Lerp(time, ry, mousey - self.dragy)
        else
            --> The user has stopped dragging so let's give the window some velocity depending on how fast they are moving their mouse
            self.dragging = false

            local time = FrameTime() * 5
            self.dragvx = (mousex - self.dragx - rx) * time
            self.dragvy = (mousey - self.dragy - ry) * time
        end
    else
        --> If there is no other focused element, and the user clicked, and this window is hovered then let's allow dragging
        if (not vanity.getfocus() and vanity.didclick() and vanity.ishovered(x, y, w, h)) then
            --> Allow dragging
            local mousex, mousey = vanity.mousepos()
            self.dragx = mousex - rx
            self.dragy = mousey - ry
            self.dragging = true
            self.dragvx = 0
            self.dragvy = 0
            vanity.focus(self)
        else
            --> Apply the velocity
            local time = 1 - (FrameTime() * 10)
            local dragvx, dragvy = self.dragvx, self.dragvy
            position[1] = rx + dragvx
            position[2] = ry + dragvy
            self.dragvx = dragvx * time
            self.dragvy = dragvy * time
        end
    end
end

--> Invalidates the window's layout, causing it to recalculate some internal values
function WindowMT:invalidatelayout()
    local style = self.style
    local inset1 = style.inset_1
    local styletabheight = style.tab_height

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
        local position = tab.position
        local size = tab.size

        --- @cast tab Vanity.Tab
        local w, _ = surface.GetTextSize(tab.name)
        w = math.max(w + 20, 50)

        position[1] = cumulativex
        position[2] = tabheight
        size[1] = w
        size[2] = styletabheight
        cumulativex = cumulativex + w + inset1
    end

    if (activetab) then
        self.toplinelx = activetab.position[1]
        self.toplinerx = activetab.position[1] + activetab.size[1]
    end
end