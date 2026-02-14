local testwindow = vanity:window({
    name = "Vanity",
    position = vanity.vector(200, 200)
})

local visuals = testwindow:tab({
    name = "Example"
})

local combat = testwindow:tab({
    name = "Example 2"
})

-- we need a way to layout these groups vvvvvvvv

local group = visuals:group({
    name = "players",
})

local example = visuals:group({
    name = "entities",
})

local padding = visuals:group({
    name = "padding",
})

local example2 = visuals:group({
    name = "test"
})

group:button("test1")
group:button("test2")
group:checkbox("checkbox")

for i = 1, 15 do
    local colorValue = 255 - (i - 1) * (255 - 64) / 19
    local label = vanity.Label("Label " .. i, vanity.color(colorValue, colorValue, colorValue, 255))
    group:__addchild(label)
end

for i = 1, 20 do
    local colorValue = 255 - (i - 1) * (255 - 64) / 19
    local label = vanity.Label("Test " .. i, vanity.color(colorValue, colorValue, colorValue, 255))
    example2:__addchild(label)
end