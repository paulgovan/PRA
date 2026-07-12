# Bayesian Inference for Risk Probability.

This function calculates the overall probability of a risk event 'R'
occurring based on the probabilities of multiple root causes and their
associated conditional probabilities.

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

## Details

Each cause contributes a marginal probability \\P(R \mid C_i) P(C_i) +
P(R \mid \bar{C}\_i) P(\bar{C}\_i)\\ via the law of total probability.
Independent causes are combined with a noisy-OR — the probability that
the risk event is triggered by at least one cause — so the result always
lies in \\\[0, 1\]\\ and reduces to the single-cause marginal when there
is one cause.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## Examples

``` r
cause_probs <- c(0.3, 0.2)
risks_given_causes <- c(0.8, 0.6)
risks_given_not_causes <- c(0.2, 0.4)
risk_prob_value <- risk_prob(cause_probs, risks_given_causes, risks_given_not_causes)
print(risk_prob_value)
#> [1] 0.6528
```
