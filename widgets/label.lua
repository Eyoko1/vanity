local vanity = vanity

local labelmt = {
    text = "",
    parent = nil,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    color = vanity.color(255, 255, 255, 255)
}

labelmt.__index = labelmt
vanity.metatables.label = labelmt
lje.env.auth_metatable(labelmt)

function labelmt:__render(x, y, w, h)
    local style = vanity.style
    surface.SetFont(style.text)

    self.size[1], self.size[2] = surface.GetTextSize(self.text)

	vanity.__settextcolor(self.color)
	surface.SetTextPos(x, y)
	surface.DrawText(self.text)
end


function vanity.Label(text, color)
    local label = setmetatable({}, labelmt)
    label.text = text or ""
    label.position = vanity.vector(0, 0)
    label.size = vanity.vector(0, 0)
    label.color = color or vanity.color(255, 255, 255, 255)
    
    surface.SetFont(vanity.style.text)
    label.size[1], label.size[2] = surface.GetTextSize(text or "")
    
    return label
end