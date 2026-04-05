# Coerce an input to an R object

Accepts either a JSON string (from LLM tool calls) or a native R object
(from direct R usage). If the input is a single character string, it is
parsed as JSON. Otherwise it is returned as-is.

## Usage

``` r
as_r_input(x)
```
