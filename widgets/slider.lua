local vanity = vanity

local clamp = math.Clamp
local floor = math.floor

local function quantize(value, step)
    if (not step) or (step <= 0) then
        return value
    end
    return floor((value / step) + 0.5) * step
end

local function formatValue(value, decimals, suffix)
    decimals = decimals or 0
    local fmt = "%." .. tostring(decimals) .. "f"
    local s = string.format(fmt, value)
    if (suffix and suffix ~= "") then
        return s .. " " .. suffix
    end
    return s
end

local slidermt = {
    text = "Slider",
    parent = nil,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    value = 0,
    min = 0,
    max = 100,
    step = 1,
    decimals = 0,
    suffix = "",

    callback = function(value) end,

    __computedx = 0,
    __computedy = 0,
    __computedwidth = 0,
    __computedheight = 0,
    __track = nil,
    __plus = nil,
    __minus = nil,
    __hoverframe = 0
}

slidermt.__index = slidermt
setmetatable(slidermt, vanity.metatables.base)
vanity.metatables.slider = slidermt

function vanity.metatables.group:slider(text, min, max, value, step, suffix, decimals, callback)
    local slider = vanity.__inherit({
        text = text or "Slider",
        min = min or 0,
        max = max or 100,
        value = value or min or 0,
        step = step or 1,
        suffix = suffix or "",
        decimals = decimals or 0,
        callback = callback or function() end
    }, slidermt)

    slider:__invalidatelayout()
    slider:setvalue(slider.value, true)

    return self:__addchild(slider)
end

function slidermt:__invalidatelayout()
    surface.SetFont(vanity.style.text)
    local _, th = surface.GetTextSize(self.text or "")

    local trackH = 16
    local gap = 6

    local size = self.size
    size[1] = size[1] or 0
    size[2] = th + gap + trackH
end

function slidermt:getvalue()
    return self.value
end

function slidermt:setvalue(v, silent)
    local min, max = self.min, self.max
    if (min > max) then
        min, max = max, min
    end

    v = clamp(v, min, max)
    v = quantize(v, self.step)
    v = clamp(v, min, max)

    if (self.value == v) then
        return v
    end

    self.value = v
    if (not silent) then
        self.callback(v)
    end
    return v
end

function slidermt:setrange(min, max)
    self.min = min
    self.max = max
    self:setvalue(self.value, true)
end

function slidermt:setstep(step)
    self.step = step
    self:setvalue(self.value, true)
end

function slidermt:setdecimals(decimals)
    self.decimals = decimals or 0
end

function slidermt:setsuffix(suffix)
    self.suffix = suffix or ""
end

local dragging = false
local dragtarget = nil
local holdtarget = nil
local holdkind = nil
local holdnext = 0

local HOLD_INITIAL_DELAY = 0.35
local HOLD_REPEAT_DELAY = 0.06

local function setFromMouseX(self, mx)
    local track = self.__track
    if (not track) then
        return
    end

    local tx, _, tw = track[1], track[2], track[3]
    if (tw <= 0) then
        return
    end

    local t = (mx - tx) / tw
    if (t < 0) then t = 0 end
    if (t > 1) then t = 1 end

    local v = self.min + (self.max - self.min) * t
    self:setvalue(v, false)
end

local function beginHold(self, kind)
    holdtarget = self
    holdkind = kind
    holdnext = CurTime() + HOLD_INITIAL_DELAY
end

local function clearHold(self)
    if (holdtarget == self) then
        holdtarget = nil
        holdkind = nil
        holdnext = 0
    end
end

local function stepHold(self, kind)
    if (kind == "plus") then
        self:setvalue(self.value + self.step, false)
    elseif (kind == "minus") then
        self:setvalue(self.value - self.step, false)
    end
end

local function updateHold(self)
    if (holdtarget ~= self) or (not holdkind) then
        return false
    end

    if (not vanity.mousedown()) then
        clearHold(self)
        return false
    end

    local now = CurTime()
    if (now < holdnext) then
        return false
    end

    stepHold(self, holdkind)
    holdnext = now + HOLD_REPEAT_DELAY
    return true
end

