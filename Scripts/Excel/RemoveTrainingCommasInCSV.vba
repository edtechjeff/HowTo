' VBA script to remove trailing commas from a CSV file
' This script reads a CSV file, removes any trailing commas from each line,
' and writes the cleaned lines to a new CSV file.
' The original file is assumed to be located at "c:\alpha.csv" and the cleaned file will be saved as "c:\omega.csv".
' The script uses file I/O operations to read and write the files line by line.
' It is important to ensure that the file paths are correct and that the files are accessible.
' The script uses a loop to read each line of the input file, checks for trailing commas,
' and removes them before writing the cleaned line to the output file.
' The script also closes the file handles after processing to free up system resources.
' The script is designed to be run in a VBA environment, such as within Excel or Access.
' It is a simple yet effective way to clean up CSV files that may have been improperly formatted.
' The script can be modified to handle different file paths or to include additional error handling as needed.
' It is a good practice to back up the original file before running such scripts to prevent data loss.

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