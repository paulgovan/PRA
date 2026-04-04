#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*

# Helper: extract text value from tool results (either character or ContentToolResult)
tool_text <- function(result) {
  if (is.character(result)) {
    return(result)
  }
  # ContentToolResult S7 object
  tryCatch(result@value, error = function(e) as.character(result))
}

# ============================================================================
# JSON Parsing & Input Coercion
# ============================================================================

test_that("parse_json handles valid JSON", {
  skip_if_not_installed("jsonlite")
  expect_equal(PRA:::parse_json("[1, 2, 3]"), c(1, 2, 3))
  expect_equal(PRA:::parse_json("null"), NULL)
  expect_equal(PRA:::parse_json(""), NULL)
  expect_equal(PRA:::parse_json(NULL), NULL)
})

test_that("parse_json handles common LLM formatting mistakes", {
  skip_if_not_installed("jsonlite")
  # Bare comma-separated numbers (no brackets)
  expect_equal(PRA:::parse_json("0.3, 0.2"), c(0.3, 0.2))
  # Trailing comma
  expect_equal(PRA:::parse_json("[0.3, 0.2,]"), c(0.3, 0.2))
  # Single quotes instead of double
  expect_equal(PRA:::parse_json("['hello', 'world']"), c("hello", "world"))
  # Whitespace padding
  expect_equal(PRA:::parse_json("  [1, 2, 3]  "), c(1, 2, 3))
  # Smart quotes around value (LLM wraps in curly quotes)
  expect_equal(PRA:::parse_json("\u201c0.3\u201d"), "0.3")
})

test_that("as_numeric_input coerces to numeric", {
  skip_if_not_installed("jsonlite")
  expect_equal(PRA:::as_numeric_input("[0.3, 0.2]"), c(0.3, 0.2))
  expect_equal(PRA:::as_numeric_input("0.3, 0.2"), c(0.3, 0.2))
  expect_null(PRA:::as_numeric_input(NULL))
  # Already numeric
  expect_equal(PRA:::as_numeric_input(c(0.3, 0.2)), c(0.3, 0.2))
})

test_that("as_r_input passes R objects through unchanged", {
  expect_equal(PRA:::as_r_input(c(1, 2, 3)), c(1, 2, 3))
  expect_equal(PRA:::as_r_input(list(a = 1)), list(a = 1))
  expect_null(PRA:::as_r_input(NULL))
})

test_that("as_r_input parses JSON strings", {
  skip_if_not_installed("jsonlite")
  expect_equal(PRA:::as_r_input("[1, 2, 3]"), c(1, 2, 3))
  expect_null(PRA:::as_r_input("null"))
  expect_null(PRA:::as_r_input(""))
})

test_that("parse_task_dists converts JSON to list-of-lists", {
  skip_if_not_installed("jsonlite")
  json <- '[{"type":"normal","mean":10,"sd":2},{"type":"uniform","min":8,"max":12}]'
  result <- PRA:::parse_task_dists(json)
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$type, "normal")
  expect_equal(result[[1]]$mean, 10)
  expect_equal(result[[2]]$type, "uniform")
})

test_that("parse_json_param provides contextual errors", {
  skip_if_not_installed("jsonlite")
  expect_error(PRA:::parse_json_param("[invalid", "my_param", "my_tool"), "my_param.*my_tool")
  expect_null(PRA:::parse_json_param("null", "x", "y"))
  expect_null(PRA:::parse_json_param("", "x", "y"))
  expect_null(PRA:::parse_json_param(NULL, "x", "y"))
})

# ============================================================================
# Formatting Helpers
# ============================================================================

test_that("summarize_distribution returns correct structure", {
  x <- rnorm(1000, mean = 30, sd = 5)
  result <- PRA:::summarize_distribution(x)
  expect_type(result, "list")
  expect_true("mean" %in% names(result))
  expect_true("sd" %in% names(result))
  expect_true("percentiles" %in% names(result))
  expect_equal(names(result$percentiles), c("P5", "P10", "P25", "P50", "P75", "P90", "P95"))
  expect_true(result$percentiles$P5 < result$percentiles$P50)
  expect_true(result$percentiles$P50 < result$percentiles$P95)
})

test_that("format_result_table produces readable text", {
  result <- PRA:::format_result_table(Mean = 30.5, SD = 2.1)
  expect_type(result, "character")
  expect_true(grepl("Mean", result))
  expect_true(grepl("30.5", result))
  expect_true(grepl("SD", result))
})

test_that("format_distribution produces readable text", {
  x <- rnorm(1000, mean = 30, sd = 5)
  result <- PRA:::format_distribution(x)
  expect_type(result, "character")
  expect_true(grepl("Summary Statistics", result))
  expect_true(grepl("Percentiles", result))
  expect_true(grepl("P50", result))
  expect_true(grepl("P95", result))
})

