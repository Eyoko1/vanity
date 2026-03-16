local vanity = vanity


local next = next
hook.pre("ljeutil/postrender", "__vanity_render", function()
    --surface.SetDrawColor(0, 0, 0, 255) -- white color, fully opaque
    --surface.DrawRect(0, 0, ScrW(), ScrH()) -- full screen

    vanity.__checkchildreninput(vanity.windows)
    vanity.__drawchildren(vanity.windows, 0, 0, 0, 0)
end)