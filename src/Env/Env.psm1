# *************************************************************************
#
# Copyright (c) 2023 Andrei Gramakov. All rights reserved.
#
# This file is licensed under the terms of the MIT license.  
# For a copy, see: https://opensource.org/licenses/MIT
#
# site:    https://agramakov.me
# e-mail:  mail@agramakov.me
#
# *************************************************************************

. $PSScriptRoot/EnvironmentHandle.ps1
. $PSScriptRoot/EnvironmentRegistry.ps1
. $PSScriptRoot/FindTools.ps1


<#
.SYNOPSIS
Returns a table with all active environments
#>
function Get-Environment {
    return [EnvironmentRegistry]::EnvironmentTable
}


<#
.SYNOPSIS
Creates a new environment and returns a DirectoryInfo object

.PARAMETER Name
Name of the a environment

.PARAMETER $Path
In which directory the environment will be created
#>
function New-Environment ($Name, $Path) {
    if (!$Name) { $Name = [EnvironmentHandle]::DefaultEnvDirName }
    if (!$Path) { $Path = Get-Location }
    $env = [EnvironmentHandle]::new($(Join-Path $Path $Name))
    $env.Build()
    return $env.EnvironmentLocation
}


# PRIVATE
function Select-Environment($EnvironmentHandleList){
    
    [System.Collections.ArrayList]$EnvTable = @()
    $i = 1
    foreach ($e in $EnvironmentHandleList){
        $EnvTable.Add([PSCustomObject]@{N = $i; Location = $e.EnvironmentLocation }) > $null
        $i += 1
    }
    
    if ($EnvTable.Count -gt 1) {
        Write-Host "[INFO] Found several environments. Specify the environment to Enable..."
        $EnvTable | Format-Table | Out-Host
        $selected_n = Read-Host -Prompt "Write an environment number: "
    } elseif ($EnvTable.Count -eq 1) {
        $selected_n = 1
    }
    
    $selected = $EnvTable | where N -EQ  $selected_n
    return $selected[0].Location
    
}


<#
.SYNOPSIS
Enables an environment with the provided name. If the name is not provided, used the default one - psenv

.PARAMETER Name
Name of an environment to enable
#> 
function Enable-Environment {
    param(
        [parameter(Mandatory = $false)]
        [String]$Path
    )
    
    if (!$Path){
        $envs = Find-EnvironmentsInBranch
        if($envs){
            $Path = Select-Environment $envs
        }
        if(!$Path)
        {
            "[ERROR] No environment found"
            return
        }
        "[INFO] Selected: $Path"
    }
    
    if ($Path){
        $env_info = [EnvironmentHandle]::New($Path)
        $env_is_valid = $env_info.IsValid()
    }
    
    $env_name = $env_info.GetName()
    if (Get-Module $env_name){
        "[ERROR] $env_name is already enabled!"
        return
    }
    
    if (!$env_is_valid){
        "[ERROR] No environment found"
        return
    }
    
    "[INFO] Enabling environment: $($env_info.EnvironmentLocation)"
    $env_info.Enable()
    [EnvironmentRegistry]::Add($env_name, $env_info.GetMainModulePath())
    "[DONE] Environment $env_name is enabled."
}


# PRIVATE
function Get-EnabledEnvironments{
    [System.Collections.ArrayList]$EnabledEnvs = @()
    "$([EnvironmentRegistry]::EnvironmentTable.Values)"
    foreach ($env_module in [EnvironmentRegistry]::EnvironmentTable.Values) {
        $env_path = Get-Item $env_module
        $e = [EnvironmentHandle]::New($env_path.Directory)
        $EnabledEnvs.Add($e) > $null
    }
    return $EnabledEnvs
}

<#
.SYNOPSIS
Disables an environment with the provided name. If the name is not provided, used the default one - psenv

.PARAMETER Name
Name of an environment to disable
#> 
function Disable-Environment($Name){
    if ([EnvironmentRegistry]::EnvironmentTable.Count -eq 0) {
        "[ERROR] No enabled environments."
        return
    }
    
    if (!$Name){
        "[ERROR] The name is not provided. Curretly active environments:"
        return Get-Environment
    }
    
    if (![EnvironmentRegistry]::Contains($Name)){
        "[ERROR] The environment is not enabled."
        return
    }
    
    $e_path = [EnvironmentRegistry]::GetPsm1Root($Name)
    $e = [EnvironmentHandle]::New($e_path)
    $e.Disable()
    
    [EnvironmentRegistry]::Remove($Name)
    "[DONE] Environment $Name is disabled."
}


function Add-EnvironmentModule ($EnvironmentPath, $Module) {
    $e = [EnvironmentHandle]::New($EnvironmentPath)
    if (!$e.IsValid()){
        "[ERROR] Not an environment."
        return
    }
    New-Item $e.GetModulesDir() -Force -ItemType Directory
    Save-Module $Module -Path $e.GetModulesDir()
}

function Remove-EnvironmentModule ($EnvironmentPath, $Module) {
    $e = [EnvironmentHandle]::New($EnvironmentPath)
    if (!$e.IsValid()){
        "[ERROR] Not an environment."
        return
    }
    $imported = Get-Module $Module | Where-Object { $_.Prefix -eq $this.GetName() }
    Remove-Item $(Join-Path "$modules_dir" "$Module") -Recurse -Force
    
}

function Get-EnvironmentModules ($EnvironmentPath) {
    $e = [EnvironmentHandle]::New($EnvironmentPath)
    if (!$e.IsValid()){
        "[ERROR] Not an environment."
        return
    }
    return $e.GetModules()
}

function Get-EnvironmentId ($Environment){
    $env_path = [EnvironmentRegistry]::GetPsm1Root($Environment)
    $e = [EnvironmentHandle]::New($env_path)
    return $e.GetGuid()
}
