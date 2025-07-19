#!/Users/hyzoon/.local/share/mise/installs/python/3.12.3/bin/python

"""
This script converts Markdown files to PDFs using Pandoc with enhanced metadata handling.
To use:
1. Make it executable:
   $ chmod +x markdown_to_pdf.py
2. Create a symlink for convenience:
   $ ln -s /Users/${USER}/dotfiles/script/markdown_to_pdf.py /usr/local/bin/mdpdf

You can then use the script by typing `mdpdf <input_markdown_file>`.

To ignore further modifications in Git:
$ git update-index --assume-unchanged script/markdown_to_pdf.py
"""

import subprocess
import os
import yaml
import sys


def extract_metadata_from_markdown(input_file):
    with open(input_file, "r", encoding="utf-8") as file:
        content = file.read()
        # Check for YAML metadata block at the beginning of the file
        if content.startswith("---"):
            return yaml.safe_load(content.split("---", 2)[1]) or {}
    return {}


def create_intermediate_markdown(input_file, metadata):
    # Define default metadata
    default_metadata = {
        "title": "My Document Title",
        "subtitle": "",
        "date": "\\today",
        "fontsize": "9",
        "margin": "1in",
        "left header": "left header",
        "author": "2020310083 \\ \\  Hyungjun Shon",
        "affil": "Dept. of System Management Engineering\\\\Dept. of Software\\\\Sungkyunkwan University",
        "abstract": "",
        "korean": False,
        "bibfile": "/Users/hyzoon/dotfiles/script/md2pdf/bib.bib",
        "toc": True,
        "output": "output.pdf",  # Output file name
    }

    # Merge default metadata with user-provided metadata, prioritizing user input
    meta = {**default_metadata, **metadata}

    # Create YAML metadata section for Pandoc
    yaml_metadata = rf"""---
title: {meta['title']}
subtitle: {meta['subtitle']}
date: {meta['date']}
geometry: margin={meta['margin']}
papersize: a4
fontfamily: newtxtext, newtxmath
numbersections: true
autoEqnLabels: true
pandoc-latex-environment:
    tcolorbox: [box]
    info-box: [info]
    warning-box: [warning]
    error-box: [error]    
header-includes: |
    \usepackage[fontsize={meta['fontsize']}pt]{{scrextend}}
    \usepackage{{authblk}}
    \usepackage[utf8]{{inputenc}}
    \usepackage{{caption}}
    \usepackage{{fvextra}}
    \usepackage{{xcolor}}
    \usepackage{{tcolorbox}}
    \renewtcolorbox{{quote}}{{colback=gray!10}}
    \newtcolorbox{{info-box}}{{colback=cyan!5!white,arc=0pt,outer arc=0pt,colframe=cyan!60!black}}
    \newtcolorbox{{warning-box}}{{colback=orange!5!white,arc=0pt,outer arc=0pt,colframe=orange!80!black}}
    \newtcolorbox{{error-box}}{{colback=red!5!white,arc=0pt,outer arc=0pt,colframe=red!75!black}}
    \DefineVerbatimEnvironment{{Highlighting}}{{Verbatim}}{{breaklines,breakanywhere, commandchars=\\\{{\}}, frame=lines, framesep=3mm}}
    \author{{{meta['author']}}}
    \affil{{{meta['affil']}}}
    \usepackage{{fancyhdr}}
    \pagestyle{{fancy}}
    \fancyhead[L]{{{meta['left header']}}}
    \fancyhead[R]{{\thepage}}
    \fancyfoot{{}}
    \usepackage{{float}}
    \usepackage{{url}}
"""

    # Include Kotex for Korean text if needed
    if meta.get("korean"):
        yaml_metadata += "    \\usepackage[hangul, nonfrench, finemath]{kotex}\n"

    # Add an abstract if provided
    if meta["abstract"]:
        abstract_text = meta["abstract"].replace("\n", "\n    ")
        yaml_metadata += "abstract: |\n    {}\n".format(abstract_text)
    yaml_metadata += "---\n" + ("\\tableofcontents\n\n" if meta.get("toc") else "")

    # Load the original content, skipping any metadata already present
    print(f"Input file: {input_file}")
    with open(input_file, "r", encoding="utf-8") as file:
        original_content = file.read().split("---", 2)[-1]

    # Define the path for the intermediate file
    intermediate_file = os.path.join(os.path.dirname(input_file), "intermediate.md")
    with open(intermediate_file, "w", encoding="utf-8") as file:
        file.write(yaml_metadata + original_content)

    # Define the path for the output file and bibfile
    output_file = os.path.join(os.path.dirname(intermediate_file), meta["output"])

    # if bibfile is not default one, change the path
    if meta["bibfile"] != "/Users/hyzoon/dotfiles/script/bib.bib":
        bibfile = os.path.join(os.path.dirname(intermediate_file), meta["bibfile"])
    else:
        bibfile = meta["bibfile"]

    return intermediate_file, bibfile, output_file


def convert_markdown_to_pdf(intermediate_file, output_file, bibfile):

    # Execute the Pandoc command for PDF conversion with citation processing
    subprocess.run(
        [
            "pandoc",
            intermediate_file,
            "-o",
            output_file,
            "--filter",
            "pandoc-latex-environment",
            "--filter",
            "pandoc-crossref",
            "--citeproc",
            f"--bibliography={bibfile}",
        ],
        check=True,
    )


def markdown_to_pdf(input_file):
    # Extract metadata and create an intermediate Markdown file
    metadata = extract_metadata_from_markdown(input_file)
    intermediate_file, bibfile, output_file = create_intermediate_markdown(
        input_file, metadata
    )

    try:
        # Convert the intermediate Markdown to PDF
        convert_markdown_to_pdf(intermediate_file, output_file, bibfile)
    except subprocess.CalledProcessError as e:
        print(f"Error during PDF conversion: {e}")
    finally:
        # Clean up the intermediate file
        os.remove(intermediate_file)
        print("Intermediate Markdown file removed.")
        # open the output file with default pdf viewer
        subprocess.run(["open", output_file])


# Run the Markdown-to-PDF conversion, checking for a command-line argument
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mdpdf <input_markdown_file>")
        sys.exit(1)
    markdown_to_pdf(sys.argv[1])
