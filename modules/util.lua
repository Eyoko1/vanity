local vanity = vanity

local next = next
local istable = istable

--- Creates a new vector.
--- @param x integer
--- @param y integer
--- @return Vector table
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
--- @return Color table
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
--- @return string
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

function vanity.fontdata(id)
    return fontdata[id]
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
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local floor = math.floor

function vanity.__setdrawcolor(color)
    surface_SetDrawColor(color[1], color[2], color[3], color[4])
end

function vanity.__setdrawcoloralpha(color, alpha)
    surface_SetDrawColor(color[1], color[2], color[3], alpha)
end

function vanity.__settextcolor(color)
    surface_SetTextColor(color[1], color[2], color[3], color[4])
end

--- Draws a softer two-pass gradient for panels and controls.
--- @param x integer
--- @param y integer
--- @param w integer
--- @param h integer
--- @param intensity number|nil Optional multiplier for style.gradient alpha.
function vanity.__drawgradient(x, y, w, h, intensity)
    if (w <= 0) or (h <= 0) then
        return
    end

    local gradient = vanity.style.gradient
    local baseAlpha = gradient[4] or 0
    if (baseAlpha <= 0) then
        return
    end

    local scale = intensity or 1
    local topAlpha = floor(math.min(255, baseAlpha * scale))
    local bottomAlpha = floor(math.min(255, topAlpha * 0.45))

    surface_SetMaterial(vanity.materials.gradientup)
    vanity.__setdrawcoloralpha(gradient, topAlpha)
    surface_DrawTexturedRect(x, y, w, h)

    surface_SetMaterial(vanity.materials.gradientdown)
    vanity.__setdrawcoloralpha(gradient, bottomAlpha)
    surface_DrawTexturedRect(x, y, w, h)
end

function vanity.__drawchildren(children, px, py, pw, ph)
    local count = #children
    if (count == 0) then
        return
    end

    local i = 1
    ::draw_children::
    local child = children[i]
    if (not child.hidden) and (not child.isHidden or not child:isHidden()) then
        child:__render(px, py, pw, ph)
    end
    if (i ~= count) then
        i = i + 1
        goto draw_children
    end
end

function vanity.__checkchildreninput(children)
    local count = #children
    if (count == 0) then
        return
    end

    local i = 1
    ::check_children_input::
    local child = children[i]
    if (not child.hidden) and (not child.isHidden or not child:isHidden()) then
        local __checkinput = child.__checkinput
        if (__checkinput and __checkinput(child)) then
            return true
        end
    end
    if (i ~= count) then
        i = i + 1
        goto check_children_input
    end
end

function vanity.__invalidatelayouts(children)
    local count = #children
    if (count == 0) then
        return
    end

    local i = 1
    ::draw_children::
    children[i]:__invalidatelayout()
    if (i ~= count) then
        i = i + 1
        goto draw_children
    end
end

-- Shallow clone of the value (which is assumed to be a table)
local function clone(target)
    local cloned = {}
    local key, value = next(target)
    ::clone_table::
    if (key) then
        cloned[key] = value
        key, value = next(target, key)
        goto clone_table
    end

    return cloned
end

function vanity.__inherit(data, mt)
    data = data or {}

    setmetatable(data, mt)

    -- Shallow-copy any tables already on the instance (caller-provided),
    -- so the caller can't accidentally share references across widgets.
    for k, v in pairs(data) do
        if istable(v) then
            local copy = {}
            for key, val in pairs(v) do
                copy[key] = val
            end
            data[k] = copy
        end
    end

    -- Also clone table fields that exist on the metatable/prototype chain.
    -- Many widgets keep mutable defaults (children, size, position, etc) on the prototype;
    -- without cloning, every instance shares those same tables.
    local seen = {}
    local proto = mt
    while (istable(proto) and not seen[proto]) do
        seen[proto] = true
        for k, v in pairs(proto) do
            if (rawget(data, k) == nil and istable(v)) then
                data[k] = clone(v)
            end
        end
        proto = getmetatable(proto)
    end

    return data
end