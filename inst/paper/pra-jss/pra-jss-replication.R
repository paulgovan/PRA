## ---------------------------------------------------------------------
## Replication script for:
##   "Quantitative Project Risk Analysis with PRA"
##   Paul Govan, Journal of Statistical Software
##
## This standalone script reproduces every numerical result, table and
## figure in the manuscript, in the order they appear.
##
## Requirements:
##   install.packages(c("PRA", "knitr"))
## PRA >= 0.5.0 is required. All random results use set.seed(42).
##
## Run with:  Rscript --vanilla pra-jss-replication.R
## Or render code + output:  knitr::spin("pra-jss-replication.R")
## ---------------------------------------------------------------------

## --- setup ---
#+ setup
options(prompt = "R> ", continue = "+  ", width = 70, useFancyQuotes = FALSE)
set.seed(42)
library(PRA)


## --- comparison-table ---
#+ comparison-table
comp <- data.frame(
  Feature = c(
    "MCS schedule risk", "EVM (11 metrics)", "Noisy-OR updating",
    "Learning curves", "Design structure matrices",
    "Probabilistic networks", "MCP tool server",
    "Open-source (CRAN)", "SRR general standards"
  ),
  PRA         = c("Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes"),
  mc2d        = c("Partial","---","---","---","---","---","---","Yes","---"),
  sensitivity = c("---","---","---","---","---","---","---","Yes","---"),
  `rstan/brms`= c("---","---","Yes","---","---","Partial","---","Yes","---"),
  `bnlearn/gRain` = c("---","---","Partial","---","---","Yes","---",
                      "Yes","---"),
  `@RISK`     = c("Yes","Yes","---","---","---","---","---","---","---"),
  check.names = FALSE
)
tab <- knitr::kable(
  comp,
  format = "latex",
  caption = paste0("\\label{tab:comparison}Comparison of \\pkg{PRA} with",
    " related",
    " \\proglang{R} packages and commercial tools. ``Partial'' = only",
    " general-purpose support, requiring custom modeling and not",
    " project-specific; ``---'' = not supported."),
  booktabs = TRUE, align = "lcccccc"
)
# Seven columns overrun the JSS text width at the default size.
cat(sub("\\centering", "\\centering\n\\small", tab, fixed = TRUE))


## --- install ---
#+ install
# install.packages("PRA")
# library("PRA")


## --- bp-load ---
#+ bp-load
data("building_project", package = "PRA")
bp <- building_project
bp$task_names


## --- smm-example ---
#+ smm-example
tri_mean <- function(d) (d$a + d$b + d$c) / 3
tri_var  <- function(d) (d$a^2 + d$b^2 + d$c^2 -
                         d$a * d$b - d$a * d$c - d$b * d$c) / 18
task_means <- vapply(bp$task_distributions, tri_mean, numeric(1))
task_vars  <- vapply(bp$task_distributions, tri_var,  numeric(1))

result <- smm(task_means, task_vars)
cat("Total mean:", round(result$total_mean, 2), "weeks\n")
cat("Total SD:  ", round(result$total_std,  2), "weeks\n")


## --- smm-cor ---
#+ smm-cor
result_cor <- smm(task_means, task_vars, bp$cor_mat)
cat("Total SD (correlated):", round(result_cor$total_std, 2), "weeks\n")


## --- mcs-run ---
#+ mcs-run
set.seed(42)
results <- mcs(10000, bp$task_distributions)
cat("Simulated mean:", round(results$total_mean, 2), "weeks\n")
cat("Simulated SD:  ", round(results$total_sd,   2), "weeks\n")


## --- mcs-cor ---
#+ mcs-cor
set.seed(42)
results_cor <- mcs(10000, bp$task_distributions, bp$cor_mat)
cat("Simulated SD (correlated):", round(results_cor$total_sd, 2), "weeks\n")


## --- validation ---
#+ validation
cat(sprintf("Mean:            SMM %.2f  vs  MCS %.2f\n",
            result$total_mean, results$total_mean))
