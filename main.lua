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

-- Widget files
lje.include("widgets/window.lua")
lje.include("widgets/tab.lua")

lje.include("modules/render.lua") 

-- Uncomment this to run the example!
lje.include("example.lua")