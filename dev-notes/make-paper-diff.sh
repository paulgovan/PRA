#!/usr/bin/env bash
# Build a latexdiff markup PDF of inst/paper/pra-jss/pra-jss.tex.
# Usage: dev-notes/make-paper-diff.sh [BASELINE_REF]   (default: 2facb3f, i.e. pre-peer-review-fixes)
set -euo pipefail
export PATH="$HOME/Library/TinyTeX/bin/universal-darwin:$PATH"

BASE="${1:-2facb3f}"
REPO="$(git rev-parse --show-toplevel)"
PAPER="$REPO/inst/paper/pra-jss"
WORK="$(mktemp -d)"

cp -R "$PAPER"/jss.cls "$PAPER"/jss.bst "$PAPER"/jsslogo.jpg \
      "$PAPER"/pra-jss.bib "$PAPER"/pra-jss_files "$WORK"/
cp "$PAPER"/pra-jss.tex "$WORK"/new.tex
git -C "$REPO" show "$BASE:inst/paper/pra-jss/pra-jss.tex" > "$WORK"/old.tex

cd "$WORK"
latexdiff --type=UNDERLINE --disable-citation-markup \
  --exclude-textcmd="section,subsection,subsubsection,paragraph,title,Plaintitle,Shorttitle,Abstract,Keywords,Plainkeywords" \
  --config="VERBATIMENV=(?:CodeInput|CodeOutput|verbatim[*]?)" \
  --config="PICTUREENV=(?:picture|DIFnomarkup|figure)[\w\d*@]*" \
  old.tex new.tex > diff.tex 2>/dev/null

latexmk -pdf -interaction=nonstopmode -halt-on-error diff.tex > build.log 2>&1

cp diff.pdf "$REPO/dev-notes/pra-jss-diff.pdf"
echo "Wrote dev-notes/pra-jss-diff.pdf (baseline: $BASE)"
