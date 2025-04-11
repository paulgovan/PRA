## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(PRA)

## -----------------------------------------------------------------------------
num_simulations <- 10000
task_distributions <- list(
  list(type = "normal", mean = 10, sd = 2),  # Task A: Normal distribution
  list(type = "triangular", a = 5, b = 10, c = 15),  # Task B: Triangular distribution
  list(type = "uniform", min = 8, max = 12)  # Task C: Uniform distribution
)

## -----------------------------------------------------------------------------
correlation_matrix <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)

## -----------------------------------------------------------------------------
results <- mcs(num_simulations, task_distributions, correlation_matrix)

## ----results='asis'-----------------------------------------------------------
cat("Mean Total Duration:", round(results$total_mean, 2), "\n")

## ----results='asis'-----------------------------------------------------------
cat("Variance of Total Duration:", round(results$total_variance, 2), "\n")

## -----------------------------------------------------------------------------
hist(results$total_distribution, breaks = 50, main = "Total Project Duration", 
     xlab = "Total Duration", col = "skyblue", border = "white")

## ----results='asis'-----------------------------------------------------------
contingency <- contingency(results, phigh = 0.95, pbase = 0.50)
cat("Contingency based on 95th percentile:", round(contingency, 2))

## -----------------------------------------------------------------------------
sensitivity_results <- sensitivity(task_distributions, correlation_matrix)

## -----------------------------------------------------------------------------
data <- data.frame(
   Tasks = c('A', 'B', 'C'),
   Sensitivity = sensitivity_results
)
barplot(height=data$Sensitivity, names=data$Tasks, col='skyblue', 
        horiz=TRUE, main = "Sensitivity Analysis", xlab = 'Sensitivity', ylab = 'Tasks')

