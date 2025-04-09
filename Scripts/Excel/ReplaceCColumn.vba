' VBA code to replace account names in column C based on a mapping table in columns A and B
' The mapping table has old names in column A and new names in column B
' and the data to be replaced is in column C
' This script assumes that the first row contains headers and starts processing from the second row.

Sub ReplaceAccountNames()

    Dim ws As Worksheet
    Dim lastRow As Long, lastRowC As Long
    Dim i As Long, j As Long
    Dim oldName As String, newName As String

    Set ws = ThisWorkbook.Sheets(1) ' Modify if needed for different sheet

    ' Find the last row in columns A and B (account mappings)
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row

    ' Find the last row in column C
    lastRowC = ws.Cells(ws.Rows.Count, "C").End(xlUp).Row

    ' Loop through the mapping table (A & B)
    For i = 2 To lastRow ' Assuming row 1 is headers
        oldName = ws.Cells(i, "A").Value
        newName = ws.Cells(i, "B").Value

        ' Loop through column C
        For j = 2 To lastRowC
            If ws.Cells(j, "C").Value = oldName Then
                ws.Cells(j, "C").Value = newName
            End If
        Next j
    Next i

    MsgBox "Replacement complete.", vbInformation

End Sub