function slidermt:__render(x, y, w, h)
    self.__computedx = x
    self.__computedy = y
    self.__computedwidth = w
    self.__computedheight = h

    local style = vanity.style

    surface.SetFont(style.text)
    local _, th = surface.GetTextSize(self.text or "")

    local btn = th
    local btnGap = 4
    local trackH = 12
    local gap = 6

    local plusX = x + w - (btn * 2) - btnGap
    local minusX = x + w - btn
    local btnY = y

    self.__plus = { plusX, btnY, btn, btn }
    self.__minus = { minusX, btnY, btn, btn }

    local trackX = x
    local trackY = y + th + gap
    local trackW = w
    self.__track = { trackX, trackY, trackW, trackH }

    -- label
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(x, y)
    surface.DrawText(self.text or "")

    local mx, my = vanity.mousepos()
    local plusHot = vanity.ishovered(self.__plus[1], self.__plus[2], self.__plus[3], self.__plus[4])
    local minusHot = vanity.ishovered(self.__minus[1], self.__minus[2], self.__minus[3], self.__minus[4])
    local plusIsHot = plusHot and self.__hoverframe == FrameNumber()
    if plusIsHot then
        vanity.__setdrawcolor(style.accent)
    else
        vanity.__setdrawcoloralpha(style.accent, 155)
    end
    surface.DrawRect(self.__plus[1], self.__plus[2], self.__plus[3], self.__plus[4])
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(self.__plus[1], self.__plus[2], self.__plus[3], self.__plus[4])
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(self.__plus[1] - 1, self.__plus[2] - 1, self.__plus[3] + 2, self.__plus[4] + 2)
    vanity.__drawgradient(self.__plus[1] + 1, self.__plus[2] + 1, self.__plus[3] - 2, self.__plus[4] - 2, 1)
    surface.SetFont(style.text)
    local tw, tH = surface.GetTextSize("+")
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(self.__plus[1] + (self.__plus[3] * 0.5) - (tw * 0.5), self.__plus[2] + (self.__plus[4] * 0.5) - (tH * 0.5) - 1)
    surface.DrawText("+")

    local minusIsHot = minusHot and self.__hoverframe == FrameNumber()
    if minusIsHot then
        vanity.__setdrawcolor(style.accent)
    else
        vanity.__setdrawcoloralpha(style.accent, 155)
    end
    surface.DrawRect(self.__minus[1], self.__minus[2], self.__minus[3], self.__minus[4])
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(self.__minus[1], self.__minus[2], self.__minus[3], self.__minus[4])
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(self.__minus[1] - 1, self.__minus[2] - 1, self.__minus[3] + 2, self.__minus[4] + 2)
    vanity.__drawgradient(self.__minus[1] + 1, self.__minus[2] + 1, self.__minus[3] - 2, self.__minus[4] - 2, 1)
    surface.SetFont(style.text)
    tw, tH = surface.GetTextSize("-")
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(self.__minus[1] + (self.__minus[3] * 0.5) - (tw * 0.5), self.__minus[2] + (self.__minus[4] * 0.5) - (tH * 0.5) - 1)
    surface.DrawText("-")

    -- slider track background
    vanity.__setdrawcolor(style.background2)
    surface.DrawRect(trackX, trackY, trackW, trackH)

    -- fill
    local min, max = self.min, self.max
    if (min > max) then
        min, max = max, min
    end
    local denom = (max - min)
    local frac = 0
    if (denom ~= 0) then
        frac = (self.value - min) / denom
    end
    if (frac < 0) then frac = 0 end
    if (frac > 1) then frac = 1 end
    local fillW = floor((trackW - 2) * frac)
    if (fillW > 0) then
        vanity.__setdrawcolor(style.accent)
        surface.DrawRect(trackX + 1, trackY + 1, fillW, trackH - 2)
    end

    -- outlines: grey inner, black outer
    vanity.__setdrawcolor(style.outline1)
    surface.DrawOutlinedRect(trackX, trackY, trackW, trackH)
    vanity.__setdrawcolor(style.outline2)
    surface.DrawOutlinedRect(trackX - 1, trackY - 1, trackW + 2, trackH + 2)

    -- subtle gradient pass
    vanity.__drawgradient(trackX + 1, trackY + 1, trackW - 2, trackH - 2, 0.85)

    -- value text centered on the bar
    local valueText = formatValue(self.value, self.decimals, self.suffix)
    surface.SetFont(style.text)
    local tw, tH = surface.GetTextSize(valueText)
    vanity.__settextcolor(style.textcolor)
    surface.SetTextPos(trackX + (trackW * 0.5) - (tw * 0.5), trackY + (trackH * 0.65) - (tH * 0.5) - 1)
    surface.DrawText(valueText)
end

function slidermt:__checkinput()
    local x = self.__computedx
    local y = self.__computedy
    local w = self.__computedwidth
    local h = self.__computedheight

    if (dragging and dragtarget == self) then
        if (vanity.mousedown()) then
            local mx = (vanity.mousepos())
            setFromMouseX(self, mx)
            return true
        else
            dragging = false
            dragtarget = nil
        end
    end

    if (updateHold(self)) then
        return true
    end

    if (not vanity.ishovered(x, y, w, h)) then
        return
    end

    local plus = self.__plus
    local minus = self.__minus
    local track = self.__track
    if (not plus) or (not minus) or (not track) then
        return
    end

    local mx, my = vanity.mousepos()
    local overPlus = vanity.ishovered(plus[1], plus[2], plus[3], plus[4])
    local overMinus = vanity.ishovered(minus[1], minus[2], minus[3], minus[4])
    local overTrack = vanity.ishovered(track[1], track[2], track[3], track[4])

    if (overPlus or overMinus or overTrack) then
        self.__hoverframe = FrameNumber()
    end

    if (vanity.didclick()) then
        if (overPlus) then
            self:setvalue(self.value + self.step, false)
            beginHold(self, "plus")
            return true
        elseif (overMinus) then
            self:setvalue(self.value - self.step, false)
            beginHold(self, "minus")
            return true
        elseif (overTrack) then
            setFromMouseX(self, mx)
            dragging = true
            dragtarget = self
            clearHold(self)
            return true
        end
    elseif (vanity.mousedown()) then
        if (overTrack) then
            setFromMouseX(self, mx)
            dragging = true
            dragtarget = self
            clearHold(self)
            return true
        elseif (overPlus or overMinus) then
            if (overPlus and holdtarget ~= self) then
                beginHold(self, "plus")
            elseif (overMinus and holdtarget ~= self) then
                beginHold(self, "minus")
            end
            return true
        end
    else
        clearHold(self)
    end
end