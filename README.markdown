This Lua library computes basic dice roll statistics: the average, maximum, minimum, and range of a dice roll.

# Documentation

Import the module like so:

    local Dice = require'Dice'

The actual import code may vary depending on your Lua environment.

## Computing the statistics of a roll

The following functions can be called on either a string representing a dice roll, or a dice roll value as given by the functions in the section [Parsing a roll from a string](#parsing-a-roll-from-a-string).

### `Dice.average`

(Also called `Dice.ev`, `Dice.expected_value`, and `Dice.mean`.)

Compute the average value of all possible rolls.

Conceptually, this is the sum of all the possible rolls that can be made, weighted by how likely they are, divided by the total weight of all possible rolls.

For example:

- `Dice.average'1d6'` gives `3.5`, because all the possible rolls are 1, 2, 3, 4, 5, and 6, whose sum is 21, which is then divided by 6, which is the number of distinct rolls. 21 divided by 6 is 3.5.
- `Dice.average'3d4'` gives `7.5`, which is the average of 1d4, multiplied by 3.
- `Dice.average'3d4-1d3'` gives `5.5`, which is the difference of the average of the individual rolls 3d4 and 1d3.

### `Dice.maximum`

Compute the maximum possible value that can be rolled.

That is, all dice whose values are added to the total take on their greatest value; all that are *subtracted* from the total take on their *least* value.

For example:

- `Dice.maximum'1d6'` gives `6`, the greatest number that can be rolled on a six-sided die.
- `Dice.maximum'3d4'` gives `12`, because each of three dice is rolling a 4.
- `Dice.maximum'3d4-1d3'` gives `11`, because each of the three positive dice roll a 4, and the one negative die rolls a 1, giving three times four minus one.

### `Dice.minimum`

(Also called `Dice.min`.)

Compute the minimum possible value that can be rolled.

That is, all dice whose values are added to the total take on their least value; all that are *subtracted* from the total take on their *greatest* value.

For example:

- `Dice.minimum'1d6'` gives `1`, the least number that can be rolled on a polyhedral die.
- `Dice.minimum'3d4'` gives `3`, because each of three dice is rolling a 1.
- `Dice.minimum'3d4-1d3'` gives `0`, because each of the three positive dice roll a 1 and the one negative die rolls its maximum value, a 3, which cancels the 3 contributed by the positive dice.

### `Dice.range`

Compute the number of possible distinct values the dice roll can take on.

This is the same as subtracting its minimum from its maximum and adding one.

For example:

- `Dice.range'1d6'` gives `6`, because there are 6 possible values on a six-sided die.
- `Dice.range'3d4'` gives `10`, because even though some of the possible totals of the three dice are more likely than others, there are still only 10 distinct ones.
- `Dice.range'3d4-1d3'` gives `12`, because subtracting 1d3 gives two more possibilities (not three!).

### `Dice.variance`

Compute the variance of the dice roll's probability distribution. This is the sum of the variances of all the individual dice rolled, where each die's variance is equal to the sum of the squares of each possible result's difference from the die's mean result weighted by how probable they are.

This description may be a mouthful, but variance is a useful measure in statistics and thus is provided both for completeness and for its usefulness in [`Dice.compare`](#dicecompare).

### `Dice.compare`

Compute which of two dice rolls is “better” using the following metrics, in order of applicability:

- greater average
- smaller range
- less variance

If all of these are equal, the two distributions are the same.

The result is two values. The first is a number, which is:

- -1 if the second argument is better;
- 0 if neither is better;
- or 1 if the first argument is better.

The second is a string describing which metric was used to determine the result: either one of the above metrics as a string or `'no difference'`.

For example:

- `Dice.compare('1d6', '1d4')` returns `1, 'greater average'` because the average of 1d6 is greater than that of 1d4.
- `Dice.compare('1d5', '1d3+1')` returns `-1, 'smaller range'` because the averages are the same and the range of 1d3+1 is smaller than that of 1d5.
- `Dice.compare('1d3+1', '2d2')` returns `-1, 'less variance'` because everything is the same except the variance, which is smaller for 2d2.
- `Dice.compare('1d3', '4-1d3')` returns `0, 'no difference'` because both rolls represent the same probability distribution.

## Parsing a roll from a string

### `Dice.from_dice_string`

(Also called `Dice.from_string`.)

`Dice.from_dice_string` is the more general of the parsing functions and can be used to return any roll resulting from addition and subtraction of rolls of conventional polyhedral dice and constants.

    local dice_roll = Dice.from_dice_string(dice_string)

Get a dice roll based on the given dice string, which is a list of terms separated by `+` or `-`, where each term is either:

- a constant term comprising one or more decimal digits (such as `0`, `1`, `36`, or `123`), representing a fixed amount;
- or a dice term comprising two constants as just described, separated by `d` as in the common tabletop roleplaying convention (such as `1d6`, `2d4`, or `36d15`), representing the rolling of a certain quantity (the first constant) of dice of a certain number of sides (the second constant).

(Whitespace is completely ignored and thus may appear *anywhere* in the string.)

Example valid dice strings include `0`, `1d6`, `2d4 + 1`, `1d2-1`, and `6 -1d4`.

This function is implicitly called by all functions in the section [Computing the statistics of a roll](#computing-the-statistics-of-a-roll) when passed a string. It may still be useful if you wish to call several methods on the same dice roll without implicitly creating multiple copies of the same dice roll value.

### `Dice.from_range_string`

`Dice.from_range_string` is more specialized than `Dice.from_dice_string` but uses a more conventional syntax for a specific type of random choice.

    local dice_roll = Dice.from_range_string(range_string)

Get a dice roll based on the given range string, which is two constant terms (as in `Dice.from_dice_string`) separated by `-`, representing a roll with equal possibility of giving any of the integers starting at one limit and ending at the other. (Note: Both constants must be non-negative.)

(Whitespace is ignored the same as with `Dice.from_dice_string`.)

Example valid range strings include `1-6`, `4 - 8`, `2-2`, `0-0`.

(Note: Take care not to confuse the use of `-` here for the way it's used to represent a minus sign in the other parser's syntax.)

# Examples

See [`Examples.lua`](Examples.lua) for a complete example of a program that uses this library. It's runnable using the base Lua distribution's command line program.
