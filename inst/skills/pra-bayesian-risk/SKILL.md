---
name: pra-bayesian-risk
description: >
  Compute and update the probability of a risk event from root causes, and turn
  risk probabilities into project cost distributions, using the PRA package. Use
  when a user has a risk register with root-cause probabilities and wants a
  prior risk probability, a Bayesian update after observing causes, or a
  cost-impact distribution.
---

# When to use

Best when you have identifiable root causes with estimated probabilities and
want to update estimates as the project progresses (i.e. a risk register). For
task-level distributions and total project cost/schedule, prefer Monte Carlo
(`pra-monte-carlo`). The two combine: estimate risk probabilities here, then
feed cost impacts into a cost distribution.

# Prior and posterior risk probability

`risk_prob_tool(cause_probs_json, risks_given_causes_json,
risks_given_not_causes_json)` computes P(R) by the law of total probability
over independent root causes. All three arrays are the same length:

- `cause_probs_json`: P(cause present), e.g. `[0.3, 0.2]`
- `risks_given_causes_json`: P(Risk | Cause), e.g. `[0.8, 0.6]`
- `risks_given_not_causes_json`: P(Risk | not Cause), e.g. `[0.2, 0.4]`

`risk_post_prob_tool(..., observed_causes_json)` updates P(R) after observing
cause states. `observed_causes_json` uses `1` (occurred), `0` (did not occur),
`null` (still unknown), e.g. `[1, null]`.

# Cost distributions

- `cost_pdf_tool(num_sims, risk_probs_json, means_given_risks_json,
  sds_given_risks_json, base_cost)` — prior cost distribution. Each simulation
  draws whether each risk occurs, then samples its cost impact.
- `cost_post_pdf_tool(num_sims, observed_risks_json, means_given_risks_json,
  sds_given_risks_json, base_cost)` — posterior after observing which risks
  occurred (`observed_risks_json` uses `true`/`false`/`null`).

Parameters: `means_given_risks_json` / `sds_given_risks_json` give the mean and
SD of the *additional* cost if a risk occurs (one per risk); `base_cost` is the
baseline before any risk impacts.

# Workflow

`risk_prob_tool` → `cost_pdf_tool` → [observe causes/risks] →
`risk_post_prob_tool` → `cost_post_pdf_tool`.

# References

- NASA Risk-Informed Decision Making Handbook (SP-2010-576).
- NASA Bayesian Schedule and Cost Risk Analysis.
