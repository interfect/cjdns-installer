Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

source_file = "cjdroute.conf"
temp_file = "cjdroute.tmp"

Set in_stream = fso.OpenTextFile(source_file)
' Make a temp file, clobbering any already there
Set out_stream = fso.CreateTextFile(temp_file, True)

' x equals zero as zero lines read
x = 0

Do Until in_stream.AtEndOfStream
    ' Increase the line counting variable
    x = x + 1
	
    ' Read the next line in the config file
	line = in_stream.ReadLine

	' Copy it over if it's not the line that we need to skip
    If Not ((x = 117) And (Right(line, 2) = "],")) Then
		out_stream.WriteLine line
    End If
Loop

in_stream.Close
out_stream.Close

fso.DeleteFile source_file
fso.MoveFile temp_file, source_file


