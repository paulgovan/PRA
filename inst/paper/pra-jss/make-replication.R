## Regenerate the JSS replication materials from pra-jss.Rmd.
##
## Run from this directory:
##   Rscript make-replication.R
##
## Produces:
##   pra-jss-replication.R    plain-ASCII standalone replication script
##   pra-jss-replication.html code + output, via knitr::spin() (JSS-recommended)

knitr::purl("pra-jss.Rmd", output = "repl-body.R", documentation = 1,
            quiet = TRUE)
body <- readLines("repl-body.R", warn = FALSE)

## drop knitr rendering directives (document formatting, not results)
drop <- grep("^knitr::opts_chunk\\$set|^ +fig\\.width|^ +out\\.width", body)
if (length(drop)) body <- body[-drop]

## turn purl chunk markers into readable headers + spin chunk markers
out <- character(0)
for (ln in body) {
  if (grepl("^## ----", ln)) {
    lab <- trimws(sub("-+$", "", sub(",.*$", "", sub("^## ----", "", ln))))
    out <- c(out, paste0("## --- ", lab, " ---"), paste0("#+ ", lab))
  } else {
    out <- c(out, ln)
  }
}

header <- c(
  "## ---------------------------------------------------------------------",
  "## Replication script for:",
  "##   \"Quantitative Project Risk Analysis with PRA\"",
  "##   Paul Govan, Journal of Statistical Software",
  "##",
  "## This standalone script reproduces every numerical result, table and",
  "## figure in the manuscript, in the order they appear.",
  "##",
  "## Requirements:",
  "##   install.packages(c(\"PRA\", \"knitr\"))",
  "## PRA >= 0.5.0 is required. All random results use set.seed(42).",
  "##",
  "## Run with:  Rscript --vanilla pra-jss-replication.R",
  "## Or render code + output:  knitr::spin(\"pra-jss-replication.R\")",
  "## ---------------------------------------------------------------------",
  ""
)
footer <- c("", "## --- session-info ---", "#+ session-info",
            "sessionInfo()", "")

writeLines(c(header, out, footer), "pra-jss-replication.R")
unlink("repl-body.R")

## JSS requires ASCII source; fail loudly if the paper introduces anything else
txt <- readLines("pra-jss-replication.R", warn = FALSE)
bad <- grep("[^ -~\t]", txt)
if (length(bad)) {
  stop("non-ASCII characters on lines: ", paste(bad, collapse = ", "))
}
wide <- which(nchar(txt) > 80)
if (length(wide)) {
  warning("lines over 80 characters: ", paste(wide, collapse = ", "))
}

cat("wrote pra-jss-replication.R (", length(txt), " ASCII lines)\n", sep = "")
