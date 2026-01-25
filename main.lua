vanity = {
    style = {}, --> populated in modules/style.lua
    windows = {},
    metatables = {
        window = nil,
        tab = nil
    }
}

lje.include("modules/util.lua")
lje.include("modules/style.lua")

lje.include("modules/window.lua")
lje.include("modules/tab.lua")

lje.include("modules/render.lua")

-----------------------------

local testwindow = vanity:new({
    name = "Test",
    position = vanity.vector(600, 450)
})