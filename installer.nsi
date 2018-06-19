# We want to be pretty
!include MUI2.nsh

!define MUI_ICON "installation/logo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "sidebar.bmp"
!define MUI_UNICON "installation/logo.ico"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "sidebar.bmp"

!define PRODUCT_NAME "CJDNS for Windows"
!define PRODUCT_VERSION "0.10-proto20.2"
!define PRODUCT_PUBLISHER "Santa Cruz Meshnet Project"

# NSIS Dependencies
# To build the installer:
# (the required 2 plugins are now also embbed in this code repository in
# directory dependencies/NSIS_plugins/)
# <http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin>
# AND the ShellLink plug-in from
# <http://nsis.sourceforge.net/ShellLink_plug-in>
# You may have to second-guess the default DLL install paths
# for ANSI and Unicode DLLS on NSIS 3

# What is the installer called?
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "cjdns-installer-${PRODUCT_VERSION}.exe"
ShowInstDetails show

# Where do we want to install to?
InstallDir "$PROGRAMFILES\cjdns"

# Get proper permissions for uninstalling in Windows 7
RequestExecutionLevel admin

# Set up page order
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Set up language
!insertmacro MUI_LANGUAGE "English"

Section
	# Copy invisible.vbs to install dir
	SetOutPath "$INSTDIR"
	File "installation\invisible.vbs"
SectionEnd

Section
	# Delete old files
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Apply DNS hack.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Revert DNS hack.lnk"

	Delete "$INSTDIR\dns_hack.cmd"
	Delete "$INSTDIR\dns_unhack.cmd"
SectionEnd

Section "Install TUN/TAP Driver"
	# Install the tap driver
	SetOutPath "$INSTDIR\dependencies"
	File "dependencies\tap-windows-9.21.1.exe"
	IfSilent +2
	ExecWait "$INSTDIR\dependencies\tap-windows-9.21.1.exe"
	IfSilent 0 +2
	ExecWait "$INSTDIR\dependencies\tap-windows-9.21.1.exe /S"
	Delete "$INSTDIR\dependencies\tap-windows-9.21.1.exe"
	# TODO: Doesn't seem to work
	RMDir /r "$INSTDIR\dependencies"
SectionEnd

Section "Install cjdns"
	# Things the installer does

	# Stop the service if it exists
	SimpleSC::StopService "cjdns" 1 30

	# Install shell stuff for everyone
	SetShellVarContext all

	SetOutPath $INSTDIR

	# Write all the files
	File "installation\cjdroute.exe"
	File "installation\makekeys.exe"
	File "installation\mkpasswd.exe"
	File "installation\privatetopublic.exe"
	File "installation\publictoip6.exe"
	File "installation\randombytes.exe"
	File "installation\sybilsim.exe"
	File "installation\genconf.cmd"
	File "installation\logo.ico"

	# create the uninstaller
	WriteUninstaller "$INSTDIR\uninstall.exe"

	# Delete the old uninstall shortcut if we're upgrading
	Delete "$SMPROGRAMS\Uninstall cjdns.lnk"

	# Add a shortcut to the uninstaller
	CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall cjdns.lnk" "$INSTDIR\uninstall.exe"

	# Add a tool and shortcut to edit the config
	File "installation\edit_config.cmd"
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Configure cjdns.lnk" "cmd.exe" "/k $\"cd $\"$\"$\"$INSTDIR$\"$\"$\" & edit_config.cmd <NUL & exit$\"" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Configure cjdns.lnk"
	Pop $0

	# And one to test it
	File "installation\test_config.cmd"
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Test cjdns configuration.lnk" "cmd.exe" "/k $\"cd $\"$\"$\"$INSTDIR$\"$\"$\" & test_config.cmd <NUL & exit$\"" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Test cjdns configuration.lnk"
	Pop $0

	# And one to test connectivity
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Test cjdns connectivity.lnk" "ping" "/t fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5" "$INSTDIR\logo.ico"

	# Add tools to patch and unpatch DNS
	# Basically spray static IPv6 addresses on all the interfaces so Firefox can browse by domain name.
	File "installation\dns_patch.cmd"
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Apply DNS patch.lnk" "cmd.exe" "/k $\"cd $\"$\"$\"$INSTDIR$\"$\"$\" & dns_patch.cmd <NUL & exit$\"" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Apply DNS patch.lnk"
	Pop $0

	File "installation\dns_unpatch.cmd"
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Revert DNS patch.lnk" "cmd.exe" "/k $\"cd $\"$\"$\"$INSTDIR$\"$\"$\" & dns_unpatch.cmd <NUL & exit$\"" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Revert DNS patch.lnk"
	Pop $0

	# Register with add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "DisplayName" "${PRODUCT_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "Publisher" "${PRODUCT_PUBLISHER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
SectionEnd

Section "Add public peers when generating config"
	# Be in the right directory
	SetOutPath "$INSTDIR"

	# Add these files
	File "installation\public_peers.txt"
	File "installation\addPublicPeers.vbs"
SectionEnd

Section "Generate cjdns configuration if needed"
	# Be in the right directory
	SetOutPath "$INSTDIR"
	# Make cjdns config file if it doesn't exist
	ExecWait "C:\Windows\System32\wscript.exe invisible.vbs genconf.cmd"
SectionEnd

