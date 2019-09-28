This library is for computing basic dice roll statistics: their minimum, mean,
and maximum values.

# Documentation

Require the module like so (the actual string may vary depending on your
environment):

    local Dice = require'Dice'

## Parsing a roll from a string

### `Dice.fromDiceString`

(Also called `Dice.fromString`.)

`Dice.fromDiceString` is the more general of the parsing functions and can be
used to return any roll resulting from addition and subtraction of rolls of
conventional polyhedral dice and constants.

    local diceRoll = Dice.fromDiceString(diceString)

Get a dice roll based on the given dice string, which is a list of terms
separated by `+` or `-`, where each term is either:

- a constant term comprising one or more decimal digits (such as `0`, `1`,
`36`, or `123`), representing a fixed amount;
- or a dice term comprising two constants as just described, separated by `d`
as in the common tabletop roleplaying convention (such as `1d6`, `2d4`, or
`36d15`), representing the rolling of a certain quantity (the first constant)
of dice of a certain number of sides (the second constant).

(Whitespace is completely ignored and thus may appear *anywhere* in the string.)

Example valid dice strings include `0`, `1d6`, `2d4 + 1`, `1d2-1`, and `6 -1d4`.

### `Dice.fromRangeString`

`Dice.fromRangeString` is more specialized than `Dice.fromDiceString` but uses
a more conventional syntax for a specific type of random choice.

    local diceRoll = Dice.fromRangeString(rangeString)

Get a dice roll based on the given range string, which is two constant terms
(as in `Dice.fromDiceString`) separated by `-`, representing a roll with equal
possibility of giving any of the integers starting at one limit and ending at
the other. (Note: Both constants must be non-negative.)

(Whitespace is ignored the same as with `Dice.fromDiceString`.)

Example valid range strings include `1-6`, `4 - 8`, `2-2`, `0-0`.

(Note: Take care not to confuse the use of `-` here for the way it's used to
represent a minus sign in the other parser's syntax.)

## Computing statistics from a roll

Once you have a roll value given by one of the aforementioned functions, you
can call one of the following methods on it to compute a specific statistic:

### `diceRoll:minimum()`

Compute the minimum possible value that can be rolled.

That is, all dice whose values are added to the total take on their least
value; all that are *subtracted* from the total take on their *greatest* value.

For example:

- `Dice.fromDiceString'1d6':minimum()` gives `1`, the least number that can be
rolled on a polyhedral die.
- `Dice.fromDiceString'3d4':minimum()` gives `3`, because each of three dice is
rolling a 1.
- `Dice.fromDiceString'3d4-1d3':minimum()` gives `0`, because each of the three
positive dice roll a 1 and the one negative die rolls its maximum value, a 3,
which cancels the 3 contributed by the positive dice.

### `diceRoll:mean()`

Compute the mean value of all possible rolls.

Conceptually, this is the sum of all the possible rolls that can be made,
weighted by how likely they are, divided by the total weight of all possible
rolls.

For example:

- `Dice.fromDiceString'1d6':mean()` gives `3.5`, because all the possible rolls
are 1, 2, 3, 4, 5, and 6, whose sum is 21, which is then divided by 6, which is
the number of distinct rolls. 21 divided by 6 is 3.5.
- `Dice.fromDiceString'3d4':mean()` gives `7.5`, which is the mean of 1d4,
multiplied by 3.
- `Dice.fromDiceString'3d4-1d3':mean()` gives `5.5`, which is the difference of
the mean of the individual rolls 3d4 and 1d3.

### `diceRoll:maximum()`

Compute the maximum possible value that can be rolled.

That is, all dice whose values are added to the total take on their greatest
value; all that are *subtracted* from the total take on their *least* value.

For example:

- `Dice.fromDiceString'1d6':maximum()` gives `6`, the greatest number that can
be rolled on a six-sided die.
- `Dice.fromDiceString'3d4':maximum()` gives `12`, because each of three dice
is rolling a 4.
- `Dice.fromDiceString'3d4-1d3':maximum()` gives `11`, because each of the
three positive dice roll a 4, and the one negative die rolls a 1, giving three
times four minus one.

# Examples

See [`Main.lua`](Main.lua) for a complete example of a program that uses this
library. It's runnable using the base Lua distribution.
