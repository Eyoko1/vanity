--- @TODO: Allow for markup

--- @class Vanity.Label : Vanity.Widget
--- @field parent Vanity.Group?
--- @
--- @field text string
--- @field blocks Vanity.Label.Block[]
--- @field disabled boolean
--- @
--- @field disable fun(self: Vanity.Label): nil
--- @field enable fun(self: Vanity.Label): nil

--- @class Vanity.Label.Data
--- @field text string?
--- @field disabled boolean?

--- @class Vanity.Label.Block
--- @field text string
--- @field linebreak boolean
--- @field width number
--- @field height number

--- @type Vanity.Label
local LabelMT = {
    parent = nil,
    children = {},
    position = vanity.vector(0, 0),
    size = vanity.vector(0, 3),

    text = "",
    blocks = {},
    disabled = false,

    disable = function() end,
    enable = function() end,
    render = function() end,
    invalidatelayout = function() end
}

local GroupMT = vanity.metatables.group

--- @param data Vanity.Label.Data?
--- @return Vanity.Label
function GroupMT:label(data)
    local label = vanity.inherit(data or {}, LabelMT)
    self:addchild(label)

    label.parent = self
    label:invalidatelayout()

    return label
end

function LabelMT:disable()
    self.disabled = true
end

function LabelMT:enable()
    self.disabled = false
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param parenthovered boolean
--- @param style Vanity.Style
--- @return nil
function LabelMT:render(x, y, w, h, parenthovered, style)
    vanity.settextcolor(style.text_color)
    surface.SetFont(style.text)
    --surface.SetTextPos(x, y)
    --surface.DrawText(self.text)

    local drawx, drawy = x, y
    for i, block in ipairs(self.blocks) do
        surface.SetTextPos(drawx, drawy)
        surface.DrawText(block.text)
        if (block.linebreak) then
            drawx = x
            drawy = drawy + block.height
        else
            drawx = drawx + block.width
        end
    end
end

--- @return nil
function LabelMT:invalidatelayout()
    surface.SetFont(vanity.findstyle(self).text)
    local textwidth, textheight = surface.GetTextSize(self.text)
    --- @type Vanity.Group
    local parent = self.parent
    local width = parent:getwidth()
    local text = self.text
    local blocks = {}
    local nextnewline = string.find(text, "\n")

    --> Calculate the blocks required for this label's text
    --- @TODO: Clean this code up
    if (not nextnewline and textwidth <= width) then
        --> We can cleanly fit the text on one line
        self.size[2] = textheight
        table.insert(blocks, {
            text = text,
            linebreak = false,
            width = textwidth,
            height = textheight
        })
    else
        --> We are going to need to split this text across lines
        local totalheight = 0
        local split = string.Split(text, "\n")
        for i, subtext in ipairs(split) do
            local subwidth, subheight = surface.GetTextSize(subtext)
            if (subwidth <= width) then
                --> This substring can be simply fit onto a new line
                --- @type Vanity.Label.Block
                local block = {
                    text = subtext,
                    linebreak = true,
                    width = subwidth,
                    height = subheight
                }
                table.insert(blocks, block)
                totalheight = totalheight + subheight
            else
                --> This substring cannot simply fit onto a new line so we have to split it up
                local spacesplit = string.Split(subtext, " ")
                local spacewidth = surface.GetTextSize(" ")
                local block = {
                    text = "",
                    linebreak = false,
                    width = 0,
                    height = 0
                }
                for j, word in ipairs(spacesplit) do
                    local wordwidth, wordheight = surface.GetTextSize(word)
                    wordwidth = wordwidth + spacewidth
                    local blockwidth = block.width + wordwidth
                    if (blockwidth - spacewidth >= width) then
                        --> We need to move this word to the next line in one of two ways
                        if (wordwidth >= width) then
                            --> This word is so large that we cannot fit all of it onto one line, so let's break it up into smaller chunks
                            local splitcount = math.floor(wordwidth / width)
                            local length = #word
                            local start = 1
                            local stop = math.max(1, (length / splitcount) - 1)
                            for _ = 1, splitcount do
                                local section
                                local sectionwidth, sectionheight
                                while (true) do
                                    if (stop >= length) then
                                        break
                                    end

                                    section = string.sub(word, start, stop)
                                    sectionwidth, sectionheight = surface.GetTextSize(section)
                                    local freewidth = width - block.width
                                    if (sectionwidth <= freewidth) then
                                        if (surface.GetTextSize(string.sub(word, start, stop + 1)) > freewidth) then
                                            break
                                        else
                                            stop = stop + 1
                                        end
                                    else
                                        stop = stop - 1
                                    end
                                end

                                block.text = block.text .. section
                                block.linebreak = true
                                block.width = block.width + sectionwidth
                                block.height = math.max(block.height, sectionheight)
                                totalheight = totalheight + block.height
                                table.insert(blocks, block)
                                block = {
                                    text = "",
                                    linebreak = false,
                                    width = 0,
                                    height = 0
                                }
                                start = stop + 1
                                stop = start + ((length - start) / splitcount)
                            end

                            local section = string.sub(word, start, length)
                            local sectionwidth, sectionheight = surface.GetTextSize(section)
                            block.text = block.text .. section
                            block.linebreak = true
                            block.width = block.width + sectionwidth
                            block.height = math.max(block.height, sectionheight)
                            totalheight = totalheight + block.height
                            table.insert(blocks, block)
                            block = {
                                text = "",
                                linebreak = false,
                                width = 0,
                                height = 0
                            }
                        else
                            --> We can insert a linebreak so this next word starts on a new line
                            block.linebreak = true
                            totalheight = totalheight + block.height
                            table.insert(blocks, block)
                            block = {
                                text = word .. " ",
                                linebreak = false,
                                width = wordwidth,
                                height = wordheight
                            }
                        end
                    else
                        --> This word can fit on this line
                        block.text = block.text .. word .. " "
                        block.width = blockwidth
                        block.height = math.max(wordheight, block.height)
                    end
                end
                if (block.text ~= "") then
                    block.linebreak = true
                    table.insert(blocks, block)
                    totalheight = totalheight + block.height
                end
            end
        end
        self.size[2] = totalheight
    end

    self.blocks = blocks
    parent:invalidatelayout()
end