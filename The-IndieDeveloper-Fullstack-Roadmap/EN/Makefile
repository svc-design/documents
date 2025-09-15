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

CHAPTERS = chapters/01-foundations-tech-stack-overview.md \
	   chapters/02-backend-development-deep-dive.md \
	   chapters/03-frontend-fundamentals.md \
	   chapters/04-frontend-framework-advanced-fullstack-expansion.md \
	   chapters/05-backend-architecture-optimization-engineering-practices.md \
	   chapters/06-project-deployment-comprehensive-advancement.md

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
