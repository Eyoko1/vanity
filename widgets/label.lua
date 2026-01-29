local labelmt = {
    text = "",
    parent = nil
}

labelmt.__index = labelmt
vanity.metatables.label = labelmt
lje.env.auth_metatable(labelmt)

function labelmt:__render()

end

