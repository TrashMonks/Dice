--[[
    Dice.lua

    The core repository for this Lua module can be found at:
    https://bitbucket.org/HeladoDeBrownie/dice/

--]]
local Dice = {}
Dice.__index = Dice

--# Private

local function newDice(diceTable)
    return setmetatable({diceTable = diceTable}, Dice)
end

--# Interface

--[[
    Get a dice distribution from a dice string, which is in the form of a list
    of terms separated by + and -. Each term is either:

    - a dice roll expression of the form XdY, where X and Y are integers;
    - or a constant integer X, which is interpreted as Xd1.

    The terms are added and subtracted, as specified by + and - respectively,
    to form a compound dice distribution.

    For example, Dice.fromDiceString'5d3+1d2-1' gets the distribution that's
    represented by rolling 5 3-sided dice, rolling a 2-sided die, and
    subtracting 1 from their sum.
--]]
function Dice.fromDiceString(diceString)
    local diceTable = {}

    for term in diceString:gsub('%s', ''):gmatch'[+-]?[^+-]+' do
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

    return newDice(diceTable)
end

-- Dice.fromString is an alias for Dice.fromDiceString.
Dice.fromString = Dice.fromDiceString

--[[
    Get a dice distribution from a range string, which is of the form X-Y,
    where X and Y are nonnegative integers.

    This has the limitation that it doesn't accept negative numbers. To specify
    a distribution involving negative numbers, use the more general
    Dice.fromDiceString instead.

    For example, Dice.fromRangeString'4-8' gets the distribution that gives
    integers 4 through 8 with equal probability, equivalent to the distribution
    given by the dice string '1d5+3'.
--]]
function Dice.fromRangeString(rangeString)
    local minimum, maximum = rangeString:gsub('%s', ''):match'^(%d+)-(%d+)$'

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
        error("I couldn't make sense of this as a range string: "
            .. rangeString)
    end
end

-- Get the minimum possible value of the distribution.
function Dice:minimum()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        if subdice.quantity >= 0 then
            sum = sum + subdice.quantity * 1
        else
            sum = sum + subdice.quantity * subdice.size
        end
    end

    return sum
end

--[[
    Get the mean value of the distribution, defined as the mean of all the
    possible values the distribution can take on weighted by their probability.
--]]
function Dice:mean()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * (1 + subdice.size) / 2
    end

    return sum
end

-- Get the maximum possible value of the distribution.
function Dice:maximum()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        if subdice.quantity >= 0 then
            sum = sum + subdice.quantity * subdice.size
        else
            sum = sum + subdice.quantity * 1
        end
    end

    return sum
end

--# Export

return Dice
