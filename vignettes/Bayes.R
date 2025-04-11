## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(PRA)

## -----------------------------------------------------------------------------
cause_probs <- c(0.3, 0.2)

## -----------------------------------------------------------------------------
risks_given_causes <- c(0.8, 0.6)
risks_given_not_causes <- c(0.2, 0.4)

## ----results='asis'-----------------------------------------------------------
risk_prob_value <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
cat(risk_prob_value)

## -----------------------------------------------------------------------------
risk_probs <- c(0.3, 0.5, 0.2)

## -----------------------------------------------------------------------------
means_given_risks <- c(10000, 15000, 5000)
sds_given_risks <- c(2000, 1000, 1000)

## -----------------------------------------------------------------------------
base_cost <- 2000

## -----------------------------------------------------------------------------
num_sims <- 1000
samples <- cost_pdf(num_sims, risk_probs, means_given_risks, sds_given_risks, base_cost)
hist(samples, breaks = 30, col = "skyblue", main = "Histogram of Cost", xlab = "Cost")

## -----------------------------------------------------------------------------
cause_probs <- c(0.3, 0.2)

## -----------------------------------------------------------------------------
risks_given_causes <- c(0.8, 0.6)
risks_given_not_causes <- c(0.2, 0.4)

## -----------------------------------------------------------------------------
observed_causes <- c(1, NA)

## ----results='asis'-----------------------------------------------------------
risk_post_prob <- risk_post_prob(cause_probs, risks_given_causes,
  risks_given_not_causes, observed_causes)
cat(risk_post_prob)

## -----------------------------------------------------------------------------
observed_risks <- c(1, NA, 1)

## -----------------------------------------------------------------------------
means_given_risks <- c(10000, 15000, 5000)
sds_given_risks <- c(2000, 1000, 1000)

## -----------------------------------------------------------------------------
base_cost <- 2000

## -----------------------------------------------------------------------------
num_sims <- 1000
posterior_samples <- cost_post_pdf(
  num_sims = num_sims,
  observed_risks = observed_risks,
  means_given_risks = means_given_risks,
  sds_given_risks = sds_given_risks,
  base_cost = base_cost
)

hist(posterior_samples, breaks = 30, col = "skyblue", main = "Posterior Cost PDF", xlab = "Cost")

