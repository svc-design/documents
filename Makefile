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

all:
	$(PANDOC_CMD) CV-EN.md -o CV-EN.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) CV-ZH.md -o CV-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) Resume-EN.md -o Resume-EN.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt
	$(PANDOC_CMD) Resume-ZH.md -o Resume-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="$(CJK_FONT)" -V mainfont="$(MAIN_FONT)" -V geometry:margin=1in -V fontsize=12pt

clean:
	$(RM_CMD) *.pdf
