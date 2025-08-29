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
CHAPTERS = chapters/01-introduction.md \
           chapters/02-design-goals.md \
           chapters/03-core-design.md \
           chapters/04-identity-management.md \
           chapters/05-cross-cloud-architecture.md \
           chapters/06-security-compliance.md \
           chapters/07-automation-cicd.md \
           chapters/08-cost-management.md \
           chapters/09-disaster-recovery.md \
           chapters/10-open-source-code.md \
           chapters/11-conclusion.md

# 目标：生成 PDF 电子书
book.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Landing-Zone-Design-and-Implementation.pdf --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)" \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in \
		--variable fontsize=12pt

# 目标：生成 DOCX 电子书
book.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Landing-Zone-Design-and-Implementation.docx \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

# 清理中间文件
clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx
