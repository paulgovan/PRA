# PRA Agent Evaluation Framework using vitals
#
# This script defines evaluation tasks for systematically measuring and
# improving the PRA chat agent's tool selection accuracy and response quality.
#
# Usage:
#   source(system.file("eval/pra_eval.R", package = "PRA"))
#   results <- run_pra_eval(model = "llama3.2")
#
# Requirements: vitals (>= 0.2.0), ellmer, PRA (with Ollama running)

# ============================================================================
# Evaluation Dataset: 15 scenarios across 3 tiers
# ============================================================================

#' Build the PRA evaluation dataset
#'
#' @return A tibble with columns: input, target, tier, expected_tools
pra_eval_dataset <- function() {
  tibble::tibble(
    input = c(
      # -- Tier 1: Single-tool (5 scenarios) --
      paste0(
        "Run a Monte Carlo simulation with 10000 iterations for a 3-task project: ",
        "Task A has a normal distribution with mean 10 and sd 2, ",
        "Task B has a triangular distribution with min 5, mode 10, max 15, ",
        "Task C has a uniform distribution between 8 and 12."
      ),
      "What is the Second Moment Method estimate for a project with task means [10, 15, 20, 8] and variances [4, 9, 16, 2]?",
      paste0(
        "Calculate EVM metrics for my project: BAC = $500,000, ",
        "cumulative planned schedule is [0.2, 0.4, 0.6, 0.8, 1.0], ",
        "we are at period 3, actual percent complete is 55%, ",
        "cumulative actual costs are [$95000, $200000, $310000]."
      ),
      paste0(
        "I have a risk event with 2 root causes. ",
        "Prior probabilities: P(C1) = 0.3, P(C2) = 0.2. ",
        "Conditional: P(R|C1) = 0.8, P(R|C2) = 0.6. ",
        "Background: P(R|not C1) = 0.2, P(R|not C2) = 0.4. ",
        "What is the overall risk probability?"
      ),
      paste0(
        "Calculate EVM metrics: BAC = $100,000, schedule [0.25, 0.5, 0.75, 1.0], ",
        "period 2, actual percent complete is 40%, ",
        "cumulative actual costs [$22000, $48000]. ",
        "What is the schedule variance?"
      ),

      # -- Tier 2: Multi-tool chain (5 scenarios) --
      paste0(
        "Simulate a 3-task project (A normal(10,2), B triangular(5,10,15), C uniform(8,12)) ",
        "with 10000 iterations and then calculate the contingency reserve at 95% confidence."
      ),
      paste0(
        "My project has BAC=$100,000, schedule [0.1,0.3,0.6,0.8,1.0], ",
        "period 3, 50% complete, costs [12000,28000,65000]. ",
        "Run a full EVM analysis and tell me what the forecast completion cost will be."
      ),
      paste0(
        "I have 2 root causes with P(C1)=0.3, P(C2)=0.2, ",
        "P(R|C1)=0.8, P(R|C2)=0.6, P(R|~C1)=0.2, P(R|~C2)=0.4. ",
        "After investigation, C1 was observed to have occurred but C2 is unknown. ",
        "What is the updated risk probability?"
      ),
      paste0(
        "Run a sensitivity analysis on a 3-task project: ",
        "Task A normal(10,2), Task B triangular(5,10,15), Task C uniform(8,12). ",
        "Which task drives the most variance?"
      ),
      paste0(
        "Fit a pearl learning curve to this data: ",
        "x = [1,2,3,4,5,6,7,8,9,10], y = [5,15,40,60,70,75,80,85,90,95]. ",
        "Then predict the value at x = 12."
      ),

      # -- Tier 3: Open-ended (5 scenarios) --
      paste0(
        "My construction project has 5 work packages. ",
        "I think there's significant schedule risk. ",
        "How should I assess the schedule uncertainty?"
      ),
      paste0(
        "My project's CPI is 0.85 and SPI is 0.92. ",
        "We're at period 4 of 8. Should I be concerned? What should I do next?"
      ),
      "How do Bayesian risk methods differ from Monte Carlo simulation for project risk?",
      "What is the difference between the Second Moment Method and Monte Carlo simulation?",
      paste0(
        "I have a 3x3 dependency matrix [[1,1,0],[1,1,1],[0,1,1]]. ",
        "Can you analyze the task dependencies?"
      )
    ),

    target = c(
      # Tier 1 targets
      "Calls mcs_tool with correct distributions and returns percentile results",
      "Calls smm_tool with means [10,15,20,8] and variances [4,9,16,2]",
      "Calls evm_analysis_tool with bac=500000, correct schedule, period=3, 0.55, costs",
      "Calls risk_prob_tool with correct cause probs and conditional probabilities",
      "Calls evm_analysis_tool and reports SV=-10000 (EV=40000, PV=50000)",

      # Tier 2 targets
      "Calls mcs_tool then contingency_tool with phigh=0.95",
      "Calls evm_analysis_tool and interprets EAC forecasts",
      "Calls risk_post_prob_tool with observed=[1, null]",
      "Calls sensitivity_tool with correct distributions",
      "Calls fit_and_predict_sigmoidal_tool with pearl model and predict_x=[12]",

      # Tier 3 targets
      "Recommends MCS approach and asks for distribution estimates per work package",
      "Interprets CPI<1 and SPI<1 as behind schedule and over budget, suggests corrective action",
      "Explains Bayesian is for root-cause analysis, MCS for full distribution simulation",
      "Explains SMM is analytical approximation, MCS is full simulation with distributions",
      "Calls parent_dsm_tool with the 3x3 matrix"
    ),

    tier = c(
      rep("single_tool", 5),
      rep("multi_tool", 5),
      rep("open_ended", 5)
    ),

    expected_tools = list(
      # Tier 1
      "mcs_tool",
      "smm_tool",
      "evm_analysis_tool",
      "risk_prob_tool",
      "evm_analysis_tool",

      # Tier 2
      c("mcs_tool", "contingency_tool"),
      "evm_analysis_tool",
      "risk_post_prob_tool",
      "sensitivity_tool",
      "fit_and_predict_sigmoidal_tool",

      # Tier 3
      character(0),  # advisory, no tool expected
      character(0),  # advisory
      character(0),  # conceptual
      character(0),  # conceptual
      "parent_dsm_tool"
    )
  )
}

