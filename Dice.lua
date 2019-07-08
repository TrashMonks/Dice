#!/usr/bin/env lua
local Dice = {}
Dice.__meta = Dice

--# Interface

function Dice.fromString(diceString)
    error'UNIMPLEMENTED: Dice.fromString'
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
