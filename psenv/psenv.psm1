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

$EnvRepoRoot = Resolve-Path "$PSScriptRoot/.."
$EnvModulePath = Join-Path $(Join-Path $EnvRepoRoot "src") "Env"
$EnvTestsPath = Join-Path $EnvRepoRoot "tests"

function Publish-Env{
    Publish-Module -Path $EnvModulePath -NuGetApiKey $MyNuGetApiKey
}

function Test-Env{
    . $EnvTestsPath/test_smoke.ps1
}

Export-ModuleMember -Function * -Variable *
