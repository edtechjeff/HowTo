# This will take 2 CSV's and compare them and add a column and Value of BothList if they appear in both list. 

$fullList = Import-Csv "C:\temp\FullDeviceList.csv"
$partialList = Import-Csv "C:\temp\HPSerial.csv"

# Assuming the column is named "SerialNumber"
$partialSerials = $partialList.SerialNumber

$fullList | ForEach-Object {
    if ($partialSerials -contains $_.SerialNumber) {
        $_ | Add-Member -NotePropertyName 'Highlight' -NotePropertyValue 'BothList'
    } else {
        $_ | Add-Member -NotePropertyName 'Highlight' -NotePropertyValue ''
    }
}

$fullList | Export-Csv "C:\temp\FullList_Highlighted.csv" -NoTypeInformation