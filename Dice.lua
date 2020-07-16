local Dice = {}
local dice_metatable = {__index = Dice}
local private = setmetatable({}, {__mode = 'k'})

local DICE_STRING_PARSE_ERROR_FORMAT = [[

I couldn't make sense of this as a dice string: %s
In particular, this part doesn't look like a term I understand: %s]]

local RANGE_STRING_PARSE_ERROR_FORMAT = [[

I couldn't make sense of this as a range string: %s]]

local DICE_TERM_PATTERN = '[+-]?[^+-]+'
local XDY_PATTERN = '^([+-]?%d+)d(%d+)$'
local CONSTANT_PATTERN = '^([+-]?%d+)$'

local RANGE_PATTERN = '^(%d+)-(%d+)$'

local function new_dice(dice_list)
    local result = {}
    private[result] = {dice_list = dice_list}
    return setmetatable(result, dice_metatable)
end

local function map_sum_dice(dice, mapper)
    local sum = 0

    for _, subdice in ipairs(private[dice].dice_list) do
        sum = sum + mapper(subdice.quantity, subdice.size)
    end

    return sum
end

--# Exports

function Dice.from_dice_string(dice_string)
    local dice_list = {}

    for term in dice_string:gsub('%s', ''):gmatch(DICE_TERM_PATTERN) do
        local quantity, size = term:match(XDY_PATTERN)

        if quantity ~= nil and size ~= nil then
            dice_list[#dice_list + 1] = {
                quantity = tonumber(quantity, 10),
                size = tonumber(size, 10),
            }
        else
            local quantity = term:match(CONSTANT_PATTERN)

            if quantity ~= nil then
                dice_list[#dice_list + 1] = {
                    quantity = tonumber(quantity, 10),
                    size = 1,
                }
            else
                error(DICE_STRING_PARSE_ERROR_FORMAT:format(dice_string, term))
            end
        end
    end

    return new_dice(dice_list)
end

Dice.from_string = Dice.from_dice_string

function Dice.from_range_string(range_string)
    local minimum, maximum = range_string:gsub('%s', ''):match(RANGE_PATTERN)

    if minimum ~= nil and maximum ~= nil then
        return new_dice{
            {
                quantity = 1,
                size = maximum - minimum + 1,
            },
            {
                quantity = minimum - 1,
                size = 1,
            },
        }
    else
        error(RANGE_STRING_PARSE_ERROR_FORMAT:format(range_string, term))
    end
end

function Dice:minimum()
    return map_sum_dice(self, function (quantity, size)
        return math.min(quantity * 1, quantity * size)
    end)
end

Dice.min = Dice.minimum

function Dice:average()
    return map_sum_dice(self, function (quantity, size)
        return quantity * ((1 + size) / 2)
    end)
end

Dice.ev = Dice.average
Dice.expected_value = Dice.average
Dice.mean = Dice.average

function Dice:maximum()
    return map_sum_dice(self, function (quantity, size)
        return math.max(quantity * 1, quantity * size)
    end)
end

Dice.max = Dice.maximum

return Dice
