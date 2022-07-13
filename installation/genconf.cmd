if exist cjdroute.conf (
	rem Not clobbering config
) else (
	cjdroute.exe --genconf > cjdroute.conf
	if exist fixBrokenConfig.vbs (
		rem Fix the problem with the generated config file
		cscript fixBrokenConfig.vbs
	)
	if exist addPublicPeers.vbs (
		rem Add public peers to config file
		cscript addPublicPeers.vbs
	)
)
