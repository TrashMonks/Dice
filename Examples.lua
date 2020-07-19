#!/usr/bin/env lua
local Dice = require'Dice'

local example_dice_strings = {
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

local example_range_strings = {
    '1-6',
    '1-4',
    '1-3',
    '4-8',
}

local function print_distribution(string, dice)
        print('distribution:', string)
        print('minimum:', dice:minimum())
        print('average:', dice:average())
        print('maximum:', dice:maximum())
        print('range:', dice:range())
        print('variance:', dice:variance())
end

local function main()
    print'FROM DICE STRINGS\n'

    for i, dice_string in ipairs(example_dice_strings) do
        if i ~= 1 then
            print()
        end

        local dice = Dice.from_dice_string(dice_string)
        print_distribution(dice_string, dice)
    end

    print'\nFROM RANGE STRINGS\n'

    for i, range_string in ipairs(example_range_strings) do
        if i ~= 1 then
            print()
        end

        local dice = Dice.from_range_string(range_string)
        print_distribution(range_string, dice)
    end
end

-- If this module is run without arguments, run the main function.
if ... == nil then
    main()
end

return main
