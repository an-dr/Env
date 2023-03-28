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

# =============================================================================
# Imports
# =============================================================================
. $PSScriptRoot/strings.ps1


# =============================================================================
# Private stuff
# =============================================================================

function Get-PSExecName
{

    if ($PSVersionTable.PSVersion.Major -gt 5)
    {
        $ps_exe = "pwsh"
        if ($IsWindows) { $ps_exe += ".exe" }
    }
    else { $ps_exe = "powershell.exe" }
    return $ps_exe
}

function EnvStart
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Code,

        [parameter(Mandatory = $false)]
        [String]$Path,

        [parameter(Mandatory = $false)]
        [Switch]$NoExit
    )

    if (!$Path) { $Path = $(Get-Location) }

    $start_args = @()
    $start_args += "-NoLogo"

    #adding a command key
    if ($NoExit)
    { $start_args += "-NoExit", "-Command", "'`n> PS Subprocess with the Environment`n> =============started==============`n';" }
    else
    { $start_args += "-Command" }

    #adding a command
    if ($Code -and ($Code) -ne "")
    { $start_args += $Code }
    Start-Process -NoNewWindow -Wait -FilePath $(Get-PSExecName) -ArgumentList $start_args -WorkingDirectory $Path
    "`n> =============closed===============`n> PS Subprocess with the Environment`n"
}


# =============================================================================
# Public
# =============================================================================

function Find-DefaultEnvironment 
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Path
    )
    
    while ("$(Get-Location)" -ne "$($(Get-Location).Drive.Root)") {
        $path = "$(Get-Location)/$EnvDirName/$EnvDirName.psm1"
        if (Test-Path -Path $path) {
            return Split-Path $path
        } else {
            Set-Location ..
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
    if ($Path -eq $null) { 
        $env = Find-DefaultEnvironment 
    } else {
        if(Test-Path $Path){
            $env = $Path
        }
    }
    
    if ($env -eq $null)
    {
        $env_name = Split-Path $env -Leaf
        $global:PsEnvironment = Resolve-Path $env
        Import-Module "$env/$env_name.psm1"
    } else {
        "No environment found"
    }

}

New-Alias -Name eenv -Value Enable-Environment

function Disable-Environment{
    if($global:PSENV_NAME -and $global:PSENV_ENABLED)
    {
        exit
    }
}



function New-Environment ($Name)
{
    if (!$Name) { $Name = $EnvDirName }
    
    $env = Test-Path -Path "$(Get-Location)/$Name"
    if ($env) {
        Write-Output "Already created an environment in $PWD/$Name".Replace("`\", "`/")
        return
    }
    New-Item -ItemType Directory -Path "$(Get-Location)\$Name"
    
    $new_env_file = "$(Get-Location)/$Name/$Name.psm1"
    New-Item -ItemType File -Path $new_env_file
    $init_ps1_content = Get-Content $PSScriptRoot/scripts/init.psm1 -Raw
    Add-Content $new_env_file $init_ps1_content
}
