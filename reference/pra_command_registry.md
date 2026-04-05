# Get the slash-command registry

Returns a named list of command definitions. Each entry has:

- title:

  Display name

- description:

  One-line summary

- args:

  Named list of argument specs (name, type, required, description,
  example)

- fn:

  Function to call with parsed arguments

Returns a named list of command definitions. Each command has a title,
description, argument specs (name, type, required, help), usage
examples, and an executor function that calls the underlying PRA tool
wrapper.

## Usage

``` r
pra_command_registry()

pra_command_registry()
```

## Value

Named list of command definitions.

A named list of command definitions.
