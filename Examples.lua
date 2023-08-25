#!/usr/bin/env lua
local Dice = require'Dice'

local example_inputs = {
    '1d6',
    '1d4',
    '1d3x3',
    '2d6',
    '2d3',
    '1d6+1',
    '1d6-1d4',
    '5d3+1d2-1',
    '1d10-1d7+8',
    '0',
    '-1',
    '1d6-1d6',
    '2 + 3d2 + 2d6',
    '2+3d2+2d6',
    '0d1',
    '0d11',
    '1-6',
    '1-4',
    '1-3x2',
    '4-8',
}

local function print_distribution(string, dice)
        print('distribution:', string)
        print('minimum:     ', dice:minimum())
        print('average:     ', dice:average())
        print('maximum:     ', dice:maximum())
        print('range:       ', dice:range())
        print('variance:    ', dice:variance())
end

local function main()
    for i, input in ipairs(example_inputs) do
        if i ~= 1 then
            print()
        end

        local dice = Dice.parse(input)
        print_distribution(input, dice)
    end
end

-- If this module is run without arguments, run the main function.
if ... == nil then
    main()
end

return main
