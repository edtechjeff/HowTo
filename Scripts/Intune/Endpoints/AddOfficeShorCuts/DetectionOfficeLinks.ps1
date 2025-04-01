$shortcuts = @(
    "C:\Users\Public\Desktop\Word.lnk",
    "C:\Users\Public\Desktop\Excel.lnk",
    "C:\Users\Public\Desktop\PowerPoint.lnk"
    "C:\Users\Public\Desktop\Publisher.lnk"
)

$missing = $shortcuts | Where-Object { -Not (Test-Path $_) }

if ($missing) {
    Write-Host "Missing shortcuts: $($missing -join ', ')"
    exit 1
} else {
    Write-Host "All shortcuts exist."
    exit 0
}
