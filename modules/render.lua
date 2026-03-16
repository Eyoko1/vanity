local vanity = vanity

local next = next
hook.pre("ljeutil/postrender", "__vanity_render", function()
    vanity.__checkchildreninput(vanity.windows)
    vanity.__drawchildren(vanity.windows, 0, 0, 0, 0)
end)