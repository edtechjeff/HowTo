' Remove Groups from Column C Based on Column D in Excel
' This VBA code removes groups listed in Column D from the group list in Column C
' in an Excel worksheet. It uses a dictionary for fast lookups and processes the data in bulk for efficiency.
' The code assumes that the first row contains headers and starts processing from the second row.

Sub RemoveGroupsFromColumnC()
    Dim ws As Worksheet
    Dim lastRowC As Long, lastRowD As Long
    Dim i As Long, j As Long
    Dim groupsToRemove As Object
    Dim data As Variant, groupList As Variant
    Dim result As String
    
    ' Set the worksheet (change "Sheet1" to match your actual sheet name)
    Set ws = ThisWorkbook.Sheets("Sheet1")
    
    ' Find the last row in Column C (Group List) and Column D (Groups to Remove)
    lastRowC = ws.Cells(ws.Rows.Count, 3).End(xlUp).Row
    lastRowD = ws.Cells(ws.Rows.Count, 4).End(xlUp).Row
    
    ' Create a dictionary for fast lookup of groups to remove
    Set groupsToRemove = CreateObject("Scripting.Dictionary")
    
    ' Store all groups from Column D into the dictionary
    For i = 2 To lastRowD  ' Start from row 2 (assuming row 1 contains headers)
        If ws.Cells(i, 4).Value <> "" Then
            groupsToRemove(ws.Cells(i, 4).Value) = True
        End If
    Next i
    
    ' Read all data from Column C into an array for faster processing
    data = ws.Range("C2:C" & lastRowC).Value
    
    ' Loop through each row in Column C
    For i = 1 To UBound(data, 1)
        If data(i, 1) <> "" Then
            ' Split the list in Column C by semicolon (;)
            groupList = Split(data(i, 1), ";")
            result = ""
            
            ' Loop through each group in the list
            For j = LBound(groupList) To UBound(groupList)
                ' Trim spaces and check if the group exists in Column D
                If Not groupsToRemove.exists(Trim(groupList(j))) Then
                    ' Add the group back to the result if it should NOT be deleted
                    If result = "" Then
                        result = Trim(groupList(j)) ' First group
                    Else
                        result = result & "; " & Trim(groupList(j)) ' Append with semicolon
                    End If
                End If
            Next j
            
            ' Store the cleaned-up list back in the array
            data(i, 1) = result
        End If
    Next i
    
    ' Write the updated data back to Column C in one operation (faster than looping)
    ws.Range("C2:C" & lastRowC).Value = data

    ' Notify the user that the cleanup is complete
    MsgBox "Cleanup Complete!", vbInformation
End Sub
