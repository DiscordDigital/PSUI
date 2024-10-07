Import-Module $PSScriptRoot\PSUI.psm1 -Force
function SearchLocalUsers() {
    $form = New-Form -Title "Search Local Users" -SizeX 400 -SizeY 460 -FormBorderStyle FixedDialog -Icon "C:\Windows\System32\lusrmgr.msc"
    $Label1 = New-Label -Text "Search Local Users" -LocationY 23 -LocationX 70
    $Label2 = New-Label -Text "Query:" -LocationX 14 -LocationY 80

    $Separator = New-Label -Text "" -AutoSize $false -SizeY 2 -SizeX ($form.Width - 40) -LocationX 10 -LocationY 58 -BorderStyle Fixed3D

    $SearchAction = {
        if ($TextBox.Text -eq "") {
            $ListBox.Items.Clear();
            Show-Msg -Text "Search query can't be empty" `
                     -Icon Error `
                     -Title "Search"
        } else {
            $results = Get-LocalUser | Where-Object {$_.Name -like "*$($TextBox.Text)*"}

            $ListBox.Items.Clear();
            foreach ($result in $results) {
                $ListBox.Items.Add($result.Name)
            }
        }
    }

    $CloseAction = {
        $this.FindForm().Close();
    }

    $icon = "C:\Windows\System32\lusrmgr.msc"

    $TextBox = New-Textbox -LocationX 100 -LocationY 78 -SizeX 250 -OnEnter $SearchAction
    $Image = New-PictureBox -Image $icon -SizeX 32 -SizeY 32 -AutoSize $false -LocationX 16 -LocationY 16
    $Button1 = New-Button -Text "Search" -OnClick $SearchAction -LocationX 275 -LocationY 100
    $Button2 = New-Button -Text "OK" -OnClick $CloseAction -LocationX 230 -LocationY 390
    $Button3 = New-Button -Text "Cancel" -OnClick $CloseAction -LocationX 315 -LocationY 390
    $ListBox = New-ListBox -AutoSize $false -SizeX ($form.Width - 55) -SizeY ($form.Height - 240) -LocationX 16 -LocationY 130 -BorderStyle "None"
    $TabPage1 = New-TabPage -Text "Search" -Controls @($Label1, $Label2, $Separator, $TextBox, $Button1, $ListBox, $Image);
    $TabControl = New-TabControl -TabPages @($TabPage1)

    $Panel = New-Panel -panelItems @($TabControl) -AutoSize $false -SizeX $form.Width -SizeY ($form.Height - 70) -BorderStyle None
    $Panel.Padding = "5, 5, 2, 5"
    $form.Controls.Add($Panel)
    $form.Controls.Add($Button2)
    $form.Controls.Add($Button3)
    $form.ShowDialog() | Out-Null
}

function ProgressBarSimulation {
    $ProgressBar = New-ProgressBar -Step 40 -SizeX 365 -LocationX 10 -LocationY 10

    $form = New-Form -Title "Progressbar Simulation" -SizeX 400 -SizeY 80 -Controls @($ProgressBar)

    $Timer = New-Timer -OnTick {
        Write-Host "ProgressBar at: $($ProgressBar.Value)%"
        if ($ProgressBar.Value -lt $ProgressBar.Maximum) {
            $ProgressBar.PerformStep();
        } else {
            Write-Host "ProgressBar finished!"
            $Timer.Stop();
            $ProgressBar.FindForm().Close();
        }
    }

    $form.Add_Shown({ $Timer.Start() })
    $form.ShowDialog() | Out-Null

    if ($Timer.Enabled) {
        $Timer.Stop();
    }
}

function Radios {
    $Radio1 = New-RadioButton -LocationX 10 -LocationY 20 -Text "Radio 1" -Checked $true

    $Radio2 = New-RadioButton -LocationX 10 -LocationY 40 -Text "Radio 2" -OnClick {
        param(
            $button
        )
        Write-Host "$($button.Text) has been clicked."
    }

    $Radios = @($Radio1, $Radio2)
    $GroupBox = New-GroupBox -Controls $Radios -SizeX 120 -SizeY 80

    $Button = New-Button -LocationY 30 -LocationX 140 -Text "Check" -OnClick {
        $RadioResult = Get-SelectedRadio -RadioButtons $Radios
        if ($RadioResult -eq $false) {
            Show-Msg -Icon Error -Text "No radio is selected" -Title "Error"
        } else {
            Show-Msg -Text "$($RadioResult) is selected"
        }
    }

    $form = New-Form -Title "Radios" -SizeX 250 -SizeY 130 -Controls @($GroupBox, $Button)

    $form.ShowDialog() | Out-Null
}

