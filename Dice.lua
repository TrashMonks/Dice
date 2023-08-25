-- The implementation of this module makes use of a class metaphor. All a class
-- really is is a table meant to be used as a metatable.

-- # Helper Functions

-- Instantiate the given class, passing the given arguments to its 'initialize'
-- method.
local function new(class, ...)
    local result = setmetatable({}, {__index = class})
    result:initialize(...)
    return result
end

-- Derive the given class, adding a 'new' method to the child class.
local function derive(class)
    return setmetatable({new = new}, {__index = class})
end

-- Return a function usable as a method that always gives an error.
local function unimplemented(method_name)
    assert(type(method_name) == 'string')

    return function ()
        error('unimplemented: ' .. method_name)
    end
end

-- Return a function usable as a method that calls the given method.
local function alias(method_name)
    return function (self, ...)
        return self[method_name](self, ...)
    end
end

-- Is the given value an integer?
local function is_integer(value)
    return type(value) == 'number' and value == math.floor(value)
end

-- Is the given value an integer at least a certain amount?
local function is_integer_at_least(lower_bound, value)
    return is_integer(value) and value >= lower_bound
end

-- Is the given value a natural number, i.e., an integer at least 0?
local function is_natural(value)
    return is_integer_at_least(0, value)
end

-- Does the given value represent an expression in the dice DSL?
-- NOTE: This function exists mostly to mark intent. It doesn't actually check
-- if the given table has all the methods expected of an expression.
local function is_expression(value)
    return type(value) == 'table'
end

-- Every distribution we care about is symmetric, so its mean is the mean of
-- its minimum and maximum.
local function mean(expression)
    return (expression:maximum() + expression:minimum()) / 2
end

-- The range of a distribution is the distance between its minimum and maximum.
local function range(expression)
    return expression:maximum() - expression:minimum()
end

-- The standard deviation of a distribution is the square root of its variance.
local function standard_deviation(expression)
    return math.sqrt(expression:variance())
end

-- Given two dice expressions, signal which is "better", as judged by the
-- following metrics:
-- - greater mean
-- - smaller range
-- - less variance
-- The first return value will be 1 if the first argument is better, -1 if the
-- second is, or 0 if they're indistinguishable. The second return value is a
-- string describing the metric by which the better one won.
function compare(dice_a, dice_b)
    local mean_a, mean_b = dice_a:mean(), dice_b:mean()

    if mean_a > mean_b then
        return 1, 'greater mean'
    elseif mean_b > mean_a then
        return -1, 'greater mean'
    else
        local range_a, range_b = dice_a:range(), dice_b:range()

        if range_a < range_b then
            return 1, 'smaller range'
        elseif range_b < range_a then
            return -1, 'smaller range'
        else
            local variance_a, variance_b =
                dice_a:variance(), dice_b:variance()

            if variance_a < variance_b then
                return 1, 'less variance'
            elseif variance_b < variance_a then
                return -1, 'less variance'
            else
                return 0, 'no difference'
            end
        end
    end
end

-- # Dice Expression DSL

-- ## BaseExpression

local BaseExpression = {
    -- These definitions don't need to be overridden by derived classes.
    mean = mean,
    range = range,
    standard_deviation = standard_deviation,
    compare = compare,

    -- Derived classes must provide definitions for these.
    initialize = unimplemented('initialize'),
    minimum = unimplemented('minimum'),
    maximum = unimplemented('maximum'),
    variance = unimplemented('variance'),
    roll = unimplemented('roll'),

    -- Methods can be called by various names.
    average = alias('mean'),
    ev = alias('mean'),
    expected_value = alias('mean'),
    sd = alias('standard_deviation'),
    min = alias('minimum'),
    max = alias('maximum'),
    sample = alias('roll'),
}

-- ## Constant

local Constant = derive(BaseExpression)

function Constant:initialize(constant)
    assert(is_integer(constant))
    self.constant = constant
end

function Constant:minimum()
    return self.constant
end

function Constant:maximum()
    return self.constant
end

function Constant:variance()
    return 0
end

function Constant:roll()
    return self.constant
end

-- ## DiceRoll

local DiceRoll = derive(BaseExpression)