Section "Install cjdns service"
	# Stop the service if it exists.
	SimpleSC::StopService "cjdns" 1 30

	# Copy the service files
	File "installation\CjdnsService.exe"
	File "installation\restart.cmd"
	File "installation\stop.cmd"
	File "installation\start.cmd"

	# Add a shortcut to restart cjdns. It has to be told to run as admin since the batch script can't do it.
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Restart cjdns.lnk" "$INSTDIR\restart.cmd" "" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Restart cjdns.lnk"
	Pop $0

	# Similarly add stop and start shortcuts
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Stop cjdns.lnk" "$INSTDIR\stop.cmd" "" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Stop cjdns.lnk"
	Pop $0
	CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Start cjdns.lnk" "$INSTDIR\start.cmd" "" "$INSTDIR\logo.ico"
	ShellLink::SetRunAsAdministrator "$SMPROGRAMS\${PRODUCT_NAME}\Start cjdns.lnk"
	Pop $0

	# Install a normal service that the user manually starts
	SimpleSC::InstallService "cjdns" "cjdns Mesh Network Router" "16" "3" "$INSTDIR\CjdnsService.exe" "" "" ""
SectionEnd

Section "Apply DNS patch"
	# Be in the right directory
	SetOutPath "$INSTDIR"
	# Apply the DNS patch to all the interfaces
	ExecWait "C:\Windows\System32\wscript.exe invisible.vbs dns_patch.cmd"
	# Now we have a legit-looking on at least one interface
	# Sleep so that we don't immediately open a browser tab while the network was just changed and confuse e.g. Chrome.
	Sleep 10000
SectionEnd

Section "Start cjdns automatically"
	# Set cjdns to start at boot, instead of manually
	SimpleSC::SetServiceStartType "cjdns" "2"

	# And start it now
	SimpleSC::StartService "cjdns" "" 30
SectionEnd

Section "Restart cjdns on crash"
	# If it dies, restart it after 10 seconds
	SimpleSC::SetServiceFailure "cjdns" "0" "" "" "1" "10000" "0" "0" "0" "0"\
	# Restart if it stops properly with nonzero return code
	SimpleSC::SetServiceFailureFlag "cjdns" "1"
SectionEnd

Section "Display instructions"
	# Send the user to our web page where we talk about how to actually use cjdns
	ExecShell "open" "https://github.com/interfect/cjdns-installer/blob/master/Users%20Guide.md"
SectionEnd

Section "un.Uninstall cjdns"
	# Things the uninstaller does

	# Uninstall shell stuff for everyone
	SetShellVarContext all

	# Stop the service
	SimpleSC::StopService "cjdns" 1 30

	# Remove the service
	SimpleSC::RemoveService "cjdns"

	# Undo the DNS patch, whether applied or not
	ExecWait "$INSTDIR\dns_unpatch.bat"

	# Delete the uninstaller
	Delete "$INSTDIR\uninstall.exe"

	# Delete the uninstall shortcut
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall cjdns.lnk"

	# Delete the other shortcuts
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Restart cjdns.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Stop cjdns.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Start cjdns.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Configure cjdns.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Test cjdns configuration.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Test cjdns connectivity.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Apply DNS patch.lnk"
	Delete "$SMPROGRAMS\${PRODUCT_NAME}\Revert DNS patch.lnk"

	# Delete the start menu folder
	RMDir "$SMPROGRAMS\${PRODUCT_NAME}"

	# Delete all the files (including optional ones)
	Delete "$INSTDIR\cjdroute.exe"
	Delete "$INSTDIR\makekeys.exe"
	Delete "$INSTDIR\mkpasswd.exe"
	Delete "$INSTDIR\privatetopublic.exe"
	Delete "$INSTDIR\publictoip6.exe"
	Delete "$INSTDIR\randombytes.exe"
	Delete "$INSTDIR\sybilsim.exe"
	Delete "$INSTDIR\genconf.cmd"
	Delete "$INSTDIR\CjdnsService.exe"
	Delete "$INSTDIR\restart.cmd"
	Delete "$INSTDIR\stop.cmd"
	Delete "$INSTDIR\start.cmd"
	Delete "$INSTDIR\test_config.cmd"
	Delete "$INSTDIR\edit_config.cmd"
	Delete "$INSTDIR\dns_patch.cmd"
	Delete "$INSTDIR\dns_unpatch.cmd"
	Delete "$INSTDIR\public_peers.txt"
	Delete "$INSTDIR\addPublicPeers.vbs"
	Delete "$INSTDIR\invisible.vbs"
	Delete "$INSTDIR\logo.ico"

	# Remove the dependencies directory
	RMDir /r "$INSTDIR\dependencies"

	# Delete the install directory, if empty
	RMDir "$INSTDIR"

	# Unregister with add/remove programs
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns"
SectionEnd

Section "un.Remove cjdns configuration"
	# Delete the config if it exists
	Delete "$INSTDIR\cjdroute.conf"

	# Delete the install directory, if empty
	RMDir "$INSTDIR"
SectionEnd

Section /o "un.Remove OpenVPN Tap Driver"
	# Removes the tap driver by calling it's uninstaller
	IfSilent +2
	ExecWait "C:\Program Files\TAP-Windows\Uninstall.exe"
	IfSilent 0 +2
	ExecWait "C:\Program Files\TAP-Windows\Uninstall.exe /S"
SectionEnd