function LocalUserGrid {
    $data = Get-LocalUser
    $DataGridView = New-DataGridView -Data $data -ReadOnly $false -Properties PasswordRequired, PrincipalSource, ObjectClass
    $form = New-Form -Title "DataGridView Example" -SizeX 550 -SizeY 250 -Controls @($DataGridView) -FormBorderStyle Sizable -Maximizable $true -Topmost $true

    Enable-DataGridEditHotKeys -Form $form -DataGridView $DataGridView

    $form.ShowDialog() | Out-Null

    $test = Convert-DataGridViewToPSCustomObject -DataGridView $DataGridView
    $test | Format-Table
}

function SysprepDemo {
    $FormWidth = 445
    $FormHeight = 285
    $script:ActiveTab = 0

    # Computer Tab Start
    $ComputernameTabText1 = New-Label -Text "First computer setup. (Non-functional Demo)" -LocationX 5 -LocationY 10 -FontSize 10
    $ComputernameTabText2 = New-Label -Text "Enter computername:" -LocationX 5 -LocationY 50
    $ComputernameTabInput = New-Textbox -LocationX 5 -LocationY 70 -SizeX ($FormWidth - 35) -Text $env:computername -FontSize 12

    $ComputernameTabNext = New-Button -Text "Next" -OnClick {
        $script:ActiveTab = 1;
        $TabControl.SelectTab($script:ActiveTab);
    } -LocationX ($FormWidth - 110) -LocationY ($FormHeight - 100)

    $ComputernameTabCancel = New-Button -Text "Cancel" -OnClick {$this.FindForm().Close()} -LocationX ($FormWidth - 195) -LocationY ($FormHeight - 100)
    $ComputernameTab = New-TabPage -Text "Computername" -Controls @($ComputernameTabText1, $ComputernameTabText2, $ComputernameTabInput, $ComputernameTabNext, $ComputernameTabCancel)
    # Computer Tab End

    # Software Tab Start
    $SoftwareText1 = New-Label -Text "Select software to install: (Non-functional demo)" -LocationX 5 -LocationY 10
    $SoftwareOffice = New-CheckBox -Text "Office M365" -LocationX 5 -LocationY 30 -Checked $true
    $SoftwareVPN = New-CheckBox -Text "VPN Software" -LocationX 5 -LocationY 50 -Checked $true
    $SoftwareAntivirus = New-CheckBox -Text "Antivirus Software" -LocationX 5 -LocationY 70 -Enabled $false -Checked $true

    $SoftwareInstall = New-Button -Text "Install" -OnClick {
        $script:ActiveTab = 2;
        $TabControl.SelectTab($script:ActiveTab);
        $i = 0;
        if ($SoftwareOffice.Checked) {$i++}
        if ($SoftwareVPN.Checked) {$i++}
        if ($SoftwareAntivirus.Checked) {$i++}
        $InstallProgressbar.Maximum = $i;

        $InstallTimer.Start();
    } -LocationX ($FormWidth - 110) -LocationY ($FormHeight - 100)

    $SoftwareTab = New-TabPage -Text "Software" -Controls @($SoftwareText1, $SoftwareOffice, $SoftwareVPN, $SoftwareAntivirus, $SoftwareInstall)
    # Software Tab End

    # Install Tab Start
    $InstallTimer = New-Timer -OnTick {
        if ($InstallProgressbar.Value -lt $InstallProgressbar.Maximum) {
            $InstallProgressbar.PerformStep();
        } else {
            $InstallTimer.Stop();
            $InstallEnd.Enabled = $true;
            $InstallText1.Text = "Click Finish to close this window"
        }
    } -Interval 3000

    $InstallText1 = New-Label -Text "Please wait for software to install.." -LocationX 5 -LocationY 10
    $InstallProgressbar = New-ProgressBar -Step 1 -LocationX 5 -LocationY 50 -SizeX ($FormWidth - 35)
    $InstallEnd = New-Button -Text "Finish" -LocationX ($FormWidth - 110) -LocationY ($FormHeight - 100) -OnClick {$this.FindForm().Close();} -Enabled $false
    $InstallTab = New-TabPage -Text "Software Setup" -Controls @($InstallText1, $InstallProgressbar, $InstallEnd)
    # Install Tab End

    $TabControl = New-TabControl -TabPages @($ComputernameTab, $SoftwareTab, $InstallTab) -OnSelectChange {
        $TabControl.SelectTab($script:ActiveTab);
    }

    $form = New-Form -Title "First Setup" -Controls @($TabControl) -SizeX $FormWidth -SizeY $FormHeight -Topmost $true -Icon "C:\Windows\System32\mmc.exe"
    $form.ShowDialog() | Out-Null

    if ($InstallTimer.Enabled) {
        $InstallTimer.Stop();
    }
}

SearchLocalUsers
ProgressBarSimulation
Radios
LocalUserGrid
SysprepDemo
