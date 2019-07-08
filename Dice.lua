#!/usr/bin/env lua
local Dice = {}
Dice.__index = Dice

--# Interface

function Dice.fromString(diceString)
    local quantity, size = diceString:match'(%d+)d(%d+)'

    if quantity ~= nil and size ~= nil then
        return Dice.new(tonumber(quantity, 10), tonumber(size, 10))
    else
        error'UNIMPLEMENTED: Dice.fromString'
    end
end

function Dice.new(quantity, size)
    return setmetatable({
        quantity = quantity,
        size = size,
    }, Dice)
end

function Dice:minimum()
    return self.quantity * 1
end

function Dice:mean()
    return self.quantity * (1 + self.size) / 2
end

function Dice:maximum()
    return self.quantity * self.size
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
