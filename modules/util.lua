--- @alias Vanity.Vector {[1]: number, [2]: number}
--- @alias Vanity.Color {[1]: number, [2]: number, [3]: number}
--- @alias Vanity.Font string

local fonts = {}
local fontdata = {}
local materialcache = {}
local scissorrectstack = {}

local mousex, mousey = 0, 0
local lastmousex, lastmousey = 0, 0
local clicked = false
local mousedown = false
local focused = nil

--> Creates and returns a Vector2 object
--- @param x number
--- @param y number
--- @return Vanity.Vector
function vanity.vector(x, y)
    return {x, y}
end

--> Creates and returns a Color object
--- @param r number
--- @param g number
--- @param b number
--- @return Vanity.Color
function vanity.color(r, g, b, a)
    return {r, g, b, a or 255}
end

--> Creates a font and returns its randomly generated id
--- @param name string
--- @param data FontData
--- @return Vanity.Font
function vanity.font(name, data)
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

--> Returns the FontData structure associated with the given font id
--- @param id string
--- @return FontData
function vanity.fontdata(id)
    return fontdata[id]
end

--> Creates a material and caches it
--- @param id string
--- @param path string
--- @return IMaterial
function vanity.material(id, path)
    local material = materialcache[id]
    if (not material) then
        material = Material(path)
        materialcache[id] = material
    end

    return material
end

--> An internal function which inherits the given base (metatable) into the given value
--- @param value table
--- @param base table
--- @return table
function vanity.inherit(value, base)
    for i, v in pairs(base) do
        if (not value[i]) then
            if (istable(v)) then
                value[i] = table.Copy(v)
            else
                value[i] = v
            end
        end
    end

    return setmetatable(value, base)
end

--> Sets the surface draw color to the given Color object
--- @param color Vanity.Color
--- @return nil
function vanity.setdrawcolor(color)
    surface.SetDrawColor(color[1], color[2], color[3], color[4])
end

--> Sets the surface draw color to the given Color object, and overrides the alpha with the given alpha
--- @param color Color
--- @param alpha number
--- @return nil
function vanity.setdrawcoloralpha(color, alpha)
    surface.SetDrawColor(color[1], color[2], color[3], alpha)
end

function vanity.settextcolor(color)
    surface.SetTextColor(color[1], color[2], color[3], color[4])
end

local gradientdown = vanity.material("gradientdown", "gui/gradient_down")
local gradientup = vanity.material("gradientup", "gui/gradient_up")

--> Draws a two-pass gradient for panels and controls
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param color Vanity.Color
--- @param intensity number? An optional multiplier for the gradient's alpha
function vanity.drawgradient(x, y, w, h, color, intensity)
    if (w <= 0 or h <= 0) then
        return
    end

    local alpha = (color[4] or 0)
    if (intensity) then
        alpha = alpha * intensity
    end

    if (alpha <= 0) then
        return
    end

    local topalpha = math.floor(math.min(255, alpha))
    local bottomalpha = math.floor(alpha * 0.45)

    surface.SetMaterial(gradientup)
    vanity.setdrawcoloralpha(color, topalpha)
    surface.DrawTexturedRect(x, y, w, h)

    surface.SetMaterial(gradientdown)
    vanity.setdrawcoloralpha(color, bottomalpha)
    surface.DrawTexturedRect(x, y, w, h)

    draw.NoTexture()
end

--> Draws the up gradient
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param color Vanity.Color
--- @param intensity number? An optional multiplier for the gradient's alpha
function vanity.drawgradientdown(x, y, w, h, color, intensity)
    if (w <= 0 or h <= 0) then
        return
    end

    local alpha = (color[4] or 0)
    if (intensity) then
        alpha = alpha * intensity
    end

    if (alpha <= 0) then
        return
    end

    local topalpha = math.floor(math.min(255, alpha))

    surface.SetMaterial(gradientdown)
    vanity.setdrawcoloralpha(color, topalpha)
    surface.DrawTexturedRect(x, y, w, h)

    draw.NoTexture()
end

--> Invalidates the given element's children
--- @param widget Vanity.Widget
function vanity.invalidatechildren(widget)
    for i, v in ipairs(widget.children) do
        v:invalidatelayout()
    end
end

--> Finds the active style used for the given widget
--- @param widget Vanity.Widget
--- @return Vanity.Style
function vanity.findstyle(widget)
    while (true) do
        --- @cast widget Vanity.Widget | Vanity.Window 
        local style = widget.style
        if (style) then
            return style
        end

        widget = widget.parent
        if (not widget) then
            break
        end
    end
end

--> Returns whether or not the user clicked
--- @return boolean
function vanity.didclick()
    return clicked
end

--> Returns whether or not the user's mouse is down
--- @return boolean
function vanity.mousedown()
    return mousedown
end

--> Returns the user's mouse position
--- @return number, number
function vanity.mousepos()
    return mousex, mousey
end

--> Returns the delta between this frame's mouse position and last frame's mouse position
function vanity.mousedelta()
    return mousex - lastmousex, mousey - lastmousey
end

--> Returns whether or not the user's mouse is within the given boundaries
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @return boolean
function vanity.ishovered(x, y, w, h)
    return mousex >= x and mousex <= x + w and mousey >= y and mousey <= y + h
end

--> Marks the given widget as being focused
--- @param widget Vanity.Widget
--- @return nil
function vanity.focus(widget)
    if (focused) then
        lje.con_printf("$yellow{Warning}: A vanity widget was focused while another was already focused!")
    end

    focused = widget
end

--> Returns the currently focused widget
--- @return Vanity.Widget?
function vanity.getfocus()
    return focused
end

--> Pushes a scissor rect to the top of the stack and actives it
function vanity.pushscissorrect(x1, y1, x2, y2)
    render.SetScissorRect(x1, y1, x2, y2, true)
    table.insert(scissorrectstack, {x1, y1, x2, y2})
end

--> Pops a scissor rect from the stack and activates the last one (if it exists)
function vanity.popscissorrect()
    table.remove(scissorrectstack)
    local length = #scissorrectstack
    if (length > 0) then
        local scissorrect = scissorrectstack[length]
        render.SetScissorRect(scissorrect[1], scissorrect[2], scissorrect[3], scissorrect[4], true)
    else
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end

hook.pre("StartCommand", "vanity/input", function()
    lastmousex, lastmousey = mousex, mousey
    mousex, mousey = gui.MouseX(), gui.MouseY()
    clicked = input.WasMousePressed(MOUSE_LEFT) or input.WasMouseDoublePressed(MOUSE_LEFT)
    mousedown = input.IsMouseDown(MOUSE_LEFT)
end)

hook.pre("lje-util/render", "vanity/render", function()
    focused = nil
    for i, v in ipairs(vanity.windowlist) do
        v:render()
    end
end)