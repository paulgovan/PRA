# Probabilistic network module: equation/implementation gaps

**Status:** documented, not fixed. Raised 2026-08-22 while checking the §6
equations in `inst/paper/pra-jss/pra-jss.Rmd` against `R/network.R` and against
Pearl (2009).

## Verdict

The three display equations in §6 are **correct as statements of Pearl's
formalism**:

- the factorization `p(x) = ∏ p(xᵢ | pa(xᵢ))`;
- the rejection-sampling estimator for `E[g(X) | X_E = e]` — filtering whole
  joint draws is a valid sampler for `p(x | X_E = e)`, and the batching in
  `prob_net_learn()` keeps accepted draws i.i.d., so truncating to the first
  `num_samples` introduces no bias;
- the truncated factorization, which matches *Causality* eq. 3.10.

What follows are gaps between those equations (and the prose around them) and
what the code actually does. **None of them produce wrong numbers in the paper
as it stands** — the published figures are all correct. They are correctness-of-
description and generality issues.

---

## Gap 1 — the DAG framing describes an object the code doesn't build

§6 opens: *"A probabilistic network is a directed acyclic graph in which nodes
represent project variables … and edges encode conditional dependencies."*

In the implementation:

- `prob_net_sim()` contains **no reference to `links` or `adjacency_matrix`**.
  The dependency structure lives entirely in the `distributions` list, via the
  `condition` field (conditional nodes) and `nodes` field (aggregate nodes).
- `prob_net()` builds a **symmetric** adjacency matrix (`R/network.R:110-111`
  sets both `[source, target]` and `[target, source]`), discarding direction.
  This is deliberate — `tests/testthat/test-network.R:152` asserts symmetry by
  name.
- There is **no acyclicity check** anywhere in the module.
- Links that contradict the distributions are accepted silently.

Reproduce:

```r
# direction is discarded
net$adjacency_matrix["A", "C"]   # 1
net$adjacency_matrix["C", "A"]   # 1
isSymmetric(net$adjacency_matrix) # TRUE

# links may contradict the distributions with no complaint
prob_net(
  data.frame(id = c("A", "B", "C")),
  data.frame(source = "A", target = "C"),          # claims A -> C
  list(A = list(type = "discrete", values = c(1, 0), probs = c(.5, .5)),
       B = list(type = "discrete", values = c(1, 0), probs = c(.5, .5)),
       C = list(type = "conditional", condition = "B",   # actually B -> C
                true_dist  = list(type = "normal", mean = 10, sd = 1),
                false_dist = list(type = "normal", mean = 0,  sd = 1)))
)  # accepted
```

**Proposed fix (documentation).** Reword §6's opening to say that the `links`
frame records structure for inspection and for the DSM view in §7, while the
conditional dependencies that drive simulation are carried by the
`distributions` list. Keep the factorization equation — it correctly describes
the joint the `distributions` list encodes.

**Proposed fix (code, needs a decision).** Make the adjacency matrix directed so
the DAG claim is literally true, and add an acyclicity check plus validation
that `links` agrees with `distributions`. This changes documented, tested
behavior. Note the companion book slices this matrix in `book/ch-dsm.qmd:100`
and `book/appendix-solutions.qmd:354-358` to build the DSM `S` and `R` matrices;
a directed matrix would still work for those slices (`adj[resources, tasks]`
picks up the forward entries), but the change must be verified against the book
before shipping.

---

## Gap 2 — "removes its incoming edges" is a no-op

§6.4 says intervention *"replaces X_k's conditional distribution with a point
mass at x_k* and removes its incoming edges."* The edge removal has no
operational effect, because `prob_net_sim()` never reads links.

Reproduce — same seed, 50k draws:

```r
set.seed(1); mean(prob_net_sim(net, 50000)$I)                      # 113316
cut <- prob_net_update(net, remove_links = data.frame(source = "B", target = "D"))
set.seed(1); mean(prob_net_sim(cut, 50000)$I)                      # 113316
```

The intervention is carried **entirely** by `update_distributions`. A user who
removes the edge but forgets to replace the distribution gets the un-intervened
answer with no warning.

**Proposed fix (documentation).** State that intervention is performed by
replacing the node's distribution, and that `remove_links` keeps the recorded
structure consistent with that replacement rather than causing it.

**Proposed fix (code).** Either warn from `prob_net_update()` when
`remove_links` targets an edge whose child distribution is not also being
replaced, or make `prob_net_sim()` honor the link structure. The warning is much
the cheaper option and catches the realistic mistake.

---

## Gap 3 — two of the three examples aren't atomic interventions

The equation defines `do(X_k = x_k*)` as replacing X_k with a **point mass**.

- **§6.4** instead replaces node `D` (Resource-2) with `N(50000, 10000)` — a
  non-degenerate distribution, on a *different node* than the label
  `do(Risk-2=0)` names. A soft intervention on the child, presented as an atomic
  intervention on the parent.
- **§6.6** (`do_A`, risk-importance ranking) has the same shape: it intervenes
  on `C`, labeled as intervening on Risk-1.
- **§6.5** (the confounded example) **does it correctly** — `Rk` gets
  `probs = c(0, 1)`, a genuine point mass. This is the example the do-calculus
  argument actually rests on, so the paper's central claim is sound.

The §6.4 numbers do agree with a proper `do(B = 0)`:

```
paper form   mean 95467  sd 14495
atomic do()  mean 95457  sd 14491
```

but only because `D`'s `false_dist` is exactly `N(50000, 10000)`. That is a
coincidence of this example, not an identity — pick any other resource
distribution and the two diverge.

**Proposed fix (paper, low risk — do this one first).** Rewrite §6.4 and §6.6 to
intervene atomically on the risk nodes:

```r
inter_net <- prob_net_update(net,
  remove_links = data.frame(source = "B", target = "D"),
  update_distributions = list(
    B = list(type = "discrete", values = c(1, 0), probs = c(0, 1))
  )
)
```

Three lines each; results move by <0.02%; the examples then instantiate the
equation printed above them. Re-render and re-check the surrounding prose,
which quotes rounded figures.

---

## Gap 4 — soft interventions are undocumented

`update_distributions` accepts **any** distribution, so the function supports
stochastic (soft) interventions, which are strictly more general than the atomic
`do()` the equation covers. The paper presents only the atomic case while its
examples quietly rely on the general one.

**Proposed fix.** One sentence in §6.4 noting that replacing a node's
distribution with a non-degenerate one expresses a soft intervention — "the
mitigation changes the cost profile" rather than "the risk is eliminated" — and
that the displayed equation is the atomic special case.

---

## Suggested order

1. Gap 3 paper fix (self-contained, makes the examples match the equation).
2. Gap 1 and 2 rewording (removes the two overstated claims).
3. Gap 4 sentence.
4. Gap 1/2 code changes — only with a decision on the adjacency matrix, since
   the companion book depends on its current shape.
