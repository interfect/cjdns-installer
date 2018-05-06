@echo off
rem Tack static bogus IPv6 addresses onto every interface, so at least Firefox will work out of the box.
rem Rather than actually try and see what interfaces exist/are good/will be up on ethernet vs wifi, we just throw addresses at the first 100.
rem See <http://student.agh.edu.pl/~ksztand/2015/12/dns-fix-for-windows/>.

echo Adding fake IPv6 addresses, please wait...

rem Skip 1 because that's loopback.
FOR /L %%N IN (2,1,100) DO (netsh interface ipv6 add address %%N fd42:562a:6d05::%%N/48) > NUL

echo DNS patch aplied!
