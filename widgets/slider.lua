local vanity = vanity

local slidermt = {
    parent = nil,

    position = vanity.vector(0, 0),
    size = vanity.vector(0, 0),

    value = 1.0,
    min = 1.0,
    max = 100.0
}

slidermt.__index = slidermt
vanity.metatables.slidermt = slidermt
lje.env.auth_metatable(slidermt)