cat(sprintf("SD:              SMM %.2f  vs  MCS %.2f\n",
            result$total_std,  results$total_sd))
cat(sprintf("SD (correlated): SMM %.2f  vs  MCS %.2f\n",
            result_cor$total_std, results_cor$total_sd))


## --- mcs-hist ---
#+ mcs-hist
hist(results$total_distribution,
  breaks = 50, freq = FALSE,
  main = "MCS: Total Project Duration",
  xlab = "Duration (weeks)", col = "steelblue", border = "white"
)
lines(density(results$total_distribution), col = "tomato", lwd = 2)
abline(v = results$total_mean, lty = 2, lwd = 1.5)


## --- cor-matrix ---
#+ cor-matrix
set.seed(42)
dists <- list(
  normal  = function(n) rnorm(n, mean = 10, sd = 2),
  triang  = function(n) mc2d::rpert(n, min = 5, mode = 10, max = 15),
  uniform = function(n) runif(n, min = 8, max = 12)
)
C_emp <- cor_matrix(num_samples = 1000, num_vars = 3, dists = dists)
print(round(C_emp, 3))


## --- contingency ---
#+ contingency
reserve <- contingency(results, phigh = 0.80, pbase = 0.50)
cat("Schedule contingency (P80 - P50):", round(reserve, 2), "weeks\n")


## --- sensitivity ---
#+ sensitivity
sens <- sensitivity(bp$task_distributions)
names(sens) <- paste0("T", seq_along(sens))
barplot(sort(sens),
  horiz = TRUE, col = "steelblue",
  main = "Sensitivity: Task Contributions",
  xlab = "Proportion of Total Variance"
)


## --- evm-setup ---
#+ evm-setup
bac         <- 500000
schedule    <- c(0.10, 0.25, 0.50, 0.75, 1.00)
time_period <- 3


## --- evm-core ---
#+ evm-core
pv_val <- pv(bac, schedule, time_period)
ev_val <- ev(bac, actual_per_complete = 0.40)
ac_val <- ac(c(45000, 110000, 135000), time_period, cumulative = FALSE)

cat("PV: $", format(pv_val, big.mark = ","), "\n")
cat("EV: $", format(ev_val, big.mark = ","), "\n")
cat("AC: $", format(ac_val, big.mark = ","), "\n")


## --- evm-indices ---
#+ evm-indices
spi_val  <- spi(ev_val, pv_val)
cpi_val  <- cpi(ev_val, ac_val)
sv_val   <- sv(ev_val,  pv_val)
cv_val   <- cv(ev_val,  ac_val)

cat("SPI:", round(spi_val, 3), "  CPI:", round(cpi_val, 3), "\n")
cat("SV: $", format(round(sv_val), big.mark = ","),
    "  CV: $", format(round(cv_val), big.mark = ","), "\n")


## --- evm-eac ---
#+ evm-eac
cat("EAC (typical):  $", format(round(eac(bac, method = "typical",
    cpi = cpi_val)), big.mark = ","), "\n")
cat("EAC (atypical): $", format(round(eac(bac, method = "atypical",
    ac = ac_val, ev = ev_val)), big.mark = ","), "\n")
cat("EAC (combined): $", format(round(eac(bac, method = "combined",
    cpi = cpi_val, ac = ac_val, ev = ev_val, spi = spi_val)),
    big.mark = ","), "\n")


## --- evm-remaining ---
#+ evm-remaining
eac_typ <- eac(bac, method = "typical", cpi = cpi_val)
cat("ETC:  $",
    format(round(etc(bac, ev_val, cpi = cpi_val)), big.mark = ","), "\n")
cat("TCPI:", round(tcpi(bac, ev_val, ac_val), 3), "\n")
cat("VAC:  $", format(round(vac(bac, eac_typ)), big.mark = ","), "\n")


## --- sigmoidal-data ---
#+ sigmoidal-data
progress <- data.frame(
  time       = 1:9,
  completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90)
)


