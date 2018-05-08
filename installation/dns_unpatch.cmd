@echo off
rem "Undo the DNS patch, because it may mess up IPv6 DHCP-type settings."

echo Removing fake IPv6 addresses, please wait...

FOR /L %%N IN (2,1,100) DO (netsh interface ipv6 del address %%N fd42:562a:6d05::%%N) > NUL

echo DNS patch reverted!
