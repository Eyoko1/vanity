local checkboxmt = {
    text = "",
    parent = nil,
    state = false,
    halftextwidth = 0,

    callback = function(state) end,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}

checkboxmt.__index = checkboxmt
vanity.metatables.label = checkboxmt
lje.env.auth_metatable(checkboxmt)

function vanity.metatables.group:checkbox(text, callback)
    local checkbox = vanity.__inherit({
        text = text,
        callback = callback
    }, checkboxmt)

    checkbox:__invalidatelayout()

    return self:__addchild(checkbox)
end

function checkboxmt:__invalidatelayout()
    surface.SetFont(vanity.style.text)
    local w, h = surface.GetTextSize(self.text)
    h = h + 4

    self.halftextwidth = w * 0.5
    
    local size = self.size
    size[1], size[2] = w, h - 5
end

local blanktexture = surface.GetTextureID("vgui/white")
function checkboxmt:__render(x, y, w, h)
    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    -- rectangle
    vanity.__setdrawcolor(vanity.style.background2)
    surface.DrawRect(x, y, h, h)

    -- outline 
    vanity.__setdrawcolor(vanity.style.outline1)
    surface.DrawOutlinedRect(x, y, h, h)

    -- text
    vanity.__settextcolor(vanity.style.textcolor)
    surface.SetFont(vanity.style.text)
    surface.SetTextPos(x + h + 7, y)
    surface.DrawText(self.text)

    if (self.state) then
        vanity.__setdrawcolor(vanity.style.accent)
        surface.DrawRect(x + 1, y + 1, h - 2, h - 2)
    end

    -- gradient down
    surface.SetMaterial(vanity.materials.gradientdown)
    vanity.__setdrawcolor(vanity.style.gradient)
    surface.DrawTexturedRect(x + 1, y + 1, h - 2, h - 8)
end

function checkboxmt:__checkinput()
    if (vanity.didclick()) then
        if (vanity.ishovered(self.__computedx, self.__computedy, self.__computedwidth, self.__computedheight)) then
            local state = not self.state
            self.state = state
            self.callback(state)
            lje.con_printf("toggled checkbox: '%s' = %s", tostring(self.text), state)
            return true
        end
    elseif (vanity.mousedown()) then
        if (vanity.ishovered(self.__computedx, self.__computedy, self.__computedwidth, self.__computedheight)) then
            return true
        end
    end
end

function checkboxmt:getstate()
    return self.state
end

function checkboxmt:setstate(state)
    self.state = state
end