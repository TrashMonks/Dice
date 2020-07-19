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

-- Return a dice-string-compatible version of the given function.
local function dice_method(method)
    return function (dice)
        if type(dice) == 'string' then
            return method(Dice.from_dice_string(dice))
        else
            return method(dice)
        end
    end
end

local function map_sum_dice(dice, mapper)
    local sum = 0

    for _, subdice in ipairs(private[dice].dice_list) do
        sum = sum + mapper(subdice.quantity, subdice.size)
    end

    return sum
end

--# Exports

--## Computing the statistics of a roll

--### Dice.average

function Dice:average()
    return map_sum_dice(self, function (quantity, size)
        return quantity * ((1 + size) / 2)
    end)
end

Dice.average = dice_method(Dice.average)
Dice.ev = Dice.average
Dice.expected_value = Dice.average
Dice.mean = Dice.average

--### Dice.maximum

function Dice:maximum()
    return map_sum_dice(self, function (quantity, size)
        return math.max(quantity * 1, quantity * size)
    end)
end

Dice.maximum = dice_method(Dice.maximum)
Dice.max = Dice.maximum

--### Dice.minimum

function Dice:minimum()
    return map_sum_dice(self, function (quantity, size)
        return math.min(quantity * 1, quantity * size)
    end)
end

Dice.minimum = dice_method(Dice.minimum)
Dice.min = Dice.minimum

--### Dice.range

function Dice:range()
    return math.abs(self:maximum() - self:minimum() + 1)
end

Dice.range = dice_method(Dice.range)

--### Dice.variance

function Dice:variance()
    return map_sum_dice(self, function (quantity, size)
        local single_die_average = (1 + size) / 2
        local sum = 0

        for n = 1, size do
            sum = sum + (n - single_die_average) ^ 2 / size
        end

        return math.abs(quantity) * sum
    end)
end

Dice.variance = dice_method(Dice.variance)

--### Dice.roll

function Dice:roll()
    return map_sum_dice(self, function (quantity, size)
        local sum = 0

        for n = 1, math.abs(quantity) do
            sum = sum + math.random(1, size)
        end

        if quantity >= 0 then
            return sum
        else
            return -sum
        end
    end)
end

Dice.roll = dice_method(Dice.roll)
Dice.sample = Dice.roll

--### Dice.compare

function Dice.compare(dice_a, dice_b)
    local average_a, average_b = Dice.average(dice_a), Dice.average(dice_b)

    if average_a > average_b then
        return 1, 'greater average'
    elseif average_b > average_a then
        return -1, 'greater average'
    else
        local range_a, range_b = Dice.range(dice_a), Dice.range(dice_b)

        if range_a < range_b then
            return 1, 'smaller range'
        elseif range_b < range_a then
            return -1, 'smaller range'
        else
            local variance_a, variance_b =
                Dice.variance(dice_a), Dice.variance(dice_b)

            if variance_a < variance_b then
                return 1, 'less variance'
            elseif variance_b < variance_a then
                return -1, 'less variance'
            else
                return 0, 'no difference'
            end

            return 0, 'inconclusive'
        end
    end
end

--## Parsing a roll from a string

--### Dice.from_dice_string

function Dice.from_dice_string(dice_string)
    local dice_list = {}

    for term in dice_string:gsub('%s', ''):gmatch(DICE_TERM_PATTERN) do
        local quantity, size = term:match(XDY_PATTERN)

        if quantity ~= nil and size ~= nil then
            table.insert(dice_list, {
                quantity = tonumber(quantity, 10),
                size = tonumber(size, 10),
            })
        else
            local quantity = term:match(CONSTANT_PATTERN)

            if quantity ~= nil then
                table.insert(dice_list, {
                    quantity = tonumber(quantity, 10),
                    size = 1,
                })
            else
                error(DICE_STRING_PARSE_ERROR_FORMAT:format(dice_string, term))
            end
        end
    end

    return new_dice(dice_list)
end

Dice.from_string = Dice.from_dice_string

--### Dice.from_range_string

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

--##

return Dice
