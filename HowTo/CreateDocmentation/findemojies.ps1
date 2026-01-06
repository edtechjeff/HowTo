# ==============================
# CONFIG – EDIT THIS PATH ONLY
# ==============================
$Root = "C:\Path\To\Your\MarkdownRoot"

# Optional: CSV report path (leave "" to skip)
$ReportCsv = ""   # example: "$env:TEMP\MarkdownEmojiReport.csv"

Write-Host "Scanning root: $Root"
if (-not (Test-Path -LiteralPath $Root)) { throw "Root path not found: $Root" }

function Test-IsEmojiGlueCodePoint {
    param([int]$cp)
    # Things that are part of emoji sequences/presentation but are not "emoji pictures" themselves
    if ($cp -eq 0xFE0F) { return $true }   # VS16
    if ($cp -eq 0x200D) { return $true }   # ZWJ
    if ($cp -eq 0x20E3) { return $true }   # keycap combining mark
    if ($cp -ge 0x1F3FB -and $cp -le 0x1F3FF) { return $true } # skin tones
    if ($cp -ge 0x1F1E6 -and $cp -le 0x1F1FF) { return $true } # flag indicators
    return $false
}

function Test-IsEmojiBaseCodePoint {
    param([int]$cp)

    # Core emoji blocks (tight – avoids ✓ → © etc.)
    if ($cp -ge 0x1F300 -and $cp -le 0x1F5FF) { return $true }
    if ($cp -ge 0x1F600 -and $cp -le 0x1F64F) { return $true }
    if ($cp -ge 0x1F680 -and $cp -le 0x1F6FF) { return $true }
    if ($cp -ge 0x1F700 -and $cp -le 0x1F77F) { return $true }
    if ($cp -ge 0x1F780 -and $cp -le 0x1F7FF) { return $true }
    if ($cp -ge 0x1F800 -and $cp -le 0x1F8FF) { return $true }
    if ($cp -ge 0x1F900 -and $cp -le 0x1F9FF) { return $true }
    if ($cp -ge 0x1FA00 -and $cp -le 0x1FAFF) { return $true }

    return $false
}

function Get-CodePointsFromString {
    param([string]$s)

    $i = 0
    while ($i -lt $s.Length) {
        $c = [int][char]$s[$i]

        # High surrogate?
        if ($c -ge 0xD800 -and $c -le 0xDBFF -and ($i + 1) -lt $s.Length) {
            $c2 = [int][char]$s[$i + 1]

            # Low surrogate?
            if ($c2 -ge 0xDC00 -and $c2 -le 0xDFFF) {
                $codePoint = 0x10000 + (($c - 0xD800) * 0x400) + ($c2 - 0xDC00)
                $i += 2
                $codePoint
                continue
            }
        }

        # Normal BMP char
        $i += 1
        $c
    }
}

function CpToString {
    param([int]$cp)
    # Safe conversion in Windows PowerShell 5.1
    return [char]::ConvertFromUtf32([int]$cp)
}

$results = @()
$errors  = @()

$mdFiles = Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md -ErrorAction Stop
Write-Host "Markdown files found: $($mdFiles.Count)"
Write-Host ""

$idx = 0
foreach ($file in $mdFiles) {
    $idx++
    if ($idx % 50 -eq 0) { Write-Host "Scanned $idx / $($mdFiles.Count) ..." }

    $path = $file.FullName
    try {
        $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

        $emojiCount = 0
        $glueCount  = 0

        $emojiSamples = New-Object System.Collections.Generic.List[string]
        $glueSamples  = New-Object System.Collections.Generic.List[string]

        foreach ($cp in (Get-CodePointsFromString -s $text)) {

            if (Test-IsEmojiBaseCodePoint $cp) {
                $emojiCount++
                if ($emojiSamples.Count -lt 8) { $emojiSamples.Add((CpToString $cp)) }
                continue
            }

            if (Test-IsEmojiGlueCodePoint $cp) {
                $glueCount++
                if ($glueSamples.Count -lt 8) { $glueSamples.Add(("U+{0:X4}" -f $cp)) }
            }
        }

        # Report a file if it has actual emoji OR glue characters
        if ($emojiCount -gt 0 -or $glueCount -gt 0) {
            $results += [pscustomobject]@{
                FileName     = $file.Name
                FullPath     = $path
                EmojiCount   = $emojiCount
                EmojiSamples = ($emojiSamples -join " ")
                GlueCount    = $glueCount
                GlueSamples  = ($glueSamples -join " ")
            }
        }
    }
    catch {
        $errors += "Failed to read: $path :: $($_.Exception.Message)"
    }
}

$results | Sort-Object FullPath | Format-Table -AutoSize

Write-Host ""
Write-Host "Files with emoji or emoji-glue found: $($results.Count)"

if ($ReportCsv -and $results.Count -gt 0) {
    $results | Sort-Object FullPath | Export-Csv -NoTypeInformation -Path $ReportCsv
    Write-Host "CSV written to: $ReportCsv"
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Read errors ($($errors.Count)):" -ForegroundColor Yellow
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}