Sub ReplaceOldNamesWithNew()
    Dim ws As Worksheet
    Dim lastRowA As Long, lastRowC As Long
    Dim i As Long, j As Long
    Dim replacements As Object
    Dim data As Variant, groupList As Variant
    Dim newName As String, oldName As String
    Dim result As String

    ' Set worksheet (change "Sheet1" to your actual sheet name)
    Set ws = ThisWorkbook.Sheets("Sheet1")

    ' Find last row in Columns A and C
    lastRowA = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    lastRowC = ws.Cells(ws.Rows.Count, 3).End(xlUp).Row

    ' Create a dictionary for fast lookup of old-to-new replacements
    Set replacements = CreateObject("Scripting.Dictionary")

    ' Load replacement values from Columns A and B into dictionary
    For i = 2 To lastRowA ' Assuming row 1 is headers
        newName = Trim(ws.Cells(i, 1).Value) ' New Name
        oldName = Trim(ws.Cells(i, 2).Value) ' Old Name
        If oldName <> "" And newName <> "" Then
            replacements(oldName) = newName
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
                Dim trimmedValue As String
                trimmedValue = Trim(groupList(j))

                ' Replace only if an exact match exists in the dictionary
                If replacements.exists(trimmedValue) Then
                    trimmedValue = replacements(trimmedValue)
                End If

                ' Preserve the order and rebuild the string correctly
                If result = "" Then
                    result = trimmedValue ' First value
                Else
                    result = result & "; " & trimmedValue ' Append with semicolon
                End If
            Next j

            ' Store the corrected value back in the array
            data(i, 1) = result
        End If
    Next i

    ' Write the updated data back to Column C in one operation (faster than looping)
    ws.Range("C2:C" & lastRowC).Value = data

    ' Notify the user that the replacements are complete
    MsgBox "Replacement Complete!", vbInformation
End Sub
