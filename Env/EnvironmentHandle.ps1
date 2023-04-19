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


class EnvironmentHandle {
    static $DefaultEnvDirName = "psenv"
    static $DefaultEnvModule = "$global:PSScriptRoot/scripts/template.psm1"
    
    [System.IO.DirectoryInfo] $EnvironmentLocation
    
    EnvironmentHandle([String] $Path) {
        [Environment]::CurrentDirectory = $pwd
        $this.EnvironmentLocation = [System.IO.Path]::GetFullPath("$Path")
    }
    
    [string]ToString(){
        return $this.EnvironmentLocation.ToString()
    }
    
    [string]GetName(){
        return $this.EnvironmentLocation.BaseName
    }
    
    [string]GetModulePath(){
        $file_name = "$($this.GetName()).psm1"
        $path = Join-Path $this.EnvironmentLocation $file_name
        return "$path"
    }
    
    [void]Build(){
        if ($this.IsValid()){
            "[ERROR] Already created"
            return
        }
        "test: $([EnvironmentHandle]::DefaultEnvDirName)"
        New-Item -ItemType Directory `
            -Path $this.EnvironmentLocation `
            -ErrorAction SilentlyContinue
                 
        $new_env_file = New-Item -ItemType File -Path $this.GetModulePath()
        $init_ps1_content = Get-Content "$([EnvironmentHandle]::DefaultEnvModule)" -Raw
        Add-Content $new_env_file $init_ps1_content
    }
    
    [bool]IsValid(){
        return Test-Path $($this.GetModulePath())
    }
    
    [void]Clear(){
        if ($this.IsValid())
        {
            #If exists
            Remove-Item -Recurse -Force $this.EnvironmentLocation
        }
    }
}
