local vanity = vanity

local windowmt = {
    name = "Window",
    hidden = false,
    tabs = {},
    activetab = nil,

    position = vanity.vector(2, 2),
    size = vanity.vector(500, 600),
    __titleheight = 0,
    __tabx = 0
}

windowmt.__index = windowmt
vanity.metatables.window = windowmt
lje.env.auth_metatable(windowmt)

--- Adds a new tab to a window.
--- @param data table
--- @return data table
function windowmt:tab(data)
    local tab = setmetatable(data or {}, vanity.metatables.tab)
    local index = #self.tabs + 1
    tab.parent = self
    tab.index = index
    tab.children = tab.children or {}

    self.tabs[index] = tab

    if (index == 1) then
        self.activetab = tab
    end

    return tab
end

--- Hides the window.
function windowmt:hide()
    self.hidden = true
end

--- Shows the window.
function windowmt:show()
    self.hidden = false
end

--- Toggles the visibility of window.
function windowmt:togglehidden()
    self.hidden = not self.hidden
end

--- Renders the window.
function windowmt:__render()
    if (self.hidden) then
        return
    end

    local style = vanity.style

    local position = self.position
    local size = self.size
    local name = self.name

    local x, y = position[1], position[2]
    local w, h = size[1], size[2]

    -- draw the black outline around the window
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)

    -- draw the accented outline around the window
    vanity.__setdrawcolor(style.accent)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    -- draw the entire window background
    vanity.__setdrawcolor(style.background1)
    surface.DrawRect(x, y, w, h)

    -- draw the menu text in top left corner
    surface.SetFont(style.text)
    surface.SetTextPos(x + style.inset1, y + style.inset1)
    vanity.__settextcolor(style.textcolor)
    surface.DrawText(name)

    -- draw the outline around the main area
    if #self.tabs > 0 then
        local tabStartX = x + style.inset1 - 1
        local tabY = y + self.__titleheight + (style.inset1 * 2) - 2
        
        vanity.__setdrawcolor(style.outline1)
        surface.DrawOutlinedRect(tabStartX, tabY + style.tabheight - 1, w - 15, h - 65)
        
        vanity.__setdrawcolor(style.outline2)
        surface.DrawOutlinedRect(tabStartX - 1, tabY + style.tabheight - 2, w - 13, h - 63)

        --- @TODO: make sure that this main area has some sort of "clipping"


    end

    if self.activetab then
        --- @TODO: Render widgets here!
        --- @TODO: Remember to layout them properly inside main content area.
        vanity.__drawchildren(self.activetab.children, self)
    end

    -- draw the tabs
    local _, th = surface.GetTextSize(name)
    self.__titleheight = th
    self.__tabx = 0
    vanity.__drawchildren(self.tabs, self)
end

local dragging = false
local dragtarget = nil
local dragx = 0
local dragy = 0
function windowmt:__checkinput()
    if (self.hidden) then
        return
    end

    local position = self.position
    local x, y = position[1], position[2]
    if (dragging and dragtarget == self) then
        if (vanity.mousedown()) then
            local mx, my = vanity.mousepos()
            position[1] = mx - dragx
            position[2] = my - dragy
            return true
        else
            dragging = false
        end
    end

    local size = self.size
    if (vanity.ishovered(x, y, size[1], size[2])) then
        --- @TODO: Implement __checkinput on other widgets and check them
        if (vanity.__checkchildreninput(self.tabs)) then
            dragging = false
            return true
        else
            if (vanity.didclick()) then
                local mx, my = vanity.mousepos()
                dragx = mx - x
                dragy = my - y
                dragging = true
                dragtarget = self
                return true
            end
        end
    end
end

--- Creates a new window.
--- @param data table Window data
--- @return data table
function vanity:new(data)
    local window = setmetatable(data or {}, windowmt)
    vanity.windows[#vanity.windows + 1] = window

    return window
end