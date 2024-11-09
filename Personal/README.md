# PDF Generation with Pandoc

This project uses a Makefile to generate PDF files from Markdown files using Pandoc and XeLaTeX. The Makefile is designed to support multiple operating systems: macOS, Linux/Ubuntu, and Windows.

## Prerequisites

Make sure you have the following tools installed:

1. [Pandoc](https://pandoc.org/)
2. [TeX Live](https://www.tug.org/texlive/) (with `xelatex` support)
3. Fonts:
   - For macOS: Ensure that "Times New Roman" and "PingFang SC" are available.
   - For Linux/Ubuntu: Install `DejaVu Serif` and `Noto Sans CJK SC`.
   - For Windows: Ensure that "Times New Roman" and "Microsoft YaHei" are available.

## Installation

### Linux/Ubuntu

Run the following commands to install the necessary dependencies:

    sudo apt-get update
    sudo apt-get install -y pandoc texlive-xetex texlive-fonts-recommended texlive-lang-chinese fonts-dejavu fonts-noto-cjk

### macOS

Use Homebrew to install the dependencies:

    brew install pandoc
    brew install --cask mactex

Make sure "Times New Roman" and "PingFang SC" are available on your system.

### Windows

Download and install Pandoc from Pandoc's official website. Ensure that you have the necessary fonts installed: "Times New Roman" and "Microsoft YaHei".

Usage
Build PDFs
Run the following command to generate all PDF files:

    make all
The Makefile will automatically detect your operating system and use the appropriate fonts.

# Clean Up
To remove the generated PDF files, run:

    make clean

This will delete all PDF files in the directory.

# Supported Files

The following Markdown files are used to generate PDFs:

- CV-EN.md -> CV-EN.pdf
- CV-ZH.md -> CV-ZH.pdf
- Resume-EN.md -> Resume-EN.pdf
- Resume-ZH.md -> Resume-ZH.pdf

# Notes

Ensure that the fonts specified for each OS are installed and accessible to the system.
If you encounter any issues with missing fonts, you can update the Makefile with the paths or names of the fonts available on your system.

# 更新内容摘要
1. **项目概述**：解释了 Makefile 的作用和支持的操作系统。
2. **先决条件**：列出了在不同操作系统上安装 Pandoc 和 TeX Live 的方法，并说明了需要的字体。
3. **用法**：展示如何运行 `make all` 来生成 PDF 文件以及如何清理生成的文件。
4. **支持的文件**：列出了生成 PDF 的源 Markdown 文件。
5. **注意事项**：提醒用户确保系统上已安装所需字体，并根据需要调整 Makefile。

此 `README.md` 文件将帮助用户理解如何在不同平台上使用 Makefile 生成 PDF 文件。
