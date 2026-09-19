# Book Proposal

## Chapman & Hall/CRC

> **Drafting note — not part of the submission.** This is a first draft assembled
> from the manuscript in this repository, following the Chapman & Hall/CRC
> proposal form. Every figure, count, and title below was verified against the
> source files. The form carries a notice asking that generative AI not be used
> to create the proposal, so this draft is intended as a fact-checked scaffold to
> be rewritten in the author's own voice before submission. Question 9 is left
> for the author to answer personally. Delete this note before submitting.

## Title and Author(s)/Editor(s)

**1. Provisional title of your book.**

Project Risk Analysis: A Practical Guide — From Monte Carlo to AI Agents

**2. Names, titles, affiliations, and email addresses for all authors/editors**

Paul Govan, Senior Engineer, GE Aerospace, paul.govan2@gmail.com

## Contents

**3. Please include a complete table of contents including chapter and section
headings.**

Preface
- What This Book Is About
- Who This Book Is For
- How to Use This Book
- Getting Started
- A Note on Tone
- Why the PRA Package?
- A Reproducible Book
- How to Cite
- License
- Acknowledgements

1\. Into the Unknown: An Introduction to Project Risk Analysis
- What Is Project Risk?
- The Quantitative Toolkit
- How to Navigate This Book
- A Map of the Methods
- Installing the Package
- A Note on Uncertainty About Uncertainty
- Garbage In, Garbage Out

2\. Roll the Dice: Monte Carlo Simulation
- Learning Objectives
- How Monte Carlo Simulation Works
- The Five Steps of Monte Carlo Simulation
- Example
- Interpreting Percentiles
- Contingency Analysis
- Sensitivity Analysis
- Summary
- Key Takeaways
- Exercises

3\. May I Have a (Second) Moment? The Second Moment Method
- Learning Objectives
- When to Use SMM
- SMM vs. Monte Carlo: The Decision Rule
- How It Works
- Example
- Implied Distribution and Confidence Interval
- Comparison with Monte Carlo Simulation
- What This Comparison Is Testing
- Benefits and Limitations
- Summary
- Key Takeaways
- Exercises

4\. Who's Driving? Sensitivity Analysis
- Learning Objectives
- What Is Sensitivity Analysis?
- Sensitivity vs. Percentiles
- Setup
- Computing Sensitivity
- Tornado Chart
- With Correlated Tasks
- Summary
- Key Takeaways
- Exercises

5\. Keeping Score: Earned Value Management
- Learning Objectives
- The Three Core Numbers
- PV, EV, AC: The Foundation of Everything
- Key Metrics
- Example Setup
- Forecasting: Estimate at Completion (EAC)
- Additional Metrics
- Performance Trend Chart
- Summary
- Key Takeaways
- Exercises

6\. I Had a Feeling: Bayesian Risk Inference
- Learning Objectives
- The Core Idea
- Bayes' Theorem in Plain English
- Causal Structure
- Step 1: Prior Risk Probability
- Step 2: Prior Cost Distribution
- Step 3: Posterior Risk Probability (Bayesian Update)
- Step 4: Posterior Cost Distribution
- The Workflow
- Summary
- Key Takeaways
- Exercises

7\. S Is for Success: Sigmoidal Learning Curves
- Learning Objectives
- Why Sigmoidal?
- The Three Models
- Example: Fitting a Logistic Model
- Comparing All Three Model Types
- Logistic and Pearl Are the Same Model
- The Workflow
- Summary
- Key Takeaways
- Exercises

8\. It's a Small World After All: Probabilistic Networks
- Learning Objectives
- What Is a Bayesian Network?
- Bayesian Network vs. DSM
- Project Setup
- Building the Bayesian Network
- Inference: Forward Simulation
- Learning: Incorporating New Evidence
- Updating: Modifying the Network
- The Four Core Functions
- Summary
- Key Takeaways
- Exercises

9\. Everything Is Connected: Design Structure Matrices
- Learning Objectives
- What Is a DSM?
- Rebuilding the Project Network
- The Adjacency Matrix
- The Resource-Task Matrix
- Parent DSM
- The Risk-Resource Matrix
- Grandparent DSM
- Interpreting the DSM
- From DSM to Decision
- Using the DSM to Prioritize Mitigation
- Summary
- Key Takeaways
- DSM vs. Bayesian Network: When to Use Each
- Exercises

10\. The Portfolio Problem: When Risks Are Shared
- Learning Objectives
- The Portfolio Case Study
- Seeing Is Not the Same as Doing
- Setup
- Building the Portfolio Network
- Observational Distribution
- Seeing vs. Doing at the Risk Level
- Enterprise vs. Project-Scoped Intervention
- Risk Importance Ranking
- Summary Table
- Summary
- Key Takeaways
- Exercises

11\. Write Once, Trust Always: Reproducible Risk Analysis with Quarto
- Learning Objectives
- The Spreadsheet Problem
- Reproducible vs. Repeatable
- What is Quarto?
- Quarto vs. R Markdown
- Your First Risk Report
- Parameterized Reports
- Parametric Reporting in Practice
- Version Control with Git
- Package Environments with renv
- This Book as a Living Example
- What "Live Book" Means for You
- Exercises