## --- sigmoidal-fit ---
#+ sigmoidal-fit
fit_log  <- fit_sigmoidal(progress, "time", "completion", "logistic")
fit_gomp <- fit_sigmoidal(progress, "time", "completion", "gompertz")

cat("Logistic RSE: ", round(summary(fit_log)$sigma,  2), "\n")
cat("Gompertz RSE: ", round(summary(fit_gomp)$sigma, 2), "\n")


## --- sigmoidal-plot ---
#+ sigmoidal-plot
plot_sigmoidal(fit_gomp, progress, "time", "completion", "gompertz",
               conf_level = 0.95,
               main = "Gompertz Learning Curve",
               xlab = "Week", ylab = "Completion (%)")


## --- sigmoidal-predict ---
#+ sigmoidal-predict
preds <- predict_sigmoidal(fit_gomp, seq(10, 12, by = 0.5),
                            "gompertz", conf_level = 0.95)
print(round(preds, 1))


## --- bayes-prior ---
#+ bayes-prior
bp <- building_project
prior_delay <- risk_prob(bp$cause_probs, bp$risks_given_causes,
                         bp$risks_given_not_causes)
cat("Prior P(schedule delay):", round(prior_delay, 3), "\n")


## --- bayes-post ---
#+ bayes-post
post_delay <- risk_post_prob(
  bp$cause_probs, bp$risks_given_causes,
  bp$risks_given_not_causes, bp$observed_causes
)
cat("Posterior P(schedule delay):", round(post_delay, 3),
    " (observed causes:", paste(bp$observed_causes, collapse = ", "), ")\n")


## --- net-setup ---
#+ net-setup
nodes <- data.frame(
  id = c("A","B","C","D","E","F","G","H","I"),
  label = c("Risk-1","Risk-2","Resource-1","Resource-2","Resource-3",
            "Task-1","Task-2","Task-3","Project"),
  stringsAsFactors = FALSE
)
links <- data.frame(
  source = c("A","B","C","D","E","F","G","H"),
  target = c("C","D","F","G","H","I","I","I"),
  stringsAsFactors = FALSE
)
distributions <- list(
  A = list(type = "discrete", values = c(1, 0), probs = c(0.70, 0.30)),
  B = list(type = "discrete", values = c(1, 0), probs = c(0.60, 0.40)),
  C = list(type = "conditional", condition = "A",
    true_dist  = list(type = "normal", mean = 30000, sd = 8000),
    false_dist = list(type = "normal", mean = 15000, sd = 3000)),
  D = list(type = "conditional", condition = "B",
    true_dist  = list(type = "normal", mean = 80000, sd = 20000),
    false_dist = list(type = "normal", mean = 50000, sd = 10000)),
  E = list(type = "normal", mean = 20000, sd = 4000),
  F = list(type = "aggregate", nodes = "C"),
  G = list(type = "aggregate", nodes = "D"),
  H = list(type = "aggregate", nodes = "E"),
  I = list(type = "aggregate", nodes = c("F","G","H"))
)
net <- prob_net(nodes, links, distributions = distributions)


## --- net-sim ---
#+ net-sim
set.seed(42)
sim_net <- prob_net_sim(net, num_samples = 10000)
cat("Mean project cost: $",
    format(round(mean(sim_net$I)), big.mark = ","), "\n")
cat("P80 project cost:  $", format(round(quantile(sim_net$I, 0.80)),
    big.mark = ","), "\n")


## --- net-learn ---
#+ net-learn
learn_net <- prob_net_learn(net, observations = list(B = 0),
                            num_samples = 10000)

prior_net_dens <- density(sim_net$I)
post_net_dens  <- density(learn_net$I)

plot(prior_net_dens, col = "steelblue", lwd = 2,
     main = "Total Project Cost: Prior vs. Posterior",
     xlab = "Cost ($)",
     xlim = range(c(sim_net$I, learn_net$I)),
     ylim = range(c(prior_net_dens$y, post_net_dens$y)))
