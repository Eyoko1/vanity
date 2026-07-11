--> This file's only purpose is to be copied and pasted into new widget files to save time
--> This should not be included in main.lua

--- @class Vanity.Checkbox : Vanity.Widget
--- @field parent Vanity.Group?
--- @
--- @field text string
--- @field state boolean
--- @field toggled fun(self: Vanity.Checkbox, state: boolean): nil
--- @
--- @field label Vanity.Label?
--- @
--- @field getwidth fun(self: Vanity.Checkbox): number

--- @class Vanity.Checkbox.Data
--- @field text string?
--- @field state boolean?
--- @field toggled (fun(self: Vanity.Checkbox, state: boolean): nil)?

--- @class Vanity.Group
--- @field checkbox fun(self: Vanity.Group, data: Vanity.Checkbox.Data): Vanity.Checkbox

--- @type Vanity.Checkbox
local CheckboxMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    text = "",
    state = false,
    toggled = function() end,

    label = nil,

    render = function() end,
    invalidatelayout = function() end,
    getwidth = function() return 0 end
}

local GroupMT = vanity.metatables.group
local LabelMT = vanity.metatables.label

local size = 16
local offset = 6

--- @param data Vanity.Checkbox.Data
--- @return Vanity.Checkbox
function GroupMT:checkbox(data)
    local checkbox = vanity.inherit(data or {}, CheckboxMT)
    self:addchild(checkbox)

    local label = vanity.inherit({text = checkbox.text}, LabelMT)
    label.parent = checkbox

    checkbox.parent = self
    checkbox.label = label
    checkbox:invalidatelayout()
    self:invalidatelayout()
    label:invalidatelayout()
    self:invalidatelayout()

    return checkbox
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function CheckboxMT:render(x, y, w, h, parenthovered, style)
    --- @type Vanity.Label
    local label = self.label
    local totaloffset = size + offset
    label:render(x + totaloffset, y, w - totaloffset, h, parenthovered, style)


    --local recty = y + ((label.size[2] - size) * 0.5) --> This is centered, however it doesn't look as good as simply using the y value
    if (parenthovered and not vanity.getfocus() and vanity.ishovered(x, y, size, size)) then
        if (vanity.didclick()) then
            self.state = not self.state
        end
    end

    if (self.state) then
        vanity.setdrawcolor(style.accent)
    else
        vanity.setdrawcolor(style.background_1)
    end

    surface.DrawRect(x + 1, y + 1, size - 2, size - 2)

    vanity.setdrawcolor(style.outline_1)
    surface.DrawOutlinedRect(x, y, size, size)
end

--- @return nil
function CheckboxMT:invalidatelayout()
    --- @type Vanity.Label
    local label = self.label
    label:invalidatelayout()

    self.size[2] = label.size[2]
end

--> Simulate a group environment
function CheckboxMT:getwidth()
    --- @type Vanity.Group
    local parent = self.parent
    return parent:getwidth() - (size + offset)
end