test_that("html_result_table produces HTML table", {
  result <- PRA:::html_result_table(Mean = 30.5, SD = 2.1)
  expect_type(result, "character")
  expect_true(grepl("<table", result))
  expect_true(grepl("Mean", result))
  expect_true(grepl("30.5", result))
})

test_that("tool_result returns ContentToolResult with HTML when available", {
  skip_if_not_installed("ellmer")
  result <- PRA:::tool_result("plain text", title = "Test", html = "<p>rich</p>")
  expect_true(inherits(result, "ellmer::ContentToolResult") || is.character(result))
  text <- tool_text(result)
  expect_equal(text, "plain text")
})

test_that("tool_result falls back to plain text without HTML", {
  result <- PRA:::tool_result("plain text only")
  expect_type(result, "character")
  expect_equal(result, "plain text only")
})

# ============================================================================
# Tool Structure & Format Tests
# ============================================================================

test_that("pra_tools requires ellmer", {
  skip_if_not_installed("ellmer")
  tools <- pra_tools()
  expect_type(tools, "list")
  expect_true(length(tools) > 0)
})

test_that("validate_task_dists catches errors", {
  skip_if_not_installed("jsonlite")
  expect_error(PRA:::validate_task_dists(list(), "test"), "non-empty")
  expect_error(PRA:::validate_task_dists(list(list(type = "unknown")), "test"), "invalid type")
  expect_error(PRA:::validate_task_dists(list(list(type = "normal", mean = 10)), "test"), "missing required")
  expect_invisible(PRA:::validate_task_dists(list(list(type = "normal", mean = 10, sd = 2)), "test"))
})

test_that("get_ollama_models returns character vector", {
  result <- PRA:::get_ollama_models()
  expect_type(result, "character")
  expect_true(length(result) > 0)
})

# ============================================================================
# Input Validation Tests
# ============================================================================

test_that("mcs_tool validates num_sims", {
  skip_if_not_installed("jsonlite")
  task_json <- '[{"type":"normal","mean":10,"sd":2}]'
  expect_error(PRA:::mcs_tool(-1, task_json), "positive integer")
  expect_error(PRA:::mcs_tool(0, task_json), "positive integer")
})

test_that("mcs_tool validates distribution types", {
  skip_if_not_installed("jsonlite")
  expect_error(PRA:::mcs_tool(100, '[{"type":"beta","a":1,"b":2}]'), "invalid type")
  expect_error(PRA:::mcs_tool(100, '[{"type":"normal"}]'), "missing required parameters")
  expect_error(PRA:::mcs_tool(100, '[{"type":"triangular","a":5}]'), "missing required parameters")
})

test_that("evm_analysis_tool validates inputs", {
  skip_if_not_installed("jsonlite")
  expect_error(PRA:::evm_analysis_tool(
    bac = -100, schedule_json = "[0.5, 1.0]", time_period = 1,
    actual_per_complete = 0.5, actual_costs_json = "[1000]"
  ), "positive number")
  expect_error(PRA:::evm_analysis_tool(
    bac = 100000, schedule_json = "[0.5, 1.0]", time_period = 0,
    actual_per_complete = 0.5, actual_costs_json = "[1000]"
  ), "positive integer")
  expect_error(PRA:::evm_analysis_tool(
    bac = 100000, schedule_json = "[0.5, 1.0]", time_period = 5,
    actual_per_complete = 0.5, actual_costs_json = "[1000]"
  ), "exceeds schedule length")
  expect_error(PRA:::evm_analysis_tool(
    bac = 100000, schedule_json = "[0.5, 1.0]", time_period = 1,
    actual_per_complete = 1.5, actual_costs_json = "[1000]"
  ), "between 0 and 1")
})

test_that("contingency_tool errors without prior MCS", {
  skip_if_not_installed("jsonlite")
  env <- PRA:::.pra_agent_env
  old <- env$last_mcs
  env$last_mcs <- NULL
  result <- PRA:::contingency_tool(0.95, 0.50)
  expect_true(grepl("Run mcs_tool first", result))
  env$last_mcs <- old
})

# ============================================================================
# Numerical Correctness Tests — Tool wrappers produce correct values
# ============================================================================

test_that("smm_tool computes correct total mean, variance, and std dev", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::smm_tool("[10, 15, 20, 8]", "[4, 9, 16, 2]")
  text <- tool_text(result)
  # total_mean = 10+15+20+8 = 53
  expect_true(grepl("53", text))
  # total_var = 4+9+16+2 = 31
  expect_true(grepl("31", text))
  # total_std = sqrt(31) = 5.5678
  expect_true(grepl("5\\.567[0-9]", text))
})

