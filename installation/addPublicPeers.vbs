Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

source_file = "cjdroute.conf"
temp_file = "cjdroute.tmp"
peer_file = "public_peers_ipv4.txt"
peer_6_file = "public_peers_ipv6.txt"

set in_stream = fso.OpenTextFile(source_file)
' Make a temp file, clobbering any already there
set out_stream = fso.CreateTextFile(temp_file, True)

' x equals zero as zero in times we saw the place holder
x = 0

Do Until in_stream.AtEndOfStream
    ' Copy over config file lines
    line = in_stream.ReadLine
    out_stream.WriteLine line
    if InStr(line, "// Ask somebody who is already connected.") <> 0 then
	' Found once, we do ipv4
	x = x + 1
        if x = 1 then
            ' This is the first occurrence (IPv4)
            set peer_stream = fso.OpenTextFile(peer_file)
            
            Do Until peer_stream.AtEndOfStream
                ' Copy over all the public peers
                line2 = peer_stream.ReadLine
                out_stream.WriteLine line2
            Loop
        end if
	' Found second time, we do ipv6
	if x = 2 then
		set peer_stream6 = fso.OpenTextFile(peer_6_file)
		Do Until peer_stream6.AtEndOfStream
			line3 = peer_stream6.ReadLine
			out_stream.WriteLine line3
		Loop
   	end if
    end if
Loop

in_stream.Close
out_stream.Close
peer_stream.Close

fso.DeleteFile source_file
fso.MoveFile temp_file, source_file


