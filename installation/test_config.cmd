@echo off
if exist cjdroute.conf (
	if exist stop.cmd (
		stop.cmd
	)
	cjdroute.exe --nobg < cjdroute.conf
	if exist start.cmd (
		start.cmd
	)
) else (
	echo No cjdroute.conf file found!
)
pause