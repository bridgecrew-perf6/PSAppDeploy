. "$($PSScriptRoot)\Toolkit\functions.ps1"
    # Do not modify code above this line


	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Microsoft'
	[string]$appName = 'Teams'
	[string]$appVersion = ''
	[string]$appScriptDate = '2020-12-10'
	[string]$appScriptAuthor = 'Alexander L. Larsson'
	##*===============================================



If((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -lt 378389) {
BalloonTip -Type 'none' -Title 'Software installing' -Text 'An old version of .Net Framework was found, installing new version of .Net Framework'
InstallEXE -File 'dotNetFx45_Full_setup.exe' -Arguments '/q /norestart' -Wait
}
BalloonTip -Type 'none' -Title 'Software installing' -Text 'The installation of Microsoft Teams has started.'
InstallMSI -File 'Teams_windows_x64.msi' -Arguments 'ALLUSERS=1 /qn /norestart' -Wait
BalloonTip -Type 'none' -Title 'Software installed' -Text 'The installation of Microsoft Teams has been completed.'