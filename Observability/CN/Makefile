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
           chapters/02-1-metrics-overview.md             \
           chapters/02-2-logs-overview.md                \
           chapters/02-3-traces-overview.md              \
           chapters/02-4-events-overview.md              \
           chapters/02-5-profiles-overview.md            \
           chapters/02-6-network-tuple-analysis.md       \
           chapters/02-7-sla-slo-sli-overview.md         \
           chapters/03-1-bpf-introduction.md             \
           chapters/03-2-bpf-kernel-hooks.md             \
           chapters/03-3-bpf-network-protocols.md        \
           chapters/03-4-bpf-syscall-analysis.md         \
           chapters/03-5-bpf-agent-data-collection.md    \
           chapters/04-1-overall-troubleshooting-process.md \
           chapters/04-2-application-request-indicators-analysis.md \
           chapters/04-3-network-key-metrics-analysis.md \
           chapters/04-4-log-analysis-and-fault-location.md \
           chapters/04-5-typical-fault-scenarios-and-case-studies.md \
           chapters/05-production-monitoring-linux-bare-metal.md \
           chapters/05-vector-unified-collector-architecture.md

all: Observability-Guide.html Observability-Guide.pdf Observability-Guide.docx

# 目标：生成 HTML 电子书
Observability-Guide.html: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Observability-Design-and-Implementation.html \
		--toc --toc-depth=3                  \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable fontsize=12pt

# 目标：生成 PDF 电子书
Observability-Guide.pdf: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Observability-Design-and-Implementation.pdf --pdf-engine=xelatex \
		--variable mainfont="$(MAIN_FONT)"   \
		--variable CJKmainfont="$(CJK_FONT)" \
		--variable geometry:margin=1in       \
		--variable fontsize=12pt

# 目标：生成 DOCX 电子书
Observability-Guide.docx: $(CHAPTERS)
	$(PANDOC_CMD) $(CHAPTERS) -o Observability-Guide.docx \
		--variable mainfont="$(MAIN_FONT)" \
		--variable fontsize=12pt

# 清理中间文件
clean:
	$(RM_CMD) *.aux *.log *.out *.toc *.pdf *.docx *.html
