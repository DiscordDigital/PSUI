Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

[System.Windows.Forms.Application]::EnableVisualStyles();

<#
  .Function Name : Convert-DataGridViewToPSCustomObject
  .Description   : Converts a DataGridView object to a PSCustomObject
  .How to use    : Pass a DataGridView to -DataGridView to get a PSCustomObject array of all rows
#>
function Convert-DataGridViewToPSCustomObject {
    param(
        [Object]$DataGridView
    )

    $ColumnNames = @();
    for ($i=0; $i -le $DataGridView.ColumnCount - 1; $i++) {
        $ColumnNames += $DataGridView.Columns[$i].Name;
    }

    $PSCustomObjectCollection = [Array]@()
    for ($i=0; $i -le $DataGridView.RowCount - 1; $i++) {
        $PSCustomObject = [PSCustomObject]@{}
        for ($j=0; $j -le $DataGridView.Rows[$i].Cells.Count - 1; $j++) {
            $PSCustomObject | Add-Member -MemberType NoteProperty -Name $ColumnNames[$DataGridView.Rows[$i].Cells[$j].ColumnIndex] -Value $DataGridView.Rows[$i].Cells[$j].Value
        }
        $PSCustomObjectCollection += $PSCustomObject
    }

    return $PSCustomObjectCollection
}

<#
  .Function Name : Enable-DataGridEditHotKeys
  .Description   : Enables various editing hotkeys for a DataGrid that is not ReadOnly
  .How to use    : Run this on a Form and DataGridView, and the hotkeys will be enabled
#>
function Enable-DataGridEditHotKeys {
    param(
        [Object]$Form,
        [System.Windows.Forms.DataGridView]$DataGridView
    )

    $Form.Add_KeyDown({
        param(
            $sender,
            $e
        )

        if ($DataGridView.ReadOnly -eq $true) {
            return
        }

        if ($e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Down) {
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            if ($cRowIndex -eq $DataSource.Rows.Count - 1) {
                return
            }

            $rowBelow = $DataSource.Rows[$cRowIndex + 1];

            $tempRow = $DataSource.NewRow();
            $tempRow.ItemArray = $DataSource.Rows[$cRowIndex].ItemArray

            $DataSource.Rows[$cRowIndex].ItemArray = $rowBelow.ItemArray

            $rowBelow.ItemArray = $tempRow.ItemArray

            $DataGridView.Refresh();
            return
        }

        if ($e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Up) {
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            if ($cRowIndex -eq 0) {
                return
            }

            $rowAbove = $DataSource.Rows[$cRowIndex - 1];

            $tempRow = $DataSource.NewRow();
            $tempRow.ItemArray = $DataSource.Rows[$cRowIndex].ItemArray

            $DataSource.Rows[$cRowIndex].ItemArray = $rowAbove.ItemArray

            $rowAbove.ItemArray = $tempRow.ItemArray

            $DataGridView.Refresh();
            return
        }

        if ($e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Left) {
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            if ($cColumnIndex - 1 -lt 0) {
                return
            }

            if ($DataSource.Rows.Count -eq 0) {
                return
            }

            $DataSource.Columns[$cColumnIndex].SetOrdinal($cColumnIndex - 1);

            $DataGridView.DataSource = $null;
            $DataGridView.DataSource = $DataSource;

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex].Cells[$cColumnIndex]

            $DataGridView.Refresh();
            return
        }

        if ($e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Right) {
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            if ($cColumnIndex -eq $DataSource.Columns.Count - 1) {
                return
            }

            if ($DataSource.Rows.Count -eq 0) {
                return
            }

            $DataSource.Columns[$cColumnIndex].SetOrdinal($cColumnIndex + 1);

            $DataGridView.DataSource = $null;
            $DataGridView.DataSource = $DataSource;

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex].Cells[$cColumnIndex]

            $DataGridView.Refresh();
            return
        }

        if ($e.Control -and $e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::R) {
            $newName = $DataGridView.CurrentCell.Value
            if ($newName.GetType().FullName -eq "System.DBNull") {
                return
            }
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            $DataSource.Columns[$cColumnIndex].ColumnName = $newName;

            $DataGridView.DataSource = $null;
            $DataGridView.DataSource = $DataSource;

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex].Cells[$cColumnIndex]

            $DataGridView.Refresh();
            return
        }

        if ($e.Control -and $e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::N) {
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource
            $newCol = New-Object System.Data.DataColumn("", [System.String])
            $DataSource.Columns.Add($newCol)
            $newCol.SetOrdinal($cColumnIndex + 1);

            $DataGridView.DataSource = $null;
            $DataGridView.DataSource = $DataSource;

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex].Cells[$cColumnIndex + 1]

            $DataGridView.Refresh();
            return
        }

        if ($e.Control -and $e.Shift -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Delete) {
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex;
            $cRowIndex = $DataGridView.CurrentCell.RowIndex;
            $DataSource = $DataGridView.DataSource;
            $DataSource.Columns.RemoveAt($cColumnIndex);

            $DataGridView.DataSource = $null;
            $DataGridView.DataSource = $DataSource;

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex].Cells[$cColumnIndex];

            $DataGridView.Refresh();
            return
        }

        if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::N) {
            $cRowIndex = $DataGridView.CurrentCell.RowIndex;
            $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex;
            $DataSource = $DataGridView.DataSource;

            $NewRow = $DataSource.NewRow();
            $DataSource.Rows.InsertAt($NewRow, $cRowIndex + 1);

            if ($DataSource.Rows.Count -1 -eq 0) {
                return
            }

            $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex + 1].Cells[$cColumnIndex];
            return
        }

        if ($e.Control -and $e.KeyCode -eq [System.Windows.Forms.Keys]::Delete) {
            $cRowIndex = $DataGridView.CurrentCell.RowIndex
            $DataSource = $DataGridView.DataSource

            if ($DataSource.Rows.Count -eq 0) {
                return
            }

            if ($DataSource.Rows.Count -eq $cRowIndex + 1) {
                $cColumnIndex = $DataGridView.CurrentCell.ColumnIndex;
                $DataGridView.CurrentCell = $DataGridView.Rows[$cRowIndex - 1].Cells[$cColumnIndex];
            }

            $DataGridView.Rows.RemoveAt($cRowIndex);
            return
        }
    }.GetNewClosure());
}