12\. Your AI Co-Pilot: Agentic Risk Analysis
- Learning Objectives
- How PRA Talks to AI Agents
- Prerequisites
- The MCP Server
- Agent Skills
- From Request to Tool Call
- Tool Reference
- Summary
- Key Takeaways
- Exercises

Appendix A: Glossary
- Probability & Distributions
- Monte Carlo Simulation & Sensitivity
- Second Moment Method
- Earned Value Management
- Bayesian Inference
- Learning Curves
- Structural Methods
- Agentic Framework

Appendix B: Mathematical Derivations
- Why Total Variance Is a Sum
- Variance Formulas for Standard Distributions
- The Sensitivity Index
- Bayesian Updating for Project Risk

Appendix C: Quick Reference
- Monte Carlo Simulation
- Second Moment Method
- Sensitivity Analysis
- Contingency & Correlation
- Earned Value Management
- Bayesian Risk
- Learning Curves
- Design Structure Matrices
- Probabilistic Networks
- Agentic Framework

Appendix D: Case Study — Riverside Bridge Replacement
- The Project
- Step 1: Monte Carlo Simulation
- Step 2: Sensitivity Analysis
- Step 3: Second Moment Method
- Step 4: Earned Value Management
- Step 5: Bayesian Risk Update
- Step 6: Learning Curve
- Step 7: Design Structure Matrix
- Step 8: Probabilistic Network
- Step 9: Agentic Analysis
- Driving the Tools from Natural Language
- What the Methods Told Us

Appendix E: Exercise Solutions
- Monte Carlo Simulation
- Sensitivity Analysis
- Second Moment Method
- Earned Value Management
- Bayesian Risk Inference
- Sigmoidal Learning Curves
- Design Structure Matrices
- Probabilistic Networks
- Portfolio Networks
- Agentic Risk Analysis

References

## Subject/Audience

**4. Please describe in detail the subject of your book. Why will this book be
important, who will find it useful, and what is new? What background will you
assume?**

Project Risk Analysis: A Practical Guide teaches the quantitative methods used to
manage uncertainty in project schedules and costs, introducing each method
alongside the open-source R code that implements it, so that readers learn the
technique and how to run it at the same time. The book covers Monte Carlo
simulation, the second moment method, sensitivity analysis, earned value
management, Bayesian risk inference, sigmoidal learning curves, design structure
matrices, and probabilistic networks, all built on the `PRA` package published on
CRAN.

The book matters because project risk analysis has a tooling problem rather than
a theory problem. The underlying mathematics has been settled for decades, but
most practitioners still run it in spreadsheets, where a broken formula or a
range that ends three rows short can silently change a P95 estimate that goes on
to justify a contingency reserve. This book's emphasis is on reproducibility:
every example is executable R code rather than a static screenshot, and the book
itself is rendered by executing that code against the live package, so no printed
result is transcribed by hand.

What is new is the last two chapters. One shows how to build auditable,
version-controlled risk reports with Quarto, including parameterized reports that
re-run across projects and scenarios. The other shows how to expose the
analytical functions to AI assistants through the Model Context Protocol, so that
a plain-language request produces a real computed result rather than a
plausible-sounding estimate. No existing project risk text treats either subject.

The book is useful to project managers and controls engineers moving from
spreadsheets or commercial simulation add-ins toward reproducible workflows; to
engineers and analysts who know statistics but have not applied it to project
risk; to data scientists supporting a project controls or PMO function; and to
students and instructors in construction management, systems engineering, and
operations research. It assumes basic probability — what a mean is, what a
variance is — and some familiarity with R, but no prior background in project
risk management. Mathematical derivations are placed in an appendix so the main
text stays readable without them.

**5. Will your book be primarily a textbook? If so, for which courses will it be
the primary text and at what level is the course taught? Will you include
exercises sets and supply a solutions manual?**

The book is written as a practitioner's guide first, but it is structured for
classroom use and would work as a primary text for an upper-level undergraduate
or introductory graduate course in project risk management, construction
management, engineering project controls, or systems engineering — particularly
where the course already uses R. Each chapter follows a consistent pattern:
learning objectives, a short answer to when the method is actually used, enough
theory to understand the computation, a fully worked example, a summary, key
takeaways, and exercises.

All eleven method chapters end with exercise sets of roughly ten to fifteen
questions, ranging from verifying that the reader followed the worked example to
extending the method to a new scenario. Worked solutions for ten of those
chapters are already written as an appendix; the Quarto chapter's exercises are
currently unsolved and would be completed before delivery. If the publisher wants
a more conventional classroom package, the solutions could be separated into an
instructor-only manual and expanded with additional problem sets.

**6. What related books are available, and how do they differ from the proposed
book?**

