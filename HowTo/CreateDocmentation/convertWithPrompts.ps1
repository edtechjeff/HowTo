Add-Type -AssemblyName System.Windows.Forms

function Select-Folder {
    param(
        [string]$Title = "Select a folder"
    )

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Title
    $dialog.ShowNewFolderButton = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }

    throw "Folder selection cancelled."
}


# ---------------- CONFIG ----------------
$InputRoot   = Select-Folder "Select the folder containing Markdown files"
$OutputRoot  = Select-Folder "Select the folder where PDFs should be written"
$ToolingRoot = Select-Folder "Select the tooling folder (defaults.yaml, pandoc-header.tex)"

$DefaultsYaml = Join-Path $ToolingRoot "defaults.yaml"
$PandocHeader = Join-Path $ToolingRoot "pandoc-header.tex"

$today = Get-Date -Format "yyyy-MM-dd"


# ------------- SAFETY CHECKS -------------
if (-not (Test-Path -LiteralPath $InputRoot))    { throw "InputRoot not found: $InputRoot" }
if (-not (Test-Path -LiteralPath $DefaultsYaml)) { throw "defaults.yaml not found: $DefaultsYaml" }
if (-not (Test-Path -LiteralPath $PandocHeader)) { throw "Pandoc header not found: $PandocHeader" }

# Ensure output root exists
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

Write-Host "Using defaults.yaml : $DefaultsYaml"
Write-Host "Using header.tex    : $PandocHeader"
Write-Host "InputRoot           : $InputRoot"
Write-Host "OutputRoot          : $OutputRoot"
Write-Host ""

# ------------- FIND FILES -------------
$mdFiles = Get-ChildItem -LiteralPath $InputRoot -Recurse -Filter *.md -File
Write-Host "Found $($mdFiles.Count) markdown file(s)."
Write-Host ""

if ($mdFiles.Count -eq 0) {
    Write-Warning "No .md files found under InputRoot. Nothing to do."
    return
}

# ------------- BUILD -------------
foreach ($f in $mdFiles) {

    $inFile = $f.FullName

    # Keep folder structure under OutputRoot
    $relative = $inFile.Substring($InputRoot.Length).TrimStart('\','/')
    $outFile  = Join-Path $OutputRoot ([IO.Path]::ChangeExtension($relative, ".pdf"))

    New-Item -ItemType Directory -Path (Split-Path $outFile -Parent) -Force | Out-Null

    # This is the key for ../Assets/... to work:
    $mdDir = Split-Path -Parent $inFile

    # Resource path search order:
    # - md folder (so relative links work)
    # - md parent (so ../Assets works)
    # - tooling (if you reference anything there)
    $resourcePath = "$mdDir;$mdDir\..;$ToolingRoot"

    Write-Host "BUILD: $inFile"
    Write-Host "OUT  : $outFile"
    Write-Host "RES  : $resourcePath"

    # Use call operator & to ensure execution
    & pandoc `
        $inFile `
        -d $DefaultsYaml `
        --resource-path "$resourcePath" `
        --metadata date="$today" `
        -o $outFile

    $code = $LASTEXITCODE
    Write-Host "Pandoc exit code: $code"
    Write-Host ""

    if ($code -ne 0) {
        Write-Warning "Pandoc failed for: $inFile"
        continue
    }

    if (-not (Test-Path -LiteralPath $outFile)) {
        Write-Warning "Pandoc reported success but PDF not found: $outFile"
    }
}

Write-Host "Done. PDFs are in: $OutputRoot"

# ------------- CLEANUP --------------
# Remove media-* folders created by pandoc
Get-ChildItem $ToolingRoot -Directory -Filter "media-*" |
  Remove-Item -Recurse -Force