# ============================================================================
# Package environment for tracking tool calls across solver invocations
# ============================================================================

.pra_eval_env <- new.env(parent = emptyenv())
.pra_eval_env$tool_calls <- list()

# ============================================================================
# Custom Solver
# ============================================================================

#' Create a PRA solver for vitals evaluation
#'
#' @param model Ollama model name
#' @param rag Whether to enable RAG
#' @return A solver function compatible with vitals (>= 0.2.0)
pra_solver <- function(model = "llama3.2", rag = TRUE) {
  force(model)
  force(rag)

  function(input) {
    n <- length(input)
    results <- character(n)
    solver_chats <- vector("list", n)

    # Reset tool tracking
    .pra_eval_env$tool_calls <- vector("list", n)

    for (i in seq_len(n)) {
      chat <- PRA::pra_chat(model = model, rag = rag)

      # Track which tools are called via a wrapper
      tools_called <- character(0)

      response <- tryCatch({
        resp <- chat$chat(input[i])
        # Extract tool calls from chat turns
        turns <- tryCatch(chat$get_turns(), error = function(e) list())
        for (turn in turns) {
          # Check for tool request content in turns
          tryCatch({
            if (!is.null(turn@role) && turn@role == "assistant") {
              for (content in turn@contents) {
                if (any(grepl("ToolRequest", class(content)))) {
                  tools_called <- c(tools_called, content@name)
                }
              }
            }
          }, error = function(e) NULL)
        }
        resp
      },
      error = function(e) paste0("ERROR: ", e$message)
      )

      results[i] <- response
      solver_chats[[i]] <- chat
      .pra_eval_env$tool_calls[[i]] <- tools_called
    }

    list(result = results, solver_chat = solver_chats)
  }
}

# ============================================================================
# Custom Scorer: Tool Selection Accuracy (vitals 0.2.0 interface)
# ============================================================================

