--> This file's only purpose is to be copied and pasted into new widget files to save time
--> This should not be included in main.lua

--- @class Vanity.Button : Vanity.Widget
--- @field text string
--- @field disabled boolean
--- @field clicked fun(self: Vanity.Button): nil

--- @class Vanity.Button.Data
--- @field text string?
--- @field disabled boolean?
--- @field clicked (fun(self: Vanity.Button): nil)?

--- @class Vanity.Group
--- @field button fun(self: Vanity.Group, data: Vanity.Button.Data?): Vanity.Button

--- @type Vanity.Button
local ButtonMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 20),

    text = "",
    disabled = false,
    clicked = function() end,

    halftextwidth = 0,

    render = function() end,
    invalidatelayout = function() end
}

local GroupMT = vanity.metatables.group

--- @param data Vanity.Button.Data?
--- @return Vanity.Button
function GroupMT:button(data)
    local button = vanity.inherit(data or {}, ButtonMT)
    self:addchild(button)

    button.parent = self
    button:invalidatelayout()
    self:invalidatelayout()

    return button
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function ButtonMT:render(x, y, w, h, parenthovered, style)
    local textx = x + (w * 0.5) - self.halftextwidth

    local accent = style.accent
    if (self.disabled) then
        surface.SetDrawColor(accent[1] * 0.7, accent[2] * 0.7, accent[3] * 0.7, accent[4])
        surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
        vanity.setdrawcolor(style.outline_1)
        surface.DrawOutlinedRect(x, y, w, h)

        surface.SetFont(style.text)
        surface.SetTextPos(textx, y + 2)
        vanity.settextcolor(style.text_color_disabled)
        surface.DrawText(self.text)
    else
        if (parenthovered and not vanity.getfocus() and vanity.ishovered(x, y, w, h)) then
            if (vanity.didclick()) then
                vanity.focus(self)
                self.clicked(self)
            end
            surface.SetDrawColor(accent[1] * 1.15, accent[2] * 1.15, accent[3] * 1.15, accent[4])
        else
            vanity.setdrawcolor(accent)
        end
        
        surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
        vanity.setdrawcolor(style.outline_1)
        surface.DrawOutlinedRect(x, y, w, h)

        surface.SetFont(style.text)
        surface.SetTextPos(textx, y + 2)
        vanity.settextcolor(style.text_color)
        surface.DrawText(self.text)
    end
end

--- @return nil
function ButtonMT:invalidatelayout()
    surface.SetFont(vanity.findstyle(self).text)
    local width, height = surface.GetTextSize(self.text)
    self.size[2] = math.max(height, 15) + 4
    self.halftextwidth = width * 0.5
end