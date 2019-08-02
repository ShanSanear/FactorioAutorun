param(
    [Parameter(Mandatory = $true)][String] $SteamExe,
    [Parameter(Mandatory = $true, ParameterSetName='SaveLoadType')][String] $SaveFolder,
    [switch] $SelectSave = $false
)
# Based on https://thomasrayner.ca/open-file-dialog-box-in-powershell/
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Save file (*.zip)| *.zip"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$FactorioAppID = 427520

$Saves = Get-ChildItem -Path $SaveFolder

if ($SelectSave) {
    $SelectedSave = Get-FileName -InitialDirectory $SaveFolder
    $SaveToLoad = $SelectedSave
}
else {
    $LastSave = $Saves | sort LastWriteTime | select -last 1
    $SaveToLoad = $LastSave.FullName
}



& $SteamExe -applaunch $FactorioAppID --load-game $SaveToLoad
