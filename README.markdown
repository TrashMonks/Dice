This library is for computing basic dice roll statistics: their minimum,
average, and maximum values.

# Documentation

Require the module like so (the actual string may vary depending on your
environment):

    local Dice = require'Dice'

## Parsing a roll from a string

### `Dice.from_dice_string`

(Also called `Dice.from_string`.)

`Dice.from_dice_string` is the more general of the parsing functions and can be
used to return any roll resulting from addition and subtraction of rolls of
conventional polyhedral dice and constants.

    local dice_roll = Dice.from_dice_string(dice_string)

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

### `Dice.from_range_string`

`Dice.from_range_string` is more specialized than `Dice.from_dice_string` but
uses a more conventional syntax for a specific type of random choice.

    local dice_roll = Dice.from_range_string(range_string)

Get a dice roll based on the given range string, which is two constant terms
(as in `Dice.from_dice_string`) separated by `-`, representing a roll with
equal possibility of giving any of the integers starting at one limit and
ending at the other. (Note: Both constants must be non-negative.)

(Whitespace is ignored the same as with `Dice.from_dice_string`.)

Example valid range strings include `1-6`, `4 - 8`, `2-2`, `0-0`.

(Note: Take care not to confuse the use of `-` here for the way it's used to
represent a minus sign in the other parser's syntax.)

## Computing statistics from a roll

Once you have a roll value given by one of the aforementioned functions, you
can call one of the following methods on it to compute a specific statistic:

### `dice_roll:minimum()`

(Also called `dice_roll:min()`.)

Compute the minimum possible value that can be rolled.

That is, all dice whose values are added to the total take on their least
value; all that are *subtracted* from the total take on their *greatest* value.

For example:

- `Dice.from_dice_string'1d6':minimum()` gives `1`, the least number that can
be rolled on a polyhedral die.
- `Dice.from_dice_string'3d4':minimum()` gives `3`, because each of three dice
is rolling a 1.
- `Dice.from_dice_string'3d4-1d3':minimum()` gives `0`, because each of the
three positive dice roll a 1 and the one negative die rolls its maximum value,
a 3, which cancels the 3 contributed by the positive dice.

### `dice_roll:average()`

(Also called `dice_roll:ev()`, `dice_roll:expected_value()`, and
`dice_roll:mean()`.)

Compute the average value of all possible rolls.

Conceptually, this is the sum of all the possible rolls that can be made,
weighted by how likely they are, divided by the total weight of all possible
rolls.

For example:

- `Dice.from_dice_string'1d6':average()` gives `3.5`, because all the possible
rolls are 1, 2, 3, 4, 5, and 6, whose sum is 21, which is then divided by 6,
which is the number of distinct rolls. 21 divided by 6 is 3.5.
- `Dice.from_dice_string'3d4':average()` gives `7.5`, which is the average of
1d4, multiplied by 3.
- `Dice.from_dice_string'3d4-1d3':average()` gives `5.5`, which is the
difference of the average of the individual rolls 3d4 and 1d3.

### `dice_roll:maximum()`

Compute the maximum possible value that can be rolled.

That is, all dice whose values are added to the total take on their greatest
value; all that are *subtracted* from the total take on their *least* value.

For example:

- `Dice.from_dice_string'1d6':maximum()` gives `6`, the greatest number that
can be rolled on a six-sided die.
- `Dice.from_dice_string'3d4':maximum()` gives `12`, because each of three dice
is rolling a 4.
- `Dice.from_dice_string'3d4-1d3':maximum()` gives `11`, because each of the
three positive dice roll a 4, and the one negative die rolls a 1, giving three
times four minus one.

### `dice_roll:range()`

Compute the number of possible distinct values the dice roll can take on.

This is the same as subtracting its minimum from its maximum and adding one.

For example:

- `Dice.from_dice_string'1d6':range()` gives `6`, because there are 6 possible
values on a six-sided die.
- `Dice.from_dice_string'3d4':range()` gives `10`, because even though some
of the possible totals of the three dice are more likely than others, there
are still only 10 distinct ones.
- `Dice.from_dice_string'3d4-1d3':range()` gives `12`, because subtracting 1d3
gives two more possibilities (not three!).

# Examples

See [`Main.lua`](Main.lua) for a complete example of a program that uses this
library. It's runnable using the base Lua distribution.
