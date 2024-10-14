all:
	eval "$(/usr/libexec/path_helper)"
	pandoc CV-EN.md -o CV-EN.pdf --pdf-engine=xelatex -V CJKmainfont="PingFang SC" -V mainfont="Times New Roman" -V geometry:margin=1in -V fontsize=12pt
	pandoc CV-ZH.md -o CV-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="PingFang SC" -V mainfont="Times New Roman" -V geometry:margin=1in -V fontsize=12pt
	pandoc Resume-EN.md -o Resume-EN.pdf --pdf-engine=xelatex -V CJKmainfont="PingFang SC" -V mainfont="Times New Roman" -V geometry:margin=1in -V fontsize=12pt
	pandoc Resume-ZH.md -o Resume-ZH.pdf --pdf-engine=xelatex -V CJKmainfont="PingFang SC" -V mainfont="Times New Roman" -V geometry:margin=1in -V fontsize=12pt
clean:
	rm -rvf *.pdf
