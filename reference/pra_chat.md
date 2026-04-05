# Create a PRA Risk Analysis Chat Agent

Creates an ellmer chat object configured as a project risk analysis
expert, with all PRA functions registered as tools and optional RAG
context retrieval from the bundled knowledge base.

## Usage

``` r
pra_chat(
  chat = NULL,
  model = "llama3.2",
  rag = TRUE,
  embed_model = .pra_default_embed_model
)
```

## Arguments

- chat:

  An optional pre-configured ellmer chat object. If provided, `model` is
  ignored and tools are registered on this object instead.

- model:

  Character. Ollama model name (default `"llama3.2"`). Must support tool
  calling. Other options: `"qwen2.5"`, `"llama3.1:70b"`.

- rag:

  Logical. Whether to use RAG context from the PRA knowledge base
  (default `TRUE`). Requires Ollama embedding model to be available.

- embed_model:

  Character. Ollama embedding model for RAG (default
  `"nomic-embed-text"`). Only used when `rag = TRUE`.

## Value

A configured ellmer chat object with PRA tools registered. Use
`chat$chat("your question")` to interact.

## Details

By default, uses a local Ollama model for fully offline, private
operation. Alternatively, supply a pre-configured ellmer chat object
(e.g.,
[`ellmer::chat_openai()`](https://ellmer.tidyverse.org/reference/chat_openai.html))
via the `chat` parameter for cloud-hosted models.

## Examples

``` r
if (FALSE) { # \dontrun{
# Default: local Ollama model
chat <- pra_chat()
chat$chat("Run a Monte Carlo simulation for a 3-task project with
  Task A: normal(10, 2), Task B: triangular(5, 10, 15), Task C: uniform(8, 12)")

# Use a cloud model for better accuracy
chat <- pra_chat(chat = ellmer::chat_openai(model = "gpt-4o"))

# Follow-up questions use conversation context
chat$chat("What is the contingency reserve at 95% confidence?")
} # }
```
