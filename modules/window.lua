local vanity = vanity

local windowmt = {
    name = "Window",
    hidden = false,
    tabs = {},

    position = vanity.vector(2, 2),
    size = vanity.vector(500, 600),
    accent = vanity.color(92, 122, 219, 255),
}
windowmt.__index = windowmt
vanity.metatables.window = windowmt
lje.env.auth_metatable(windowmt)

function windowmt:tab(data)
    local tab = setmetatable(data or {}, vanity.metatables.tab)
    tab.window = self

    self.tabs[#self.tabs + 1] = tab

    return tab
end

function windowmt:hide()
    self.hidden = true
end

function windowmt:show()
    self.hidden = false
end

function windowmt:togglehidden()
    self.hidden = not self.hidden
end

function windowmt:__render()
    local style = vanity.style

    local position = self.position
    local size = self.size

    local x, y = position[1], position[2]
    local w, h = size[1], size[2]

    vanity.__setcolor(style.outline2)
    surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)

    vanity.__setcolor(self.accent)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    vanity.__setcolor(style.background1)
    surface.DrawRect(x, y, w, h)

    surface.SetTextPos(x + style.inset1, y + style.inset1)
    surface.SetTextColor(style.textcolor)
    surface.DrawText(self.name)

    vanity.__drawchildren(self.tabs)
end

function vanity:new(data)
    local window = setmetatable(data or {}, windowmt)
    vanity.windows[#vanity.windows + 1] = window

    return window
end