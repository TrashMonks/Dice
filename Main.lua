#!/usr/bin/env lua
local Dice = require'Dice'

local sampleDiceStrings = {
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
    '1d6-1d6',
}

local function main()
    for i, diceString in ipairs(sampleDiceStrings) do
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

-- If this module is run without arguments, run the main function.
if ... == nil then
    main()
end

return main
