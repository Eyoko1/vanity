vanity = {
    style = {}, --> populated in modules/style.lua
    windows = {},
    metatables = {
        window = nil,
        tab = nil
    }
}

function vanity.include(path)
    lje.con_printf("[$black{Vanity}] including %s", path)
    lje.include(path)
end

vanity.include("modules/util.lua")
vanity.include("modules/style.lua")
vanity.include("modules/input.lua")

-- Widget files
vanity.include("widgets/window.lua")
vanity.include("widgets/tab.lua")
vanity.include("widgets/group.lua")

vanity.include("modules/render.lua") 

-- Uncomment this to run the example!
vanity.include("example.lua")