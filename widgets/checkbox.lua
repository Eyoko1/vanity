local checkboxmt = {
    name = "",
    parent = nil,
    checked = false,
}

checkboxmt.__index = checkboxmt
vanity.metatables.label = checkboxmt
lje.env.auth_metatable(checkboxmt)

function checkboxmt:__render()


end

