local buttonmt = {
    text = "",
    parent = nil,
    halftextwidth = 0,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}

buttonmt.__index = buttonmt
vanity.metatables.label = buttonmt
lje.env.auth_metatable(buttonmt)

function vanity.metatables.group:button(text)
    text = text or ""

    local button = vanity.__inherit({
        text = text
    }, buttonmt)

    button:__invalidatelayout()

    return self:__addchild(button)
end

function buttonmt:__invalidatelayout()
    surface.SetFont(vanity.style.text)
    local w, h = surface.GetTextSize(self.text)
    h = h + 4

    self.halftextwidth = w * 0.5
    
    local size = self.size
    size[1], size[2] = w, h
end

function buttonmt:__render(x, y, w, h)
    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    vanity.__setdrawcolor(vanity.style.accent)
    surface.DrawRect(x, y, w, h)

    vanity.__settextcolor(vanity.style.textcolor)
    surface.SetFont(vanity.style.text)
    surface.SetTextPos(x + (w * 0.5) - self.halftextwidth, y + 2)
    surface.DrawText(self.text)
end

function buttonmt:__checkinput()
    if (vanity.didclick()) then
        local x = self.__computedx
        local y = self.__computedy
        local w = self.__computedwidth
        local h = self.__computedheight
        if (vanity.ishovered(x, y, w, h)) then
            lje.con_printf("clicked button: '%s'", tostring(self.text))
        end
    end
end