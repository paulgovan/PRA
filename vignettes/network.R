## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----results='asis'-----------------------------------------------------------
roadway_tasks <- data.frame(
  ID = c("A", "B", "C", "D", "E", "F", "G", "H"),
  Label = c(
    "Task-1",
    "Task-2",
    "Task-3",
    "Task-4",
    "Task-5", 
    "Task-6",
    "Task-7",
    "Task-8"
  ),
  Task = c(
    "Survey and Site Assessment",
    "Design and Planning",
    "Permitting and Approvals",
    "Excavation and Grading",
    "Pavement Installation",
    "Drainage and Utilities Installation",
    "Signage and Markings",
    "Final Inspection and Handover"
  ), 
  Project_ID = rep("T", 8)
)

knitr::kable(roadway_tasks, caption = "Roadway Tasks")

## ----results='asis'-----------------------------------------------------------
roadway_resources <- data.frame(
  ID = c("I", "J", "K", "L", "M", "N", "O", "P"),
  Label = c(
    "Resource-1",
    "Resource-2",
    "Resource-3",
    "Resource-4",
    "Resource-5",
    "Resource-6",
    "Resource-7",
    "Resource-8"
  ),
  Resource = c(
    "Surveyer",
    "Engineer",
    "Regulatory Support",
    "Heavy Machinery",
    "Pavement and Related Machinery",
    "Drainage Material and Equipment",
    "Painters, Traffic Signs, Road Markers",
    "Inspectors and Quality Control Support"
  ),
  Task_ID = c("A", "B", "C", "D", "E", "F", "G", "H"),
  Task = c(
    "Survey and Site Assessment",
    "Design and Planning",
    "Permitting and Approvals",
    "Excavation and Grading",
    "Pavement Installation",
    "Drainage and Utilities Installation",
    "Signage and Markings",
    "Final Inspection and Handover"
  ),
  Mean = c(
    10000,
    20000,
    3500,
    35000,
    100000,
    25000,
    6500,
    2000
  ), 
  SD = c(
    2000,
    5000,
    1000,
    10000,
    20000,
    5000,
    1500,
    500
  )
)

knitr::kable(roadway_resources, caption = "Roadway Resources")

## ----results='asis'-----------------------------------------------------------
roadway_risks <- data.frame(
  Risk_ID = c("Q", "R", "S"),
  Name = c(
    "Risk-1",
    "Risk-2",
    "Risk-3"
  ),
  Risk = c(
    "Delays in Permitting and Approvals",
    "Unforeseen Site Conditions",
    "Material Price Fluctuations"
  ),
  Probability = c(
    0.1,
    0.05,
    0.2
  ),
  Resource_ID = c("K", "L", "M"),
  Resource = c(
    "Regulatory Support",
    "Heavy Machinery",
    "Pavement and Related Machinery"
  ),
  Mean = c(
    3500,
    35000,
    100000
  ),
  SD = c(
    1000,
    10000,
    20000
  )
)

knitr::kable(roadway_risks, caption = "Roadway Risks")

## -----------------------------------------------------------------------------
nodes <- data.frame(
 id = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"),
  label = c(
    "Task-1",
    "Task-2",
    "Task-3",
    "Task-4",
    "Task-5", 
    "Task-6",
    "Task-7",
    "Task-8",
    "Resource-1",
    "Resource-2",
    "Resource-3",
    "Resource-4",
    "Resource-5",
    "Resource-6",
    "Resource-7",
    "Resource-8",
    "Risk-1",
    "Risk-2",
    "Risk-3",
    "Project"
  ),
  stringsAsFactors = FALSE
 )

## -----------------------------------------------------------------------------
links <- data.frame(
  source = c(
    "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "A", "B", "C", "D", "E", "F", "G", "H"
  ),
  target = c(
    "A", "B", "C", "D", "E", "F", "G", "H", "K", "L", "M", "T", "T", "T", "T", "T", "T", "T", "T"
  ),
  stringsAsFactors = FALSE
)

## -----------------------------------------------------------------------------
distributions <- list(
  A = list(
    type = "aggregate",
    nodes = c("T")
  ),
  B = list(
    type = "aggregate",
    nodes = c("T")
  ),
  C = list(
    type = "aggregate",
    nodes = c("T")
  ),
  D = list(
    type = "aggregate",
    nodes = c("T")
  ),
  E = list(
    type = "aggregate",
    nodes = c("T")
  ),
  F = list(
    type = "aggregate",
    nodes = c("T")
  ),
  G = list(
    type = "aggregate",
    nodes = c("T")
  ),
  H = list(
    type = "aggregate",
    nodes = c("T")
  ),
  I = list(
    type = "continuous",
    mean = 10000,
    sd = 2000
  ),
  J = list(
    type = "continuous",
    mean = 20000,
    sd = 5000
  ),
  K = list(
    type = "conditional", condition = "Q",
    true_dist = list(
      mean = 3500,
      sd = 1000
    ),
    false_dist = list(
      mean = 0,
      sd = 0
    )
  ),
  L = list(
    type = "conditional", condition = "R",
    true_dist = list(
      mean = 35000,
      sd = 10000
    ),
    false_dist = list(
      mean = 0,
      sd = 0
    )
  ),
  M = list(
    type = "conditional", condition = "S",
    true_dist = list(
      mean = 100000,
      sd = 20000
    ),
    false_dist = list(
      mean = 0,
      sd = 0
    )
  ),
  N = list(
    type = "continuous",
    mean = 100000,
    sd = 20000
  ),
  O = list(
    type = "continuous",
    mean = 25000,
    sd = 5000
  ),
  P = list(
    type = "continuous",
    mean = 6500,
    sd = 1500
  ),
  Q = list(
    type = "discrete",
    values = c("Yes", "No"),
    probs = c(0.1, 0.9)
  ),
  R = list(
    type = "discrete",
    values = c("Yes", "No"),
    probs = c(0.05, 0.95)
  ),
  S = list(
    type = "discrete",
    values = c("Yes", "No"),
    probs = c(0.2, 0.8)
  ),
  T = list(
    type = "aggregate",
    nodes = c("A", "B", "C", "D", "E", "F", "G", "H")
  )
)

## -----------------------------------------------------------------------------
library(PRA)
graph <- prob_net(nodes, links, distributions = distributions)

## -----------------------------------------------------------------------------
g <- igraph::graph_from_data_frame(graph$links, vertices = graph$nodes, directed = TRUE)
plot(g, main = "Bayesian Network")

