if exist cjdroute.conf (
	rem Not clobbering config
) else (
	cjdroute.exe --genconf > cjdroute.conf
)
