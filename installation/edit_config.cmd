@echo off
echo Editing cjdns configuration...
 
if exist cjdroute.conf (
	rem Do nothing
) else (
	genconf.cmd
)

start /wait notepad.exe cjdroute.conf

echo Config changes will be tested.
echo If no errors are displayed, just close the cjdns window.
echo
echo If errors are displayed, or cjdns stops unexpectedly and a command prompt appears, edit your config file again.

test_config.cmd <NUL

exit