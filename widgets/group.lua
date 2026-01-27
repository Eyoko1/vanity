--- A group is a rectangular box with children inside of it.
local vanity = vanity

local groupmt = {
    name = "Default",
    parent = nil
}

groupmt.__index = groupmt
vanity.metatables.group = groupmt
lje.env.auth_metatable(groupmt)