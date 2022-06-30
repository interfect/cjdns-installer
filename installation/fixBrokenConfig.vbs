Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

source_file = "cjdroute.conf"
temp_file = "cjdroute.tmp"

set in_stream = fso.OpenTextFile(source_file)
' Make a temp file, clobbering any already there
set out_stream = fso.CreateTextFile(temp_file, True)

' x equals zero as zero lines read
x = 0

Do Until in_stream.AtEndOfStream
    ' First line and so on
    x = x + 1
    ' Copy over config file lines
    line = in_stream.ReadLine
    out_stream.WriteLine line
    if x = 117 then
        ' Write an empty line 
	line2 = "" 
        out_stream.WriteLine line2
    end if
Loop

in_stream.Close
out_stream.Close

fso.DeleteFile source_file
fso.MoveFile temp_file, source_file


