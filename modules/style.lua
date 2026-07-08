--- @class Vanity.Style
--- @field accent Vanity.Color
--- @
--- @field background_1 Vanity.Color
--- @field background_2 Vanity.Color
--- @
--- @field outline_1 Vanity.Color
--- @field outline_2 Vanity.Color
--- @
--- @field text_color Vanity.Color
--- @field text_color_disabled Vanity.Color
--- @
--- @field tab_active Vanity.Color
--- @field tab_inactive Vanity.Color
--- @
--- @field gradient Vanity.Color
--- @
--- @field text Vanity.Font
--- @field text_group Vanity.Font
--- @field text_tab Vanity.Font
--- @
--- @field inset_1 number
--- @field inset_2 number
--- @field tab_height number

--- @class Vanity.StyleData

--- @type Vanity.Style
local StyleMT = {
    accent = vanity.color(92, 122, 219, 255),

    background_1 = vanity.color(30, 30, 30, 255),
    background_2 = vanity.color(26, 26, 26, 255),

    outline_1 = vanity.color(60, 60, 60, 255),
    outline_2 = vanity.color(0, 0, 0, 255),

    text_color = vanity.color(255, 255, 255, 255),
    text_color_disabled = vanity.color(160, 160, 160, 255),

    tab_active = vanity.color(30, 30, 30, 255),
    tab_inactive = vanity.color(25, 25, 25, 255),

    gradient = vanity.color(10, 10, 10, 120),

    text = vanity.font("text", {
        font = "Verdana",
        size = 13,
        antialias = false,
        outline = true
    }),
    text_group = vanity.font("text_group", {
        font = "Verdana",
        size = 13,
        weight = 400,
        antialias = false,
        outline = true
    }),
    text_tab = vanity.font("text_tab", {
        font = "Verdana",
        size = 13,
        antialias = false,
        outline = true
    }),

    inset_1 = 8,
    inset_2 = 4,
    tab_height = 26
}

--- @param data Vanity.StyleData?
--- @return Vanity.Style
function vanity.style(data)
    --- @type Vanity.Style
    local style = vanity.inherit(data or {}, StyleMT)
    return style
end
