OS := $(shell uname)

ifeq ($(OS), Linux)
    MAIN_FONT = DejaVu Serif
    PANDOC_CMD = pandoc
    RM_CMD = rm -rvf
else ifeq ($(OS), Darwin)
    MAIN_FONT = Times New Roman
    PANDOC_CMD = pandoc
    RM_CMD = rm -rvf
else ifeq ($(OS), Windows_NT)
    MAIN_FONT = Times New Roman
    PANDOC_CMD = pandoc.exe
    RM_CMD = del /Q
endif

CHAPTERS := $(sort $(wildcard chapters/*.md))

OUTPUT_HTML = fullstack-roadmap-en.html
OUTPUT_PDF = fullstack-roadmap-en.pdf
OUTPUT_DOCX = fullstack-roadmap-en.docx

.PHONY: all clean

all: $(OUTPUT_HTML) $(OUTPUT_PDF) $(OUTPUT_DOCX)

$(OUTPUT_HTML): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $(OUTPUT_HTML) \
	--toc --toc-depth=3 \
	--variable mainfont="$(MAIN_FONT)" \
	--variable fontsize=12pt

$(OUTPUT_PDF): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $(OUTPUT_PDF) --pdf-engine=xelatex \
	--variable mainfont="$(MAIN_FONT)" \
	--variable geometry:margin=1in \
	--variable fontsize=12pt

$(OUTPUT_DOCX): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $(OUTPUT_DOCX) \
	--variable mainfont="$(MAIN_FONT)" \
	--variable fontsize=12pt

clean:
	$(RM_CMD) $(OUTPUT_HTML) $(OUTPUT_PDF) $(OUTPUT_DOCX) *.aux *.log *.out *.toc
