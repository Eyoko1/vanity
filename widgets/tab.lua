--- A tab is a small button widget featured under the menu name. 
local vanity = vanity

local tabmt = {
    name = "Tab",
    parent = nil,
    children = {},
    index = 1
}
tabmt.__index = tabmt
vanity.metatables.tab = tabmt
lje.env.auth_metatable(tabmt)

--- Marks the tab as active.
function tabmt:select()
    self.window.activetab = self
end

-- Internal function used to add a widget to this specific tab - you do not need to manually call this
function tabmt:__addchild(widget)
    local children = self.children
    children[#children + 1] = widget
end

-- Internal function used to render the tab widget - you do not need to manually call this
function tabmt:__render(px, py, pw, ph)
    local style = vanity.style
    local inset1 = style.inset1
    local inset2 = style.inset2

    local index = self.index
    local parent = self.parent
    local name = self.name

    local x = px + (inset1 * index) + parent.__tabx
    local y = py + parent.__titleheight + (inset1 * 2)

    surface.SetFont(style.tabtext)
    local w, h = surface.GetTextSize(name)
    w = math.max(w + 20, 50)
    h = style.tabheight

    local notone = index ~= 1

    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x - 2, y - 5, w + 4, h + 2)

    if (notone) then
        local yh = (y + h) - 4
        surface.DrawLine(x - inset1 + 1, yh, x - 2, yh)
    end

    -- Draw the "main outline" around tabs
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)

    -- Draw the line between buttons
    if (notone) then
        local yh = (y + h) - 3
        surface.DrawLine(x - inset1, yh, x - 1, yh)
    end

    vanity.__setdrawcolor(style.background1)

    -- Draw the background behind button
    if (parent.activetab == self) then
        surface.DrawRect(x, y - 3, w, h + 1)
        -- Draw the active line on top of the button
        vanity.__setdrawcolor(parent.accent)
        surface.DrawRect(x, y - 3, w, 1)
    else
        surface.DrawRect(x, y - 3, w, h)
    end

    parent.__tabx = parent.__tabx + w
    
    -- Render the text
    surface.SetTextPos(x + 10, y + 4)
    vanity.__settextcolor(style.textcolor)
    surface.DrawText(name)
end