Several established texts cover adjacent ground but differ in important ways.
David Vose's Risk Analysis: A Quantitative Guide is the closest competitor and
remains the standard reference on quantitative risk modelling. It is broader and
more theoretical than the proposed book, but its worked examples depend on
commercial spreadsheet add-ins rather than open-source tooling, it offers no
reproducible workflow, and the current edition is now more than fifteen years
old. The Project Management Institute's PMBOK Guide is the authoritative
standards document for the field, but it is deliberately descriptive: it
establishes what a risk process should include without showing how to compute
anything, so it complements rather than competes with this book. Fleming and
Koppelman's Earned Value Project Management is the definitive treatment of earned
value, but that is a single chapter of twelve here, and the book does not address
simulation, Bayesian methods, or structural analysis. Benjamin and Cornell's
Probability, Statistics, and Decision for Civil Engineers remains excellent on
the underlying theory but is a general engineering statistics text rather than a
project-specific one, and predates any modern software workflow.

The proposed book differs from all of these by pairing broad method coverage with
fully reproducible R code throughout, backed by a maintained CRAN package, and by
being the only treatment that addresses reproducible reporting via Quarto and
AI-assisted analysis via MCP.

## Production

**7. Approximately how many printed pages will your book contain? Are colour
figures essential to your book? If so, about how many would have to be in colour?
Colour printing is still very expensive and colour figures will increase the
price so black and white should be used unless colour is essential.**

The manuscript currently runs to about 31,000 words of source text across twelve
chapters and five appendices, plus executable code and generated figures. I
expect roughly 180 – 200 printed pages depending on layout and formatting, since
code listings set less densely than prose.

There are 33 captioned figures. Most do not require colour: histograms, tornado
charts, cumulative distribution plots, and performance trend charts all read
correctly in black and white. Roughly fifteen do carry information in colour —
the multi-curve learning curve comparisons, the network and portfolio diagrams
where node colour distinguishes risks from resources and tasks, and the design
structure matrix heat maps. Of those, the line plots could be redrawn using
distinct line types and the heat maps using a greyscale ramp without losing
meaning. I would be glad to convert them if colour printing is a concern, and
would want to keep colour only for the network diagrams, where the node
categories are genuinely hard to distinguish otherwise.

**8. When would you hope to be able to submit the final draft of the book to us?
Will you use Latex, bookdown, Quarto, or Word? We will supply a style file for
LaTeX authors and request an unformatted file from Word authors.**

A complete draft is already written and available online at
https://paulgovan.github.io/PRA/book/. The book is a Quarto project and renders
to HTML, PDF, and EPUB from the same source. Because the manuscript exists, the
remaining work is editorial rather than generative: I would expect to deliver a
final draft within four to six months of contract, allowing time for technical
review, the outstanding Quarto exercise solutions, and any restructuring the
publisher wants.

**9. Are you planning on using generative AI tools in the writing process? If so,
please summarise how you plan to use the tools. Please refer to our AI policy
here: https://taylorandfrancis.com/our-policies/ai-policy/.**

> **To be answered by the author.** This question asks about the writing of the
> book and should be answered personally and accurately, in line with the
> Taylor & Francis AI policy.

## Reviews

**10. Please give the names and e-mail addresses of four people who would be
qualified to give an opinion on your proposed book.**

> **For the author to confirm.** The four below are carried over from the
> reliability proposal. Ivan Damnjanovic is a direct fit, being co-author on both
> of the project risk publications this book draws on. The others should be
> re-checked for relevance to project risk specifically before submitting.

Ivan Damnjanovic, Professor, Texas A&M University, ddivan@gmail.com

Pierre Brandicourt, Risk Manager, Sempra Infrastructure, pbrandicourt@gmail.com

Brad Foulkes, Founder, Gapz Analytics, bfoulkes@gmail.com

Ken (Myungkeun) Yoon, Senior Principal Systems Engineer, Raytheon Technologies, manggun.yoon@gmail.com

## Key Features

**11. Please list up to six key features of your proposed book that we can use in
bulleted form.**

- Complete quantitative toolkit in a single volume
- Every result computed from executable code, not transcribed
- Backed by a tested, actively maintained CRAN package
- One worked project carried end to end through all nine methods
- Exercises with worked solutions in every method chapter
- Modern coverage of reproducible reporting and AI-assisted analysis

**12. Please list up to six key words or phrases that people interested in this
topic may use to search Amazon or the web. Do not repeat words in the title as
these will already be found.**

- Schedule uncertainty modeling in R
- Cost contingency estimation
- Earned value management R package
- Bayesian networks for construction
- Design structure matrix
- Second moment method

**13. Please select the three most important markets for your book. Other
categories are available including education, psychology, and economics so please
mention other important disciplines.**

> **For the author to confirm against the publisher's category list.** Only the
> first code below is taken from the publisher's list as it appeared on the
> reliability form; the other two are described in words rather than guessed at.

Statistics

STA10A-Statistics-Statistics for Engineering and Physical Science

Beyond statistics, the two most relevant disciplines are civil engineering and
construction management (project controls, cost and schedule estimation) and
industrial or systems engineering (engineering management, operations research).
Business and management — specifically project management and decision analysis
— is a credible third market.
