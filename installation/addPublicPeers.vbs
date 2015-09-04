Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

source_file = "cjdroute.conf"
temp_file = "cjdroute.tmp"
peer_file = "public_peers.txt"

set in_stream = fso.OpenTextFile(source_file)
' Make a temp file, clobbering any already there
set out_stream = fso.CreateTextFile(temp_file, True)

' We only need to add at the first line, since IPv4 comes before IPv6
need_to_add = True

Do Until in_stream.AtEndOfStream
    ' Copy over config file lines
    line = in_stream.ReadLine
    out_stream.WriteLine line
    
    if InStr(line, "// Ask somebody who is already connected.") <> 0 then
        if need_to_add then
            ' This is the first occurrence (IPv4)
            set peer_stream = fso.OpenTextFile(peer_file)
            
            Do Until peer_stream.AtEndOfStream
                ' Copy over all the public peers
                line2 = peer_stream.ReadLine
                out_stream.WriteLine line2
            Loop
            
            need_to_add = False
        end if
    end if
Loop

in_stream.Close
out_stream.Close
peer_stream.Close

fso.DeleteFile source_file
fso.MoveFile temp_file, source_file


