# Posterior Risk Probability.

Calculates the posterior probability of the risk event given
observations of the root causes.

## Usage

``` r
risk_post_prob(
  cause_probs,
  risks_given_causes,
  risks_given_not_causes,
  observed_causes
)
```

## Arguments

- cause_probs:

  A vector of prior probabilities for each root cause 'C_i'.

- risks_given_causes:

  A vector of conditional probabilities of the risk event 'R' given each
  cause 'C_i'.

- risks_given_not_causes:

  A vector of conditional probabilities of the risk event 'R' given not
  each cause 'C_i'.

- observed_causes:

  A vector of observed values for each cause 'C_i' (1 if observed, 0 if
  not observed, NA if unobserved).

## Value

A numeric value for the posterior probability of the risk event given
the observed causes.

## Examples

``` r
cause_probs <- c(0.3, 0.2)
risks_given_causes <- c(0.8, 0.6)
risks_given_not_causes <- c(0.2, 0.4)
observed_causes <- c(1, NA)
risk_post_prob <- risk_post_prob(
  cause_probs, risks_given_causes,
  risks_given_not_causes, observed_causes
)
print(risk_post_prob)
#> [1] 0.6315789
```
