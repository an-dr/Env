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

# TODO: create a set of tools for vertical (in the same folder) and 
# horisontal (up to the root) search by pattern 

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
