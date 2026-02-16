# How to convert Markdown files to PDF Using Command Line Tools
# The purpose of this documentation is to give you a process to take your makedown files and convert them to PDF
# This process will also create a cover page and table of contents

**Advice**
- Standardize on your creation of Markdown files. 
- This process is making some assumptions. 
    - There is an asset file located in the same folder or could be higher level sub folder that has the images. 
    - No EMOJIS are being used (Had a bug and I could not resolve it)
    - Each file a title block is included to make the cover page
```
    ---
    title: Example Title Block
    author: Jeff Downs
    date: January 5, 2026
    ---
```
## Install Pandoc

```powershell
winget install JohnMacFarlane.Pandoc
```
## Install miktex (Used for PDF creation)
```powershell
winget install miktex
``` 

## Find path to PDFLatex
```powershell
Get-ChildItem -Path "C:\Program Files\MiKTeX" -Recurse -Filter pdflatex.exe -ErrorAction SilentlyContinue
Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\MiKTeX" -Recurse -Filter pdflatex.exe -ErrorAction SilentlyContinue
```

## Fix Path (Using the above path found) 
```powershell
setx PATH "$env:PATH;C:\Users\JeffDowns\AppData\Local\Programs\MiKTeX\miktex\bin\x64"
```
**Close Powershell and reopen to take effect**

## Update Miktex Console
Launch the Miktex console via the start menu, do the updates and then restart the console to verify all updates have been done

## Example command to export to HTML
```powershell
pandoc Create-HyperV-Cluster.md -o Create-HyperV-Cluster.html
```

## Example command to export to PDF (Test)
```powershell
pandoc infra.md -o infra.pdf
```

# After you have this setup you will need to have the default.yaml and the pandoc-header.tex file to do the folowing
***I would recommend to create a folder on c:\apps to store them***

## Folder Structure

c:\apps
    c:\apps\tooling

## copy default and pandoc file to the tooling directory

**Note:** You can use my copy of default.yaml file or create your own
**Note:** You can use my copy of pandoc-header.tex file or create your own
**Note:** You will need to have defaults-docx.yaml file located in the tools directory. You an use my copy or create your own

## Create a reference word docuemnt for the process to use to help with formatting
```bash
pandoc -o reference.docx --print-default-data-file reference.docx
```

**Note:** This file can be used. In order for this file defaults-docx.yaml needs to be modified. Uncomment out the line for the reference file so it can be used


## Once you have copied the files to the tooling directory you can now edit the convert.ps1 with the correct paths for the following
```powershell
$InputRoot   = "Path\To\Your\Markdown\Files" # where .md files live
$OutputRoot  = "Path\To\Your\Output\PDFs"  # where PDFs will be saved
$ToolingRoot = "Path\To\Your\Tooling"  # where defaults.yaml and pandoc-header.tex live
```

## Now that you have adjusted the powershell script variables you can now run it. Either run it in ISE or just straight PowerShell
