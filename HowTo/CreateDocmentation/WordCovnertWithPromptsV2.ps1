# Requires -Version 5.1
# Converts all Markdown files under a selected input folder to Word (.docx) using pandoc,
# preserving folder structure, and copies supporting files (XML/JSON/PS1/etc.) alongside
# the generated docs in the output tree.

Add-Type -AssemblyName System.Windows.Forms

function Select-Folder {
    param([string]$Title = "Select a folder")

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Title
    $dialog.ShowNewFolderButton = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }

    throw "Folder selection cancelled."
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory)] [string]$BasePath,
        [Parameter(Mandatory)] [string]$FullPath
    )

    # Normalize and ensure BasePath ends with a slash for correct Uri behavior
    $base = (Resolve-Path -LiteralPath $BasePath).Path.TrimEnd('\') + '\'
    $full = (Resolve-Path -LiteralPath $FullPath).Path

    $baseUri = [Uri]::new($base)
    $fullUri = [Uri]::new($full)

    $rel = $baseUri.MakeRelativeUri($fullUri).ToString()

    # Uri returns forward slashes
    return $rel -replace '/', '\'
}

# ---------------- CONFIG ----------------
$InputRoot   = Select-Folder "Select the folder containing Markdown files"
$OutputRoot  = Select-Folder "Select the folder where PDFs should be written"
$ToolingRoot = Select-Folder "Select the tooling folder (defaults.yaml, pandoc-header.tex)"

$DefaultsDocxYaml = Join-Path $ToolingRoot "defaults-docx.yaml"
$today = Get-Date -Format "yyyy-MM-dd"

# Optional build log
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
$BuildLog = Join-Path $OutputRoot ("pandoc-build-{0}.log" -f $today)
"==== Pandoc build log - $([DateTime]::Now) ====" | Out-File -FilePath $BuildLog -Encoding UTF8

# ------------- SAFETY CHECKS -------------
$InputRoot = (Resolve-Path -LiteralPath $InputRoot).Path.TrimEnd('\')

if (-not (Test-Path -LiteralPath $DefaultsDocxYaml)) {
    throw "defaults-docx.yaml not found: $DefaultsDocxYaml"
}

# Check pandoc exists
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    throw "pandoc not found in PATH. Install pandoc or add it to PATH."
}

Write-Host "Using defaults-docx.yaml : $DefaultsDocxYaml"
Write-Host "InputRoot               : $InputRoot"
Write-Host "OutputRoot              : $OutputRoot"
Write-Host "ToolingRoot             : $ToolingRoot"
Write-Host "Build log               : $BuildLog"
Write-Host ""

# ------------- COPY SUPPORTING FILES -------------
# Only copy "sidecar" / support types (no exe/iso)
$includeExt = @(
    '.xml', '.json',
    '.ps1', '.psm1', '.psd1',
    '.cmd', '.bat',
    '.reg',
    '.txt', '.csv',
    '.yml', '.yaml',
    '.inf'
)

$supportFiles = Get-ChildItem -LiteralPath $InputRoot -Recurse -File |
    Where-Object { $includeExt -contains $_.Extension.ToLowerInvariant() }

Write-Host "Found $($supportFiles.Count) support file(s) to copy."
Write-Host ""

foreach ($sf in $supportFiles) {
    try {
        $relative = Get-RelativePath -BasePath $InputRoot -FullPath $sf.FullName
        $dest = Join-Path $OutputRoot $relative

        New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
        Copy-Item -LiteralPath $sf.FullName -Destination $dest -Force
    }
    catch {
        Write-Warning "Failed to copy support file: $($sf.FullName)  Error: $($_.Exception.Message)"
        ("COPY FAIL: {0}`r`n{1}`r`n" -f $sf.FullName, $_.Exception.Message) |
            Out-File -FilePath $BuildLog -Append -Encoding UTF8
    }
}

Write-Host ""

# ------------- FIND MARKDOWN FILES -------------
$mdFiles = Get-ChildItem -LiteralPath $InputRoot -Recurse -File |
    Where-Object { $_.Extension -in '.md', '.markdown' }

Write-Host "Found $($mdFiles.Count) markdown file(s)."
Write-Host ""

if ($mdFiles.Count -eq 0) {
    Write-Warning "No markdown files found under InputRoot. Nothing to do."
    return
}

# ------------- BUILD DOCX -------------
foreach ($f in $mdFiles) {
    $inFile = $f.FullName

    # Preserve folder structure under OutputRoot
    $relative = Get-RelativePath -BasePath $InputRoot -FullPath $inFile
    $outFile  = Join-Path $OutputRoot ([IO.Path]::ChangeExtension($relative, ".docx"))

    New-Item -ItemType Directory -Path (Split-Path $outFile -Parent) -Force | Out-Null

    $mdDir = Split-Path -Parent $inFile

    # Resource path search order:
    # - md folder (so relative links work)
    # - md parent (so ../Assets works)
    # - InputRoot (so shared repo-level assets/includes work)
    # - tooling (if you reference anything there)
    $resourcePath = @(
        $mdDir
        (Join-Path $mdDir "..")
        $InputRoot
        $ToolingRoot
    ) -join ';'

    Write-Host "BUILD: $inFile"
    Write-Host "OUT  : $outFile"
    Write-Host "RES  : $resourcePath"

    # Capture pandoc output (stderr+stdout) for troubleshooting
    $pandocOutput = & pandoc `
        $inFile `
        -d $DefaultsDocxYaml `
        --resource-path "$resourcePath" `
        --metadata date="$today" `
        -o $outFile 2>&1

    $code = $LASTEXITCODE

    if ($pandocOutput) {
        ("`r`n--- {0} ---`r`n{1}`r`nExitCode: {2}`r`n" -f $inFile, ($pandocOutput -join "`r`n"), $code) |
            Out-File -FilePath $BuildLog -Append -Encoding UTF8
    }
    else {
        ("`r`n--- {0} ---`r`n(no output)`r`nExitCode: {1}`r`n" -f $inFile, $code) |
            Out-File -FilePath $BuildLog -Append -Encoding UTF8
    }

    Write-Host "Pandoc exit code: $code"
    Write-Host ""

    if ($code -ne 0) {
        Write-Warning "Pandoc failed for: $inFile (see log: $BuildLog)"
        continue
    }

    if (-not (Test-Path -LiteralPath $outFile)) {
        Write-Warning "Pandoc reported success but DOCX not found: $outFile"
    }
}

Write-Host "Done. Word docs (and support files) are in: $OutputRoot"
Write-Host "Build log: $BuildLog"

# ------------- CLEANUP --------------
# Remove media-* folders created by pandoc (only if they exist in tooling root)
Get-ChildItem $ToolingRoot -Directory -Filter "media-*" -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
