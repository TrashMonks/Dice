#!/usr/bin/env lua
local Dice = {}
Dice.__index = Dice

--# Interface

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

function Dice:minimum()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * 1
    end

    return sum
end

function Dice:mean()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * (1 + subdice.size) / 2
    end

    return sum
end

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
