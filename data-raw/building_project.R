# Construct the `building_project` example dataset.
#
# A realistic mid-rise commercial building construction project used to
# illustrate the PRA workflow end to end (uncertainty, EVM, Bayesian risk,
# and dependency structure). The structure and parameter ranges are adapted
# from the illustrative construction-project examples in Damnjanovic and
# Reinschmidt (2020), "Data Analytics for Engineering and Construction Project
# Risk Management" (Springer), which is the reference text the PRA package
# operationalizes. All values are representative estimates for a project of
# this type, not proprietary data from a specific project.
#
# Run with:  source("data-raw/building_project.R")

# Six work packages, durations in weeks. PRA's triangular convention is
# a = optimistic (min), b = most likely (mode), c = pessimistic (max).
task_names <- c(
  "Site Preparation & Earthworks",
  "Foundations",
  "Structural Frame",
  "Building Envelope",
  "Mechanical/Electrical/Plumbing",
  "Interior Fit-out & Finishes"
)

task_distributions <- list(
  list(type = "triangular", a = 4,  b = 6,  c = 10),
  list(type = "triangular", a = 6,  b = 8,  c = 12),
  list(type = "triangular", a = 12, b = 16, c = 24),
  list(type = "triangular", a = 8,  b = 11, c = 16),
  list(type = "triangular", a = 10, b = 14, c = 20),
  list(type = "triangular", a = 8,  b = 12, c = 18)
)

# Positive correlations from shared crews, weather exposure, and sequencing.
cor_mat <- matrix(c(
  1.00, 0.40, 0.20, 0.10, 0.10, 0.05,
  0.40, 1.00, 0.35, 0.15, 0.10, 0.05,
  0.20, 0.35, 1.00, 0.45, 0.30, 0.15,
  0.10, 0.15, 0.45, 1.00, 0.40, 0.25,
  0.10, 0.10, 0.30, 0.40, 1.00, 0.35,
  0.05, 0.05, 0.15, 0.25, 0.35, 1.00
), nrow = 6, byrow = TRUE)
dimnames(cor_mat) <- list(paste0("T", 1:6), paste0("T", 1:6))

# Earned value inputs at the current reporting period (end of quarter 3).
bac <- 8500000                                   # budget at completion ($)
schedule <- c(0.08, 0.22, 0.45, 0.68, 0.88, 1.00) # cumulative planned value
actual_costs <- c(620000, 1180000, 1650000)      # per-period actual cost ($)
time_period <- 3
actual_per_complete <- 0.40

# Bayesian risk register: root causes of a schedule-delay risk event.
cause_names <- c("Adverse weather", "Late design changes")
cause_probs            <- c(0.35, 0.25)
risks_given_causes     <- c(0.70, 0.55)
risks_given_not_causes <- c(0.20, 0.25)
# Mid-project observation: weather occurred; design changes not yet assessed.
observed_causes        <- c(1, NA)

# Dependency structure: resource-task matrix S (resources x tasks).
resource_names <- c(
  "Excavation crew", "Concrete crew", "Steel erector",
  "Tower crane", "MEP subcontractor", "Finishing crew"
)
resource_task <- matrix(c(
  1, 1, 0, 0, 0, 0,   # Excavation crew -> site prep, foundations
  0, 1, 1, 0, 0, 0,   # Concrete crew  -> foundations, frame
  0, 0, 1, 0, 0, 0,   # Steel erector  -> frame
  0, 1, 1, 1, 0, 0,   # Tower crane    -> foundations, frame, envelope
  0, 0, 0, 1, 1, 0,   # MEP subcontractor -> envelope, MEP
  0, 0, 0, 0, 1, 1    # Finishing crew -> MEP, fit-out
), nrow = 6, byrow = TRUE)
dimnames(resource_task) <- list(resource_names, paste0("T", 1:6))

# Risk-resource matrix R (risks x resources).
risk_names <- c("Weather", "Supply chain", "Labor market")
risk_resource <- matrix(c(
  1, 1, 0, 1, 0, 0,   # Weather      -> excavation, concrete, crane
  0, 1, 1, 0, 1, 0,   # Supply chain -> concrete, steel, MEP
  1, 0, 1, 0, 1, 1    # Labor market -> excavation, steel, MEP, finishing
), nrow = 3, byrow = TRUE)
dimnames(risk_resource) <- list(risk_names, resource_names)

