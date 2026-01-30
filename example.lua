local testwindow = vanity:new({
    name = "Vanity",
    position = vanity.vector(200, 200)
})

local combat = testwindow:tab({
    name = "Example"
})

local visuals = testwindow:tab({
    name = "Example 2"
})

-- we need a way to layout these groups vvvvvvvv

local group = visuals:group({
    name = "players",
})

local example = visuals:group({
    name = "entities",
})

for i = 1, 20 do
    local colorValue = 255 - (i - 1) * (255 - 64) / 19
    local label = vanity.Label("Label " .. i, vanity.color(colorValue, colorValue, colorValue, 255))
    example:__addchild(label)
end