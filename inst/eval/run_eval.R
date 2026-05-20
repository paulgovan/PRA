# Run PRA evaluation and save results for manuscript supplementary material
# Usage: Rscript inst/eval/run_eval.R

library(PRA)
source(system.file("eval/pra_eval.R", package = "PRA"))

out_dir <- file.path(system.file("eval", package = "PRA"), "results")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

# -- Primary run: llama3.2 with RAG --
message("\n>>> llama3.2 + RAG <<<")
res_rag <- run_pra_eval(model = "llama3.2", rag = TRUE, n_trials = 1L)

# -- Secondary run: llama3.2 without RAG (ablation) --
message("\n>>> llama3.2 without RAG <<<")
res_norag <- run_pra_eval(model = "llama3.2", rag = FALSE, n_trials = 1L)

# Save samples for both runs
save_samples <- function(res, label) {
  samples <- tryCatch(res$task$get_samples(), error = function(e) NULL)
  if (!is.null(samples)) {
    # Flatten list columns to character so write.csv works
    samples_flat <- as.data.frame(lapply(samples, function(col) {
      if (is.list(col)) vapply(col, function(x) paste(x, collapse = "; "), character(1))
      else col
    }))
    path <- file.path(out_dir, paste0("samples_", label, "_", timestamp, ".csv"))
    write.csv(samples_flat, path, row.names = FALSE)
    message("Saved: ", path)
  }
}

save_samples(res_rag,   "llama3.2_rag")
save_samples(res_norag, "llama3.2_norag")

# Save summary as RDS for further analysis
saveRDS(
  list(rag = res_rag$summary, norag = res_norag$summary, timestamp = timestamp),
  file.path(out_dir, paste0("summary_", timestamp, ".rds"))
)

# Print comparison
cat("\n=== RAG vs No-RAG comparison ===\n")
cat(sprintf("  llama3.2 + RAG:    %.1f%%\n", res_rag$summary$overall_mean * 100))
cat(sprintf("  llama3.2 no RAG:   %.1f%%\n", res_norag$summary$overall_mean * 100))
cat(sprintf("  RAG delta:         %+.1f%%\n",
            (res_rag$summary$overall_mean - res_norag$summary$overall_mean) * 100))
cat("================================\n")
cat("Results saved to:", out_dir, "\n")
