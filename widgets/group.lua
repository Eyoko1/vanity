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

groupmt.__index = groupmt
setmetatable(groupmt, vanity.metatables.base)
vanity.metatables.group = groupmt

-- Internal function used to add a widget to this specific group - you do not need to manually call this
function groupmt:__addchild(widget)
    local children = self.children
    local childcount = #children

    if (childcount == 0) then
        children[childcount + 1] = self:__internalseparator()
        childcount = childcount + 1
    end

    children[childcount + 1] = widget

    self:__invalidatelayout(true)

    return widget
end

function groupmt:__removechild(widget_or_index)
    local children = self.children
    local childcount = #children
    if (isnumber(widget_or_index)) then
        table.remove(children, widget_or_index)
    else
        local i = 1
        ::remove_child::
        if (children[i] == widget_or_index) then
            table.remove(children, i)
        elseif (i ~= childcount) then
            i = i + 1
            goto remove_child
        end
    end

    if (childcount == 2) then --> childcount would now be -1, so if it is at 2 here, there is only 1 element which is the separator
        children[1] = nil --> remove the separator
    end
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
    vanity.__drawgradient(x, y, w, h, 1)

    -- draw the grey outline 
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(x, y, w, h)

    -- draw the black outline
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x - 1 , y - 1, w + 2, h + 2)

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
        local child_y = y + vanity.fontdata(vanity.style.text).size + 13
        local maxy = child_y + h
        local child_width = w - 20
        local i = 1
        -- Store current group's scissor rect so children that need to temporarily
        -- disable clipping (e.g. dropdown popups) can restore it reliably.
        vanity.__scissorrect = { x, y, x + w, y + h, true }
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
        vanity.__scissorrect = nil
    end
end

function groupmt:__checkinput()
    local x = self.__computedx
    local y = self.__computedy
    local size = self.size
    local w = size[1]
    local h = size[2]
    if (vanity.ishovered(x, y, w, h)) then
        return vanity.__checkchildreninput(self.children)
    end
end