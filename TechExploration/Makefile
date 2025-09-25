OS := $(shell uname)

# 配置字体和命令根据不同操作系统
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

# 章节文件列表
CHAPTERS := $(sort $(wildcard chapters/*.md))

OUTPUT_BASENAME = Tech-Exploration
PDF_OUTPUT = $(OUTPUT_BASENAME).pdf
DOCX_OUTPUT = $(OUTPUT_BASENAME).docx
HTML_OUTPUT = $(OUTPUT_BASENAME).html

.PHONY: all pdf docx html clean

all: pdf docx html

pdf: $(PDF_OUTPUT)

docx: $(DOCX_OUTPUT)

html: $(HTML_OUTPUT)

# 目标：生成 PDF 电子书
$(PDF_OUTPUT): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $@ --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)" \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in \
		--variable fontsize=12pt

# 目标：生成 DOCX 电子书
$(DOCX_OUTPUT): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $@ \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

# 目标：生成 HTML 电子书
$(HTML_OUTPUT): $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o $@ --standalone \
		--metadata title="Tech Exploration"

# 清理中间文件
clean:
	$(RM_CMD) $(PDF_OUTPUT) $(DOCX_OUTPUT) $(HTML_OUTPUT)
