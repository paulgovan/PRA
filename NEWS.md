# NEWS

## v0.5.0
- **AI integration is now MCP-only.** Removed the natural-language chat agent
  (`pra_chat()`), the Shiny application (`pra_app()`), the slash-command
  interface, and the RAG knowledge base functions (`build_knowledge_base()`,
  `add_documents()`, `retrieve_context()`).
- AI agents now drive PRA through the Model Context Protocol via
  `pra_mcp_server()`, complemented by bundled Agent Skills (`SKILL.md` files)
  under `inst/skills/`.
- Dropped the optional `ragnar`, `shiny`, `shinychat`, `bslib`, `vitals`, and
  `mockr` dependencies.
- **Bayesian risk (breaking):** `risk_prob()` and `risk_post_prob()` now combine
  multiple independent causes with a noisy-OR, so the result always lies in
  `[0, 1]`, the posterior is on the same scale as the prior, and observing an
  aggravating cause raises the posterior. Single-cause results are unchanged.
- Added the `building_project` example dataset: a mid-rise commercial building
  used to demonstrate the full workflow (MCS, SMM, EVM, Bayesian risk, DSM).
- Documented a known limitation of `mcs()` correlation handling (distorts
  marginal means); prefer `smm()` when correlation matters.

## v0.4.0
- DSM Improvements
- Bayesian Improvements
- **Agentic AI Framework**  
  - Slash Commands  
  - Natural Language Interface  
  - RAG-enhanced Reasoning  
  - Local Execution via Ollama  
  - Shiny App  
  - Evaluation Framework

## v0.3.0
- Previous changes and improvements...

## v0.2.0
- Previous changes and improvements...

## v0.1.0
- Previous changes and improvements...