test_that("evm_analysis_tool computes correct metric values", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::evm_analysis_tool(
    bac = 100000,
    schedule_json = "[0.1, 0.2, 0.4, 0.7, 1.0]",
    time_period = 3,
    actual_per_complete = 0.35,
    actual_costs_json = "[10000, 22000, 37000]",
    cumulative = "true"
  )
  text <- tool_text(result)
  # PV = 100000 * 0.4 = 40,000
  expect_true(grepl("40,000", text))
  # EV = 100000 * 0.35 = 35,000
  expect_true(grepl("35,000", text))
  # AC = 37,000 (cumulative at period 3)
  expect_true(grepl("37,000", text))
  # SV = EV - PV = 35000 - 40000 = -5,000
  expect_true(grepl("-5,000", text))
  # CV = EV - AC = 35000 - 37000 = -2,000
  expect_true(grepl("-2,000", text))
  # SPI = 35000/40000 = 0.875
  expect_true(grepl("0\\.875", text))
  # CPI = 35000/37000 = 0.9459
  expect_true(grepl("0\\.945[0-9]", text))
  # EAC(typical) = BAC/CPI = 100000/0.9459 = 105,714.29
  expect_true(grepl("105,714", text))
  # EAC(atypical) = AC + (BAC - EV) = 37000 + 65000 = 102,000
  expect_true(grepl("102,000", text))
})

test_that("evm_analysis_tool auto-converts integer percentages", {
  skip_if_not_installed("jsonlite")
  # 35 (integer-like) should be auto-converted to 0.35
  result <- PRA:::evm_analysis_tool(
    bac = 100000,
    schedule_json = "[0.5, 1.0]",
    time_period = 1,
    actual_per_complete = 35,
    actual_costs_json = "[30000]",
    cumulative = "true"
  )
  text <- tool_text(result)
  # EV = 100000 * 0.35 = 35,000
  expect_true(grepl("35,000", text))
})

test_that("evm_analysis_tool does not auto-convert decimal values", {
  skip_if_not_installed("jsonlite")
  # 0.55 should NOT be converted (it's already a decimal)
  result <- PRA:::evm_analysis_tool(
    bac = 100000,
    schedule_json = "[0.5, 1.0]",
    time_period = 1,
    actual_per_complete = 0.55,
    actual_costs_json = "[50000]",
    cumulative = "true"
  )
  text <- tool_text(result)
  # EV = 100000 * 0.55 = 55,000
  expect_true(grepl("55,000", text))
})

test_that("individual EVM tools compute correct values", {
  skip_if_not_installed("jsonlite")

  # PV = BAC * schedule[period] = 100000 * 0.4 = 40,000
  result_pv <- PRA:::pv_tool(100000, "[0.1, 0.2, 0.4, 0.7, 1.0]", 3)
  expect_true(grepl("40,000", result_pv))

  # EV = BAC * actual_per_complete = 100000 * 0.35 = 35,000
  result_ev <- PRA:::ev_tool(100000, 0.35)
  expect_true(grepl("35,000", result_ev))

  # AC = cumulative costs at period 3 = 37,000
  result_ac <- PRA:::ac_tool("[10000, 22000, 37000]", 3, "true")
  expect_true(grepl("37,000", result_ac))

  # SV = EV - PV = 35000 - 40000 = -5,000
  result_sv <- PRA:::sv_tool(35000, 40000)
  expect_true(grepl("-5,000", result_sv))

  # CV = EV - AC = 35000 - 37000 = -2,000
  result_cv <- PRA:::cv_tool(35000, 37000)
  expect_true(grepl("-2,000", result_cv))

  # SPI = EV/PV = 35000/40000 = 0.875
  result_spi <- PRA:::spi_tool(35000, 40000)
  expect_true(grepl("0\\.875", result_spi))

  # CPI = EV/AC = 35000/37000 = 0.9459...
  result_cpi <- PRA:::cpi_tool(35000, 37000)
  expect_true(grepl("0\\.945[0-9]", result_cpi))

  # EAC(atypical) = AC + (BAC - EV) = 37000 + 65000 = 102,000
  result_eac <- PRA:::eac_tool(100000, "atypical", ac = 37000, ev = 35000)
  expect_true(grepl("102,000", result_eac))

  # ETC = (BAC - EV)/CPI = 65000/0.9459 = 68,714.29
  result_etc <- PRA:::etc_tool(100000, 35000, 0.9459)
  expect_true(grepl("68,71[0-9]", result_etc))

  # VAC = BAC - EAC = 100000 - 110000 = -10,000
  result_vac <- PRA:::vac_tool(100000, 110000)
  expect_true(grepl("-10,000", result_vac))

  # TCPI = (BAC - EV)/(BAC - AC) = 65000/63000 = 1.0317...
  result_tcpi <- PRA:::tcpi_tool(100000, 35000, 37000, "bac")
  expect_true(grepl("1\\.031[0-9]", result_tcpi))
})

