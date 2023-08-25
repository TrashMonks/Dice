This Lua library computes basic dice roll statistics: the mean, maximum, minimum, range, variance, and standard deviation of a dice roll.

# Documentation

## Parsing a roll from a string

### `Dice.parse`

`Dice.parse` is designed to emulate the dice parsing functionality in *Caves of Qud*. It supports, in order of precedence: addition (`+`), subtraction (`-`), multiplication by a constant (`x`), ranges (`-`), dice rolls (`d`), and constants (such as `1`, `25`, `-2`, etc.). (Subtraction and ranges are differentiated only by the fact that the character `d` appears in subtractions and not in ranges.)

(Whitespace is completely ignored and thus may appear *anywhere* in the string.)

Example valid dice strings include `0`, `1d6`, `2d4 + 1`, `1d2-1`, `6 -1d4`, and `1d6 + 1-3x3`.

    local Dice = require'Dice'
    local dice_roll = Dice.parse('1d6 + 1-3x3')
    print(dice_roll:mean()) -- -> 9.5

Unusual parses, such as that of `1d6-1d6-1d6`, *are not bugs* unless they behave differently from the game. When reporting a bug in the parser, please include a dice string that actually appears in the game files or code, and for which the game's parser and this parser behave differently.

## Computing the statistics of a roll

The following are all methods on the objects returned from `Dice.parse`.

### `mean`

(Also called `average`, `ev`, and `expected_value`.)

Compute the mean value of all possible rolls.

Conceptually, this is the sum of all the possible rolls that can be made, weighted by how likely they are, divided by the total weight of all possible rolls.

For example:

- `Dice.parse'1d6':mean()` gives `3.5`, because all the possible rolls are 1, 2, 3, 4, 5, and 6, whose sum is 21, which is then divided by 6, which is the number of distinct rolls. 21 divided by 6 is 3.5.
- `Dice.parse'3d4':mean()` gives `7.5`, which is the mean of 1d4, multiplied by 3.
- `Dice.parse'3d4-1d3':mean()` gives `5.5`, which is the difference of the mean of the individual rolls 3d4 and 1d3.

### `Dice.maximum`

(Also called `max`.)

Compute the maximum possible value that can be rolled.

That is, all dice whose values are added to the total take on their greatest value; all that are *subtracted* from the total take on their *least* value.

For example:

- `Dice.parse'1d6':maximum()` gives `6`, the greatest number that can be rolled on a six-sided die.
- `Dice.parse'3d4':maximum()` gives `12`, because each of three dice is rolling a 4.
- `Dice.parse'3d4-1d3':maximum()` gives `11`, because each of the three positive dice roll a 4, and the one negative die rolls a 1, giving three times four minus one.

### `minimum`

(Also called `min`.)

Compute the minimum possible value that can be rolled.

That is, all dice whose values are added to the total take on their least value; all that are *subtracted* from the total take on their *greatest* value.

For example:

- `Dice.parse'1d6':minimum()` gives `1`, the least number that can be rolled on a polyhedral die.
- `Dice.parse'3d4':minimum()` gives `3`, because each of three dice is rolling a 1.
- `Dice.parse'3d4-1d3':minimum()` gives `0`, because each of the three positive dice roll a 1 and the one negative die rolls its maximum value, a 3, which cancels the 3 contributed by the positive dice.

### `range`

The range is the distance from the maximum to the minimum value.

For example:

- `Dice.parse'1d6':range()` gives `5` (6 - 1).
- `Dice.parse'3d4':range()` gives `9` (12 - 3).
- `Dice.parse'3d4-1d3':range()` gives `11` (11 - 0).

### `variance`

Compute the variance of the dice roll's probability distribution. Variance is a measure of average distance from the average.

### `standard_deviation`

(Also called `sd`.)

The standard deviation is the square root of the variance. It's notable in general for having the same unit as the distribution it's a measure of (whereas variance has the square of the unit).

### `Dice.compare`

Compute which of two dice rolls is “better” using the following metrics, in order of applicability:

- greater mean
- smaller range
- less variance

If all of these are equal, the two distributions are the same.

The result is two values. The first is a number, which is:

- -1 if the second argument is better;
- 0 if neither is better;
- or 1 if the first argument is better.

The second result is a string describing which metric was used to determine the result: either one of the above metrics as a string or `'no difference'`.

For example:

- `Dice.parse('1d6'):compare(Dice.parse'1d4')` returns `1, 'greater mean'` because the mean of 1d6 is greater than that of 1d4.
- `Dice.parse('1d5'):compare(Dice.parse'1d3+1')` returns `-1, 'smaller range'` because the means are the same and the range of 1d3+1 is smaller than that of 1d5.
- `Dice.parse('1d3+1'):compare(Dice.parse'2d2')` returns `-1, 'less variance'` because everything is the same except the variance, which is smaller for 2d2.
- `Dice.parse('1d3'):compare(Dice.parse'4-1d3')` returns `0, 'no difference'` because both rolls represent the same probability distribution.

### `roll`

(Also called `sample`.)

Roll the dice, producing a single integer as a result. This method uses Lua's `math.random` and thus is affected by `math.randomseed`.

# Examples

See [`Examples.lua`](Examples.lua) for a complete example of a program that uses this library. It's runnable using the base Lua distribution's command line program.