<#
  .Function Name : Get-SelectedRadio
  .Description   : Takes an array of radios and returns the text of the checked one
  .How to use    : Pass -RadioButtons as an array, if $false is returned, no Radio is selected
#>
function Get-SelectedRadio {
    param(
        [array]$RadioButtons = @()
    )

    foreach ($RadioButton in $RadioButtons) {
        if ($RadioButton.Checked -eq $true) {
            return $RadioButton.Text
        }
    }
    return $false
}

<#
  .Function Name : Show-Msg
  .Description   : Shows a message
  .How to use    : Specify $Text as a parameter to show a message
#>
function Show-Msg {
    param(
        [string]$Text,
        [string]$Title = "Info",
        [string]$Buttons = "OK", # OK, OKCancel, YesNo, YesNoCancel
        [string]$Icon = "Information" # Asterisk, Error, Exclamation, Hand, Information, None, Question, Stop, Warning
    )
    [System.Windows.MessageBox]::Show($Text, $Title, $Buttons, $Icon)
}

<#
  .Function Name : New-Button
  .Description   : Creates a button
  .How to use    : You can use the OnClick ScriptBlock parameter to add actions to it,
                   if you want to access the form underneath it use: $this.FindForm()
#>
function New-Button {
    param(
        [bool]$AutoSize = $true,
        [bool]$Enabled = $true,
        [float]$FontSize = 8.25,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [string]$Text = "Button",
        $DialogResult = $false,
        $OnClick = $false
    )

    $Button = New-Object System.Windows.Forms.Button

    if ($DialogResult -ne $false) {
        $Button.DialogResult = [System.Windows.Forms.DialogResult]::$DialogResult;
    }

    if ($OnClick -ne $false) {
        $Button.Add_Click($OnClick);
    }

    $Button.Text = $Text;

    if ($AutoSize -eq $true) {
        $Button.AutoSize = $true;
    } else {
        $Button.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $Button.Enabled = $Enabled;

    $Button.Location = New-Object System.Drawing.Point($LocationX,$LocationY)

    $Button.Font = New-Object System.Drawing.Font($Button.Font.FontFamily, $FontSize);

    return $Button;
}

<#
  .Function Name : New-CheckBox
  .Description   : Creates a checkbox that can be used for various things
  .How to use    : Value can be accessed through $this.Checked (boolean)
#>
function New-CheckBox {
    param(
        [bool]$AutoCheck = $true,
        [bool]$AutoSize = $true,
        [bool]$Checked = $false,
        [bool]$Enabled = $true,
        [float]$FontSize = 8.25,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [string]$FontFamily = "Microsoft Sans Serif",
        [string]$Text = "Unnamed Checkbox",
        [System.Drawing.FontStyle]$FontFormat = "Regular",
        $OnClick = $false
    )

    $CheckBox = New-Object System.Windows.Forms.CheckBox;

    $CheckBox.AutoCheck = $AutoCheck;

    $CheckBox.Checked = $Checked;

    $CheckBox.Enabled = $Enabled;

    if ($OnClick -ne $false) {
        $CheckBox.Add_Click($OnClick);
    }

    if ($AutoSize -eq $true) {
        $CheckBox.AutoSize = $AutoSize;
    } else {
        $CheckBox.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $CheckBox.Text = $Text
    $CheckBox.Font = New-Object System.Drawing.Font($FontFamily, $FontSize, $FontFormat);
    $CheckBox.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    return $CheckBox;
}

<#
  .Function Name : New-DataGridView
  .Description   : Creates a grid view of data
  .How to use    : Specify a PowerShell result or custom object as $Data
#>
function New-DataGridView {
    param(
        [bool]$AutoSize = $false,
        [bool]$AllowUsersToAddRows = $false,
        [bool]$ReadOnly = $true,
        [bool]$RowHeadersVisible = $false,
        [bool]$MultiSelect = $false,
        [float]$HeaderFontSize = 8.25,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [string]$HeaderFontName = "Microsoft Sans Serif",
        [System.Drawing.Color]$GridColor = "ControlDark",
        [System.Drawing.Color]$HeaderBackColor = "Navy",
        [System.Drawing.Color]$HeaderForeColor = "White",
        [System.Drawing.FontStyle]$HeaderFontStyle = "Regular",
        [System.Windows.Forms.DataGridViewAutoSizeRowsMode]$AutoSizeRowsMode = "DisplayedCellsExceptHeaders",
        [System.Windows.Forms.DataGridViewCellBorderStyle]$BorderStyle = "Single",
        [System.Windows.Forms.DockStyle]$Dock = "Fill",
        $Data = $false,
        $Properties = $false
    )

    $DataGridView = New-Object System.Windows.Forms.DataGridView;

    $DataGridView.ColumnHeadersDefaultCellStyle.BackColor = $HeaderBackColor;
    $DataGridView.ColumnHeadersDefaultCellStyle.ForeColor = $HeaderForeColor;
    $DataGridView.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font($HeaderFontName, $HeaderFontSize, $HeaderFontStyle);
    
    if ($AutoSize -eq $true) {
        $DataGridView.AutoSize = $true;
    } else {
        $DataGridView.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $DataGridView.AllowUserToAddRows = $AllowUsersToAddRows;
    $DataGridView.AutoSizeRowsMode = $AutoSizeRowsMode;
    $DataGridView.CellBorderStyle = $BorderStyle;
    $DataGridView.Dock = $Dock;
    $DataGridView.GridColor = $GridColor;
    $DataGridView.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $DataGridView.ReadOnly = $ReadOnly;
    $DataGridView.RowHeadersVisible = $RowHeadersVisible;
    $DataGridView.MultiSelect = $MultiSelect;

    if ($Data -ne $false) {
        $DataTable = New-Object System.Data.DataTable;

        if ($Properties -eq $false) {
            $Properties = ($Data | Get-Member -MemberType Properties | Select-Object Name).Name
        }
        
        $i = 0;
        foreach ($Property in $Properties) {
            $column = New-Object System.Data.DataColumn;
            $column.ColumnName = $Property;
            $DataTable.Columns.Add($column);
            $i++;
        }

        for ($i=0; $i -le $Data.Length - 1; $i++) {
            $row = $DataTable.NewRow();
            for ($j=0; $j -le $Properties.Length - 1; $j++) {
                
                $propertyName = $Properties[$j];
                $row[$propertyName] = $Data[$i].$propertyName
            }
            $DataTable.Rows.Add($row);
        }

        $DataGridView.DataSource = $DataTable;
    }

    return $DataGridView;
}


<#
  .Function Name : New-FlowLayoutPanel
  .Description   : Creates a more organized item panel, which can be inserted into other panels or forms
  .How to use    : Create it using $panelItems passing an array of UI items, then insert this panel into a form or panel
#>
function New-FlowLayoutPanel {
    param(
        [array]$panelItems = @(),
        [bool]$AutoSize = $true,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$TabIndex = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [System.Windows.Forms.FlowDirection]$FlowDirection = "TopDown"
    )

    $FlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel

    foreach ($panelItem in $panelItems) {
        [void] $FlowLayoutPanel.Controls.Add($panelItem);
    }

    $FlowLayoutPanel.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $FlowLayoutPanel.TabIndex = $TabIndex;
    $FlowLayoutPanel.FlowDirection = $FlowDirection;
    
    if ($AutoSize -eq $true) {
        $FlowLayoutPanel.AutoSize = $true;
    } else {
        $FlowLayoutPanel.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    return $FlowLayoutPanel;
}

<#
  .Function Name : New-Form
  .Description   : Creates a form
  .How to use    : After inserting elements, use Show() to show it.
                   In case of a DialogResult in a button, it can be used like this: (Where the DialogResult is OK)
                   $result = $form.ShowDialog();
                   if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                     ...
                   When the window is closed, it will return Cancel
#>
function New-Form {
    param(
        [array]$Controls = @(),
        [bool]$Topmost = $false,
        [bool]$AutoSize = $true,
        [bool]$KeyPreview = $true,
        [bool]$Maximizable = $false,
        [bool]$Minimizable = $true,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [string]$Title = "Unnamed Window",
        [string]$StartPosition = 'CenterScreen',
        [System.Windows.Forms.FormBorderStyle]$FormBorderStyle = "FixedDialog",
        $Icon = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    )

    $form = New-Object System.Windows.Forms.Form;

    foreach ($Control in $Controls) {
        [void] $form.Controls.Add($Control);
    }

    $form.MaximizeBox = $Maximizable;
    $form.MinimizeBox = $Minimizable;

    $form.Text = $Title;
    $form.StartPosition = $StartPosition;
    $form.FormBorderStyle = $FormBorderStyle;
    $form.Topmost = $Topmost;
    $form.AutoSize = $AutoSize;
    $form.KeyPreview = $KeyPreview;
    $form.Size = New-Object System.Drawing.Point($SizeX, $SizeY);

    $imageTypes = @("png", "jpg", "jpeg");

    if ($Icon -ne $false) {
        if ((Test-Path -Path $Icon) -eq $true) {
            $isImage = $false;
            foreach ($imageType in $imageTypes) {
                if ($Icon.EndsWith($imageType)) {
                    $isImage = $true;
                }
            }
            if ($isImage -eq $true) {
                $form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($Icon).GetHIcon()));
            } else {
                $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Icon);
            }
        } else {
            $iconBytes = [Convert]::FromBase64String($Icon);
            $stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length);
            $form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()));
        }
    }

    return $form;
}

