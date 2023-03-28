$EnvDirName = ".psenv"


$env_main_codeblock = @"

Get-ChildItem `".\$EnvDirName\*.ps1`" | ForEach-Object { . `$_ };
Set-Variable -Name "EnvRootDir" -Value $(Get-Location)
`$PSENV_NAME = Split-Path `$(Get-Location) -Leaf
`$PSENV_ENABLED = `$true
"@

$env_std_funcs = Get-Content -Path "$PSScriptRoot/env_standard_funcs.ps1" -Raw
