Sub CommaKiller()


Dim TextLine As String, comma As String
comma = ","

Close #1
Close #2

Open "c:\alpha.csv" For Input As #1
Open "c:\omega.csv" For Output As #2

Do While Not EOF(1)
Line Input #1, TextLine

l = Len(TextLine)
For i = 1 To l
If Right(TextLine, 1) = comma Then
TextLine = Left(TextLine, Len(TextLine) - 1)
End If
Next

Print #2, TextLine
Loop

Close #1
Close #2

End Sub