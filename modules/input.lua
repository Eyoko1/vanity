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