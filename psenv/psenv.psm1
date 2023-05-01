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

function Publish-Env{
    Publish-Module -Path $PSScriptRoot/../src/Env -NuGetApiKey $MyNuGetApiKey
}

Export-ModuleMember -Function * -Variable *
