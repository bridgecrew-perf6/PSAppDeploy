# Do not modify code below this line
$RootPath = Split-Path $PSScriptRoot -Parent
Function CloseProcess {
    Param([string]$Name, [switch]$Silent)
    [bool]$ProcessExist = $False

    $ProcessArray = $Name.Split("|")
    for ($i=0; $i -lt $ProcessArray.length; $i++) {
        $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
        If ($CheckProcess -ne $null) {
            $ProcessExist = $True
        }
    }
    If ($ProcessExist -eq $True)
    {
        If($Silent.IsPresent)
        {
            for ($i=0; $i -lt $ProcessArray.length; $i++) {
                $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
                While ($CheckProcess -ne $null) {
                    Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])" } | Stop-Process -Force
                    $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
                }
            }
        } Else {
        
            Add-Type -AssemblyName System.Windows.Forms


            $Form = New-Object system.Windows.Forms.Form
            $Form.ClientSize = '480,248'
            $Form.text = "$appVendor $appName $appVersion"
            $Form.BackColor = "#ffffff"
            $objIcon = New-Object system.drawing.icon ("$($PSScriptRoot)\iver.ico")
            $Form.Icon = $objIcon
            $Form.ControlBox = $False
            $Form.TopMost = $True
            $Form.FormBorderStyle = 'FixedDialog'


            $img = [System.Drawing.Image]::Fromfile("$($PSScriptRoot)\Banner.png")
            $pictureBox = new-object Windows.Forms.PictureBox
            $pictureBox.Width = $img.Size.Width
            $pictureBox.Height = $img.Size.Height
            $pictureBox.Image = $img
            $PictureBox.Location = New-Object System.Drawing.Point(0,0)


            $Titel = New-Object system.Windows.Forms.Label
            $Titel.text = "Close application"
            $Titel.AutoSize = $true
            # Define the minial width and height (not nessary with autosize true)
            $Titel.width  = 25
            $Titel.height = 10
            $Titel.location = New-Object System.Drawing.Point(20,68)
            $Titel.Font = 'Microsoft Sans Serif,13'

   
            $Description = New-Object system.Windows.Forms.Label
            $Description.text = "To be able to continue with the installation of $appName the application below need to be closed."
            $Description.AutoSize = $false
            $Description.width = 450
            $Description.height = 50
            $Description.location = New-Object System.Drawing.Point(20,98)
            $Description.Font = 'Microsoft Sans Serif,10'

    
            $listBox = New-Object System.Windows.Forms.ListBox
            $listBox.Location = New-Object System.Drawing.Point(20,148)
            $listBox.Size = New-Object System.Drawing.Size(260,10)
            $listBox.Height = 60
            for ($i=0; $i -lt $ProcessArray.length; $i++) {
                Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"} | Select Product -ExpandProperty Product | ForEach-Object {
                    [void] $listBox.Items.Add("$($_.Product)")
                } 
            }


            $button1 = New-Object System.Windows.Forms.Button 
            $button1.Location = New-Object System.Drawing.Size(55,213) 
            $button1.Size = New-Object System.Drawing.Size(120, 25) 
            $button1.Text = "Continue"
            $button1.Add_Click(
                {
                    $ProcessExist = $False
                    for ($i=0; $i -lt $ProcessArray.length; $i++) {
                        $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
                        If ($CheckProcess -ne $null) {
                            $ProcessExist = $True
                        }
                    }
                    If ($ProcessExist -eq $False){
                        $Form.Close();
                    }
                    If ($ProcessExist -eq $True)
                    {
                        $listBox.Items.Clear()
                        for ($i=0; $i -lt $ProcessArray.length; $i++) {
                            Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"} | Select Product -ExpandProperty Product | ForEach-Object {
                                [void] $listBox.Items.Add("$($_.Product)")
                            } 
                        }
                    }
                }
            )


            $button2 = New-Object System.Windows.Forms.Button 
            $button2.Location = New-Object System.Drawing.Size(305,213) 
            $button2.Size = New-Object System.Drawing.Size(120, 25) 
            $button2.Text = "Force close"
            $button2.Add_Click(
                {
                    for ($i=0; $i -lt $ProcessArray.length; $i++) {
                        $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
                        While ($CheckProcess -ne $null) {
                            Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])" } | Stop-Process -Force
                            $CheckProcess = Get-Process | Where-Object { $_.Name -like "$($ProcessArray[$i])"}
                        }
                    }
                    $Form.Close();
                }
            ) 
    

            $Form.controls.AddRange(@($pictureBox,$Titel,$Description,$button1,$button2,$listBox))

            [void]$Form.ShowDialog()
            }
    }
}
Function BalloonTip {
    Param([string]$Type, [string]$Title, [string]$Text)
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 
    $objNotifyIcon.Icon = "$PSScriptRoot\iver.ico"
    $objNotifyIcon.BalloonTipIcon = $Type
    $objNotifyIcon.BalloonTipText = $Text
    $objNotifyIcon.BalloonTipTitle = $Title
    $objNotifyIcon.Visible = $True 
    $objNotifyIcon.ShowBalloonTip(5000)
}
Function InstallMSI {
    Param([string]$File, [string]$Arguments, [Switch]$Wait)
    If($Wait.IsPresent)
    {
        Start-Process msiexec.exe -ArgumentList "/I `"$($RootPath)\Files\$($File)`" $($Arguments) /L*V `"C:\WINDOWS\Logs\AppDeploy.log`"" -Wait -NoNewWindow
    }
    Start-Process msiexec.exe -ArgumentList "/I `"$($RootPath)\Files\$($File)`" $($Arguments) /L*V `"C:\WINDOWS\Logs\AppDeploy.log`"" -NoNewWindow
}
Function InstallEXE {
    Param([string]$File, [string]$Arguments, [Switch]$Wait)
    If($Wait.IsPresent)
    {
        Start-Process -FilePath "$($RootPath)\Files\$($File)" -ArgumentList "$($Arguments)" -Wait -NoNewWindow
    }
    Start-Process -FilePath "$($RootPath)\Files\$($File)" -ArgumentList "$($Arguments)" -NoNewWindow
}
Function CopyFile {
    Param([string]$File, [string]$Destination)
    Copy-Item -Path "$($RootPath)\Files\$($File)" -Destination "$($Destination)" -Force
}
function WaitForProcess {
    Param([string]$Name, [Switch]$IgnoreAlreadyRunningProcesses)

    if ($IgnoreAlreadyRunningProcesses.IsPresent)
    {
        $NumberOfProcesses = (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count
    }
    else
    {
        $NumberOfProcesses = 0
    }
    while ( (Get-Process -Name $Name -ErrorAction SilentlyContinue).Count -eq $NumberOfProcesses )
    {
        Start-Sleep -Milliseconds 400
    }
}
Function UninstallSoftware {
    Param([string]$Name)
    $SoftwareName = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$($Name)"}
    $SoftwareName.Uninstall()
    Get-Package -Provider Programs -IncludeWindowsInstaller -Name "$($Name)"
}
# Do not modify code above this line
