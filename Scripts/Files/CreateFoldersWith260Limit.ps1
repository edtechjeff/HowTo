$basePath = "C:\TestLongPath"
$folderName = "SubFolder"
$maxLength = 260

# Ensure the base path exists
New-Item -ItemType Directory -Path $basePath -Force | Out-Null

$currentPath = $basePath
while ($currentPath.Length + $folderName.Length -lt $maxLength) {
    $currentPath = Join-Path -Path $currentPath -ChildPath $folderName
    New-Item -ItemType Directory -Path $currentPath -Force | Out-Null
}

Write-Output "Longest path created: $currentPath"