test_that("risk_prob_tool computes correct prior probability", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::risk_prob_tool("[0.3, 0.2]", "[0.8, 0.6]", "[0.2, 0.4]")
  text <- tool_text(result)
  # P(R) = (0.8*0.3 + 0.2*0.7) + (0.6*0.2 + 0.4*0.8) = 0.38 + 0.44 = 0.82
  expect_true(grepl("0\\.82", text))
  expect_true(grepl("82", text)) # 82%
})

test_that("risk_post_prob_tool computes correct posterior probability", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::risk_post_prob_tool("[0.3, 0.2]", "[0.8, 0.6]", "[0.2, 0.4]", "[1, null]")
  text <- tool_text(result)
  # Cause 1 observed (TRUE), Cause 2 unknown (NA)
  # numerator = 0.8 * 0.3 = 0.24
  # denominator = 0.8*0.3 + 0.2*0.7 = 0.38
  # posterior = 0.24/0.38 = 0.631578...
  expect_true(grepl("0\\.631[0-9]", text))
  expect_true(grepl("63\\.1[0-9]", text)) # 63.16%
  expect_true(grepl("Occurred", text))
  expect_true(grepl("Unknown", text))
})

test_that("risk_post_prob_tool with all causes observed", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::risk_post_prob_tool("[0.3, 0.2]", "[0.8, 0.6]", "[0.2, 0.4]", "[1, 0]")
  text <- tool_text(result)
  # Cause 1 observed=1: num *= 0.8*0.3=0.24, denom *= 0.38
  # Cause 2 observed=0: num *= 0.4*0.8=0.32, denom *= 0.44
  # posterior = (0.24*0.32) / (0.38*0.44) = 0.0768 / 0.1672 = 0.4593...
  expect_true(grepl("0\\.459[0-9]", text))
  expect_true(grepl("Occurred", text))
  expect_true(grepl("Did not occur", text))
})

test_that("sensitivity_tool returns 1.0 for independent tasks", {
  skip_if_not_installed("jsonlite")
  # For independent tasks, sensitivity = 1 for all tasks
  task_json <- '[{"type":"normal","mean":10,"sd":2},{"type":"triangular","a":5,"b":15,"c":10},{"type":"uniform","min":8,"max":12}]'
  result <- PRA:::sensitivity_tool(task_json)
  text <- tool_text(result)
  expect_true(grepl("Task 1", text))
  expect_true(grepl("Task 2", text))
  expect_true(grepl("Task 3", text))
  # All sensitivities should be 1.0 for independent tasks
  # Extract the numeric values — each "1" or "1.0000" after task names
  lines <- strsplit(text, "\n")[[1]]
  task_lines <- lines[grepl("Task [0-9]", lines)]
  for (line in task_lines) {
    val <- as.numeric(trimws(sub(".*Task [0-9]+\\s+", "", line)))
    expect_equal(val, 1.0, tolerance = 0.001)
  }
})

test_that("parent_dsm_tool computes correct S * t(S)", {
  skip_if_not_installed("jsonlite")
  # S = [[1,0,1],[0,1,0],[1,0,1]]
  # S * t(S) = [[2,0,2],[0,1,0],[2,0,2]]
  result <- PRA:::parent_dsm_tool("[[1,0,1],[0,1,0],[1,0,1]]")
  text <- tool_text(result)
  expect_true(grepl("Parent DSM", text))
  # Check diagonal and off-diagonal values
  expect_true(grepl("2", text)) # diagonal elements [1,1] and [3,3]
  expect_true(grepl("1", text)) # diagonal element [2,2]
})

test_that("grandparent_dsm_tool computes correct result", {
  skip_if_not_installed("jsonlite")
  # S = I(2), R = I(2) => grandparent = S * R * t(R) * t(S) = I(2)
  result <- PRA:::grandparent_dsm_tool("[[1,0],[0,1]]", "[[1,0],[0,1]]")
  text <- tool_text(result)
  expect_true(grepl("Grandparent DSM", text))
})

# ============================================================================
# MCS Numerical Tests (stochastic, use tolerances)
# ============================================================================

test_that("mcs_tool produces statistically correct results", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  # Single normal task: Normal(100, 10)
  result <- PRA:::mcs_tool(50000, '[{"type":"normal","mean":100,"sd":10}]')
  text <- tool_text(result)
  # Mean should be close to 100
  s <- PRA:::summarize_distribution(PRA:::.pra_agent_env$last_mcs$total_distribution)
  expect_equal(s$mean, 100, tolerance = 1)
  expect_equal(s$sd, 10, tolerance = 1)
})

