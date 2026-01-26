local vanity = vanity

function vanity.vector(x, y)
    return {
        x or 0,
        y or 0
    }
end

function vanity.color(r, g, b, a)
    return {
        r,
        g,
        b,
        a or 255
    }
end

local fonts = {}
local fontdata = {}
function vanity.font(name, data) --> creates a font with the given name, then returns the generated name. if the font already exists, it returns the cached name
    local cached = fonts[name]
    if (cached) then
        return cached
    end

    local id = lje.util.random_string()
    surface.CreateFont(id, data)
    fonts[name] = id
    fontdata[id] = data

    return id
end

local surface_SetDrawColor = surface.SetDrawColor
function vanity.__setdrawcolor(color)
    surface_SetDrawColor(color[1], color[2], color[3], color[4])
end

function vanity.__settextcolor(color)
    surface_SetDrawColor(color[1], color[2], color[3], color[4])
end

local baseparent = {
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}
function vanity.__drawchildren(children, parent)
    local count = #children
    if (count == 0) then
        return
    end

    parent = parent or baseparent

    local position = parent.position or vectorzero
    local size = parent.size or vectorzero

    local px, py = position[1], position[2]
    local pw, ph = size[1], size[2]

    local i = 1
    ::draw_children::
    children[i]:__render(px, py, pw, ph)
    if (i ~= count) then
        i = i + 1
        goto draw_children
    end
end