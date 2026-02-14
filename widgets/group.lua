--- A group is a rectangular box with children inside of it.
local vanity = vanity

local groupmt = {
    name = "Default",
    parent = nil,
    children = {},
    size = vanity.vector(0, 0),
    position = vanity.vector(0, 0),
    __computedx = 0,
    __computedy = 0
}

setmetatable(groupmt, {__index = vanity.metatables.base})
groupmt.__index = groupmt
vanity.metatables.group = groupmt
lje.env.auth_metatable(groupmt)

-- Internal function used to add a widget to this specific group - you do not need to manually call this
function groupmt:__addchild(widget)
    local children = self.children
    children[#children + 1] = widget

    -- Now, we obtain child height because groups should size their height with content
    self.size[2] = self.size[2] + widget.size[2]
    self:__invalidatelayout(true)
end

function groupmt:__getchildrenheight(base)
    local children = self.children
    local childcount = #children
    local height = base or 0
    if (childcount ~= 0) then
        local i = 1
        ::get_height::
        height = height + children[i].size[2] + 5
        if (i ~= childcount) then
            i = i + 1
            goto get_height
        end
    end

    return height
end

function groupmt:__invalidatelayout(recalculatesize)
    if (recalculatesize ~= false) then
        self.size[2] = self:__getchildrenheight(30)
    end
    self.parent:__recalculategroups()
end

--- Internal function used to render the groupmt widget - you do not need to manually call this
--- @TODO: finish rendering of groups with proper layouting.
function groupmt:__render(px, py, pw, ph)
    local style = vanity.style
    local inset1 = style.inset1

    local position = self.position
    local size = self.size
    local w, h = size[1], size[2]
    local windowposition = self.parent.parent.position
    local x = windowposition[1] + position[1] + inset1
    local y = py + style.tabheight + position[2]

    self.__computedx = x
    self.__computedy = y

    size[2] = h

    vanity.__setdrawcolor(style.background1)
    surface.DrawRect(x, y, w, h)

    -- draw the grey outline 
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(x, y, w, h)

    -- draw the black outline
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x + 1 , y + 1, w - 2, h - 2)

    vanity.__setdrawcolor(style.accent)
    surface.DrawLine(
        x + 2,
        y + 2,
        x + w - 2,
        y + 2
    )

    surface.SetFont(style.grouptext)
    surface.SetTextPos(x + 10, y + 8)
    vanity.__settextcolor(style.textcolor)
    surface.DrawText(self.name)

    -- Render children
    local children = self.children
    local childcount = #children
    if (childcount > 0) then
        local child_x = x + 10
        local child_y = y + 30
        local maxy = child_y + h
        local child_width = w - 20
        local i = 1
        render.SetScissorRect(x, y, x + w, y + h, true)
        ::draw_children::
        local child = children[i]
        local height = child.size[2]
        child:__render(child_x, child_y, child_width, height)
        child_y = child_y + height + 5
        if (i ~= childcount and child_y < maxy) then
            i = i + 1
            goto draw_children
        end
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

function groupmt:__checkinput()
    local x = self.__computedx
    local y = self.__computedy
    local size = self.size
    local w = size[1]
    local h = size[2]
    if (vanity.ishovered(x, y, w, h)) then
        vanity.__checkchildreninput(self.children)
        return true
    end
end