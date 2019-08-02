param(
    [Parameter(Mandatory = $true)][String] $SteamExe,
    [Parameter(Mandatory = $true, ParameterSetName='SaveLoadType')][String] $SaveFolder
)
$FactorioAppID = 427520

$Saves = Get-ChildItem -Path $SaveFolder

$LastSave = $Saves | sort LastWriteTime | select -last 1

& $SteamExe -applaunch $FactorioAppID --load-game $LastSave.FullName
