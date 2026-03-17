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
lje.env.auth_metatable(labelmt)
vanity.metatables.label = labelmt


function labelmt:__render(x, y, w, h)
    local style = vanity.style
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