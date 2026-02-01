--- A group is a rectangular box with children inside of it.
local vanity = vanity

local groupmt = {
    name = "Default",
    parent = nil,
    children = {},
    size = vanity.vector(0, 0),
    position = vanity.vector(0, 0)
}

groupmt.__index = groupmt
vanity.metatables.group = groupmt
lje.env.auth_metatable(groupmt)

-- Internal function used to add a widget to this specific group - you do not need to manually call this
function groupmt:__addchild(widget)
    local children = self.children
    children[#children + 1] = widget

    -- Now, we obtain child height because groups should size their height with content
    self.size[2] = self.size[2] + widget.size[2]
    self:__invalidatelayout(false)
end

function groupmt:__invalidatelayout(recalculatesize)
    if (recalculatesize ~= false) then
        local size = self.size
        size[2] = 100

        local children = self.children
        local childcount = #children
        if (childcount ~= 0) then
            local i = 1
            ::recalculate_size::
            size[2] = size[2] + children[i].size[2]
            if (i ~= childcount) then
                i = i + 1
                goto recalculate_size
            end
        end
    end
    self.parent:__recalculategroups()
end

--- Internal function used to render the groupmt widget - you do not need to manually call this
--- @TODO: finish rendering of groups with proper layouting.
function groupmt:__render(px, py, pw, ph)
    local style = vanity.style
    local inset1 = style.inset1

    local w, h = self.size[1], self.size[2]
    local windowposition = self.parent.parent.position
    local x = windowposition[1] + self.position[1] + inset1
    local y = py + style.tabheight + self.position[2]
    
    -- Recalculate group height based on actual child sizes
    self.size[2] = 30  -- header height
    for i, child in ipairs(self.children) do
        self.size[2] = self.size[2] + child.size[2] + 5
    end
    
    local w, h = self.size[1], self.size[2]

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

    surface.SetFont(style.text)
    surface.SetTextPos(x + 10, y + 8)
    vanity.__settextcolor(style.textcolor)
    surface.DrawText(self.name)

    -- Render children
    local child_y = y + 30
    for i, child in ipairs(self.children) do
        child:__render(x + 10, child_y, w - 20, child.size[2])
        child_y = child_y + child.size[2] + 5
    end
end