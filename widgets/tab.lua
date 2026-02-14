--- A tab is a small button widget featured under the menu name. 
local vanity = vanity

local tabmt = {
    name = "Tab",
    parent = nil,
    children = {},
    index = 1,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    __computedx = 0,
    __computedy = 0,
    __computedwidth = 0,
    __computedheight = 0
}

setmetatable(tabmt, {__index = vanity.metatables.base})
tabmt.__index = tabmt
vanity.metatables.tab = tabmt
lje.env.auth_metatable(tabmt)

--- Marks the tab as active.
function tabmt:select()
    self.parent.activetab = self
end

-- Internal function used to add a widget to this specific tab - you do not need to manually call this
function tabmt:__addchild(widget)
    local children = self.children
    children[#children + 1] = widget
end

function tabmt:__invalidatelayout()
    local style = vanity.style
    local inset1 = style.inset1
    local position = self.position

    local tabs = self.parent.tabs
    local tabcount = #tabs

    local cumulativex = inset1
    local i = 1
    surface.SetFont(style.tabtext)
    ::invalidate_tab::
    local tab = tabs[i]
    if (tab == self) then
        position[1] = cumulativex
        position[2] = self.parent.__titleheight + (inset1 * 2)
        return
    else
        local w, _ = surface.GetTextSize(tab.name)
        w = math.max(w + 20, 50)
        cumulativex = cumulativex + inset1 + w
        i = i + 1
        goto invalidate_tab
    end
end

-- Internal function used to render the tab widget - you do not need to manually call this
-- This function returns the width of the tab
function tabmt:__render(px, py, pw, ph)
    local style = vanity.style
    local inset1 = style.inset1
    local inset2 = style.inset2

    local index = self.index
    local parent = self.parent
    local name = self.name

    local position = self.position

    local x = px + position[1]
    local y = py + position[2]

    surface.SetFont(style.tabtext)
    local w, h = surface.GetTextSize(name)
    w = math.max(w + 20, 50)
    h = style.tabheight

    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x - 2, y - 5, w + 4, h + 2)

    if (index ~= 1) then
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

        -- Render the text
        surface.SetTextPos(x + 10, y + 4)
        vanity.__settextcolor(style.textcolor)
        surface.DrawText(name)

        vanity.__drawchildren(self.children, x, y, pw, ph)
    else
        surface.DrawRect(x, y - 3, w, h)

        -- Render the text
        surface.SetTextPos(x + 10, y + 4)
        vanity.__settextcolor(style.textcolor)
        surface.DrawText(name)
    end

    return w
end

function tabmt:__checkinput()
    if (vanity.didclick()) then
        local x = self.__computedx
        local y = self.__computedy
        local w = self.__computedwidth
        local h = self.__computedheight
        if (vanity.ishovered(x, y, w, h)) then
            self:select()
            return true
        end
    end

    vanity.__checkchildreninput(self.children)
end

--- @TODO: Revamp this?
--- Creates a new group.
--- @param data table
function tabmt:group(data)
    local style = vanity.style

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
    data.position = vanity.vector(style.inset1 * 2, self.position[2] + style.tabheight + style.inset1)

    -- Nice! we discovered width. Now onto height in group.lua

    local group = vanity.__inherit(data, vanity.metatables.group)
    group.parent = self

    self:__addchild(group)
    group:__invalidatelayout()

    return group
end

local OVERFLOW_FORMAT1 = "Group '%s' is overflowing due to it's size (type 1); increase the size of the window containing it to fix this."
local OVERFLOW_FORMAT2 = "Group '%s' is overflowing due to it's size (type 2); increase the size of the window containing it to fix this."
function tabmt:__recalculategroups()
    local style = vanity.style
    local inset1 = style.inset1

    local groups = self.children
    local groupcount = #groups

    local window = self.parent
    local heightthreshold = (window.__sectionend - window.__sectionstart) - inset1

    local cumulativex = inset1
    local cumulativey = inset1
    local i = 1
    local leftcount = 0
    local rightcount = 0
    
    ::invalidate_group2::
    local group = groups[i]
    local position = group.position
    local size = group.size
    local height = size[2]
    if (cumulativey + height > heightthreshold) then
        if (cumulativex == inset1) then
            if (height > heightthreshold) then
                lje.con_printf(OVERFLOW_FORMAT1, group.name)
            else
                cumulativex = cumulativex + size[1] + inset1
                cumulativey = inset1
                position[1] = cumulativex
                position[2] = cumulativey
            end
        else
            lje.con_printf(OVERFLOW_FORMAT2, group.name)
        end
    else
        position[1] = cumulativex
        position[2] = cumulativey
    end

    if (i ~= groupcount) then
        cumulativey = cumulativey + height + inset1
        i = i + 1
        goto invalidate_group2
    end
end

function tabmt:__recalculategroups2()
    local style = vanity.style
    local inset1 = style.inset1

    local groups = self.children
    local groupcount = #groups

    local window = self.parent
    local heightthreshold = (window.__sectionend - window.__sectionstart) - inset1

    local groupwidth = groups[1].size[1]

    local leftx = inset1
    local rightx = inset1 + groupwidth + inset1

    local lefty = inset1
    local righty = inset1

    lje.con_print("-----------")

    local i = 1
    ::invalidate_group::
    local group = groups[i]
    local position = group.position
    local size = group.size
    local height = size[2]

    local heightinset = height + inset1
    local newleft = lefty + heightinset
    lje.con_printf("%s: %s, %s, %s", group.name, newleft, heightthreshold, height)
    if (newleft <= heightthreshold) then
        position[1] = leftx
        position[2] = lefty
        lefty = newleft
        lje.con_printf("    left: %s", group.name)
    else
        local newright = righty + heightinset
        if (newright <= heightthreshold) then
            position[1] = rightx
            position[2] = righty
            righty = newright
        else
            lje.con_printf(OVERFLOW_FORMAT1, group.name)
        end
    end

    if (i ~= groupcount) then
        i = i + 1
        goto invalidate_group
    end
end