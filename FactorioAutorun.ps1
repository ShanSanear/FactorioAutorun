param(
    [ValidateScript({
        if (Test-Path $_ -PathType ‘Leaf’) {
            return $True
        }
        else {
            Throw "Incorrect execution file path: ${_}"
        }
    })]
    [Parameter(Mandatory = $true)][String][Alias('SteamExe')] $Exe,

    [ValidateScript({
        if (Test-Path $_ -PathType ‘Container’) {
            return $True
        } 
        else {
            throw  "Incorrect path to save folder: ${_}"
        }
    })]
    [Parameter(ParameterSetName='SaveFromFile')][String] $SaveFolder,

    [switch] $SelectSave,
    [switch] $Multiplayer,
    [Parameter(ParameterSetName='JoinGame')][String] $HostIP
)

# Based on https://thomasrayner.ca/open-file-dialog-box-in-powershell/
Function Get-FileName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Save file (*.zip)| *.zip"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$ExePath = Get-ChildItem $Exe.ToLower()
$FactorioAppID = 427520

if ($ExePath.Name.Contains("steam.exe")) {
    $ExeRun = "$($ExePath.FullName) -applaunch $FactorioAppID"
} 
elseif ($ExePath.Name.Contains("factorio.exe")) {
    $ExeRun = $ExePath.FullName
}
else {
    Write-Error "Incorrect exe file name: $($ExePath.FullName). Select either factorio.exe or steam.exe"
    Exit
}

$Saves = Get-ChildItem $SaveFolder

if ($SelectSave) {
    $SelectedSave = Get-FileName -InitialDirectory $SaveFolder
    $SaveToLoad = $SelectedSave
}
else {
    $LastSave = $Saves | sort LastWriteTime | select -last 1
    $SaveToLoad = $LastSave.FullName
}

if ($Multiplayer) {
    if ($HostIP -ne "") {
        $ExeParameters = "--mp-connect $HostIP --no-log-rotation"
    }
    else {
        $ExeParameters = "--start-server $SaveToLoad --no-log-rotation"
    }
} 
else {
    $ExeParameters = "--load-game $SaveToLoad"
}

Start-Process $ExeRun $ExeParameters