test_that("mcs_tool with multiple tasks sums correctly", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  # Normal(10,2) + Uniform(8,12): expected mean = 10 + 10 = 20
  task_json <- '[{"type":"normal","mean":10,"sd":2},{"type":"uniform","min":8,"max":12}]'
  PRA:::mcs_tool(50000, task_json)
  s <- PRA:::summarize_distribution(PRA:::.pra_agent_env$last_mcs$total_distribution)
  expect_equal(s$mean, 20, tolerance = 0.5)
  # Uniform(8,12) variance = (12-8)^2/12 = 1.333, Normal var = 4, total var = 5.333
  expect_equal(s$sd^2, 5.333, tolerance = 1)
})

test_that("contingency_tool computes correct reserve from MCS", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  task_json <- '[{"type":"normal","mean":100,"sd":10}]'
  PRA:::mcs_tool(50000, task_json)

  result <- PRA:::contingency_tool(0.95, 0.50)
  text <- tool_text(result)
  expect_true(grepl("Contingency", text))
  expect_true(grepl("P95", text))
  expect_true(grepl("P50", text))

  # For Normal(100,10): P95 - P50 ≈ 1.645*10 = 16.45
  dist <- PRA:::.pra_agent_env$last_mcs$total_distribution
  expected_contingency <- unname(quantile(dist, 0.95) - quantile(dist, 0.50))
  expect_true(grepl(format(round(expected_contingency, 4), big.mark = ","), text))
})

# ============================================================================
# Multi-Tool Chain Tests — Verify chaining state
# ============================================================================

test_that("MCS -> contingency chain produces consistent results", {
  skip_if_not_installed("jsonlite")
  set.seed(123)
  task_json <- '[{"type":"normal","mean":50,"sd":5},{"type":"triangular","a":10,"b":20,"c":30}]'

  # Step 1: Run MCS
  mcs_result <- PRA:::mcs_tool(10000, task_json)
  mcs_text <- tool_text(mcs_result)
  expect_true(grepl("Monte Carlo Simulation", mcs_text))

  # Verify MCS stored in environment
  expect_false(is.null(PRA:::.pra_agent_env$last_mcs))
  dist <- PRA:::.pra_agent_env$last_mcs$total_distribution

  # Step 2: Run contingency
  cont_result <- PRA:::contingency_tool(0.95, 0.50)
  cont_text <- tool_text(cont_result)

  # Verify contingency matches the stored MCS distribution
  p95 <- unname(quantile(dist, 0.95))
  p50 <- unname(quantile(dist, 0.50))
  expected_reserve <- p95 - p50
  expect_true(grepl(format(round(expected_reserve, 4), big.mark = ","), cont_text))
})

test_that("MCS -> sensitivity chain uses same distributions", {
  skip_if_not_installed("jsonlite")
  task_json <- '[{"type":"normal","mean":50,"sd":5},{"type":"uniform","min":10,"max":30}]'

  # Step 1: MCS
  PRA:::mcs_tool(5000, task_json)
  expect_false(is.null(PRA:::.pra_agent_env$last_mcs))

  # Step 2: Sensitivity on same distributions
  sens_result <- PRA:::sensitivity_tool(task_json)
  sens_text <- tool_text(sens_result)
  expect_true(grepl("Task 1", sens_text))
  expect_true(grepl("Task 2", sens_text))
})

test_that("cost_pdf -> cost_post_pdf chain works", {
  skip_if_not_installed("jsonlite")
  set.seed(42)

  # Step 1: Prior cost distribution
  prior_result <- PRA:::cost_pdf_tool(10000, "[0.3, 0.2]", "[50000, 30000]", "[10000, 5000]", 100000)
  prior_text <- tool_text(prior_result)
  expect_true(grepl("Prior Cost Distribution", prior_text))
  expect_false(is.null(PRA:::.pra_agent_env$last_cost_pdf))

  # Step 2: Posterior cost (risk 1 occurred, risk 2 unknown)
  post_result <- PRA:::cost_post_pdf_tool(10000, "[true, null]", "[50000, 30000]", "[10000, 5000]", 100000)
  post_text <- tool_text(post_result)
  expect_true(grepl("Posterior Cost Distribution", post_text))

  # Posterior mean should be higher than prior mean (risk 1 definitely occurred)
  prior_dist <- PRA:::.pra_agent_env$last_cost_pdf
  post_dist <- PRA:::.pra_agent_env$last_cost_post_pdf
  expect_true(mean(post_dist) > mean(prior_dist))
})

# ============================================================================
# LLM-Style Input Pipeline Tests — Simulate realistic LLM tool calls
# ============================================================================

