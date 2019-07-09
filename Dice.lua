#!/usr/bin/env lua
local Dice = {}
Dice.__index = Dice

--# Interface

--[[
    Get a dice distribution from a dice string, which is in the form of a list
    of terms separated by + and -. Each term is either:

    - a dice roll expression of the form XdY, where X and Y are integers;
    - or a constant integer X, which is interpreted as Xd1.

    The terms are added and subtracted, as specified by + and - respectively,
    to form a compound dice distribution.
--]]
function Dice.fromString(diceString)
    local diceTable = {}

    for term in diceString:gmatch'[+-]?[^+-]+' do
        local quantity, size = term:match'^([+-]?%d+)d(%d+)$'

        if quantity ~= nil and size ~= nil then
            diceTable[#diceTable + 1] = {
                quantity = tonumber(quantity, 10),
                size = tonumber(size, 10),
            }
        else
            local quantity = term:match'^([+-]?%d+)$'

            if quantity ~= nil then
                diceTable[#diceTable + 1] = {
                    quantity = tonumber(quantity, 10),
                    size = 1,
                }
            else
                error([[

I couldn't make sense of this as a dice string: ]] .. diceString .. [[

In particular, this part doesn't look like a term I understand: ]] .. term)
            end
        end
    end

    return Dice.new(diceTable)
end

function Dice.new(diceTable)
    return setmetatable({diceTable = diceTable}, Dice)
end

-- Get the minimum possible value of the distribution.
function Dice:minimum()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * 1
    end

    return sum
end

--[[
    Get the mean value of the distribution, defined as the mean of all the
    possible values the distribution can take on weighted by their probability.
--]]
function Dice:mean()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * (1 + subdice.size) / 2
    end

    return sum
end

-- Get the maximum possible value of the distribution.
function Dice:maximum()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * subdice.size
    end

    return sum
end

--# Main

-- If this module is run without arguments, run some sample cases.
if ... == nil then
    for i, diceString in ipairs{
        '1d6',
        '1d4',
        '1d3',
        '2d6',
        '2d3',
        '1d6+1',
        '1d6-1d4',
        '5d3+1d2-1',
        '1d10-1d7+8',
        '7-7-7',
        '0',
        '-1',
    } do
        if i ~= 1 then
            print()
        end

        local dice = Dice.fromString(diceString)
        print('distribution:', diceString)
        print('minimum:', dice:minimum())
        print('mean:', dice:mean())
        print('maximum:', dice:maximum())
    end
end

--# Export

return Dice
