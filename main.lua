--> Migration guidelines:
--> vanity.style is now a function which creates a new style

--> Widgets use computed* to avoid having to recomputed positions in the input function

--- @class Vanity.Widget
--- @field parent Vanity.Widget? The parent widget
--- @field children Vanity.Widget[] An array of this widget's children
--- @field position Vanity.Vector The position of this widget relative to its parent
--- @field size Vanity.Vector The size of this widget
--- @
--- @field render fun(self: Vanity.Widget, parentx: number, parenty: number, parentw: number, parenth: number, style: Vanity.Style, parenthovered: boolean): nil
--- @field invalidatelayout fun(self: Vanity.Widget): nil

--- @diagnostic disable-next-line
vanity = {
    --- @type Vanity.Window[]
    windowlist = {},
    metatables = {
        --- @type Vanity.Window
        window = nil
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

local testwindow = vanity.window({
    name = "Test Window"
})

testwindow:tab({
    name = "Tab 1"
})

testwindow:tab({
    name = "Tab 2"
})

testwindow:tab({
    name = "Long Tab Name"
})