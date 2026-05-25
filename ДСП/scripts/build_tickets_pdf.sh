#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TICKETS_DIR="$ROOT_DIR/notes/tickets"
BUILD_DIR="$ROOT_DIR/build/pdf"
OUT_DIR="$ROOT_DIR/output/pdf"
INDIVIDUAL=0
KEEP_MD=0
RENDER_CHECK=1

usage() {
  cat <<'USAGE'
Usage: scripts/build_tickets_pdf.sh [options]

Build PDF files from notes/tickets/01.md ... notes/tickets/25.md.

Options:
  --individual       Also build output/pdf/tickets/NN.pdf for each ticket.
  --keep-md          Keep generated intermediate Markdown files in build/pdf.
  --no-render-check  Skip pdftoppm smoke render of the first PDF page.
  -h, --help         Show this help.

Required tools:
  pandoc, xelatex

Recommended install on Arch Linux:
  sudo pacman -S --needed pandoc-cli texlive-bin texlive-basic texlive-latex \
    texlive-latexrecommended texlive-latexextra texlive-xetex \
    texlive-fontsrecommended texlive-langcyrillic noto-fonts poppler

Recommended install on Ubuntu/Debian:
  sudo apt-get update
  sudo apt-get install -y pandoc texlive-xetex texlive-lang-cyrillic \
    texlive-latex-recommended texlive-latex-extra lmodern fonts-noto poppler-utils
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --individual)
      INDIVIDUAL=1
      shift
      ;;
    --keep-md)
      KEEP_MD=1
      shift
      ;;
    --no-render-check)
      RENDER_CHECK=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

print_install_hint() {
  if command -v pacman >/dev/null 2>&1; then
    echo "Install dependencies on Arch Linux with:" >&2
    echo "  sudo pacman -S --needed pandoc-cli texlive-bin texlive-basic texlive-latex texlive-latexrecommended texlive-latexextra texlive-xetex texlive-fontsrecommended texlive-langcyrillic noto-fonts poppler" >&2
  elif command -v apt-get >/dev/null 2>&1; then
    echo "Install dependencies on Ubuntu/Debian with:" >&2
    echo "  sudo apt-get update" >&2
    echo "  sudo apt-get install -y pandoc texlive-xetex texlive-lang-cyrillic texlive-latex-recommended texlive-latex-extra lmodern fonts-noto poppler-utils" >&2
  else
    echo "Install pandoc, xelatex, Latin Modern fonts, Noto fonts, and Poppler for your system." >&2
  fi
}

require_font() {
  local font="$1"
  local matched

  if ! command -v fc-match >/dev/null 2>&1; then
    echo "Missing required command: fc-match" >&2
    print_install_hint
    exit 1
  fi

  matched="$(fc-match -f '%{family}\n' "$font")"
  if [[ "$matched" != *"$font"* ]]; then
    echo "Missing required font: $font" >&2
    echo "Matched fallback font: $matched" >&2
    print_install_hint
    exit 1
  fi
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    print_install_hint
    exit 1
  fi
}

require_cmd pandoc
require_cmd xelatex
require_font "Noto Serif"
require_font "Noto Sans"
require_font "Noto Sans Mono"
require_font "Noto Sans Math"

if ! kpsewhich lmroman10-regular.otf >/dev/null 2>&1; then
  echo "Missing TeX font file: lmroman10-regular.otf" >&2
  echo "On Arch Linux this is provided by texlive-fontsrecommended." >&2
  print_install_hint
  exit 1
fi

if ! kpsewhich babel-russian.tex >/dev/null 2>&1; then
  echo "Missing TeX Russian language support: babel-russian.tex" >&2
  echo "On Arch Linux this is provided by texlive-langcyrillic." >&2
  print_install_hint
  exit 1
fi

if [[ "$RENDER_CHECK" -eq 1 ]] && ! command -v pdftoppm >/dev/null 2>&1; then
  echo "Warning: pdftoppm not found; render smoke check will be skipped." >&2
  RENDER_CHECK=0
fi

mkdir -p "$BUILD_DIR" "$OUT_DIR"

clean_markdown() {
  perl \
    -pe 's/\[\[([^|\]]+)\|([^\]]+)\]\]/$2/g; s/\[\[([^\]]+)\]\]/$1/g; s/\t/    /g'
}

