
$RepoRoot = "$PSScriptRoot/.."
$WorkingDir = "$env:TEMP/tests_env"
$TesEnvName = "env_$(New-Guid)"


function Setup {
    Remove-Module Env -Force -ErrorAction SilentlyContinue
    Import-Module $RepoRoot/src/Env -Scope Global -ErrorAction SilentlyContinue
}

function Teardown {
    Remove-Item -Path $WorkingDir -Recurse -Force -ErrorAction SilentlyContinue
}

function Test-Smoke {
    New-Item $WorkingDir -ItemType Directory
    Set-Location $WorkingDir
    New-Environment $TesEnvName
    
    Enable-Environment "$WorkingDir/$TesEnvName"
    
    $result = $(Get-Environment).Values
    if ($result.Replace("\", "/") -ne "$WorkingDir/$TesEnvName/$TesEnvName.psm1".Replace("\", "/")) {
        return "result -ne $WorkingDir/$TesEnvName/$TesEnvName.psm1"}
    
    
    $result = Hello
    if ($result -ne "Hello World!") {return "result -ne Hello World"}
    
    $result = Test-DirIsEnv "$WorkingDir/$TesEnvName"
    if ($result -ne $true) {return "result -ne $true"}
    
    Disable-Environment $TesEnvName
    $result = $(Get-Environment).Values
    if ($result -ne $null) {return "result -ne $null"}
    
}


Setup
Test-Smoke
Teardown