lines(post_net_dens, col = "tomato", lwd = 2)
legend("topright",
  legend = c("Prior (Risk-2 uncertain)", "Posterior (Risk-2 = 0)"),
  col = c("steelblue", "tomato"), lwd = 2, bty = "n")


## --- net-do ---
#+ net-do
inter_net <- prob_net_update(net,
  remove_links = data.frame(source = "B", target = "D"),
  update_distributions = list(
    D = list(type = "normal", mean = 50000, sd = 10000)
  )
)
do_net <- prob_net_sim(inter_net, num_samples = 10000)

cat("Prior mean:            $",
    format(round(mean(sim_net$I)),   big.mark = ","), "\n")
cat("Seeing (Risk-2 = 0):   $",
    format(round(mean(learn_net$I)), big.mark = ","), "\n")
cat("Doing  (do(Risk-2=0)): $",
    format(round(mean(do_net$I)),    big.mark = ","), "\n")


## --- net-confound ---
#+ net-confound
set.seed(42)
cf_nodes <- data.frame(
  id = c("U", "Rk", "Wf", "Vs", "Tc"), stringsAsFactors = FALSE)
cf_links <- data.frame(
  source = c("U", "U", "Rk", "Wf", "Vs"),
  target = c("Rk", "Wf", "Vs", "Tc", "Tc"), stringsAsFactors = FALSE)
cf_dists <- list(
  U  = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
  Rk = list(type = "conditional", condition = "U",
    true_dist  = list(type = "discrete",
      values = c(1, 0), probs = c(0.9, 0.1)),
    false_dist = list(type = "discrete",
      values = c(1, 0), probs = c(0.1, 0.9))),
  Wf = list(type = "conditional", condition = "U",
    true_dist  = list(type = "normal", mean = 60000, sd = 5000),
    false_dist = list(type = "normal", mean = 20000, sd = 5000)),
  Vs = list(type = "conditional", condition = "Rk",
    true_dist  = list(type = "normal", mean = 40000, sd = 5000),
    false_dist = list(type = "normal", mean = 10000, sd = 5000)),
  Tc = list(type = "aggregate", nodes = c("Wf", "Vs")))
cf_net <- prob_net(cf_nodes, cf_links, distributions = cf_dists)

cf_prior <- prob_net_sim(cf_net, num_samples = 10000)
cf_see   <- prob_net_learn(cf_net, observations = list(Rk = 0),
                           num_samples = 10000)
cf_do    <- prob_net_sim(prob_net_update(cf_net,
  remove_links = data.frame(source = "U", target = "Rk"),
  update_distributions = list(
    Rk = list(type = "discrete", values = c(1, 0), probs = c(0, 1)))),
  num_samples = 10000)

cat("Prior mean total:        $",
    format(round(mean(cf_prior$Tc)), big.mark = ","), "\n")
cat("Seeing (Rk = 0) mean:    $",
    format(round(mean(cf_see$Tc)),   big.mark = ","),
    "  E[U | Rk=0] =", round(mean(cf_see$U), 2), "\n")
cat("Doing  do(Rk = 0) mean:  $",
    format(round(mean(cf_do$Tc)),    big.mark = ","),
    "  E[U] =", round(mean(cf_do$U), 2), "\n")


## --- net-importance ---
#+ net-importance
base_var <- var(sim_net$I)

do_A <- prob_net_sim(prob_net_update(net,
  remove_links = data.frame(source = "A", target = "C"),
  update_distributions = list(
    C = list(type = "normal", mean = 15000, sd = 3000))),
  num_samples = 10000)

importance <- c(
  "Risk-1" = base_var - var(do_A$I),
  "Risk-2" = base_var - var(do_net$I)
)
barplot(sort(importance), horiz = TRUE, col = "steelblue",
  main = "Risk Importance: Variance Eliminated by do(risk = 0)",
  xlab = "Reduction in Project-Cost Variance")


## --- dsm-S ---
#+ dsm-S
S <- matrix(c(
  1, 0, 0,
  0, 1, 0,
  1, 1, 1
), nrow = 3, ncol = 3, byrow = TRUE)
rownames(S) <- c("Resource-1", "Resource-2", "Resource-3")
colnames(S) <- c("Task-1", "Task-2", "Task-3")


