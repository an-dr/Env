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
    
    static Add([string]$Name, [string]$Path){
        if ([EnvironmentRegistry]::EnvironmentTable[$Name]){
            throw "The environment $Name already exists"
        }
        [EnvironmentRegistry]::EnvironmentTable[$Name] = $Path
        
    }
}

[EnvironmentRegistry]::Add("test","C:/test")
[EnvironmentRegistry]::Add("test1","C:/test1")
