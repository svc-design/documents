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

all: pdf docx html

pdf:
	$(PANDOC_CMD) CV-EN.md -o CV-EN.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) CV-ZH.md -o CV-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) Resume-EN.md -o Resume-EN.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) Resume-ZH.md -o Resume-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) ActiveBalance-Plan.md -o ActiveBalance-Plan.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt

docx:
	$(PANDOC_CMD) CV-EN.md -o CV-EN.docx --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) CV-ZH.md -o CV-ZH.docx --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) Resume-EN.md -o Resume-EN.docx --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) Resume-ZH.md -o Resume-ZH.docx --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) ActiveBalance-Plan.md -o ActiveBalance-Plan.docx --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt

html:
	$(PANDOC_CMD) CV-EN.md -o CV-EN.html --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) CV-ZH.md -o CV-ZH.html --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) Resume-EN.md -o Resume-EN.html --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) Resume-ZH.md -o Resume-ZH.html --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt
	$(PANDOC_CMD) ActiveBalance-Plan.md -o ActiveBalance-Plan.html --variable mainfont="$(MAIN_FONT)" --variable fontsize=12pt

clean:
	$(RM_CMD) *.pdf *.docx *.html
