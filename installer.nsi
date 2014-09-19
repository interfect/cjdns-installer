!define PRODUCT_NAME "cjdns installer"
!define PRODUCT_VERSION "0.1"
!define PRODUCT_PUBLISHER "Adam Novak"

# Make sure you have the Simple Service Plugin from
# <http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin>

# What is the installer called?
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "cjsns-installer.exe"
ShowInstDetails show

# Where do we want to install to?
InstallDir "$PROGRAMFILES\cjdns"
 
# Get proper permissions for uninstalling in Windows 7
RequestExecutionLevel admin

# Set the license
LicenseData "LICENSE"

# Set up page order
Page license
Page components
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles
 
Section "Install TUN/TAP Driver"
	# Install the tap driver
	SetOutPath "$INSTDIR\dependencies"
	File "dependencies\tap-windows-9.9.2_3.exe"
    ExecWait "$INSTDIR\dependencies\tap-windows-9.9.2_3.exe"
	Delete "$INSTDIR\dependencies\tap-windows-9.9.2_3.exe"
	RMDir "$INSTDIR\dependencies"
SectionEnd
 
Section "Install cjdns"
	# Things the installer does
    
	# Install shell stuff for everyone
	SetShellVarContext all
	
    SetOutPath $INSTDIR
 
	# Write all the files
	File "installation\cjdroute.exe"
	File "installation\makekeys.exe"
	File "installation\privatetopublic.exe"
	File "installation\publictoip6.exe"
	File "installation\randombytes.exe"
	File "installation\sybilsim.exe"
	File "installation\genconf.cmd"
	File "installation\run.cmd"
 
    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # Add a shortcut to it
    CreateShortCut "$SMPROGRAMS\Uninstall cjdns.lnk" "$INSTDIR\uninstall.exe"
	
	# Register with add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "DisplayName" "${PRODUCT_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\cjdns" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	
SectionEnd

Section "Generate cjdns configuration"
	# Be in the right directory
	SetOutPath "$INSTDIR"
	# Make cjdns config file
	ExecWait "genconf.cmd"
SectionEnd

Section "Install cjdns service"
	# Install a normal service that auto-starts
	SimpleSC::InstallService "cjdns" "cjdns Mesh Network Router" "16" "2" "$INSTDIR\run.cmd" "" "" ""
	
	# And start it now
	SimpleSC::StartService "cjdns" "" 30
	
SectionEnd
 

Section "un.Uninstall cjdns"
	# Things the uninstaller does
 
	# Stop the service
	SimpleSC::StopService "cjdns" 1 30
	
	# Remove the service
	SimpleSC::RemoveService "cjdns"
 
    # Delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
 
    # Delete the uninstall shortcut
    Delete "$SMPROGRAMS\new shortcut.lnk"
	
	# Delete all the files
	Delete "$INSTDIR\cjdroute.exe"
	Delete "$INSTDIR\makekeys.exe"
	Delete "$INSTDIR\privatetopublic.exe"
	Delete "$INSTDIR\publictoip6.exe"
	Delete "$INSTDIR\randombytes.exe"
	Delete "$INSTDIR\sybilsim.exe"
	Delete "$INSTDIR\genconf.cmd"
	Delete "$INSTDIR\run.cmd"
	
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