write_pandoc_header() {
  local target="$1"
  cat > "$target" <<'HEADER'
---
title: "Билеты по дискретным случайным процессам"
author: ""
lang: ru-RU
---

HEADER
}

append_ticket() {
  local ticket="$1"
  local target="$2"

  if [[ ! -f "$ticket" ]]; then
    echo "Ticket file not found: $ticket" >&2
    exit 1
  fi

  clean_markdown < "$ticket" >> "$target"
  printf '\n\n\\newpage\n\n' >> "$target"
}

build_pdf() {
  local input_md="$1"
  local output_pdf="$2"
  local toc_flag="${3:-}"
  local base_name
  local tex_file
  local built_pdf

  base_name="$(basename "$output_pdf" .pdf)"
  tex_file="$BUILD_DIR/$base_name.tex"
  built_pdf="$BUILD_DIR/$base_name.pdf"

  local args=(
    "$input_md"
    --standalone
    --to latex
    -o "$tex_file"
    --from markdown+tex_math_dollars+raw_tex
    -V lang=ru-RU
    -V mainfont="Noto Serif"
    -V sansfont="Noto Sans"
    -V monofont="Noto Sans Mono"
    -V mathfont="Noto Sans Math"
    -V geometry:margin=18mm
    -V papersize=a4
    -V documentclass=article
    -V fontsize=11pt
  )

  if [[ "$toc_flag" == "toc" ]]; then
    args+=(--toc --toc-depth=2)
  fi

  pandoc "${args[@]}"
  perl -0pi -e 's/\\usepackage\{lmodern\}\R//g' "$tex_file"

  for _ in 1 2; do
    if ! xelatex -interaction=nonstopmode -halt-on-error -output-directory="$BUILD_DIR" "$tex_file" >/dev/null; then
      echo "XeLaTeX failed while building: $output_pdf" >&2
      echo "Log file: $BUILD_DIR/$base_name.log" >&2
      tail -n 80 "$BUILD_DIR/$base_name.log" >&2 || true
      exit 1
    fi
  done

  mkdir -p "$(dirname "$output_pdf")"
  cp "$built_pdf" "$output_pdf"
}

COMBINED_MD="$BUILD_DIR/all_tickets.md"
COMBINED_PDF="$OUT_DIR/dsp_tickets_all.pdf"

write_pandoc_header "$COMBINED_MD"

for n in $(seq -w 1 25); do
  append_ticket "$TICKETS_DIR/$n.md" "$COMBINED_MD"
done

echo "Building combined PDF: $COMBINED_PDF"
build_pdf "$COMBINED_MD" "$COMBINED_PDF" toc

if [[ "$INDIVIDUAL" -eq 1 ]]; then
  INDIVIDUAL_DIR="$OUT_DIR/tickets"
  mkdir -p "$INDIVIDUAL_DIR"

  for n in $(seq -w 1 25); do
    ticket_md="$BUILD_DIR/ticket_$n.md"
    ticket_pdf="$INDIVIDUAL_DIR/$n.pdf"
    write_pandoc_header "$ticket_md"
    append_ticket "$TICKETS_DIR/$n.md" "$ticket_md"
    echo "Building ticket PDF: $ticket_pdf"
    build_pdf "$ticket_md" "$ticket_pdf"
  done
fi

if [[ "$RENDER_CHECK" -eq 1 ]]; then
  RENDER_DIR="$BUILD_DIR/render_check"
  RENDER_PREFIX="$RENDER_DIR/dsp_tickets_all_page"
  mkdir -p "$RENDER_DIR"
  echo "Rendering first page for smoke check..."
  pdftoppm -f 1 -l 1 -png "$COMBINED_PDF" "$RENDER_PREFIX" >/dev/null
  rendered_file="$(find "$RENDER_DIR" -maxdepth 1 -type f -name 'dsp_tickets_all_page-*.png' | sort | tail -n 1)"
  echo "Rendered: $rendered_file"
fi

if [[ "$KEEP_MD" -eq 0 ]]; then
  find "$BUILD_DIR" -maxdepth 1 -type f -name 'ticket_*.md' -delete
fi

echo "Done: $COMBINED_PDF"
