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

local function newDice(diceList)
    local result = {}
    private[result] = {diceList = diceList}
    return setmetatable(result, dice_metatable)
end

local function mapSumDice(dice, mapper)
    local sum = 0

    for _, subdice in ipairs(private[dice].diceList) do
        sum = sum + mapper(subdice.quantity, subdice.size)
    end

    return sum
end

--# Exports

function Dice.fromDiceString(diceString)
    local diceList = {}

    for term in diceString:gsub('%s', ''):gmatch(DICE_TERM_PATTERN) do
        local quantity, size = term:match(XDY_PATTERN)

        if quantity ~= nil and size ~= nil then
            diceList[#diceList + 1] = {
                quantity = tonumber(quantity, 10),
                size = tonumber(size, 10),
            }
        else
            local quantity = term:match(CONSTANT_PATTERN)

            if quantity ~= nil then
                diceList[#diceList + 1] = {
                    quantity = tonumber(quantity, 10),
                    size = 1,
                }
            else
                error(DICE_STRING_PARSE_ERROR_FORMAT:format(diceString, term))
            end
        end
    end

    return newDice(diceList)
end

Dice.fromString = Dice.fromDiceString

function Dice.fromRangeString(rangeString)
    local minimum, maximum = rangeString:gsub('%s', ''):match(RANGE_PATTERN)

    if minimum ~= nil and maximum ~= nil then
        return newDice{
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
        error(RANGE_STRING_PARSE_ERROR_FORMAT:format(rangeString, term))
    end
end

function Dice:minimum()
    return mapSumDice(self, function (quantity, size)
        return math.min(quantity * 1, quantity * size)
    end)
end

Dice.min = Dice.minimum

function Dice:average()
    return mapSumDice(self, function (quantity, size)
        return quantity * ((1 + size) / 2)
    end)
end

Dice.ev = Dice.average
Dice.expectedValue = Dice.average
Dice.mean = Dice.average

function Dice:maximum()
    return mapSumDice(self, function (quantity, size)
        return math.max(quantity * 1, quantity * size)
    end)
end

Dice.max = Dice.maximum

return Dice
