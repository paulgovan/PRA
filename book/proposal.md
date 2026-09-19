# Book Proposal

*Drafted against O'Reilly's standard proposal sections. If the ORM template's
headings differ, the content below maps onto them section for section.*

## 1. Proposed Title

**Project Risk Analysis: A Practical Guide**
Subtitle: *From Monte Carlo to AI Agents*

## 2. Author

Paul Govan — paul.govan2@gmail.com — ORCID [0000-0002-1821-8492](https://orcid.org/0000-0002-1821-8492)

## 3. Topic

This is a hands-on introduction to quantitative methods for managing uncertainty
in project schedules and costs. It covers the techniques risk analysts actually
use — Monte Carlo simulation, the second moment method, sensitivity analysis,
earned value management, Bayesian inference, learning curves, design structure
matrices, and probabilistic networks — and teaches each one through working R
code built on the `PRA` package.

The book's argument is that project risk analysis has a tooling problem, not a
theory problem. The mathematics has been settled for decades. What practitioners
lack is a way to run these methods that is reproducible, auditable, and not a
spreadsheet named `Final_v3_REVISED_use_this_one.xlsx` with three broken
formulas. Every code block in the book executes at build time against the live
package, so the numbers on the page are computed, not transcribed.

The goal for the reader is concrete: take a project estimate, ask the right "what
if" questions, and produce defensible numbers for schedule and cost contingency.

## 4. Why This Topic, Why Now

Two developments make this the right moment for this book.

**Reproducibility has become an expectation.** Risk estimates increasingly have
to survive audit, and "trust the spreadsheet" no longer clears that bar. A
literate-programming workflow — analysis and narrative in one document, rendered
fresh on every build — is now standard practice in data-driven fields and is
arriving in project controls. The book devotes a full chapter to building
reproducible and parameterized risk reports in Quarto.

**AI agents can now drive analytical tooling directly.** The `PRA` package
exposes its analytical functions as tools over the Model Context Protocol and
ships Agent Skills that tell an agent when and how to call each one. A project
manager can ask for a P95 date and a contingency reserve in plain language and
get back real computed output rather than a plausible-sounding guess. To our
knowledge no existing project-risk title covers this. It is the book's clearest
differentiator, and the final chapter is devoted to it.

Monte Carlo simulation is well-trodden ground and is treated here as table
stakes. The distinctive contribution is the workflow wrapped around it:
reproducible, tested, version-controllable, and agent-addressable.

## 5. Audience

The primary readers are:

- **Project managers** who want to move past gut-feel estimates and "10%
  contingency, because that's what we always do"
- **Engineers and analysts** who know statistics but have not applied it to
  project risk
- **Students** in construction management, systems engineering, and operations
  research programs
- **R users** who want practical, well-documented risk analysis workflows

**Assumed background:** basic probability — what a mean is, what a variance is —
and passing familiarity with R. The reader does not need to be a statistician.
Mathematical derivations are available in an appendix for readers who want them,
so the main text stays readable without them.

## 6. What Readers Will Be Able to Do

After working through the book, a reader can:

- Build a Monte Carlo model of a project schedule or budget and read percentiles
  correctly
- Size a contingency reserve to a stated confidence level and defend the number
- Identify which tasks actually drive total uncertainty, using variance
  decomposition rather than intuition
- Choose between a full simulation and a second-moment approximation, and know
  why
- Track and forecast project performance with earned value metrics
- Update a risk assessment formally when new evidence arrives, instead of
  arguing about it
- Forecast completion by fitting a learning curve to early progress data
- Model how risks propagate across a portfolio through shared root causes, and
  distinguish observing a risk from intervening on it
- Package the whole analysis as a reproducible report that re-runs cleanly in two
  years
- Expose these methods to an AI agent and supervise its work competently

## 7. Key Features

- **Every result is computed, not transcribed.** The book is a Quarto project
  rendered against the live `PRA` package. If a function's behavior changes, the
  build breaks loudly rather than going quietly stale.
- **One method per chapter, uniform structure.** Each chapter answers "when would
  I actually use this?", supplies just enough theory, works a complete example,
  and ends with exercises.
- **Exercises with full solutions.** 10–15 per chapter, ranging from "verify you
  followed along" to "extend this to a real scenario," with worked solutions in
  an appendix.
- **One project carried end to end.** A case study appendix applies all nine
  methods to a single bridge-replacement project, so the reader sees how the
  techniques compose rather than meeting them in isolation.
- **Backed by a real package.** `PRA` is on CRAN, with a full test suite,
  continuous integration on three platforms, code coverage reporting, and a
  documentation site. The code in the book is maintained software, not listings.
- **Complete supporting apparatus.** Glossary, mathematical derivations, and a
  quick-reference card are already written.

## 8. Competing and Related Titles

| Title | Relationship |
|---|---|
| Vose, *Risk Analysis: A Quantitative Guide*, 3rd ed. (Wiley, 2008) | The closest competitor and the standard reference. Broader and more theoretical, but tied to commercial spreadsheet add-ins, not reproducible, and now over fifteen years old. Covers no agentic or literate-programming workflow. |
| PMI, *A Guide to the Project Management Body of Knowledge (PMBOK Guide)*, 7th ed. (2021) | A standards document. Says what should be done; does not show how to compute it. Complementary — this book supplies the implementation PMBOK leaves to the reader. |
| Fleming & Koppelman, *Earned Value Project Management*, 4th ed. (PMI, 2010) | Authoritative on EVM alone, which this book covers in one chapter of twelve. Non-overlapping otherwise. |
| Benjamin & Cornell, *Probability, Statistics, and Decision for Civil Engineers* (Dover) | Foundational and still excellent on theory, but a general engineering-statistics text, not project-specific, and offers no software workflow. |

Adjacent but non-competing: Hubbard's *How to Measure Anything* and Savage's
*The Flaw of Averages* make the case for quantifying uncertainty but stop short
of supplying a working toolkit. This book is the practical follow-on for readers
those titles have already persuaded.

**The gap:** no current title combines project risk methods with a tested,
open-source, reproducible toolchain — and none addresses agent-driven analysis.

## 9. Author Background and Platform

Paul Govan holds a PhD from The University of Texas at Austin (2014), where his
dissertation developed a resource-based view of project risk management. His
peer-reviewed work on the subject includes:

- Govan & Damnjanovic (2016), "The Resource-Based View on Project Risk
  Management," *Journal of Construction Engineering and Management* 142(9)
- Govan & Damnjanovic (2020), "Structural Network Measures for Risk Assessment of
  Construction Projects," *ASCE-ASME Journal of Risk and Uncertainty in
  Engineering Systems, Part A: Civil Engineering*

He is the author and maintainer of `PRA`, published on CRAN (currently v0.7.0,
DOI 10.32614/CRAN.package.PRA), which gives the book a built-in distribution
channel: readers arrive at the package through CRAN and the R ecosystem, and the
book is the package's documentation in long form.

The draft is already public as a Quarto site at
https://paulgovan.github.io/PRA/book/.

> *To be completed by the author: current professional affiliation and title;
> speaking, teaching, or conference activity; social and newsletter following;
> and any other channels available for promotion.*

## 10. Annotated Table of Contents

Twelve chapters and six appendices. Each chapter follows the same four-part
structure and ends with exercises.

**Front matter — Preface.** What the book covers, who it is for, how to read it,
and why the analysis is done in code rather than a spreadsheet.

**1. Into the Unknown: An Introduction to Project Risk Analysis.** Defines risk
as uncertainty that matters, separates probability from impact, maps the methods
covered in the book, and addresses the garbage-in-garbage-out objection head on.

**2. Roll the Dice: Monte Carlo Simulation.** The five steps of a simulation,
how to read percentiles correctly, and how to convert a distribution into a
contingency reserve.

**3. May I Have a (Second) Moment? The Second Moment Method.** A defensible
thirty-second estimate from means, variances, and a correlation matrix. Includes
an explicit decision rule for when it is adequate and when it is not, validated
against Monte Carlo.

**4. Who's Driving? Sensitivity Analysis.** Variance decomposition to find the
tasks that actually drive total uncertainty, tornado charts, and what changes
when tasks are correlated.

**5. Keeping Score: Earned Value Management.** Planned value, earned value, and
actual cost; schedule and cost variances and indices; forecasting estimate at
completion; performance trend charts.

**6. I Had a Feeling: Bayesian Risk Inference.** Bayes' theorem in plain
language, then a full prior-to-posterior workflow updating both a risk
probability and its cost distribution when evidence arrives.

**7. S Is for Success: Sigmoidal Learning Curves.** Fitting logistic, Gompertz,
and Pearl models to early progress data to forecast completion — including why
two of the three are the same model in disguise.

**8. It's a Small World After All: Probabilistic Networks.** Bayesian networks as
a model of how risks flow through resources into task costs; forward simulation,
incorporating evidence, and modifying network structure.

**9. Everything Is Connected: Design Structure Matrices.** A simpler structural
question — which tasks are coupled because they share crews, equipment, or
materials — answered by deriving parent and grandparent DSMs from the network
built in Chapter 8, and used to prioritize mitigation.

**10. The Portfolio Problem: When Risks Are Shared.** Scaling to three projects
with a common upstream root cause, and the distinction that matters most for
enterprise risk: seeing a risk occur versus intervening to prevent it.
Observational versus interventional distributions, and risk importance ranking.

**11. Write Once, Trust Always: Reproducible Risk Analysis with Quarto.** The
reproducibility gap in project controls and how to close it: literate risk
reports, reproducible versus merely repeatable analysis, and parameterized
reports that re-run across projects and scenarios.

**12. Your AI Co-Pilot: Agentic Risk Analysis.** Exposing the analytical
functions as tools over the Model Context Protocol; the Agent Skills that tell an
agent when and how to call each one; how a plain-language request becomes a tool
call; and how to supervise the result.

**Appendices.** A: Glossary. B: Mathematical derivations, for readers who want
the variance and Bayesian updating results proved. C: Quick reference — every
function, grouped by method. D: Case study — Riverside Bridge Replacement, all
nine methods applied to one project in sequence. E: Exercise solutions, worked in
full. F: References.

## 11. Length and Schedule

**Current length.** Approximately 31,000 words of source across the twelve
chapters and six appendices, plus executable code and generated figures.
Estimated at **150–200 printed pages** once code output, figures, and front and
back matter are typeset.

**Status.** A complete draft of all chapters and appendices exists and is public.

**Schedule.** Because the manuscript is drafted rather than proposed, the
remaining work is editorial rather than generative. A realistic schedule from
contract signature:

| Milestone | Timing |
|---|---|
| Full draft delivered for technical review | On signature |
| Revisions from technical review | +8 weeks |
| Copyedit and author review | +6 weeks |
| Final manuscript | +4 weeks |

Roughly four to five months to final manuscript, subject to reviewer turnaround.
The author is open to expanding chapters or adding material at the editor's
direction; the estimate above assumes the current scope.

## 12. Technical Reviewers

> *To be completed by the author: two to four proposed reviewers with
> project-controls, applied-statistics, or R backgrounds, and their
> affiliations.*

## 13. Manuscript Status and Open Items

**Status.** Complete draft, publicly readable at
https://paulgovan.github.io/PRA/book/, and built reproducibly from the same
repository as the `PRA` package.

**Licensing — for discussion.** The `PRA` package is MIT licensed. The current
book text is published under CC BY 4.0 and is freely readable online. This is
raised here deliberately rather than left to be discovered: the existing free
edition and its license terms are a point to settle with the publisher early. The
author is open to discussing how the published edition and the online draft
should relate.