function DiceRoll:initialize(quantity, sides)
    assert(is_natural(quantity))
    assert(is_natural(sides) and sides >= 1)
    self.quantity = quantity
    self.sides = sides
end

function DiceRoll:minimum()
    return math.min(self.quantity * 1, self.quantity * self.sides)
end

function DiceRoll:maximum()
    return math.max(self.quantity * 1, self.quantity * self.sides)
end

function DiceRoll:variance()
    local single_die_mean = (1 + self.sides) / 2
    local sum = 0

    for n = 1, self.sides do
        sum = sum + (n - single_die_mean) ^ 2
    end

    return math.abs(self.quantity) * sum / self.sides
end

function DiceRoll:roll()
    local sum = 0

    for n = 1, math.abs(self.quantity) do
        sum = sum + math.random(1, self.sides)
    end

    if self.quantity >= 0 then
        return sum
    else
        return -sum
    end
end

-- ## Addition

local Addition = derive(BaseExpression)

function Addition:initialize(operand_a, operand_b)
    assert(is_expression(operand_a))
    assert(is_expression(operand_b))
    self.operand_a = operand_a
    self.operand_b = operand_b
end

function Addition:minimum()
    return self.operand_a:minimum() + self.operand_b:minimum()
end

function Addition:maximum()
    return self.operand_a:maximum() + self.operand_b:maximum()
end

function Addition:variance()
    return self.operand_a:variance() + self.operand_b:variance()
end

function Addition:roll()
    return self.operand_a:roll() + self.operand_b:roll()
end

-- ## Negation

local Negation = derive(BaseExpression)

function Negation:initialize(operand)
    assert(is_expression(operand))
    self.operand = operand
end

function Negation:minimum()
    return -self.operand:maximum()
end

function Negation:maximum()
    return -self.operand:minimum()
end

function Negation:variance()
    return self.operand:variance()
end

function Negation:roll()
    return -self.operand:roll()
end

-- ## Multiplication

local Multiplication = derive(BaseExpression)

function Multiplication:initialize(expression, constant)
    assert(is_expression(expression))
    assert(is_natural(constant))
    self.expression = expression
    self.constant = constant
end

function Multiplication:minimum()
    if self.constant >= 0 then
        return self.expression:minimum() * self.constant
    else
        return self.expression:maximum() * self.constant
    end
end

function Multiplication:maximum()
    if self.constant >= 0 then
        return self.expression:maximum() * self.constant
    else
        return self.expression:minimum() * self.constant
    end
end

function Multiplication:variance()
    return self.expression:variance() * self.constant * self.constant
end

function Multiplication:roll()
    return self.expression:roll() * self.constant
end

-- # Parsing

local Dice = {}

local function try_integer(input)
    return input ~= nil and tonumber(input:match'^[+-]?%d+$') or nil
end

local function try_natural(input)
    return input ~= nil and tonumber(input:match'^%d+$') or nil
end

function Dice.parse(input)
    input = input:gsub('%s', '')
    local x, y

    -- addition
    x, y = input:match'^([^+]+)+(.+)$'
    if x ~= nil then
        return Addition:new(Dice.parse(x), Dice.parse(y))
    end

    -- subtraction
    x, y = input:match'^([^-]+)-(.+)$'
    if x ~= nil and input:match'd' then
        return Addition:new(Dice.parse(x), Negation:new(Dice.parse(y)))
    end

    -- multiplication
    x, y = input:match'^([^x]+)x(.+)$'
    y = try_integer(y)
    if x ~= nil and y ~= nil then
        return Multiplication:new(Dice.parse(x), y)
    end

    -- range
    x, y = input:match'^([^-]+)-(.+)$'
    x, y = try_natural(x), try_natural(y)
    if x ~= nil and y ~= nil then
        return Addition:new(DiceRoll:new(1, y - x + 1), Constant:new(x - 1))
    end

    -- dice
    x, y = input:match'^([^d]+)d(.+)$'
    x, y = try_integer(x), try_natural(y)
    if x ~= nil and y ~= nil then
        return DiceRoll:new(x, y)
    end

    -- constant
    x = try_integer(input)
    if x ~= nil then
        return Constant:new(x)
    end

    error(([[

I couldn't understand this as part of an expression:
%s]]):format(input))
end

return Dice