<#
  .Function Name : New-GroupBox
  .Description   : Creates a GroupBox often used by radios
  .How to use    : Create a GroupBox and add radios into it
#>
function New-GroupBox {
    param(
        [array]$Controls = @(),
        [bool]$AutoSize = $false,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [System.Windows.Forms.FlatStyle]$Style = "Standard"
    )

    $GroupBox = New-Object System.Windows.Forms.GroupBox;
    $GroupBox.FlatStyle = $Style;

    foreach ($Control in $Controls) {
        [void] $GroupBox.Controls.Add($Control);
    }

    if ($AutoSize -eq $true) {
        $GroupBox.AutoSize = $true;
    } else {
        $GroupBox.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $GroupBox.Location = New-Object System.Drawing.Point($LocationX, $LocationY);

    return $GroupBox;
}

<#
  .Function Name : New-Label
  .Description   : Create a text field
  .How to use    : Can be inserted into a form or panel
#>
function New-Label {
    param(
        [bool]$AutoSize = $true,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [float]$FontSize = 8.25,
        [string]$FontColor = "Black",
        [string]$FontColorHex = "",
        [string]$FontName = "Microsoft Sans Serif",
        [string]$Text,
        [System.Drawing.FontStyle]$FontFormat = "Regular",
        [System.Windows.Forms.BorderStyle]$BorderStyle = "None"
    )

    $Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $Font = New-Object System.Drawing.Font($FontName, $FontSize, $FontFormat);
    $label = New-Object System.Windows.Forms.Label

    $label.Location = $Location;

    if ($AutoSize -eq $true) {
        $label.AutoSize = $AutoSize;
    } else {
        $label.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }

    if ($FontColorHex -ne "") {
        $label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($FontColorHex);
    } else {
        if ($FontColor -ne "Black") {
            $label.ForeColor = [System.Drawing.Color]::FromName($FontColor)
        }
    }

    $label.Font = $Font;
    $label.Text = $Text;
    $label.BorderStyle = $BorderStyle;

    return $label;
}

<#
  .Function Name : New-ListBox
  .Description   : Creates a listbox element, specify Options as an array
  .How to use    : Insert into panel or form, either use OnChange or $this.SelectedItem to obtain values
#>
function New-ListBox {
    param(
        [bool]$AutoSize = $true,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [System.Object]$Options = @(),
        $OnChange = $false
    )

    $listBox = New-Object System.Windows.Forms.ListBox

    foreach ($Option in $Options) {
        [void] $listBox.Items.Add($Option)
    }

    if ($AutoSize -eq $true) {
        $listBox.AutoSize = $true;
    } else {
        $listBox.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }

    $listBox.Location = New-Object System.Drawing.Size($LocationX,$LocationY);

    if ($OnChange -ne $false) {
        $OnChange = $listBox.add_SelectedIndexChanged($OnChange);
    }

    return $listBox
}

function New-Panel {
    param(
        [array]$panelItems = @(),
        [bool]$AutoSize = $true,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,        
        [System.Windows.Forms.BorderStyle]$BorderStyle = "FixedSingle"
    )

    $Panel = New-Object System.Windows.Forms.Panel

    foreach ($panelItem in $panelItems) {
        [void] $Panel.Controls.Add($panelItem);
    }

    if ($AutoSize -eq $true) {
        $Panel.AutoSize = $true
    } else {
        $Panel.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $Panel.Location = New-Object System.Drawing.Point($LocationX, $LocationY);

    $Panel.BorderStyle = $BorderStyle

    return $Panel
}

function New-PictureBox {
    param(
        [bool]$AutoSize = $true,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [System.Windows.Forms.PictureBoxSizeMode]$SizeMode = "StretchImage",
        $Image = $false
    )

    $PictureBox = New-Object System.Windows.Forms.PictureBox

    $PictureBox.SizeMode = $SizeMode;
    $PictureBox.Location = New-Object System.Drawing.Point($LocationX, $LocationY);

    $imageTypes = @("png", "jpg", "jpeg");

    if ($Image -ne $false) {
        if ((Test-Path -Path $Image) -eq $true) {
            $isImage = $false;
            foreach ($imageType in $imageTypes) {
                if ($Image.EndsWith($imageType)) {
                    $isImage = $true;
                }
            }
            if ($isImage -eq $true) {
                $PictureBox.Image = [System.Drawing.Bitmap]::new($Image);
            } else {
                $PictureBox.Image = [System.Drawing.Icon]::ExtractAssociatedIcon($Image);
            }
        } else {
            $iconBytes = [Convert]::FromBase64String($Image);
            $stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length);
            $PictureBox.Image = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()));
        }
    }

    if ($AutoSize -eq $true) {
        $PictureBox.AutoSize = $true;
    } else {
        $PictureBox.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    return $PictureBox
}

