# Parse key=value argument string with bracket-aware splitting

Splits a string like `n=5000 tasks=[{"type": "normal", "mean": 10}]`
into a named list
`list(n = "5000", tasks = '[{"type": "normal", "mean": 10}]')`. Tracks
bracket/brace/quote nesting so that spaces inside `[]`,
[`{}`](https://rdrr.io/r/base/Paren.html), or `""` are not treated as
argument separators.

## Usage

``` r
parse_command_args(arg_string, known_args)
```

## Arguments

- arg_string:

  Character string of arguments (without the command name).

- known_args:

  Character vector of recognized argument names.

## Value

A named list of parsed argument values (all character strings).
