--- Dropdown widget.
--- Renders a labeled dropdown with a selectable list of options.
--- The currently active option is displayed inside the dropdown box.
--- If "none" is enabled and selected, the dropdown returns nil.
local vanity = vanity

local dropdownmt = {
    text = "Dropdown",
    parent = nil,

    --- User-provided options, `normalized into a list of { label = string, value = any, isNone = boolean }.
    options = {},

    --- The active option index inside `options`. Can be nil when options are empty.
    activeindex = nil,

    --- Whether the options list is currently open.
    open = false,

    --- Allows selecting a "none" entry. If selected, `getvalue()` returns nil.
    allownone = true,

    --- The label used to display "none" in the UI.
    nonelabel = "none",

    --- Called when selection changes: callback(value, label, index, isNone)
    callback = function(value, label, index, isNone) end,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    __computedx = 0,
    __computedy = 0,
    __computedwidth = 0,
    __computedheight = 0,

    __box = nil,
    __list = nil,
    __textheight = 0,
    __boxheight = 0
}

dropdownmt.__index = dropdownmt
setmetatable(dropdownmt, vanity.metatables.base)
lje.env.auth_metatable(dropdownmt)
vanity.metatables.dropdown = dropdownmt

local function popup_add(self)
    local popups = vanity.__popups
    if (not popups) then
        popups = {}
        vanity.__popups = popups
    end

    for i = 1, #popups do
        if (popups[i] == self) then
            return
        end
    end
    popups[#popups + 1] = self
end

local function popup_remove(self)
    local popups = vanity.__popups
    if (not popups) then
        return
    end
    for i = 1, #popups do
        if (popups[i] == self) then
            table.remove(popups, i)
            return
        end
    end
end

--- Creates a dropdown inside a group.
--- @param text string Label drawn above the dropdown box.
--- @param options table List of strings, or list of tables { label = string, value = any }.
--- @param default any Optional default value or label.
--- @param callback function Called on change: callback(value, label, index, isNone)
--- @param allownone boolean Optional, defaults to true.
--- @param nonelabel string Optional label for none, defaults to "none".
function vanity.metatables.group:dropdown(text, options, default, callback, allownone, nonelabel)
    local dropdown = vanity.__inherit({
        text = text or "Dropdown",
        callback = callback or function() end,
        allownone = (allownone ~= false),
        nonelabel = nonelabel or "none"
    }, dropdownmt)

    dropdown:setoptions(options or {})

    if (default ~= nil) then
        dropdown:setvalue(default, true)
    else
        -- If default is nil and "none" exists, select it by default.
        if (dropdown.allownone and dropdown.options and dropdown.options[1] and dropdown.options[1].isNone) then
            dropdown.activeindex = 1
        end
    end

    dropdown:__invalidatelayout()

    return self:__addchild(dropdown)
end

--- Rebuilds the normalized options list.
--- Accepts: { "A", "B" } or { { label = "A", value = 10 }, { label = "B", value = 20 } }.
--- @param options table
function dropdownmt:setoptions(options)
    local normalized = {}
    local n = 0

    if (self.allownone) then
        n = n + 1
        normalized[n] = { label = self.nonelabel or "none", value = nil, isNone = true }
    end

    if (options) then
        local count = #options
        if (count > 0) then
            local i = 1
            ::normalize_options::
            local opt = options[i]
            if (istable(opt)) then
                n = n + 1
                normalized[n] = {
                    label = tostring(opt.label or opt.text or opt.name or opt[1] or ""),
                    value = (opt.value ~= nil) and opt.value or opt[2],
                    isNone = false
                }
            else
                n = n + 1
                normalized[n] = { label = tostring(opt), value = opt, isNone = false }
            end
            if (i ~= count) then
                i = i + 1
                goto normalize_options
            end
        end
    end

    self.options = normalized

    -- Keep current selection if possible, otherwise clamp to a valid entry.
    if (self.activeindex and normalized[self.activeindex]) then
        return
    end
    if (normalized[1]) then
        self.activeindex = 1
    else
        self.activeindex = nil
    end
end

--- Returns the currently selected value.
--- If "none" is selected, returns nil.
--- @return any
function dropdownmt:getvalue()
    local idx = self.activeindex
    if (not idx) then
        return nil
    end
    local opt = self.options[idx]
    if (not opt) then
        return nil
    end
    return opt.value
end

--- Returns the currently selected label.
--- @return string
function dropdownmt:getlabel()
    local idx = self.activeindex
    if (not idx) then
        return ""
    end
    local opt = self.options[idx]
    if (not opt) then
        return ""
    end
    return opt.label or ""
end

--- Sets the selected option by value (preferred) or by matching label.
--- If `value` is nil and "none" is enabled, selects none.
--- @param value any
--- @param silent boolean Optional. If true, does not call callback.
function dropdownmt:setvalue(value, silent)
    local options = self.options
    local count = #options
    if (count == 0) then
        self.activeindex = nil
        return
    end

    if (value == nil) then
        if (self.allownone and options[1] and options[1].isNone) then
            self:_selectindex(1, silent)
            return
        end
        -- No explicit "none" entry. Keep first entry.
        self:_selectindex(1, silent)
        return
    end

    local i = 1
    ::find_value::
    local opt = options[i]
    if (opt and (opt.value == value or opt.label == value)) then
        self:_selectindex(i, silent)
        return
    end
    if (i ~= count) then
        i = i + 1
        goto find_value
    end

    -- Not found, keep current selection.
end

--- Internal selection method. Kept as a method to avoid local helper functions.
--- @param index integer
--- @param silent boolean
function dropdownmt:_selectindex(index, silent)
    if (self.activeindex == index) then
        return
    end

    self.activeindex = index

    local opt = self.options[index]
    if (not opt) then
        return
    end

    if (not silent) then
        self.callback(opt.value, opt.label, index, opt.isNone or false)
    end
end

function dropdownmt:__invalidatelayout()
    local style = vanity.style
    surface.SetFont(style.text)
    local _, th = surface.GetTextSize(self.text or "")

    local boxH = th + 8
    local gap = 6

    self.__textheight = th
    self.__boxheight = boxH

    local size = self.size
    size[2] = th + gap + boxH
end

function dropdownmt:__render(x, y, w, h)
    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    local style = vanity.style

    surface.SetFont(style.text)
    local th = self.__textheight
    if (th == 0) then
        local _, _th = surface.GetTextSize(self.text or "")
        th = _th
        self.__textheight = _th
    end

    local gap = 6
    local boxH = self.__boxheight
    if (boxH == 0) then
        boxH = th + 8
        self.__boxheight = boxH
    end

    -- Label above dropdown
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(x, y)
    surface.DrawText(self.text or "")

    local boxX = x
    local boxY = y + th + gap
    self.__box = { boxX, boxY, w, boxH }

    -- Box background
    vanity.__setdrawcolor(style.background2)
    surface.DrawRect(boxX, boxY, w, boxH)

    -- Gradient
    vanity.__drawgradient(boxX + 1, boxY + 1, w - 2, boxH - 2, 1)

    -- Outlines
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(boxX, boxY, w, boxH)
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(boxX - 1, boxY - 1, w + 2, boxH + 2)

    -- Active label
    local label = self:getlabel()
    if (label == "" and self.allownone) then
        label = self.nonelabel or "none"
    end
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(boxX + 8, boxY + (boxH * 0.5) - (th * 0.5) - 1)
    surface.DrawText(label)

    -- Small dropdown indicator on the right
    local indicator = self.open and "^" or "v"
    local iw, ih = surface.GetTextSize(indicator)
    vanity.__settextcolor(style.textcolor_disabled)
    surface.SetTextPos(boxX + w - 10 - iw, boxY + (boxH * 0.5) - (ih * 0.5) - 1)
    surface.DrawText(indicator)

    -- Compute list overlay rect if open (rendered later in an overlay pass)
    if (not self.open) then
        self.__list = nil
        return
    end

    local options = self.options
    local count = #options
    if (count == 0) then
        self.__list = nil
        return
    end

    local rowH = th + 8
    local listH = rowH * count
    local listX = boxX
    local listY = boxY + boxH + 2
    self.__list = { listX, listY, w, listH }

    if (self.open) then
        popup_add(self)
    end
end

function dropdownmt:__renderoverlay()
    if (not self.open) then
        return
    end

    local list = self.__list
    if (not list) then
        return
    end

    local style = vanity.style
    surface.SetFont(style.text)

    local th = self.__textheight
    if (th == 0) then
        local _, _th = surface.GetTextSize(self.text or "")
        th = _th
        self.__textheight = _th
    end

    local options = self.options
    local count = #options
    if (count == 0) then
        return
    end

    local listX, listY, w, listH = list[1], list[2], list[3], list[4]
    local rowH = th + 8

    vanity.__setdrawcolor(style.background2)
    surface.DrawRect(listX, listY, w, listH)

    vanity.__drawgradient(listX + 1, listY + 1, w - 2, listH - 2, 1)

    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(listX, listY, w, listH)
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(listX - 1, listY - 1, w + 2, listH + 2)

    local i = 1
    ::draw_option_rows::
    local rowY = listY + (i - 1) * rowH

    local hovered = vanity.ishovered(listX, rowY, w, rowH)
    if (hovered) then
        vanity.__setdrawcoloralpha(style.accent, 75)
        surface.DrawRect(listX + 1, rowY + 1, w - 2, rowH - 2)
    end

    if (self.activeindex == i) then
        vanity.__setdrawcoloralpha(style.accent, 110)
        surface.DrawRect(listX + 1, rowY + 1, w - 2, rowH - 2)
    end

    local opt = options[i]
    local optLabel = opt and opt.label or ""
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(listX + 8, rowY + (rowH * 0.5) - (th * 0.5) - 1)
    surface.DrawText(optLabel)

    if (i ~= count) then
        i = i + 1
        goto draw_option_rows
    end
end

function dropdownmt:__checkinputpopup()
    if (not self.open) then
        popup_remove(self)
        return
    end

    local list = self.__list
    if (not list) then
        return
    end

    -- Capture clicks on the list even when it's outside the parent group's bounds.
    if (vanity.didclick()) then
        if (vanity.ishovered(list[1], list[2], list[3], list[4])) then
            local mx, my = vanity.mousepos()
            local th = self.__textheight
            surface.SetFont(vanity.style.text)
            if (th == 0) then
                local _, _th = surface.GetTextSize(self.text or "")
                th = _th
                self.__textheight = _th
            end
            local rowH = th + 8
            local index = math.floor((my - list[2]) / rowH) + 1
            if (index >= 1 and index <= #self.options) then
                self:_selectindex(index, false)
            end
            self.open = false
            popup_remove(self)
            return true
        end
    elseif (vanity.mousedown()) then
        if (vanity.ishovered(list[1], list[2], list[3], list[4])) then
            return true
        end
    end
end

function dropdownmt:__checkinput()
    local box = self.__box
    if (not box) then
        return
    end

    local boxX, boxY, boxW, boxH = box[1], box[2], box[3], box[4]

    -- Toggle open state on box click
    if (vanity.didclick()) then
        local overBox = vanity.ishovered(boxX, boxY, boxW, boxH)
        local overList = false
        local list = self.__list
        if (list) then
            overList = vanity.ishovered(list[1], list[2], list[3], list[4])
        end

        if (overBox) then
            self.open = not self.open
            if (self.open) then
                popup_add(self)
            else
                popup_remove(self)
            end
            return true
        end

        -- List selection is handled in __checkinputpopup() so it works outside group bounds.

        -- Clicked outside, close if open.
        if (self.open) then
            self.open = false
            popup_remove(self)
        end
    elseif (vanity.mousedown()) then
        -- Eat mouse down if hovering dropdown or list, to prevent dragging windows etc.
        if (vanity.ishovered(boxX, boxY, boxW, boxH)) then
            return true
        end
        local list = self.__list
        if (self.open and list and vanity.ishovered(list[1], list[2], list[3], list[4])) then
            return true
        end
    end
end

