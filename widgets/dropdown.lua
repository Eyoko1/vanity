local dropdownmt = {
    name = "",
    parent = nil,

    options = {},
    activeoption = nil 
}

dropdownmt.__index = dropdownmt
vanity.metatables.dropdown = dropdownmt
lje.env.auth_metatable(dropdownmt)

function dropdownmt:__render()
    --[[
        NOTE
        self.name is drawn above dropdown. 
    ]]
end

