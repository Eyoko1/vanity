local vanity = vanity

local labelmt = {
    text = "",
    parent = nil,
    
    color = vanity.color(255, 255, 255, 255),
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0)
}

labelmt.__index = labelmt
setmetatable(labelmt, vanity.metatables.base)
vanity.metatables.label = labelmt

function vanity.metatables.group:label(text)
    local label = vanity.__inherit({
        text = text
    }, labelmt)

    label:__invalidatelayout()

    return self:__addchild(label)
end

function labelmt:__invalidatelayout()
    surface.SetFont(vanity.style.text)
    local w, h = surface.GetTextSize(self.text)
    h = h + 4

    self.halftextwidth = w * 0.5
    
    local size = self.size
    size[1], size[2] = w, h
end

function labelmt:__render(x, y, w, h)
    vanity.__settextcolor(self.color)
    surface.SetTextPos(x, y)
    surface.SetFont(vanity.style.text)
    surface.DrawText(self.text)
end

function vanity.Label(text, color)
    local label = vanity.__inherit({}, labelmt)
    label.text = text or ""
    label.position = vanity.vector(0, 0)
    label.size = vanity.vector(0, 0)
    label.color = color or vanity.color(255, 255, 255, 255)
    
    surface.SetFont(vanity.style.text)
    label.size[1], label.size[2] = surface.GetTextSize(text or "")
    
    return label
end