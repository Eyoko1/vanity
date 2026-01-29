local buttonmt = {
    name = "",
    parent = nil
}

buttonmt.__index = buttonmt
vanity.metatables.label = buttonmt
lje.env.auth_metatable(buttonmt)

function buttonmt:__render()

end

