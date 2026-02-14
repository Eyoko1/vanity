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
    text = text or ""

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
    h = h + 10

    self.halftextwidth = w * 0.5
    
    local size = self.size
    size[1], size[2] = w, h
end

local blanktexture = surface.GetTextureID("vgui/white")
function checkboxmt:__render(x, y, w, h)
    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    vanity.__setdrawcolor(vanity.style.background2)
    surface.DrawRect(x, y, h, h)

    vanity.__setdrawcolor(vanity.style.outline1)
    surface.DrawOutlinedRect(x, y, h, h)

    vanity.__settextcolor(vanity.style.textcolor)
    surface.SetFont(vanity.style.text)
    surface.SetTextPos(x + h + 8, y + 5)
    surface.DrawText(self.text)

    if (self.state) then
        vanity.__setdrawcolor(vanity.style.accent)
        surface.SetTexture(blanktexture)
        surface.DrawTexturedRectRotated(x + 9, y + 16, 8, 3, -45)
        surface.DrawTexturedRectRotated(x + 16, y + 12, 12, 3, 45)
    end
end

function checkboxmt:__checkinput()
    if (vanity.didclick()) then
        local x = self.__computedx
        local y = self.__computedy
        local w = self.__computedwidth
        local h = self.__computedheight
        if (vanity.ishovered(x, y, w, h)) then
            local state = not self.state
            self.state = state
            self.callback(state)
            lje.con_printf("toggled checkbox: '%s' = %s", tostring(self.text), toggle)
        end
    end
end