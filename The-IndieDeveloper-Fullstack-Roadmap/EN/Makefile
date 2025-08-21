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

book.html: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o fullstack-roadmap-en.html \
	--toc --toc-depth=3 \
	--variable mainfont="$(MAIN_FONT)" \
	--variable fontsize=12pt

book.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o fullstack-roadmap-en.pdf --pdf-engine=xelatex \
	--variable mainfont="$(MAIN_FONT)" \
	--variable geometry:margin=1in \
	--variable fontsize=12pt

book.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o fullstack-roadmap-en.docx \
	--variable mainfont="$(MAIN_FONT)" \
	--variable fontsize=12pt

clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx *.html
