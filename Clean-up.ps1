# PowerShell Script to assint in the cleaning-up inside your windows
# Created by Marcelo D Avanzi on 08/16/2022

#------- Functions -----------------------------------------------------------
Function CleanUpFiles {
    [CmdletBinding()]
    Param
    (
         [Parameter(Mandatory=$true, Position=0)][string] $Path,
         [Parameter(Mandatory=$true, Position=1)][array] $Filters,
         [Parameter(Mandatory=$false, Position=2)][int] $Days=-1
    )

    try {
        $SizeCleaned = $null
        $ExclusionDay = (Get-Date).AddDays($days)

        #Get-ChildItem $Path -Recurse -Force -File -Include @("*.zip", "*.log", "*.txt", "*.csv") | ForEach-Object{
        Get-ChildItem $Path -Recurse -Force -File -Include $Filters | ForEach-Object{
           #$filename = $_.name

            if ($_.LastWriteTime -lt $ExclusionDay){
                #"Older than x days - deleting" 
                
                if (Test-Path -Path $_.PSPath -PathType Leaf){
                    $SizeCleaned += (Get-ChildItem $_.PSPath -Force| Measure-Object Length -s).Sum
                } else {
                    $SizeCleaned += (Get-ChildItem $_.PSPath -Recurse -Force| Measure-Object Length -s).Sum
                }
                
                #Remove-Item $_.fullname -Recurse -Force

            }else{
                #"Less than x days old "
            }
        }	
    } catch {

    }

    $SizeCleaned = $SizeCleaned / 1MB
    return $SizeCleaned
}

function SwitchFolder {
    param (
        [Parameter(Mandatory=$true, Position=0)][string] $Selectedfolder
    )

    try {
        $UsernamePath = $HOME

        #Chamar funções de clean-up
        switch ($Selectedfolder) {
            "Prefetch" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path "C:\Windows\Prefetch" -Filters @("*")) +" MB Cleaned" }
            "AppData" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path $UsernamePath"\AppData\Roaming" -Filters @("*") -Days -360) +" MB Cleaned" }
            #"ProgramData" {$Label3.Text = '{0:N2}' -f (CleanUpFiles -Path "C:\ProgramData" -Filters @("*.log")) +" MB Cleaned" }
            "Chrome Cache" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path $UsernamePath"\AppData\Local\Google\Chrome\User Data\Default\Cache" -Filters @("*")) +" MB Cleaned" }
            "User Temp Files" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path $UsernamePath"\AppData\Local\Temp" -Filters @("*")) +" MB Cleaned" }
            "Windows Temp Files" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path "C:\Windows\Temp" -Filters @("*")) +" MB Cleaned" }
            "Temporary Installation Caches" { $Label3.Text = '{0:N2}' -f (CleanUpFiles -Path $UsernamePath"\AppData\Local\Package Cache" -Filters @("*")) +" MB Cleaned" }
            Default {$Label3.Text =  "No matches found!"}
        }
    } catch {
        $Label3.Text =  "Cleaning Failed"
    }
} 

#----------------------------------------------------------------

#Setting up the GUI interface
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Useful PowerShell Scripts'
$main_form.Width = 550
$main_form.Height = 200
$main_form.AutoSize = $true

#Adding a label before the dropdown box
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Available Folders:"
$Label.Location  = New-Object System.Drawing.Point(0,10)
$Label.AutoSize = $true
$main_form.Controls.Add($Label)

#Adding the available folders to Clean-up
$Dropdown = New-Object System.Windows.Forms.ComboBox
$Dropdown.Width = 300
$Folders = @("Prefetch", "AppData", "Chrome Cache", "User Temp Files", "Windows Temp Files", "Temporary Installation Caches")
Foreach ($Folder in $Folders){
    $Dropdown.Items.Add($Folder);
}
$Dropdown.Location  = New-Object System.Drawing.Point(100,10)
$main_form.Controls.Add($Dropdown)

#Label for the Clean status
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Status:"
$Label2.Location  = New-Object System.Drawing.Point(0,40)
$Label2.AutoSize = $true
$main_form.Controls.Add($Label2)
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = "Please select a folder and wait"
$Label3.Location  = New-Object System.Drawing.Point(50,40)
$Label3.AutoSize = $true
$main_form.Controls.Add($Label3) 

#Button to Confirm
$Button = New-Object System.Windows.Forms.Button
$Button.Location = New-Object System.Drawing.Size(410,10)
$Button.Size = New-Object System.Drawing.Size(120,20)
$Button.Text = "Clean"
$main_form.Controls.Add($Button)



#Button Click event
$Button.Add_Click({ SwitchFolder -Selectedfolder $Dropdown.selectedItem })















$main_form.ShowDialog()