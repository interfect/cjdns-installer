@echo off
echo Testing cjdns configuration...
echo Close the other window, not this one.
if exist cjdroute.conf (
	if exist stop.cmd (
		stop.cmd
	)
	start /wait cmd /k "cjdroute.exe --nobg < cjdroute.conf"
	if exist start.cmd (
		start.cmd
	)
) else (
	echo No cjdroute.conf file found!
)
exit