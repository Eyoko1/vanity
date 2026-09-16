local vanity = vanity

local __clicked = false
function vanity.didclick()
    return __clicked
end

function vanity.mousedown()
    return input.IsMouseDown(MOUSE_LEFT)
end

function vanity.mousepos()
    return gui.MouseX(), gui.MouseY()
end

function vanity.ishovered(x, y, width, height)
    local mx, my = vanity.mousepos()
    return (mx >= x and mx <= x + width) and (my >= y and my <= y + height)
end

hook.pre("StartCommand", "__vanity_input", function()
    __clicked = input.WasMousePressed(MOUSE_LEFT) or input.WasMouseDoublePressed(MOUSE_LEFT)
end)

-- Mouse capture: a widget that grabs the mouse (e.g. a slider being dragged)
-- keeps receiving input even when the cursor leaves its parent group/window,
-- which are otherwise hover-gated.
local __captured = nil

function vanity.__setcapture(widget)
    __captured = widget
end

function vanity.__releasecapture(widget)
    if (widget == nil) or (__captured == widget) then
        __captured = nil
    end
end

function vanity.__getcapture()
    return __captured
end

function vanity.__hascapture(widget)
    return __captured == widget
end
