# We want to be pretty
!include MUI2.nsh

!define MUI_ICON "logo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "sidebar.bmp"
!define MUI_UNICON "logo.ico"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "sidebar.bmp"

!define PRODUCT_NAME "CJDNS for Windows"
!define PRODUCT_VERSION "0.4-proto16"
!define PRODUCT_PUBLISHER "Santa Cruz Meshnet Project"

# Make sure you have the Simple Service Plugin from
# <http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin>

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
 
Section "Install TUN/TAP Driver"
	# Install the tap driver
	SetOutPath "$INSTDIR\dependencies"
	File "dependencies\tap-windows-9.9.2_3.exe"
    ExecWait "$INSTDIR\dependencies\tap-windows-9.9.2_3.exe"
	Delete "$INSTDIR\dependencies\tap-windows-9.9.2_3.exe"
	# TODO: Doesn't seem to work
	RMDir "$INSTDIR\dependencies"
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
	File "installation\privatetopublic.exe"
	File "installation\publictoip6.exe"
	File "installation\randombytes.exe"
	File "installation\sybilsim.exe"
	File "installation\genconf.cmd"
 
    # create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
 
    # Add a shortcut to it
    CreateShortCut "$SMPROGRAMS\Uninstall cjdns.lnk" "$INSTDIR\uninstall.exe"
	
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
	ExecWait "genconf.cmd"
SectionEnd

Section "Install cjdns service"
	# Stop the service if it exists.
	SimpleSC::StopService "cjdns" 1 30

	# Copy the service files
	File "installation\CjdnsService.exe"
	File "installation\restart.cmd"

	# Install a normal service that the user manually starts
	SimpleSC::InstallService "cjdns" "cjdns Mesh Network Router" "16" "3" "$INSTDIR\CjdnsService.exe" "" "" ""
	
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
 

Section "un.Uninstall cjdns"
	# Things the uninstaller does
 
	# Uninstall shell stuff for everyone
	SetShellVarContext all
 
	# Stop the service
	SimpleSC::StopService "cjdns" 1 30
	
	# Remove the service
	SimpleSC::RemoveService "cjdns"
 
    # Delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
 
    # Delete the uninstall shortcut
    Delete "$SMPROGRAMS\Uninstall cjdns.lnk"
	
	# Delete all the files
	Delete "$INSTDIR\cjdroute.exe"
	Delete "$INSTDIR\makekeys.exe"
	Delete "$INSTDIR\privatetopublic.exe"
	Delete "$INSTDIR\publictoip6.exe"
	Delete "$INSTDIR\randombytes.exe"
	Delete "$INSTDIR\sybilsim.exe"
	Delete "$INSTDIR\genconf.cmd"
	Delete "$INSTDIR\CjdnsService.exe"
	Delete "$INSTDIR\restart.cmd"
	
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