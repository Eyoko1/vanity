local separatormt = {
    parent = nil,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}

separatormt.__index = separatormt
vanity.metatables.label = separatormt
lje.env.auth_metatable(separatormt)

function vanity.metatables.group:__internalseparator()
    local separator = vanity.__inherit({}, separatormt)
    separator:__invalidatelayout()

    return separator
end

function vanity.metatables.group:separator()
    return self:__addchild(self:__internalseparator())
end

function separatormt:__invalidatelayout()
    self.size[2] = 3
end

function separatormt:__render(x, y, w, h)
    vanity.__setdrawcolor(vanity.style.outline1)
    surface.DrawRect(x, y + 1, w, 1)
end

function separatormt:__checkinput()
    
end