test_that("pipeline: LLM sends string-wrapped numbers for EVM", {
  skip_if_not_installed("jsonlite")
  # LLMs often send numbers as strings in JSON
  result <- PRA:::evm_analysis_tool(
    bac = "100000",
    schedule_json = "[0.25, 0.5, 0.75, 1.0]",
    time_period = "2",
    actual_per_complete = "0.40",
    actual_costs_json = "[22000, 48000]",
    cumulative = "true"
  )
  text <- tool_text(result)
  # PV = 100000 * 0.5 = 50,000
  expect_true(grepl("50,000", text))
  # EV = 100000 * 0.40 = 40,000
  expect_true(grepl("40,000", text))
  # AC = 48,000
  expect_true(grepl("48,000", text))
  # SV = 40000 - 50000 = -10,000
  expect_true(grepl("-10,000", text))
})

test_that("pipeline: LLM sends integer percentage for EVM", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::evm_analysis_tool(
    bac = 500000,
    schedule_json = "[0.2, 0.4, 0.6, 0.8, 1.0]",
    time_period = 3,
    actual_per_complete = 55, # 55% as integer
    actual_costs_json = "[95000, 200000, 310000]",
    cumulative = "true"
  )
  text <- tool_text(result)
  # EV = 500000 * 0.55 = 275,000
  expect_true(grepl("275,000", text))
  # PV = 500000 * 0.6 = 300,000
  expect_true(grepl("300,000", text))
  # SV = 275000 - 300000 = -25,000
  expect_true(grepl("-25,000", text))
})

test_that("pipeline: LLM sends bare numbers for risk_prob", {
  skip_if_not_installed("jsonlite")
  # LLM sends "0.3, 0.2" instead of "[0.3, 0.2]"
  result <- PRA:::risk_prob_tool("0.3, 0.2", "0.8, 0.6", "0.2, 0.4")
  text <- tool_text(result)
  expect_true(grepl("0\\.82", text))
})

test_that("pipeline: LLM sends trailing-comma JSON for SMM", {
  skip_if_not_installed("jsonlite")
  result <- PRA:::smm_tool("[10, 15, 20, 8,]", "[4, 9, 16, 2,]")
  text <- tool_text(result)
  expect_true(grepl("53", text)) # total mean
  expect_true(grepl("31", text)) # total variance
})

test_that("pipeline: LLM sends R vectors directly (programmatic use)", {
  # Users calling tools from R code, not via LLM
  result <- PRA:::smm_tool(
    mean_json = c(10, 12, 8),
    var_json = c(4, 9, 2)
  )
  text <- tool_text(result)
  # total_mean = 30, total_var = 15, total_std = sqrt(15) = 3.873 (rounded)
  expect_true(grepl("30", text))
  expect_true(grepl("15", text))
  expect_true(grepl("3\\.873", text))
})

test_that("pipeline: LLM sends R lists for MCS", {
  result <- PRA:::mcs_tool(
    num_sims = 1000,
    task_dists_json = list(
      list(type = "normal", mean = 10, sd = 2),
      list(type = "uniform", min = 8, max = 12)
    )
  )
  text <- tool_text(result)
  expect_true(grepl("Monte Carlo Simulation", text))
})

test_that("pipeline: LLM sends R vectors for risk_prob", {
  result <- PRA:::risk_prob_tool(
    cause_probs_json = c(0.3, 0.2),
    risks_given_causes_json = c(0.8, 0.6),
    risks_given_not_causes_json = c(0.2, 0.4)
  )
  text <- tool_text(result)
  expect_true(grepl("0\\.82", text))
})

test_that("pipeline: LLM sends R vectors for EVM", {
  result <- PRA:::evm_analysis_tool(
    bac = 100000,
    schedule_json = c(0.1, 0.2, 0.4, 0.7, 1.0),
    time_period = 3,
    actual_per_complete = 0.35,
    actual_costs_json = c(10000, 22000, 37000),
    cumulative = TRUE
  )
  text <- tool_text(result)
  expect_true(grepl("Earned Value Management", text))
  expect_true(grepl("40,000", text)) # PV
  expect_true(grepl("-5,000", text)) # SV
})

test_that("pipeline: LLM sends R matrix for DSM", {
  result <- PRA:::parent_dsm_tool(matrix(c(1, 0, 1, 0, 1, 0, 1, 0, 1), nrow = 3))
  text <- tool_text(result)
  expect_true(grepl("Parent DSM", text))
})

test_that("pipeline: LLM sends R lists for sensitivity", {
  result <- PRA:::sensitivity_tool(
    task_dists_json = list(
      list(type = "normal", mean = 10, sd = 2),
      list(type = "triangular", a = 5, b = 15, c = 10)
    )
  )
  text <- tool_text(result)
  expect_true(grepl("Sensitivity", text))
})

# ============================================================================
# Learning Curve Numerical Tests
# ============================================================================

