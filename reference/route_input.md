# Route User Input to the Appropriate Handler

Classifies user input into one of three modes and returns a structured
routing decision. This function encapsulates the three-mode routing
architecture used by both the Shiny app and programmatic interfaces.

## Usage

``` r
route_input(input)
```

## Arguments

- input:

  Character string of user input.

## Value

A list with:

- mode:

  Character: `"command"`, `"tool"`, or `"rag"`

- reason:

  Character: brief explanation of the routing decision

For `"command"` mode, also includes `command` (the command name).

## Details

Routing logic:

1.  Input starting with `/` is routed to the **command** handler for
    deterministic execution (no LLM involved).

2.  Input containing numerical data patterns (distributions, arrays,
    dollar amounts, percentages with surrounding context) is routed to
    the **tool** handler where the LLM selects and calls tools.

3.  All other input (conceptual questions, explanations) is routed to
    the **rag** handler where the LLM answers from the knowledge base
    context.

Note: modes `"tool"` and `"rag"` both go through the LLM, but the
distinction affects how the query is framed (tool-calling emphasis vs.
RAG-context emphasis). The LLM ultimately decides whether to call a
tool, but the routing hint improves reliability with smaller models.

## Examples

``` r
if (FALSE) { # \dontrun{
route_input("/mcs tasks=[...]")
# list(mode = "command", reason = "...", command = "mcs")

route_input("Simulate 3 tasks: Normal(10,2)...")
# list(mode = "tool", reason = "...")

route_input("What is earned value?")
# list(mode = "rag", reason = "...")
} # }
```
