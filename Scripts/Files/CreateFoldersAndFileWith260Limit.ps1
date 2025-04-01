$basePath = "D:\TestLongPath290"
$folderName = "SubFolder"
$maxLength = 290
$fileName = "testfile.txt"

# Ensure the base path exists
New-Item -ItemType Directory -Path $basePath -Force | Out-Null

$currentPath = $basePath
while ($currentPath.Length + $folderName.Length -lt ($maxLength - 15)) {  # Reserve space for the file name
    $currentPath = Join-Path -Path $currentPath -ChildPath $folderName
    New-Item -ItemType Directory -Path $currentPath -Force | Out-Null
}

# Create a text file in the deepest folder
$filePath = Join-Path -Path $currentPath -ChildPath $fileName
"Test content" | Out-File -FilePath $filePath -Encoding utf8

Write-Output "Longest path created: $currentPath"
Write-Output "File created at: $filePath"
