local testwindow = vanity:window({
    name = "Vanity",
    position = vanity.vector(1200, 600)
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

local rainbowcolor = vanity.color()
-- Needed for hsl2rgb to work
local function hue2rgb(p, q, t)
    if t < 0   then t = t + 1 end
    if t > 1   then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
    return p
end

-- Here's the function you want --

local function hsl2rgb(h, s, l)
    local r, g, b

    local h = h / 360

    if s == 0 then
        r, g, b = l, l, l
    else
        local q = (l < 0.5) and l * (1 + s) or l + s - l * s
        local p = l * 2 - q

        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    rainbowcolor[1] = r * 255
    rainbowcolor[2] = g * 255
    rainbowcolor[3] = b * 255
end

group:button("random accent", function()
    vanity.style.accent = vanity.color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
end)
local dorainbow = group:checkbox("rainbow accent", function(state)
    
end)
group:button("padding", function()
    vanity.style.accent = vanity.color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
end)

local rainbowprogress = 0
hook.pre("ljeutil/render", "vanity/example", function()
    if (not dorainbow:getstate()) then
        return
    end
    
    rainbowprogress = rainbowprogress + (FrameTime() * 50)
    hsl2rgb(rainbowprogress % 360, 0.5, 0.5)
    vanity.style.accent = rainbowcolor
end)

group:separator()

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