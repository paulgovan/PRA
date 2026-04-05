# Retrieve Relevant Context for a Query

Searches the PRA knowledge base using combined vector similarity search
(VSS) and BM25 full-text search to find the most relevant chunks for a
user query.

## Usage

``` r
retrieve_context(store, query, top_k = 3)
```

## Arguments

- store:

  A ragnar store object from
  [`build_knowledge_base()`](https://paulgovan.github.io/PRA/reference/build_knowledge_base.md).

- query:

  Character string. The user's question or query.

- top_k:

  Integer. Number of chunks to retrieve (default 5).

## Value

A character vector of relevant text chunks with source attribution,
suitable for injecting into an LLM prompt as additional context.

## Examples

``` r
if (FALSE) { # \dontrun{
store <- build_knowledge_base()
chunks <- retrieve_context(store, "What is earned value management?")
cat(chunks, sep = "\n---\n")
} # }
```
