# -----------------------------
# Auto-build all Markdown files
# Unified CJK + Latin fonts for PDFs
# -----------------------------

# OS & tools
OS := $(shell uname -s)
ifeq ($(OS),Linux)
    MAIN_FONT := DejaVu Serif
    CJK_FONT  := Noto Sans CJK SC
    PANDOC    := pandoc
    RM_CMD    := rm -rvf
else ifeq ($(OS),Darwin)
    MAIN_FONT := Times New Roman
    CJK_FONT  := PingFang SC
    PANDOC    := pandoc
    RM_CMD    := rm -rvf
else ifeq ($(OS),Windows_NT)
    MAIN_FONT := Times New Roman
    CJK_FONT  := Microsoft YaHei
    PANDOC    := pandoc.exe
    RM_CMD    := del /Q
else
    # Fallback
    MAIN_FONT := Times New Roman
    CJK_FONT  := Noto Sans CJK SC
    PANDOC    := pandoc
    RM_CMD    := rm -rvf
endif

# Discover files
MD_FILES := $(wildcard *.md)
MD_BASES := $(MD_FILES:.md=)

# Outputs
PDFS  := $(MD_BASES:=.pdf)
DOCXS := $(MD_BASES:=.docx)
HTMLS := $(MD_BASES:=.html)

# Pandoc common opts
GEOMETRY := -V geometry:margin=1in
FONTSIZE := -V fontsize=12pt

.PHONY: all pdf docx html clean list help

all: pdf

help:
	@echo "Usage:"
	@echo "  make [all]   - build pdf, docx, html for all *.md"
	@echo "  make pdf     - build PDFs only"
	@echo "  make docx    - build DOCX only"
	@echo "  make html    - build HTML only"
	@echo "  make clean   - remove generated files"
	@echo "  make list    - show detected files"
	@echo ""
	@echo "Detected markdown files: $(MD_FILES)"

list:
	@echo "MD_FILES: $(MD_FILES)"
	@echo "PDFS:     $(PDFS)"
	@echo "DOCXS:    $(DOCXS)"
	@echo "HTMLS:    $(HTMLS)"

# -----------------------------
# Pattern rules
# -----------------------------

# PDF (unified: always set Latin + CJK fonts to avoid missing glyphs)
%.pdf: %.md
	$(PANDOC) $< -o $@ --pdf-engine=xelatex \
	  -V mainfont="$(MAIN_FONT)" \
	  -V CJKmainfont="$(CJK_FONT)" \
	  -V sansfont="$(MAIN_FONT)" \
	  -V monofont="$(MAIN_FONT)" \
	  $(GEOMETRY) $(FONTSIZE)

# DOCX
%.docx: %.md
	$(PANDOC) $< -o $@ --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt

# HTML
%.html: %.md
	$(PANDOC) $< -o $@ --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt

# -----------------------------
# Batch targets
# -----------------------------
pdf: $(PDFS)
docx: $(DOCXS)
html: $(HTMLS)

clean:
	$(RM_CMD) $(PDFS) $(DOCXS) $(HTMLS)
