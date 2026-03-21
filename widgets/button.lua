local buttonmt = {
    text = "",
    parent = nil,
    halftextwidth = 0,
    hoverframe = 0,

    callback = function() end,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}

buttonmt.__index = buttonmt
setmetatable(buttonmt, vanity.metatables.base)
lje.env.auth_metatable(buttonmt)
vanity.metatables.button = buttonmt

function vanity.metatables.group:button(text, callback)
    local button = vanity.__inherit({
        text = text,
        callback = callback
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

    if (self.hoverframe == FrameNumber()) then
        vanity.__setdrawcolor(vanity.style.accent)
    else
        vanity.__setdrawcoloralpha(vanity.style.accent, 155)
    end
    surface.DrawRect(x, y, w, h)

    vanity.__setdrawcolor(vanity.style.outline1)
    surface.DrawOutlinedRect(x, y, w, h)

    vanity.__setdrawcolor(vanity.style.outline2)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    vanity.__drawgradient(x + 1, y + 1, w - 2, h - 2, 1)

    vanity.__settextcolor(vanity.style.textcolor)
    surface.SetFont(vanity.style.text)
    surface.SetTextPos(x + (w * 0.5) - self.halftextwidth, y + 2)
    surface.DrawText(self.text)
end

function buttonmt:__checkinput()
    local x = self.__computedx
    local y = self.__computedy
    local w = self.__computedwidth
    local h = self.__computedheight
    if (vanity.ishovered(x, y, w, h)) then
        self.hoverframe = FrameNumber()
        if (vanity.didclick()) then
            self.callback()
            lje.con_printf("clicked button: '%s'", tostring(self.text))
            return true
        elseif (vanity.mousedown()) then
            return true
        end
    end
end