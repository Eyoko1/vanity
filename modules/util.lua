local vanity = vanity

--- Creates a new vector.
--- @param x integer
--- @param y integer
--- @return vector table
function vanity.vector(x, y)
    return {
        x or 0,
        y or 0
    }
end

--- Creates a new color.
--- @param r integer
--- @param g integer
--- @param b integer
--- @param a integer
--- @return color table
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
--- creates a font with the given name, then returns the generated name. if the font already exists, it returns the cached name
--- @param name string
--- @param data table
--- @return font table
function vanity.font(name, data) --> 
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

local materialCache = {}
--- Creates a material and caches it.
---@param id string
---@param materialPath string
---@return IMaterial
function vanity.material(id, materialPath)
    local material = materialCache[id]

    if not material then
        material = Material(materialPath)
        materialCache[id] = material
    end

    return material
end

local surface_SetDrawColor = surface.SetDrawColor
local surface_SetTextColor = surface.SetTextColor

function vanity.__setdrawcolor(color)
    surface_SetDrawColor(color[1], color[2], color[3], color[4])
end

function vanity.__settextcolor(color)
    surface_SetTextColor(color[1], color[2], color[3], color[4])
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