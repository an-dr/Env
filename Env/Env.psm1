<#
.Synopsis
Creates a Powershell process with an environment with dot-sourced content from the .environment folder.

.Description
To use it create a folder caled .environment and fulfill by your content to setup the environment.
Calling Env at the folder with a .environment folder will create a new Powershell process and dot source
everything that exists at the .environment folder

.Example
PS > Env  - Will create a new console at the same window

PS > Env "some PS code to execute"   - Will create a new console, execute the code and exit

#>

# Imports
. $PSScriptRoot/strings.ps1

function Find-Environment($Path)
{
    if(!$Path){ $Path = Get-Location}
    $dirs = Get-ChildItem -Path $Path -Directory
    foreach ($dir in $dirs) {
        $dir_name =  $dir.Name
        if (Test-Path "$dir/$dir_name.psm1")
        {
            return $dir
        } else {
            "Not found"
            return $null
        }
    }
}

function Find-DefaultEnvironment 
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Path
    )
    $cur_dir = Get-Item $(Get-Location)
    while ($cur_dir -ne "$($(Get-Location).Drive.Root)")
    {
        $path = "$cur_dir/$EnvDirName/$EnvDirName.psm1"
        if (Test-Path -Path $path) {
            return Split-Path $path
        } else {
            $cur_dir = $cur_dir.parent
        }
    }
    return $null
}


function Enable-Environment
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Path
    )
    
    if ($global:PsEnvironmentPath -and $global:PsEnvironmentName){
        "[ERROR] Another environment ($global:PsEnvironmentPath) is enabled!"
        return
    }
    
    # Searching for the environment
    if (!$Path) { 
        $env = Find-DefaultEnvironment 
        "[INFO] Found environment: $env"
    } else {
        "Path is $Path"
        if(Test-Path $Path){
            "Path exists"
            $env = $Path
        }
    }
    
    if (!$env)
    {
        "[ERROR] No environment found"
        return
    }
    
    $env_name = Split-Path $env -Leaf
    Import-Module "$env/$env_name.psm1"
    $global:PsEnvironmentPath = Resolve-Path $env
    $global:PsEnvironmentName = $env_name
    "[DONE] Environment $env_name is enabled."

}

New-Alias -Name eenv -Value Enable-Environment

function Disable-Environment{
    if($global:PsEnvironmentPath -and $global:PsEnvironmentName)
    {
        Remove-Module $global:PsEnvironmentName
        $global:PsEnvironmentPath = $null
        $global:PsEnvironmentName = $null
        "[DONE] Environment $env_name is disabled."
    } else {
        "[ERROR] There is no enabled environment."
    }
}

function New-Environment ($Name)
{
    if (!$Name) { $Name = $EnvDirName }
    
    $env = Test-Path -Path "$(Get-Location)/$Name"
    if ($env) {
        Write-Output "[ERROR] Already created an environment in $PWD/$Name".Replace("`\", "`/")
        return
    }
    New-Item -ItemType Directory -Path "$(Get-Location)\$Name"
    
    $new_env_file = "$(Get-Location)/$Name/$Name.psm1"
    New-Item -ItemType File -Path $new_env_file
    $init_ps1_content = Get-Content $PSScriptRoot/scripts/init.psm1 -Raw
    Add-Content $new_env_file $init_ps1_content
}
