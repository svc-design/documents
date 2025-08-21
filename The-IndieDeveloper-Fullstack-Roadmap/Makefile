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
CHAPTERS = chapters/01-overview.md                       \
           chapters/02-installation.md                   \
           chapters/03-configuration.md                  \
           chapters/04-sso-integration-introduction.md   \
           chapters/04-1-sso-integration-aws-cloud.md    \
           chapters/04-2-sso-integration-gcp-cloud.md    \
           chapters/04-3-sso-integration-azure-cloud.md  \
           chapters/04-4-sso-integration-ali-cloud.md    \
           chapters/04-10-sso-integration-gitlab.md      \
           chapters/04-11-sso-integration-harbor.md      \
           chapters/04-12-sso-integration-grafana.md     \
           chapters/05-best-practices.md                 \
           chapters/06-troubleshooting.md                \
           chapters/07-conclusion.md

# 目标：生成 HTML 电子书
book.html: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Keycloak-SSO-Design-and-Implementation.html \
		--toc --toc-depth=3                  \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable fontsize=12pt

# 目标：生成 PDF 电子书
book.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Keycloak-SSO-Design-and-Implementation.pdf --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in       \
		--variable fontsize=12pt             \

# 目标：生成 DOCX 电子书
book.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Keycloak-SSO-Design-and-Implementation.docx \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

# 清理中间文件
clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx *.html
