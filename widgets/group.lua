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
end

--- Internal function used to render the groupmt widget - you do not need to manually call this
--- @TODO: finish rendering of groups with proper layouting.
function groupmt:__render(x, y, w, h)
    local style = vanity.style

    local w, h = self.size[1], self.size[2]
    local x, y = self.position[1], self.position[2]
    
    --[[ draw the background
    vanity.__setdrawcolor(style.background1)
    surface.DrawRect(x, y, w, h)
    ]]

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

end