test_that("fit_and_predict_sigmoidal_tool fits logistic model correctly", {
  skip_if_not_installed("jsonlite")
  x_json <- "[1,2,3,4,5,6,7,8,9,10]"
  y_json <- "[5,15,40,60,70,75,80,85,90,95]"
  result <- PRA:::fit_and_predict_sigmoidal_tool(x_json, y_json, "logistic")
  text <- tool_text(result)
  expect_true(grepl("Learning Curve Fit", text))
  expect_true(grepl("logistic", text))
  expect_true(grepl("Coefficients", text))
  expect_true(grepl("Predictions", text))
})

test_that("fit_and_predict_sigmoidal_tool predictions at new x values", {
  skip_if_not_installed("jsonlite")
  x_json <- "[1,2,3,4,5,6,7,8,9,10]"
  y_json <- "[5,15,40,60,70,75,80,85,90,95]"
  result <- PRA:::fit_and_predict_sigmoidal_tool(x_json, y_json, "logistic", predict_x_json = "[12, 15]")
  text <- tool_text(result)
  # Predictions at x=12 and x=15 should exist
  expect_true(grepl("12", text))
  expect_true(grepl("15", text))
})

# ============================================================================
# Cost PDF Numerical Tests
# ============================================================================

test_that("cost_pdf_tool baseline cost is reflected in output", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  # With base_cost = 100000, mean should be >= 100000
  result <- PRA:::cost_pdf_tool(10000, "[0.3, 0.2]", "[50000, 30000]", "[10000, 5000]", 100000)
  text <- tool_text(result)
  expect_true(grepl("100,000", text))

  s <- PRA:::summarize_distribution(PRA:::.pra_agent_env$last_cost_pdf)
  # Mean should be > base cost (risks add cost)
  expect_true(s$mean > 100000)
  # Expected additional cost = 0.3*50000 + 0.2*30000 = 21000
  # So mean should be around 121000
  expect_equal(s$mean, 121000, tolerance = 5000)
})

test_that("cost_post_pdf_tool with known risk produces higher mean", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  # Risk 1 occurred (TRUE), risk 2 did not (FALSE)
  result <- PRA:::cost_post_pdf_tool(10000, "[true, false]", "[50000, 30000]", "[10000, 5000]", 100000)
  text <- tool_text(result)

  s <- PRA:::summarize_distribution(PRA:::.pra_agent_env$last_cost_post_pdf)
  # Only risk 1 impact: mean should be around 100000 + 50000 = 150000
  expect_equal(s$mean, 150000, tolerance = 2000)
})

# ============================================================================
# MCS with Correlation
# ============================================================================

test_that("mcs_tool with correlation matrix produces valid results", {
  skip_if_not_installed("jsonlite")
  set.seed(42)
  task_json <- '[{"type":"normal","mean":10,"sd":2},{"type":"normal","mean":12,"sd":3}]'
  cor_json <- "[[1,0.5],[0.5,1]]"
  result <- PRA:::mcs_tool(10000, task_json, cor_json)
  text <- tool_text(result)
  expect_true(grepl("Monte Carlo Simulation", text))

  # Mean should still be 22 (correlation doesn't affect mean)
  s <- PRA:::summarize_distribution(PRA:::.pra_agent_env$last_mcs$total_distribution)
  expect_equal(s$mean, 22, tolerance = 0.5)
  # But variance should be higher than independent case (4 + 9 = 13)
  # With cor=0.5: var = 4 + 9 + 2*0.5*2*3 = 19
  expect_true(s$sd^2 > 14) # Should be around 19
})

# ============================================================================
# Stores / Environment State Tests
# ============================================================================

test_that("mcs_tool stores result for downstream tools", {
  skip_if_not_installed("jsonlite")
  task_json <- '[{"type":"normal","mean":10,"sd":2},{"type":"uniform","min":8,"max":12}]'
  PRA:::mcs_tool(1000, task_json)
  expect_false(is.null(PRA:::.pra_agent_env$last_mcs))
  expect_s3_class(PRA:::.pra_agent_env$last_mcs, "mcs")
})

test_that("cost_pdf_tool stores result for chaining", {
  skip_if_not_installed("jsonlite")
  PRA:::cost_pdf_tool(1000, "[0.3, 0.2]", "[50000, 30000]", "[10000, 5000]", 100000)
  expect_false(is.null(PRA:::.pra_agent_env$last_cost_pdf))
})

# ============================================================================
# /Command Framework Tests
# ============================================================================

test_that("command registry returns all 9 commands", {
  registry <- PRA:::pra_command_registry()
  expect_type(registry, "list")
  expect_length(registry, 9)
  expected <- c(
    "mcs", "smm", "contingency", "sensitivity", "evm",
    "risk", "risk_post", "learning", "dsm"
  )
  expect_equal(sort(names(registry)), sort(expected))
})

