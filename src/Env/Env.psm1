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


<#
.SYNOPSIS
Test is the directory contains an environment

.PARAMETER Dir
Input directory
#>
function [bool]Test-DirIsEnv($Dir) {
    $env_q = [EnvironmentHandle]::New($Dir)
    return $env_q.IsValid()
}


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
#>
function New-Environment ($Name) {
    if (!$Name) { $Name = [EnvironmentHandle]::DefaultEnvDirName }
    $env = [EnvironmentHandle]::new($Name)
    $env.Build()
    return $env.EnvironmentLocation
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
    
    if(!$Path){
        $Path = Join-Path $(Get-Location) $([EnvironmentHandle]::DefaultEnvDirName)
        "[INFO] The path is not provided. Used '$Path'"
    }
    
    $env_info = [EnvironmentHandle]::New($Path)
    
    if ($env_info.IsValid()){
        "[INFO] Found environment: $($env_info.EnvironmentLocation)"
    } else {
        "[ERROR] No environment found"
        return
    }
    
    $env_info.Enable()
    [EnvironmentRegistry]::Add($env_info.GetName(), $env_info.GetModulePath())
    "[DONE] Environment $env_name is enabled."
}

<#
.SYNOPSIS
Disables an environment with the provided name. If the name is not provided, used the default one - psenv

.PARAMETER Name
Name of an environment to disable
#> 
function Disable-Environment($Name){
    if(!$Name){
        "[INFO] The name is not provided. Used '$([EnvironmentHandle]::DefaultEnvDirName)'"
        $Name = [EnvironmentHandle]::DefaultEnvDirName
    }
    
    if (![EnvironmentRegistry]::Contains($Name)){
        "[ERROR] There is no enabled environment."
        return
    }
    
    $env_info = [EnvironmentHandle]::New($Name)
    if ($env_info.IsActive()) {
        $env_info.Disable()
    } else{
        "[WARNING] Environment is in the registry, but not enabled. `
        Probably disabled using Remove-Module."
    }
    
    [EnvironmentRegistry]::Remove($Name)
}
