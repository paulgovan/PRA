# Bayesian Inference for Risk Probability.

Bayesian inference for calculating the risk probability given root
cause(s).

## Usage

``` r
risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
```

## Arguments

- cause_probs:

  A vector of probabilities for each root cause 'C_i'.

- risks_given_causes:

  A vector of conditional probabilities of the risk event 'R' given each
  cause 'C_i'.

- risks_given_not_causes:

  A vector of conditional probabilities of the risk event 'R' given not
  each cause 'C_i'.

## Value

The function returns a numeric value for the probability of risk event
'R'.

## Examples

``` r
cause_probs <- c(0.3, 0.2)
risks_given_causes <- c(0.8, 0.6)
risks_given_not_causes <- c(0.2, 0.4)
risk_prob_value <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
print(risk_prob_value)
#> [1] 0.82
```
