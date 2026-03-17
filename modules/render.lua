local vanity = vanity


local next = next
hook.pre("ljeutil/postrender", "__vanity_render", function()
    --surface.SetDrawColor(50, 50, 50, 255)
    --surface.DrawRect(0, 0, ScrW(), ScrH())

    vanity.__checkchildreninput(vanity.windows)
    vanity.__drawchildren(vanity.windows, 0, 0, 0, 0)
end)