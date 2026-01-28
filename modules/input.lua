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

local function handlewindow()

end

local function handleinput()
    local windows = vanity.windows
    local count = #windows
    if (count == 0) then
        return
    end

    local i = 1
    ::do_window_input::
    if (windows[i]:__checkinput()) then
        break
    elseif (i ~= count) then
        i = i + 1
        goto do_window_input
    end
end

hook.pre("StartCommand", "__vanity_input", function()
    __clicked = input_WasMousePressed(MOUSE_LEFT) or input_WasMouseDoublePressed(MOUSE_LEFT)

    handleinput()
end)