--> Migration guidelines:
--> vanity.style is now a function which creates a new style

--> Widgets use computed* to avoid having to recomputed positions in the input function

--- @alias Vanity.RenderFunction fun(self: Vanity.Widget, x: number, y: number, w: number, h: number, parenthovered: boolean, style: Vanity.Style): nil

--- @class Vanity.Widget
--- @field parent Vanity.Widget? The parent widget
--- @field children Vanity.Widget[] An array of this widget's children
--- @field position Vanity.Vector The position of this widget relative to its parent
--- @field size Vanity.Vector The size of this widget
--- @
--- @field render Vanity.RenderFunction
--- @field invalidatelayout fun(self: Vanity.Widget): nil

--- @diagnostic disable-next-line
vanity = {
    --- @type Vanity.Window[]
    windowlist = {},
    metatables = {
        --- @type Vanity.Window
        window = nil,
        --- @type Vanity.Tab
        tab = nil,
        --- @type Vanity.Separator
        separator = nil,
        --- @type Vanity.Label
        label = nil
    }
}

--- @param path string
function vanity.include(path)
    lje.con_printf("[$black{Vanity}] including %s", path)
    lje.include(path)
end

--> Modules
vanity.include("modules/util.lua")
vanity.include("modules/style.lua")

--> Widgets
vanity.include("widgets/window.lua")
vanity.include("widgets/tab.lua")
vanity.include("widgets/group.lua")
vanity.include("widgets/separator.lua")
vanity.include("widgets/label.lua")
vanity.include("widgets/button.lua")
vanity.include("widgets/checkbox.lua")

local testwindow = vanity.window({
    name = "Test Window"
})

--testwindow.style.background_tile_material = Material("trails/love.png")
--testwindow.style.background_tile_color = vanity.color(255, 255, 255, 125)

local testtab = testwindow:tab({
    name = "Tab 1"
})

local testgroup = testtab:group({
    name = "Group 1"
})

testgroup:label({text = "Hello, World!"})
testgroup:separator()
testgroup:label({text = "Long piece of text which should wrap around to the next line.\nNew line! This-Is-A-Very-Long-Word-Which-Should-Wrap-Around-To-New-Lines-In-This-Group."})
testgroup:separator()
testgroup:separator()
testgroup:separator()
testgroup:separator()
testgroup:button({text = "Say Something.", clicked = function() lje.con_print("I say 'Hello, World!'") end})

for i = 2, 10 do
    testtab:group({name = "Group " .. tostring(i)})
end

local testgroup2 = testtab:group({
    name = "Test Group"
})

testgroup2:checkbox({
    text = "Debug"
})

testgroup2:checkbox({
    text = "Very long checkbox name which is supported as checkboxes use labels internally."
})

testwindow:tab({
    name = "Tab 2"
}):group({
    name = "Test"
})

testwindow:tab({
    name = "Long Tab Name"
}):group({
    name = "Something"
})