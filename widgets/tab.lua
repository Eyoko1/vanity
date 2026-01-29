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
        local yh1 = y + h
        
        local yh2 = yh1 - 4
        surface.DrawLine(x - inset1 + 1, yh2, x - 2, yh2)

        -- Draw the "main outline" around tabs
        vanity.__setdrawcolor(style.outline1)
        surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)

        -- Draw the line between buttons
        local yh3 = yh1 - 3
        surface.DrawLine(x - inset1, yh3, x - 1, yh3)
    else
        -- Draw the "main outline" around tabs
        vanity.__setdrawcolor(style.outline1)
        surface.DrawOutlinedRect(x - 1, y - 4, w + 2, h + 2)
    end

    -- Draw the background behind button
    vanity.__setdrawcolor(style.background1)
    if (parent.activetab == self) then
        surface.DrawRect(x, y - 3, w, h + 1)
        -- Draw the active line on top of the button
        vanity.__setdrawcolor(style.accent)
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

--- @TODO: Revamp this?
--- Creates a new group.
--- @param data table
function tabmt:group(data)
    -- first, we obtain the parent.. aka the window.
    local parentSize = self.parent.size

    -- then, we grab the window size..
    local w, h = parentSize[1], parentSize[2]

    --[[
        1. We only want to fit two groups per row
        2. If we switch to a new row, we substract lets say 15px for a gap
        smth like this: https://files.catbox.moe/ud6ohh.png

        height increases with content amount inside the group
        case of for example like, 600 width on window, every group gets 242.5 width, and the height depends 
        on children
    ]]
    local _w = (w - 40) / 2 
    
    -- by default a empty group should be like, 100 pixel tall.
    local _h = 100 

    
    data = data or {}
    data.size = vanity.vector(_w, _h)

    -- Nice! we discovered width. Now onto height in group.lua

    local group = setmetatable(data, vanity.metatables.group)
    group.parent = self

    self:__addchild(group)

    return group
end