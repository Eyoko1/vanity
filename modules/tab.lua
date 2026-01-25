local vanity = vanity

local tabmt = {
    name = "Tab"
    window = nil,
}
windowmt.__index = windowmt
vanity.metatables.window = windowmt
lje.env.auth_metatable(windowmt)