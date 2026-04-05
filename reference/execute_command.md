# Parse and execute a slash command

Parses user input starting with `/`, validates arguments, and executes
the corresponding tool function. Returns a list with `ok` (logical) and
`result` (character string — either the tool output or a help/error
message).

## Usage

``` r
execute_command(input)

execute_command(input)
```

## Arguments

- input:

  Character string of user input (e.g. "/mcs n=5000
  tasks=[...](https://rdrr.io/r/base/dots.html)").

## Value

A list with `ok` (logical) and `result` (character or
ContentToolResult).

A list with `ok` and `result`.
