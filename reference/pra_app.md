# Launch the PRA Risk Analysis Agent App

Starts a Shiny app that provides an interactive chat interface to the
PRA risk analysis agent. The agent can select and execute PRA tools
(Monte Carlo simulation, EVM, Bayesian inference, etc.) in response to
natural language questions. Uses shinychat for a polished streaming chat
experience with inline tool result display.

## Usage

``` r
pra_app(
  model = "llama3.2",
  rag = TRUE,
  embed_model = "nomic-embed-text",
  port = NULL,
  launch.browser = TRUE
)
```

## Arguments

- model:

  Character. Ollama model name (default `"llama3.2"`).

- rag:

  Logical. Whether to enable RAG context retrieval (default `TRUE`).

- embed_model:

  Character. Ollama embedding model for RAG (default
  `"nomic-embed-text"`).

- port:

  Integer. Port for the Shiny app (default `NULL` lets Shiny choose).

- launch.browser:

  Logical. Whether to open a browser (default `TRUE`).

## Value

None. This function is called to launch the shiny app.

## Details

Requires Ollama to be running locally with the specified model
downloaded.

## Examples

``` r
if (FALSE) { # \dontrun{
# Ensure Ollama is running, then:
pra_app()

# With a specific model:
pra_app(model = "qwen2.5")
} # }
```
