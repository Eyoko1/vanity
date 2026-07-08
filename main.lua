--- @diagnostic disable-next-line
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

local widgets_to_include = {
    "base", "window", "tab", "group", "label", "button", "checkbox", "separator", "slider", "dropdown"
}


vanity.include("modules/util.lua")
vanity.include("modules/style.lua")
vanity.include("modules/input.lua")

-- Widget files
for i,v in pairs(widgets_to_include) do
    vanity.include("widgets/" .. v .. ".lua")
end



vanity.include("modules/render.lua") 

-- Uncomment this to run the example!
--vanity.include("example.lua")