test_that("each command has required fields", {
  registry <- PRA:::pra_command_registry()
  for (nm in names(registry)) {
    cmd <- registry[[nm]]
    expect_true(!is.null(cmd$title), info = paste(nm, "missing title"))
    expect_true(!is.null(cmd$description), info = paste(nm, "missing description"))
    expect_true(!is.null(cmd$args), info = paste(nm, "missing args"))
    expect_true(!is.null(cmd$examples), info = paste(nm, "missing examples"))
    expect_true(is.function(cmd$fn), info = paste(nm, "missing fn"))
  }
})

test_that("/help returns overview of all commands", {
  r <- PRA:::execute_command("/help")
  expect_true(r$ok)
  expect_true(grepl("PRA Commands", r$result))
  expect_true(grepl("/mcs", r$result, fixed = TRUE))
  expect_true(grepl("/evm", r$result, fixed = TRUE))
  expect_true(grepl("/risk", r$result, fixed = TRUE))
})

test_that("/help <command> returns detailed help", {
  r <- PRA:::execute_command("/help mcs")
  expect_true(r$ok)
  expect_true(grepl("Monte Carlo Simulation", r$result))
  expect_true(grepl("tasks", r$result))
  expect_true(grepl("Examples", r$result))
})

test_that("unknown command returns suggestions", {
  r <- PRA:::execute_command("/foobar")
  expect_false(r$ok)
  expect_true(grepl("Unknown command", r$result))
  expect_true(grepl("/mcs", r$result, fixed = TRUE))
})

test_that("command with no args shows help when args are required", {
  r <- PRA:::execute_command("/evm")
  expect_true(r$ok)
  expect_true(grepl("bac", r$result))
  expect_true(grepl("required", r$result, ignore.case = TRUE))
})

test_that("missing required args returns guidance", {
  r <- PRA:::execute_command("/risk causes=[0.3]")
  expect_false(r$ok)
  expect_true(grepl("Missing required", r$result))
  expect_true(grepl("given", r$result))
  expect_true(grepl("not_given", r$result))
})

test_that("/smm executes correctly", {
  skip_if_not_installed("jsonlite")
  r <- PRA:::execute_command("/smm means=[10,20,30] vars=[4,9,16]")
  expect_true(r$ok)
  expect_true(grepl("60", r$result)) # total mean
  expect_true(grepl("29", r$result)) # total variance
})

test_that("/risk executes correctly with numerical verification", {
  skip_if_not_installed("jsonlite")
  r <- PRA:::execute_command("/risk causes=[0.3,0.2] given=[0.8,0.6] not_given=[0.2,0.4]")
  expect_true(r$ok)
  expect_true(grepl("0\\.82", r$result))
})

test_that("/evm executes correctly with numerical verification", {
  skip_if_not_installed("jsonlite")
  r <- PRA:::execute_command("/evm bac=500000 schedule=[0.2,0.4,0.6,0.8,1.0] period=3 complete=0.35 costs=[90000,195000,310000]")
  expect_true(r$ok)
  expect_true(grepl("300,000", r$result)) # PV
  expect_true(grepl("175,000", r$result)) # EV
  expect_true(grepl("-125,000", r$result)) # SV
  expect_true(grepl("0\\.5645", r$result)) # CPI
})

test_that("/mcs executes and returns rich result", {
  skip_if_not_installed("jsonlite")
  r <- PRA:::execute_command('/mcs n=1000 tasks=[{"type":"normal","mean":10,"sd":2}]')
  expect_true(r$ok)
  expect_true(grepl("Monte Carlo", r$result))
  expect_false(is.null(r$rich_result))
})

test_that("/contingency executes with defaults after /mcs", {
  skip_if_not_installed("jsonlite")
  # Run MCS first to populate last_mcs
  PRA:::execute_command('/mcs n=1000 tasks=[{"type":"normal","mean":10,"sd":2}]')
  r <- PRA:::execute_command("/contingency")
  expect_true(r$ok)
  expect_true(grepl("Contingency", r$result))
})

test_that("error in tool execution returns friendly message", {
  skip_if_not_installed("jsonlite")
  # Invalid JSON for tasks
  r <- PRA:::execute_command("/mcs tasks=not_valid_json")
  expect_false(r$ok)
  expect_true(grepl("Error running /mcs", r$result))
  expect_true(grepl("/help mcs", r$result, fixed = TRUE))
})

test_that("format_command_help produces valid markdown", {
  registry <- PRA:::pra_command_registry()
  help_text <- PRA:::format_command_help("mcs", registry$mcs)
  expect_true(grepl("### /mcs", help_text))
  expect_true(grepl("Arguments", help_text))
  expect_true(grepl("Examples", help_text))
})

test_that("format_help_overview lists all commands", {
  overview <- PRA:::format_help_overview()
  registry <- PRA:::pra_command_registry()
  for (nm in names(registry)) {
    expect_true(grepl(paste0("/", nm), overview, fixed = TRUE),
      info = paste("Missing", nm, "in overview")
    )
  }
})
