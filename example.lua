local testwindow = vanity:new({
    name = "Vanity",
    position = vanity.vector(600, 450)
})

local combat = testwindow:tab({
    name = "Example"
})

local visuals = testwindow:tab({
    name = "Example 2"
})

-- we need a way to layout these groups vvvvvvvv

--[[
local group = visuals:group({
    name = "players",
    position = vanity.vector(615, 513)
})

local example = visuals:group({
    name = "entities",
    position = vanity.vector(854, 513)
})
]]