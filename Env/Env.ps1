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

. $PSScriptRoot/EnvironmentHandle.ps1

function Get-EnvModulePath($EnvParentDir, $EnvName){
    $env_dir = Join-Path $EnvParentDir $EnvName
    $env_module = Join-Path $env_dir "$EnvName.psm1"
    return $env_module
}


function Test-DirIsEnv($Dir) {
    $env_q = [EnvironmentHandle]::New($Dir)
    return $env_q.IsValid()
}

function Test-IsEnvWithName($EnvParentDir, $EnvName) {
    $env_module = Get-EnvModulePath $EnvParentDir $EnvName
    if ($env_module){
        return Test-Path $env_module
    } else {
        return $false
    }
}

function Find-Environment($Path) {
    if (!$Path){ $Path = Get-Location }
    $dirs = Get-ChildItem -Path $Path -Directory
    foreach ($dir in $dirs) {
        if (Test-DirIsEnv $dir) {
            return $dir
        }
    }
    return $null
}

function Find-Environments($Path) {
    if (!$Path){ $Path = Get-Location }
    $cur_dir = Get-Item $Path
    
    # A container for results
    $envs = [System.Collections.ArrayList]@()
    
    # Check all from $Path to the very root
    while ("$cur_dir" -ne "$($(Get-Location).Drive.Root)") {
        # check folders here
        $dirs = Get-ChildItem -Path $cur_dir -Directory
        foreach ($dir in $dirs) {
            $env_q = [EnvironmentHandle]::New($dir.FullName)
            if ($env_q.IsValid()) {
                $envs.Add($env_q) > $null
            }
        }
        
        # Go up
        $cur_dir = $cur_dir.parent
    }
    
    return $envs
}

function Find-DefaultEnvironment {
    param(
        [parameter(Mandatory = $false)]
        [String]$StartPath
    )
    
    if (!$StartPath){ $StartPath = Get-Location }
    
    $cur_dir = Get-Item $StartPath
    while ("$cur_dir" -ne "$($(Get-Location).Drive.Root)") {
        if (Test-IsEnvWithName $cur_dir [EnvironmentHandle]::DefaultEnvDirName) {
            return Get-Item "$cur_dir/$([EnvironmentHandle]::DefaultEnvDirName)"
        }
        
        # Go up
        $cur_dir = $cur_dir.parent
    }
    return $null
}

function Get-Environment {
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    if ($global:PsEnvironmentName){
        return [System.Collections.ArrayList]$global:PsEnvironmentName.Split($sep)
    } else {
        return $null
    }
}

function Enable-Environment {
    param(
        [parameter(Mandatory = $false)]
        [String]$Path,
        
        [parameter(Mandatory = $false)]
        [Switch]$VerboseOutput
    )
    
    # Searching for the environment
    
    if (!$Path) { 
        # No argument - search here
        $env = Find-DefaultEnvironment
        if (!$env){
            $env = Find-Environment
        }
    } else {
        # Search by path
        
        if(Test-DirIsEnv $Path){
            # Provided the env
            $env = $Path
        } else {
            # Provided a path with possible env
            $env = Find-Environment $Path
        }
        
    }
    
    if ($env){
        "[INFO] Found environment: $env"
    } else {
        "[ERROR] No environment found"
        return
    }
    
    $env_info = [EnvironmentHandle]::New($env)
    
    $env_name = $env_info.GetName()
    $env_file = $env_info.GetModulePath()
    
    Import-Module $env_file -Scope Global -Verbose:$VerboseOutput
    
    # Workin with the env list
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    $tmpEnvVar = "$global:PsEnvironmentName$sep$env_name" #temp PsEnvironmentName representation
    $env_list = $tmpEnvVar.Split($sep) | Sort-Object -Unique # make values uniqie in an Array
    $global:PsEnvironmentName = $($env_list -join $sep).TrimStart($sep)  # convert the array to the string and update the value
    "[DONE] Environment $env_name is enabled."
}


function Disable-Environment($name){
    $sep = [IO.Path]::PathSeparator # ; or : depending on the platform
    
    if ($global:PsEnvironmentName){
        [System.Collections.ArrayList]$env_list = $global:PsEnvironmentName.Split($sep)
        # $env_list = $env_list.Re
    }
    if (!$env_list){
        "[ERROR] There is no enabled environment."
        return $null
    }
    
    # Check what to remove
    $to_remove = [System.Collections.ArrayList]::new()
    if (!$name){
        foreach ($el in $env_list) {
            $to_remove.Add($el) > $null
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
    if (!$tmpEnvVar){
        $global:PsEnvironmentName = $null  # delete the variable
    } else {
        $global:PsEnvironmentName = $tmpEnvVar
    }
}

function New-Environment ($Name) {
    if (!$Name) { $Name = [EnvironmentHandle]::DefaultEnvDirName }
    $env = [EnvironmentHandle]::new($Name)
    $env.Build()
    return $env
}

# New-Alias -Name eenv -Value Enable-Environment


cd C:\Users\dongr\Desktop

$e_test = New-Environment "test"
Test-DirIsEnv ./test
Find-Environment .
Enable-Environment "test"

$e_def = New-Environment
Enable-Environment


Disable-Environment "test"
$e_test.Clear()

Disable-Environment
$e_def.Clear()