## --- parent-dsm ---
#+ parent-dsm
p <- parent_dsm(S)
plot(p)


## --- dsm-R ---
#+ dsm-R
R_mat <- matrix(c(
  1, 0, 1,
  0, 1, 1
), nrow = 2, ncol = 3, byrow = TRUE)
rownames(R_mat) <- c("Risk-1", "Risk-2")
colnames(R_mat) <- c("Resource-1", "Resource-2", "Resource-3")


## --- grandparent-dsm ---
#+ grandparent-dsm
g <- grandparent_dsm(S, R_mat)
plot(g)


## --- cs-mcs ---
#+ cs-mcs
bp <- building_project
set.seed(42)

smm_cs <- smm(task_means, task_vars, bp$cor_mat)
sim     <- mcs(10000, bp$task_distributions, bp$cor_mat)
res     <- contingency(sim, phigh = 0.80, pbase = 0.50)

cat("SMM total (correlated): mean", round(smm_cs$total_mean, 1),
    "SD", round(smm_cs$total_std, 2), "weeks\n")
cat("P50 schedule:",
    round(quantile(sim$total_distribution, 0.50), 1), "weeks\n")
cat("P80 schedule:",
    round(quantile(sim$total_distribution, 0.80), 1), "weeks\n")
cat("Contingency (P80-P50):", round(res, 2), "weeks\n")


## --- cs-sens ---
#+ cs-sens
drivers <- sensitivity(bp$task_distributions)
names(drivers) <- bp$task_names
print(round(sort(drivers, decreasing = TRUE), 3))


## --- cs-evm ---
#+ cs-evm
pv_cs <- pv(bp$bac, bp$schedule, bp$time_period)
ev_cs <- ev(bp$bac, bp$actual_per_complete)
ac_cs <- ac(bp$actual_costs, bp$time_period, cumulative = FALSE)

cat("SPI:", round(spi(ev_cs, pv_cs), 3),
    " CPI:", round(cpi(ev_cs, ac_cs), 3), "\n")
cat("EAC (typical): $", format(round(eac(bp$bac,
    method = "typical", cpi = cpi(ev_cs, ac_cs))), big.mark = ","), "\n")


## --- cs-forecast ---
#+ cs-forecast
cpi_cs  <- cpi(ev_cs, ac_cs)
eac_cs  <- eac(bp$bac, method = "typical", cpi = cpi_cs)

cat("ETC:  $", format(round(etc(bp$bac, ev_cs, cpi = cpi_cs)),
    big.mark = ","), "\n")
cat("TCPI:", round(tcpi(bp$bac, ev_cs, ac_cs), 3), "\n")
cat("VAC:  $", format(round(vac(bp$bac, eac_cs)), big.mark = ","), "\n")


## --- cs-bayes ---
#+ cs-bayes
prior_r <- risk_prob(bp$cause_probs, bp$risks_given_causes,
                     bp$risks_given_not_causes)
post_r  <- risk_post_prob(bp$cause_probs, bp$risks_given_causes,
                          bp$risks_given_not_causes, bp$observed_causes)
cat("Prior P(delay):", round(prior_r, 3),
    "-> Posterior P(delay):", round(post_r, 3), "\n")


## --- cs-net ---
#+ cs-net
cat("Prior mean project cost: $",
    format(round(mean(sim_net$I)), big.mark = ","), "\n")
cat("Prior P80 project cost:  $",
    format(round(quantile(sim_net$I, 0.80)), big.mark = ","), "\n")
cat("Posterior mean (Risk-2 = 0): $",
    format(round(mean(learn_net$I)), big.mark = ","), "\n")


## --- cs-dsm ---
#+ cs-dsm
g_cs <- grandparent_dsm(bp$resource_task, bp$risk_resource)
plot(g_cs)


## --- session-info ---
#+ session-info
sessionInfo()

