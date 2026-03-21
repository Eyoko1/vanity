local testwindow = vanity:window({
    name = "Vanity Widget Showcase",
    position = vanity.vector((ScrW() - 800 - 300) / 2, (ScrH() - 420) / 2)
})

local showcase = testwindow:tab({
    name = "Example"
})

local controls = showcase:group({
    name = "controls"
})

local status = showcase:group({
    name = "status"
})

status:__addchild(vanity.Label("Use controls on the left.", vanity.color(255, 255, 255, 255)))
status:separator()

local enabled_checkbox = status:checkbox("feature enabled", function() end)
enabled_checkbox:setstate(true)

status:checkbox("debug mode", function() end)
status:checkbox("experimental mode", function() end)

status:separator()
status:dropdown("selected profile", { "default", "aggressive", "balanced", "sniper" }, "default", function() end)
status:button("apply profile", function() end)

controls:__addchild(vanity.Label("Buttons", vanity.color(255, 255, 255, 255)))
controls:button("random accent", function()
    vanity.style.accent = vanity.color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
end)
controls:button("reset accent", function()
    vanity.style.accent = vanity.color(120, 175, 255, 255)
end)

controls:separator()
controls:__addchild(vanity.Label("Sliders", vanity.color(255, 255, 255, 255)))
controls:slider("master volume", 0, 100, 65, 1, "%", 0, function() end)
controls:slider("ui scale", 50, 150, 100, 5, "%", 0, function() end)

controls:separator()
controls:__addchild(vanity.Label("Dropdowns", vanity.color(255, 255, 255, 255)))
controls:dropdown("target hitbox", { "head", "neck", "chest", "stomach" }, "chest", function() end, false)
controls:dropdown("fov mode", {
    { label = "circle", value = "circle" },
    { label = "dynamic", value = "dynamic" },
    { label = "off", value = "off" }
}, "dynamic", function() end)

controls:separator()
controls:__addchild(vanity.Label("Checkboxes", vanity.color(255, 255, 255, 255)))
controls:checkbox("draw boxes", function() end)
controls:checkbox("draw names", function() end)
controls:checkbox("draw health", function() end)
