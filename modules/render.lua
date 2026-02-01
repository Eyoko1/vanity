local vanity = vanity

local next = next
hook.pre("ljeutil/render", "__vanity_render", function()
    vanity.__drawchildren(vanity.windows, 0, 0, 0, 0)
    vanity.__checkchildreninput(vanity.windows)
end)