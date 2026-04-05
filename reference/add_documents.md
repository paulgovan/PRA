# Add Custom Documents to the PRA Knowledge Base

Ingests additional markdown or text documents into an existing PRA
knowledge base. Use this to extend the agent's knowledge with your own
project documentation, standards, templates, or lessons learned.

## Usage

``` r
add_documents(store, path, embed_model = "nomic-embed-text")
```

## Arguments

- store:

  A ragnar store object from
  [`build_knowledge_base()`](https://paulgovan.github.io/PRA/reference/build_knowledge_base.md).

- path:

  Character. Path to a file or directory. If a directory, all `.md` and
  `.txt` files are ingested recursively.

- embed_model:

  Character. Ollama embedding model (default `"nomic-embed-text"`).

## Value

The store object (invisibly), updated with the new documents.

## Examples

``` r
if (FALSE) { # \dontrun{
store <- build_knowledge_base()

# Add a single file
add_documents(store, "path/to/my_risk_register.md")

# Add all .md and .txt files in a directory
add_documents(store, "path/to/project_docs/")
} # }
```
