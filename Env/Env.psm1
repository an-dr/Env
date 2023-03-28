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

function Enable-Environment
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Code,

        [parameter(Mandatory = $false)]
        [String]$Path

    )
    if (!$Path) { $Path = $(Get-Location) }
    $env = Test-Path -Path "$Path\$EnvDirName\*.ps1" # TODO move this check into $env_main_codeblock
    "Check: $(Get-Location)"
    if (!$env) # TODO move this check into $env_main_codeblock
    {
        if ("$(Get-Location)" -eq "$($(Get-Location).Drive.Root)"){
            # PWD is root
            Write-Verbose "No environment found"
            return
        } else {
            cd ..
            # echo "$(Join-Path $(Get-Location) "")"
            "No environment. Check next: $(Get-Location)"
            Env -Code $Code -Path $Path
        }
    }

    if ($Code)
    { EnvStart  -Path $Path -Code "$env_main_codeblock; $Code" }
    else
    { EnvStart  -Path $Path -Code "$env_main_codeblock" -NoExit }
}

New-Alias -Name eenv -Value Enable-Environment

function Disable-Environment{
    if($global:PSENV_NAME -and $global:PSENV_ENABLED)
    {
        exit
    }
}

function Global:Env-Load
{
    # $env = Test-Path -Path "$(Get-Location)\$EnvDirName\*.ps1" # TODO move this check into $env_main_codeblock
    # if (!$env) # TODO move this check into $env_main_codeblock
    # {
    #     Write-Verbose "No environment found"
    #     return
    # }
    Write-Output "Not implemented yet, WIP"; return
    Get-ChildItem ".\$EnvDirName\*.ps1" | ForEach-Object { . $_ }
    echo $apps2close
    Write-Output "Environment was loaded!"
}

function New-Environment
{
    $env = Test-Path -Path "$(Get-Location)\$EnvDirName\*.ps1"
    if ($env)
    {
        Write-Output "Already created an environment in $PWD/$EnvDirName".Replace("`\", "`/")
        return
    }
    New-Item -ItemType Directory -Path "$(Get-Location)\$EnvDirName" -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path "$(Get-Location)\$EnvDirName\init.ps1"
    $init_ps1_path = "$(Get-Location)\$EnvDirName\init.ps1"
    $init_ps1_content = Get-Content $PSScriptRoot/scripts/init.ps1 -Raw
    Add-Content $init_ps1_path $init_ps1_content
}
