local vanity = vanity

local tabmt = {
    name = "Tab",
    parent = nil,
    index = 1
}
tabmt.__index = tabmt
vanity.metatables.tab = tabmt
lje.env.auth_metatable(tabmt)

function tabmt:select()
    self.window.activetab = self
end

function tabmt:__render(px, py, pw, ph)
    local style = vanity.style
    local inset1 = style.inset1
    local inset2 = style.inset2

    local index = self.index
    local parent = self.parent
    local name = self.name

    local x = px + (inset1 * index) + parent.__tabx
    local y = py + parent.__titleheight + (inset1 * 2)

    surface.SetFont(style.text)
    local w, h = surface.GetTextSize(name)
    w = math.max(w + 20, 50)
    h = style.tabheight

    local notone = index ~= 1

    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 2)

    if (notone) then
        local yh = (y + h) - 1
        surface.DrawLine(x - inset1 + 1, yh, x - 2, yh)
    end

    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)

    if (notone) then
        local yh = (y + h)
        surface.DrawLine(x - inset1, yh, x - 1, yh)
    end

    vanity.__setdrawcolor(style.background2)
    if (parent.activetab == self) then
        surface.DrawRect(x, y, w, h + 1)
    else
        surface.DrawRect(x, y, w, h)
    end

    parent.__tabx = parent.__tabx + w
end