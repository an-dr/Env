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

<#
.SYNOPSIS
Test is the directory contains an environment

.PARAMETER Dir
Input directory
#>
function Test-DirIsEnv($Dir) {
    $env_q = [EnvironmentHandle]::New($Dir)
    return $env_q.IsValid()
}


function Find-EnvironmentsInDirectory($Path) {
    if (!$Path){ $Path = Get-Location }
    $cur_dir = Get-ChildItem $Path -Directory
    
    [System.Collections.ArrayList]$FoundEnvironmens = @()
    
    foreach ($d in $cur_dir){
        $env_q = [EnvironmentHandle]::New($d)
        if ($env_q.IsValid()){
            $FoundEnvironmens.Add($env_q) > $null
        } 
    }
    return $FoundEnvironmens
}

function Find-EnvironmentsInBranch($Path) {
    if (!$Path){ $Path = Get-Location }
    
    [System.Collections.ArrayList]$LocationsToCheck = @()
    
    $cur_dir = Get-Item $Path
    $LocationsToCheck.Add($cur_dir)  > $null
    
    # Add all parents above the current directory
    while ("$cur_dir" -ne "$($(Get-Location).Drive.Root)") {
        $cur_dir = $cur_dir.parent
        $LocationsToCheck.Add($cur_dir) > $null
    }
    
    # Check envs in all directories
    [System.Collections.ArrayList]$FoundEnvironmens = @()
    foreach ($loc in $LocationsToCheck) {
        $new_env = Find-EnvironmentsInDirectory $loc
        $FoundEnvironmens += $new_env
    }
    return $FoundEnvironmens
}
