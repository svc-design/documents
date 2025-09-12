OS := $(shell uname)

ifeq ($(OS), Linux)
	MAIN_FONT = DejaVu Serif
	CJK_FONT = Noto Sans CJK SC
	PANDOC_CMD = pandoc
	RM_CMD = rm -rvf
else ifeq ($(OS), Darwin)
	MAIN_FONT = Times New Roman
	CJK_FONT = PingFang SC
	PANDOC_CMD = pandoc
	RM_CMD = rm -rvf
else ifeq ($(OS), Windows_NT)
	MAIN_FONT = Times New Roman
	CJK_FONT = Microsoft YaHei
	PANDOC_CMD = pandoc.exe
	RM_CMD = del /Q
endif

CHAPTERS = chapters/00-Index.md \
		   chapters/01-Operations-SRE.md \
		   chapters/02-DevOps.md \
		   chapters/03-Observability.md \
		   chapters/04-AI-Ops-Agent-LLM-Ops.md

all: Interview-QA-Guide.html Interview-QA-Guide.pdf Interview-QA-Guide.docx

Interview-QA-Guide.html: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Interview-QA-Guide.html \
		--toc --toc-depth=3 \
		--variable mainfont="$(MAIN_FONT)" \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable fontsize=12pt

Interview-QA-Guide.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Interview-QA-Guide.pdf --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)" \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in \
		--variable fontsize=12pt

Interview-QA-Guide.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Interview-QA-Guide.docx \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx *.html
