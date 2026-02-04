local vanity = vanity

local basemt = {
    name = "",
    parent = nil,
    
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),
    
    hidden = false,
}

basemt.__index = basemt
vanity.metatables.base = basemt
lje.env.auth_metatable(basemt)

--- Override this in child widgets
function basemt:__render(x, y, w, h)
    -- Base render implementation
end

--- Override this in child widgets for custom updates
function basemt:__update(dt)
    -- Base update implementation
end

--- Set the position of the widget
function basemt:setPosition(x, y)
    self.position[1] = x
    self.position[2] = y
end

--- Set the size of the widget
function basemt:setSize(w, h)
    self.size[1] = w
    self.size[2] = h
end

--- Hide the widget
function basemt:hide()
    self.hidden = true
end

--- Show the widget
function basemt:show()
    self.hidden = false
end

--- Check if widget is visible
function basemt:isVisible()
    return not self.hidden and (self.parent == nil or self.parent:isVisible())
end

--- Check if visible + do click
function basemt:checkinput()

end

return basemt
