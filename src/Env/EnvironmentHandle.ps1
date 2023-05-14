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
    static $DefaultEnvModule = "psenv/psenv.psm1"
    static $DefaultModuleDirName = ".modules"
    
    [System.IO.DirectoryInfo] $EnvironmentLocation
    $LoadedModuleGuidTable = @{}
    
    EnvironmentHandle([String] $EnvironmentLocation) {
        [Environment]::CurrentDirectory = $pwd
        $this.EnvironmentLocation = [System.IO.Path]::GetFullPath("$EnvironmentLocation")
    }
    
    [string]ToString(){
        return $this.EnvironmentLocation.ToString()
    }
    
    [string]GetName(){
        return $this.EnvironmentLocation.BaseName
    }
    
    [string]GetMainModulePath(){
        $file_name = "$($this.GetName()).psm1"
        $path = Join-Path $this.EnvironmentLocation $file_name
        return "$path"
    }
    
    [string]GetModulesDir(){
        return Join-Path $this.EnvironmentLocation $this.DefaultModuleDirName
    }
    
    [string]GetPrefix(){
        return "$($this.GetName())_"
    }
    
    [void]Build(){
        if ($this.IsValid()){
            "[ERROR] Already created"
            return
        }
        New-Item -ItemType Directory `
                 -Path $this.EnvironmentLocation `
                 -ErrorAction SilentlyContinue
                 
        $new_env_file = New-Item -ItemType File -Path $this.GetMainModulePath()
        $template_tile = Join-Path $PSScriptRoot $([EnvironmentHandle]::DefaultEnvModule)
        $init_ps1_content = Get-Content $template_tile -Raw
        Add-Content $new_env_file $init_ps1_content
    }
    
    [bool]IsValid(){
        return Test-Path $($this.GetMainModulePath())
    }
    
    [bool]IsActive(){
        Write-Error "IsActive"
        $module = Get-Module $this.GetName()
        if ($module){
            $module_path = $module.Path.ToString()
            $this_env_path = $this.GetMainModulePath().ToString()
            Write-Error "[IsActive] module_path: $module_path"
            Write-Error "[IsActive] this_env_path: $this_env_path"
            return $module_path -eq $this_env_path
        }
        return $false
    }
    
    [void]LoadModules(){
        $module_list = $()
        foreach ($module in $module_list) {
            # TODO:
            #import-module $module -Prefix $this.GetPrefix()
            $module = $null
            $guid = $null
            $this.LoadedModuleGuidTable.Add($module, $guid)
        }
        
    }
    
    [void]UnloadModules(){
        Get-Module posh-git | Where-Object { $_.Prefix -eq $this.GetPrefix() }
    }
    
    [void]Enable(){
        if($this.IsActive()){
            "[ERROR] Already active"
            return
        }
        
        # Check that nothing is imported
        if($(Get-Module $this.GetName()))
        {   # Something with this name is imported! Let's check what
            if(!$this.IsActive()){
                "[ERROR] Another environment or module with the same name is already imported!"
                return
            }
        }
        Import-Module $($this.GetMainModulePath()) -Scope Global
        $this.LoadModules()
    }
    
    [void]Disable(){
        if($this.IsActive()){
            $this.UnloadModules()
            Remove-Module $this.GetName()
        }
    }
    
    [void]Clear(){
        if ($this.IsValid()) {
            #If exists
            Remove-Item -Recurse -Force $this.EnvironmentLocation
        }
    }
}
