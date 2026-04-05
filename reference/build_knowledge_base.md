# Build the PRA Knowledge Base for RAG Retrieval

Reads the curated risk analysis knowledge files bundled with the PRA
package, chunks them, generates embeddings via Ollama, and stores them
in a DuckDB-backed ragnar knowledge base for retrieval-augmented
generation.

## Usage

``` r
build_knowledge_base(
  store_path = NULL,
  embed_model = "nomic-embed-text",
  overwrite = FALSE
)
```

## Arguments

- store_path:

  Path to store the DuckDB knowledge base. Defaults to a cache directory
  under [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html).

- embed_model:

  Ollama embedding model name (default `"nomic-embed-text"`).

- overwrite:

  Logical. If `TRUE`, rebuild the knowledge base even if a cached
  version exists. Default `FALSE`.

## Value

A ragnar store object that can be passed to
[`retrieve_context()`](https://paulgovan.github.io/PRA/reference/retrieve_context.md).

## Details

The knowledge base is built once and cached to disk. Subsequent calls
with the same `store_path` load the existing store.

## Examples

``` r
if (FALSE) { # \dontrun{
store <- build_knowledge_base()
context <- retrieve_context(store, "How do I run a Monte Carlo simulation?")
} # }
```