# ---- Resource-loaded schedule (for project_schedule(), cpm() and sra()) ----
# Activity ids follow the task order (T1..T6). Durations are the most likely
# values of the task distributions, in weeks. Interior fit-out (T6) is
# resource-driven: 24 crew-weeks of work by two finishing crews, with uncertain
# crew productivity, so it has no duration of its own. Fixed costs are
# materials and subcontract lump sums ($); resource costs come from the rates.
schedule_activities <- data.frame(
  id = paste0("T", 1:6),
  name = task_names,
  duration = c(6, 8, 16, 11, 14, NA),
  fixed_cost = c(200000, 600000, 1600000, 1100000, 1200000, 500000),
  stringsAsFactors = FALSE
)

# Precedence logic, including overlaps: the envelope starts 8 weeks into the
# frame and finishes no sooner than 2 weeks after it; MEP rough-in starts 4
# weeks into the envelope; fit-out follows envelope dry-in, may start 6 weeks
# into MEP, and finishes at least 4 weeks after MEP.
schedule_links <- data.frame(
  source = c("T1", "T2", "T3", "T3", "T4", "T4", "T5", "T5"),
  target = c("T2", "T3", "T4", "T4", "T5", "T6", "T6", "T6"),
  type   = c("FS", "FS", "SS", "FF", "SS", "FS", "SS", "FF"),
  lag    = c(0,    0,    8,    2,    4,    0,    6,    4),
  stringsAsFactors = FALSE
)

# Duration uncertainty for the five duration-driven activities, with the
# matching block of the task correlation matrix.
duration_dists <- stats::setNames(task_distributions[1:5], paste0("T", 1:5))

# Resources: capacity in crews/units and cost per unit per week ($). The single
# tower crane is shared by foundations, frame and envelope.
schedule_resources <- data.frame(
  id = resource_names,
  capacity = c(1, 1, 1, 1, 2, 3),
  rate = c(18000, 22000, 30000, 12000, 35000, 20000),
  stringsAsFactors = FALSE
)

# Assignments follow the resource-task matrix above.
schedule_assignments <- data.frame(
  activity = c("T1", "T2", "T2", "T3", "T3", "T3", "T2", "T4", "T4", "T5", "T5", "T6"),
  resource = c("Excavation crew", "Excavation crew", "Concrete crew",
               "Concrete crew", "Steel erector", "Tower crane", "Tower crane",
               "Tower crane", "MEP subcontractor", "MEP subcontractor",
               "Finishing crew", "Finishing crew"),
  units = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2),
  work = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 24),
  stringsAsFactors = FALSE
)

# Finishing-crew productivity multiplier (1 = planned rate).
productivity_dists <- list(
  "Finishing crew" = list(type = "pert", a = 0.75, b = 1, c = 1.1)
)

# Discrete risk events, reusing the root causes above.
risk_register <- list(
  list(
    id = "Adverse weather", prob = 0.35, activities = c("T1", "T2"),
    impact = list(type = "triangular", a = 1, b = 2, c = 4),
    cost_impact = list(type = "uniform", min = 50000, max = 150000)
  ),
  list(
    id = "Late design changes", prob = 0.25, activities = c("T4", "T5"),
    impact = list(type = "triangular", a = 1, b = 3, c = 6),
    cost_impact = list(type = "triangular", a = 100000, b = 250000, c = 500000)
  )
)

start_date <- as.Date("2027-03-01")

building_project <- list(
  task_names             = task_names,
  task_distributions     = task_distributions,
  cor_mat                = cor_mat,
  bac                    = bac,
  schedule               = schedule,
  actual_costs           = actual_costs,
  time_period            = time_period,
  actual_per_complete    = actual_per_complete,
  cause_names            = cause_names,
  cause_probs            = cause_probs,
  risks_given_causes     = risks_given_causes,
  risks_given_not_causes = risks_given_not_causes,
  observed_causes        = observed_causes,
  resource_names         = resource_names,
  resource_task          = resource_task,
  risk_names             = risk_names,
  risk_resource          = risk_resource,
  schedule_activities    = schedule_activities,
  schedule_links         = schedule_links,
  duration_dists         = duration_dists,
  schedule_resources     = schedule_resources,
  schedule_assignments   = schedule_assignments,
  productivity_dists     = productivity_dists,
  risk_register          = risk_register,
  start_date             = start_date
)

usethis_available <- requireNamespace("usethis", quietly = TRUE)
if (usethis_available) {
  usethis::use_data(building_project, overwrite = TRUE)
} else {
  dir.create("data", showWarnings = FALSE)
  save(building_project, file = "data/building_project.rda",
       compress = "bzip2", version = 2)
}
