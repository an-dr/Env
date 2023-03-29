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


function Get-Environment {
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    if($global:PsEnvironmentName){
        return [System.Collections.ArrayList]$global:PsEnvironmentName.Split($sep)
    } else {
        return $null
    }
}

function Enable-Environment
{
    param(
        [parameter(Mandatory = $false)]
        [String]$Path
    )
    
    # Searching for the environment
    if (!$Path) { 
        $env = Find-DefaultEnvironment 
        "[INFO] Found environment: $env"
    } else {
        if(Test-Path $Path){
            $env = $Path
        }
    }
    
    $env_name = Split-Path $env -Leaf
    $env_file = "$env/$env_name.psm1"
    if (!$env -or !$(Test-Path $env_file))
    {
        "[ERROR] No environment found"
        return
    }
    
    Import-Module $env_file
    # $global:PsEnvironmentPath = Resolve-Path $env
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    
    # Workin with the env list
    $tmpEnvVar = "$global:PsEnvironmentName$sep$env_name" #temp PsEnvironmentName representation
    $env_list = $tmpEnvVar.Split($sep) | Sort-Object -Unique # make values uniqie in an Array
    # $env_list = $env_list | Where { $_ -and $_.Trim() } # clear empty elements
    $global:PsEnvironmentName = $($env_list -join $sep).TrimStart($sep)  # convert the array to the string and update the value
    "[DONE] Environment $env_name is enabled."

}

New-Alias -Name eenv -Value Enable-Environment

function Disable-Environment($name){
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    
    if($global:PsEnvironmentName){
        [System.Collections.ArrayList]$env_list = $global:PsEnvironmentName.Split($sep)
        # $env_list = $env_list.Re
    }
    if(!$env_list){
        "[ERROR] There is no enabled environment."
        return
    }
    
    # Check what to remove
    $to_remove = [System.Collections.ArrayList]::new()
    if (!$name){
        foreach ($el in $env_list) {
            $to_remove.Add($el)
        }
    } else {
        $to_remove = [System.Collections.ArrayList]@($name)
    }

    foreach ($env in $to_remove) {
        Remove-Module $env
        $env_list.Remove($env)
        "[DONE] Environment $env_name is disabled."
    }
    
    # Update the env var
    $tmpEnvVar = $env_list -join $sep
    if(!$tmpEnvVar){
        $global:PsEnvironmentName = $null  # delete the variable
    } else {
        $global:PsEnvironmentName = $tmpEnvVar
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
