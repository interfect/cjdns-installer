if exist cjdroute.conf (
	rem Not clobbering config
) else (
	cjdroute.exe --genconf > cjdroute.conf
	if exist addPublicPeers.vbs (
		rem Add public peers to config file
		cscript addPublicPeers.vbs
	)
)