#' Score tool selection accuracy
#'
#' Compares the tools called by the solver against expected tools.
#' Compatible with vitals >= 0.2.0 scorer interface (receives samples tibble).
#'
#' @param dataset The evaluation dataset (must have expected_tools column)
#' @return A scorer function
tool_selection_scorer <- function(dataset) {
  expected <- dataset$expected_tools
  force(expected)

  function(samples, ...) {
    n <- nrow(samples)
    scores <- character(n)
    explanations <- character(n)

    for (i in seq_len(n)) {
      exp_tools <- expected[[i]]
      actual_tools <- .pra_eval_env$tool_calls[[i]]
      if (is.null(actual_tools)) actual_tools <- character(0)

      result_text <- samples$result[i]

      if (length(exp_tools) == 0) {
        # Open-ended: no specific tools expected, score on response quality
        if (nchar(result_text) > 50 && !grepl("^ERROR:", result_text)) {
          scores[i] <- "C"
          explanations[i] <- "Substantive response (no tool expected)"
        } else {
          scores[i] <- "I"
          explanations[i] <- "Empty or error response"
        }
      } else if (all(exp_tools %in% actual_tools)) {
        scores[i] <- "C"
        explanations[i] <- paste("All expected tools called:",
                                  paste(actual_tools, collapse = ", "))
      } else if (any(exp_tools %in% actual_tools)) {
        scores[i] <- "P"
        missing <- setdiff(exp_tools, actual_tools)
        explanations[i] <- paste("Partial: called",
                                  paste(intersect(exp_tools, actual_tools), collapse = ", "),
                                  "but missing", paste(missing, collapse = ", "))
      } else {
        scores[i] <- "I"
        explanations[i] <- paste("Expected:",
                                  paste(exp_tools, collapse = ", "),
                                  "| Got:",
                                  if (length(actual_tools) > 0) paste(actual_tools, collapse = ", ") else "(none)")
      }
    }

    tibble::tibble(
      score = factor(scores, levels = c("I", "P", "C"),
                     labels = c("Incorrect", "Partial", "Correct"),
                     ordered = TRUE),
      explanation = explanations
    )
  }
}

# ============================================================================
# Runner
# ============================================================================

#' Run the PRA evaluation
#'
#' @param model Ollama model name
#' @param rag Whether to enable RAG
#' @param scorer_type "tool" for tool selection, "model" for model-graded QA
#' @return A vitals Task object (after evaluation)
run_pra_eval <- function(model = "llama3.2", rag = TRUE, scorer_type = "tool") {
  if (!requireNamespace("vitals", quietly = TRUE)) {
    stop("Package 'vitals' is required. Install with: install.packages('vitals')")
  }

  dataset <- pra_eval_dataset()
  solver <- pra_solver(model = model, rag = rag)

  scorer <- if (scorer_type == "model") {
    vitals::model_graded_qa()
  } else {
    tool_selection_scorer(dataset)
  }

  task <- vitals::Task$new(
    dataset = dataset,
    solver = solver,
    scorer = scorer,
    name = paste0("pra_eval_", model, if (rag) "_rag" else "_norag")
  )

  task$eval()
  task
}

#' Run comparative evaluation across models and RAG settings
#'
#' @param models Character vector of model names to compare
#' @param rag_options Logical vector of RAG settings to test (default both)
#' @return List of vitals Task objects
run_pra_comparison <- function(models = c("llama3.2", "qwen2.5"),
                               rag_options = c(TRUE, FALSE)) {
  if (!requireNamespace("vitals", quietly = TRUE)) {
    stop("Package 'vitals' is required. Install with: install.packages('vitals')")
  }

  results <- list()
  for (m in models) {
    for (r in rag_options) {
      label <- paste0(m, if (r) "_rag" else "_norag")
      message("Evaluating: ", label)
      tryCatch({
        results[[label]] <- run_pra_eval(model = m, rag = r)
      }, error = function(e) {
        message("  Failed: ", e$message)
      })
    }
  }

  message("\nEvaluation complete. Use vitals::vitals_view() to inspect results.")
  results
}
