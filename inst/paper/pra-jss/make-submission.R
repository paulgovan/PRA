## Assemble the complete JSS submission bundle.
##
## Run from this directory:
##   Rscript make-submission.R
##
## Sources live here (tracked in git):
##   pra-jss.Rmd  pra-jss.tex  pra-jss.pdf  pra-jss.bib
##   jss.cls  jss.bst  jsslogo.jpg  pra-jss_files/  comments-to-editor.md
##
## Everything below is regenerated into ../../../jss-submission/ (gitignored,
## Rbuildignored). Nothing in that directory is edited by hand.
##
## Produces in jss-submission/:
##   pra-jss.pdf                 rendered manuscript (copied from here)
##   comments-to-editor.md       cover letter (copied from here)
##   pra-jss-replication.R       plain-ASCII standalone replication script
##   pra-jss-replication.html    code + output, via knitr::spin() (JSS-recommended)
##   pra-jss-latex-sources.zip   .tex/.bib + JSS class files + figures
##   PRA_<version>.tar.gz        package source, via R CMD build

here    <- normalizePath(".")
repo    <- normalizePath(file.path(here, "..", "..", ".."))
bundle  <- file.path(repo, "jss-submission")

for (f in c("pra-jss.Rmd", "pra-jss.tex", "pra-jss.pdf", "pra-jss.bib",
            "jss.cls", "jss.bst", "jsslogo.jpg", "comments-to-editor.md")) {
  if (!file.exists(f)) stop("missing source file: ", f)
}
tex_mtime <- file.info("pra-jss.tex")$mtime
rmd_mtime <- file.info("pra-jss.Rmd")$mtime
if (rmd_mtime > tex_mtime) {
  warning("pra-jss.Rmd is newer than pra-jss.tex/.pdf - re-render the paper ",
          "before assembling the bundle")
}

if (dir.exists(bundle)) unlink(bundle, recursive = TRUE)
dir.create(bundle)

## --- replication script: purl pra-jss.Rmd, add JSS header + sessionInfo() -----

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
  "## PRA >= 0.6.0 is required. All random results use set.seed(42).",
  "##",
  "## Run with:  Rscript --vanilla pra-jss-replication.R",
  "## Or render code + output:  knitr::spin(\"pra-jss-replication.R\")",
  "## ---------------------------------------------------------------------",
  ""
)
footer <- c("", "## --- session-info ---", "#+ session-info",
            "sessionInfo()", "")

repl <- file.path(bundle, "pra-jss-replication.R")
writeLines(c(header, out, footer), repl)
unlink("repl-body.R")

## JSS requires ASCII source; fail loudly if the paper introduces anything else
txt <- readLines(repl, warn = FALSE)
bad <- grep("[^ -~\t]", txt)
if (length(bad)) {
  stop("non-ASCII characters on lines: ", paste(bad, collapse = ", "))
}
wide <- which(nchar(txt) > 80)
if (length(wide)) {
  warning("lines over 80 characters: ", paste(wide, collapse = ", "))
}
cat("wrote pra-jss-replication.R (", length(txt), " ASCII lines)\n", sep = "")

## --- code + output HTML, via knitr::spin() -----------------------------------

old <- setwd(bundle)
knitr::spin("pra-jss-replication.R")          # runs every chunk; a few minutes
unlink(c("pra-jss-replication.md", "figure"), recursive = TRUE)  # images are
                                             # base64-embedded in the .html
setwd(old)
if (!file.exists(file.path(bundle, "pra-jss-replication.html"))) {
  stop("knitr::spin() did not produce pra-jss-replication.html")
}
cat("wrote pra-jss-replication.html\n")

## --- copy the rendered manuscript + cover letter ---------------------------

file.copy("pra-jss.pdf", file.path(bundle, "pra-jss.pdf"), overwrite = TRUE)
file.copy("comments-to-editor.md",
          file.path(bundle, "comments-to-editor.md"), overwrite = TRUE)

## --- LaTeX sources zip ----------------------------------------------------------

tex_files <- c("pra-jss.tex", "pra-jss.bib", "jss.cls", "jss.bst",
               "jsslogo.jpg", "pra-jss_files")
zip_path <- file.path(bundle, "pra-jss-latex-sources.zip")
utils::zip(zip_path, tex_files, flags = "-r9Xq")
cat("wrote ", basename(zip_path), "\n", sep = "")

## --- package source tarball ---------------------------------------------------

ver <- read.dcf(file.path(repo, "DESCRIPTION"), "Version")[1, 1]
old <- setwd(bundle)
status <- system2("R", c("CMD", "build", shQuote(repo)))
setwd(old)
tarball <- file.path(bundle, sprintf("PRA_%s.tar.gz", ver))
if (status != 0 || !file.exists(tarball)) {
  warning("R CMD build did not produce ", basename(tarball),
          " - build the tarball manually")
} else {
  cat("wrote ", basename(tarball), "\n", sep = "")
}

cat("\nbundle assembled in ", bundle, ":\n", sep = "")
print(list.files(bundle))
