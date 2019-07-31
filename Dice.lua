--[[
    Dice.lua

    The core repository and documentation for this Lua module can be found at:
    https://bitbucket.org/HeladoDeBrownie/dice/

--]]
local Dice = {}
Dice.__index = Dice

--# Private

local function newDice(diceTable)
    return setmetatable({diceTable = diceTable}, Dice)
end

--# Interface

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

Dice.fromString = Dice.fromDiceString

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

function Dice:mean()
    local sum = 0

    for _, subdice in ipairs(self.diceTable) do
        sum = sum + subdice.quantity * (1 + subdice.size) / 2
    end

    return sum
end

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
