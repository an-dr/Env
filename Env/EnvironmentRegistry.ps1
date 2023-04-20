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


class EnvironmentRegistry {
    static $EnvironmentTable = @{}
    
    static [EnvironmentRegistry] Instance() {
        throw "A static class. Cannot be instantiated!"
        return $null
    }
    
    static [void]Add([string]$EnvName, [string]$EnvPsm1Path, [bool]$Force){
        if (!$Force){
            
            if (!$EnvPsm1Path.EndsWith(".psm1")) {
                throw "Accepts only .psm1 files!"
            }
        
            if (!$(Test-Path $EnvPsm1Path -PathType Leaf)){
                throw "Cannot find a .psm1 file!"
            }
        }
        
        [EnvironmentRegistry]::EnvironmentTable.Add($EnvName, $EnvPsm1Path)
        
    }
        
    static [void]Add([string]$EnvName, [string]$EnvPsm1Path){
        [EnvironmentRegistry]::Add($EnvName, $EnvPsm1Path, $false)
    }
    
    
    static [void]Remove([string]$EnvName) {
        [EnvironmentRegistry]::EnvironmentTable.Remove($EnvName) 
    }
    
    static [bool]Contains([string]$EnvName){
        return [EnvironmentRegistry]::EnvironmentTable.Contains($EnvName) 
    }
    
    static [void]Clear(){
        [EnvironmentRegistry]::EnvironmentTable.Clear()
    }
    
    static [string]GetPsm1Path($EnvName){
        return [EnvironmentRegistry]::EnvironmentTable[$EnvName]
    }
    
    static [string]GetPsm1Root($EnvName){
        $psm1_path = [EnvironmentRegistry]::GetPsm1Path($EnvName)
        if (!$psm1_path){
            return ""
        }
        
        $psm1_item = Get-Item $psm1_path
        return $psm1_item.Parent
    }
    
}

# [EnvironmentRegistry]::Add("test","C:/Windows.psm1", 1)
# [EnvironmentRegistry]::Add("test1","C:/Users", 1)
# [EnvironmentRegistry]::GetPsm1Path("test1")
# [EnvironmentRegistry]::GetPsm1Root("test1")
# [EnvironmentRegistry]::Remove("test2")
# [EnvironmentRegistry]::Remove("test1")
