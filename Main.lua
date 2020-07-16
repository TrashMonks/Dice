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
    '2 + 3d2 + 2d6',
    '2+3d2+2d6',
    '0d1',
    '0d11',
}

local sampleRangeStrings = {
    '1-6',
    '1-4',
    '1-3',
    '4-8',
}

local function printDistribution(string, dice)
        print('distribution:', string)
        print('minimum:', dice:minimum())
        print('average:', dice:average())
        print('maximum:', dice:maximum())
end

local function main()
    print'FROM DICE STRINGS\n'

    for i, diceString in ipairs(sampleDiceStrings) do
        if i ~= 1 then
            print()
        end

        local dice = Dice.fromDiceString(diceString)
        printDistribution(diceString, dice)
    end

    print'\nFROM RANGE STRINGS\n'

    for i, rangeString in ipairs(sampleRangeStrings) do
        if i ~= 1 then
            print()
        end

        local dice = Dice.fromRangeString(rangeString)
        printDistribution(rangeString, dice)
    end
end

-- If this module is run without arguments, run the main function.
if ... == nil then
    main()
end

return main
