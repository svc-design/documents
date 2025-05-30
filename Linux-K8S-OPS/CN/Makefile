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
CHAPTERS = chapters/00-Index.md          \
           chapters/01-Linux-RPM-Base.md \
           chapters/02-Linux-Deb-Base.md \
           chapters/03-K8S.md            \
           chapters/04-Etcd.md

all: Linux-K8S-OPS-Guide.html Linux-K8S-OPS-Guide.pdf Linux-K8S-OPS-Guide.docx

# 目标：生成 HTML 电子书
Linux-K8S-OPS-Guide.html: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Linux-K8S-OPS-Guide.html \
		--toc --toc-depth=3                  \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable fontsize=12pt

# 目标：生成 PDF 电子书
Linux-K8S-OPS-Guide.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Linux-K8S-OPS-Guide.pdf --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in       \
		--variable fontsize=12pt

# 目标：生成 DOCX 电子书
Linux-K8S-OPS-Guide.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Linux-K8S-OPS-Guide.docx \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

# 清理中间文件
clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx *.html