<#
  .Function Name : New-ProgressBar
  .Description   : Creates a ProgressBar
  .How to use    : Include in your form or similar, then use PerformStep() to make it perform a step
#>
function New-ProgressBar {
    param(
        [bool]$AutoSize = $false,
        [bool]$Visible = $true,
        [int]$SizeX = 0,
        [int]$SizeY = 23,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$Minimum = 0,
        [int]$Maximum = 100,
        [int]$Value = 0,
        [int]$Step = 1
    )

    $ProgressBar = New-Object System.Windows.Forms.ProgressBar

    if ($AutoSize -eq $true) {
        $ProgressBar.AutoSize = $true;
    } else {
        $ProgressBar.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $ProgressBar.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $ProgressBar.Minimum = $Minumum;
    $ProgressBar.Maximum = $Maximum;
    $ProgressBar.Step = $Step;
    $ProgressBar.Value = $Value;

    return $ProgressBar;
}

<#
  .Function Name : New-RadioButton
  .Description   : Creates a radio, which can be used in a GroupBox
  .How to use    : Create radios, use .Checked to see the selected one
#>
function New-RadioButton {
    param(
        [bool]$AutoSize = $true,
        [bool]$Checked = $false,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [string]$Text = "",
        [ScriptBlock]$OnClick = {}
    )

    $RadioButton = New-Object System.Windows.Forms.RadioButton;

    if ($AutoSize -eq $true) {
        $AutoSize = $RadioButton.AutoSize = $false;
    } else {
        $RadioButton.Size = New-Object System.Drawing.Size($SizeX, $SizeY);
    }

    $RadioButton.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $RadioButton.Text = $Text;
    $RadioButton.Add_Click($OnClick);
    $RadioButton.Checked = $Checked;

    return $RadioButton;
}

<#
  .Function Name : New-SplitContainer
  .Description   : Create a vertical or horizontal split-view.
  .How to use    : Add into Panel or Form, add other objects to $this.Panel1 or $this.Panel2
#>
function New-SplitContainer {
    param(
        [bool]$AutoSize = $true,
        [bool]$Fixed = $false,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$Panel1MinSize = 0,
        [int]$Panel2MinSize = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [int]$SplitterIncrement = 5,
        [int]$SplitterWidth = 6,
        [int]$TabIndex = 0,
        [string]$Dock = "Fill",
        [string]$FontColor = "Black",
        [string]$FontColorHex = "",
        [System.Windows.Forms.BorderStyle]$BorderStyle = "FixedSingle",
        [System.Windows.Forms.Orientation]$Orientation = "Vertical",
        $SplitterDistance = "half"
    )

    $SplitContainer = New-Object System.Windows.Forms.SplitContainer

    $SplitContainer.Dock = $Dock;
    if ($FontColorHex -ne "") {
        $SplitContainer.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($FontColorHex);
    } else {
        if ($FontColor -ne "Black") {
            $SplitContainer.ForeColor = [System.Drawing.Color]::FromName($FontColor)
        }
    }

    $SplitContainer.Location = New-Object System.Drawing.Size($LocationX,$LocationY);
    $SplitContainer.Panel1MinSize = $Panel1MinSize;
    $SplitContainer.Panel2MinSize = $Panel2MinSize;
    if ($AutoSize -eq $true) {
        $SplitContainer.AutoSize = $true;
    } else {
        $SplitContainer.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }

    if ($SplitterDistance -eq "half") {
        $SplitContainer.SplitterDistance = ($SplitContainer.Width/2) - ($SplitterWidth/2);
    } else {
        $SplitContainer.SplitterDistance = $SplitterDistance;
    }
    $SplitContainer.SplitterIncrement = $SplitterIncrement;
    $SplitContainer.SplitterWidth = $SplitterWidth;
    $SplitContainer.TabIndex = $TabIndex;
    $SplitContainer.BorderStyle = $BorderStyle;
    $SplitContainer.Orientation = $Orientation;

    if ($Fixed -eq $true) {
        $SplitContainer.IsSplitterFixed = $true;
    }

    return $SplitContainer;
}

<#
  .Function Name : New-TabControl
  .Description   : Creates an element that can hold multiple tabs created by New-TabPage
  .How to use    : Create multiple TabPages, and pass it as an Array to the TabPages parameter,
                   then insert into panel or form.
#>
function New-TabControl {
    param(
        [array]$TabPages = @(),
        [bool]$AutoSize = $true,
        [bool]$Multiline = $true,
        [int]$LocationX = 5,
        [int]$LocationY = 5,
        [int]$SelectedIndex = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [int]$TabIndex = 0,
        [string]$Alignment = "Top",
        [string]$Dock = "Fill",
        [ScriptBlock]$OnSelectChange = {}
    )

    $TabControl = New-Object System.Windows.Forms.TabControl

    foreach ($TabPage in $TabPages) {
        [void] $TabControl.Controls.Add($TabPage);
    }

    $TabControl.Alignment = $Alignment;
    $TabControl.Location = New-Object System.Drawing.Size($LocationX,$LocationY);
    $TabControl.Multiline = $Multiline;
    $TabControl.SelectedIndex = $SelectedIndex;
    $TabControl.TabIndex = $TabIndex;
    $TabControl.Dock = $Dock;

    $TabControl.Add_SelectedIndexChanged($OnSelectChange);

    if ($AutoSize -eq $true) {
        $TabControl.AutoSize = $true;
    } else {
        $TabControl.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }

    return $TabControl
}

<#
  .Function Name : New-TabPage
  .Description   : Create a singular Tab page, needs to be used with New-TabControl in an array.
  .How to use    : Treat tabs as containers for objects, you can create multiple of these and add them to a TabControl object.
#>
function New-TabPage {
    param(
        [bool]$UseVisualStyleBackColor = $true,
        [bool]$AutoSize = $true,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [int]$SizeX = 0,
        [int]$SizeY = 0,
        [int]$TabIndex = 0,
        [string]$Padding = "3, 3, 3, 3",
        [string]$Text,
        [array]$Controls = @()
    )

    $TabPage = New-Object System.Windows.Forms.TabPage

    foreach ($Control in $Controls) {
        [void] $TabPage.Controls.Add($Control);
    }

    $TabPage.Location = New-Object System.Drawing.Size($LocationX,$LocationY);
    $TabPage.Padding = $Padding;
    $TabPage.TabIndex = $TabIndex;
    $TabPage.Text = $Text;
    $TabPage.UseVisualStyleBackColor = $UseVisualStyleBackColor;
    
    if ($AutoSize -eq $true) {
        $TabPage.AutoSize = $AutoSize;
    } else {
        $TabPage.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }

    return $TabPage
}

<#
  .Function Name : New-Textbox
  .Description   : Creates an input text field, that can be written into.
  .How to use    : Add into Panel or Form, read or set values by using $this.Text
#>
function New-Textbox {
    param(
        [bool]$AutoSize = $false,
        [bool]$acceptsReturn = $false,
        [bool]$acceptsTab = $true,
        [bool]$Password = $false,
        [bool]$Multiline = $false,
        [int]$SizeX = 100,
        [int]$SizeY = 20,
        [int]$LocationX = 0,
        [int]$LocationY = 0,
        [float]$FontSize = 8.25,
        [string]$FontFamily = "Microsoft Sans Serif",
        [string]$HiddenChar = "*",
        [ScriptBlock]$OnEnter = {},
        [System.Windows.Forms.DockStyle]$Dock = "None",
        [System.Windows.Forms.ScrollBars]$ScrollBars = "Vertical",
        $MaxLength = $false,
        $Text = $false
    )

    $TextBox = New-Object System.Windows.Forms.TextBox

    if ($Password -eq $true) {
        $TextBox.PasswordChar = $HiddenChar;
    }

    $TextBox.AcceptsReturn = $acceptsReturn;
    $TextBox.AcceptsTab = $acceptsTab;
    $TextBox.Dock = $Dock;
    $TextBox.Multiline = $Multiline;
    $TextBox.ScrollBars = $ScrollBars;
    if ($AutoSize -eq $true) {
        $TextBox.AutoSize = $true;
    } else {
        $TextBox.Size = New-Object System.Drawing.Size($SizeX,$SizeY);
    }
    $TextBox.Location = New-Object System.Drawing.Point($LocationX, $LocationY);
    $TextBox.Font = New-Object System.Drawing.Font($FontFamily, $FontSize);

    if ($MaxLength -ne $false) {
        $TextBox.MaxLength = $MaxLength;
    }

    if ($Text -ne $false) {
        $TextBox.Text = $Text;
    }

    $TextBox.Add_KeyDown({
        if (($_.KeyCode -eq [System.Windows.Forms.Keys]::Return) -or ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter)) {
            $_.SuppressKeyPress = $true
            & $OnEnter
        }
    }.GetNewClosure())

    return $TextBox;
}

<#
  .Function Name : New-Timer
  .Description   : Creates a timer that runs on the same thread
  .How to use    : Add actions to $OnTick, use $Timer.Start() and $Timer.Stop() to start & stop
#>
function New-Timer {
    param(
        [int]$Interval = 1000,
        [scriptblock]$OnTick = {}
    )

    $Timer = New-Object System.Windows.Forms.Timer;

    $Timer.Interval = $Interval;
    $Timer.Add_Tick($OnTick);

    return $Timer
}
