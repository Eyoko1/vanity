local vanity = vanity


local next = next
hook.pre("lje-util/postrender", "__vanity_render", function()
    --surface.SetDrawColor(50, 50, 50, 255)
    --surface.DrawRect(0, 0, ScrW(), ScrH())

    local popups = vanity.__popups
    local popupcaptured = false
    if (popups and popups[1]) then
        -- Popups must capture input even outside their parent group,
        -- otherwise clicks "fall through" to underlying widgets.
        local i = 1
        local count = #popups
        ::check_popups_input::
        local w = popups[i]
        if (w and w.__checkinputpopup and w:__checkinputpopup()) then
            popupcaptured = true
            goto after_popup_input
        end
        if (i ~= count) then
            i = i + 1
            goto check_popups_input
        end
    end

    ::after_popup_input::
    if (not popupcaptured) then
        vanity.__checkchildreninput(vanity.windows)
    end
    vanity.__drawchildren(vanity.windows, 0, 0, 0, 0)

    if (popups and popups[1]) then
        -- Draw popups last so they appear above all UI.
        render.SetScissorRect(0, 0, 0, 0, false)
        local i = 1
        local count = #popups
        ::draw_popups::
        local w = popups[i]
        if (w and w.__renderoverlay) then
            w:__renderoverlay()
        end
        if (i ~= count) then
            i = i + 1
            goto draw_popups
        end
    end
end)