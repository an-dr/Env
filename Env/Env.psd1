@{

# Script module or binary module file associated with this manifest.
RootModule = 'Env.psm1'

# Version number of this module.
ModuleVersion = '1.0.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '641738e9-cf67-4541-bec2-89767b92a7f3'

# Author of this module
Author = 'an-dr'

# Copyright statement for this module
Copyright = 'MIT'

# Description of the functionality provided by this module
Description = 'Creates a Powershell process with an environment with dot-sourced content from the .environment folder.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.0'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("dotenv", ".env", "set-psenv", "psenv", "direnv", "env", "environment")

        # A URL to the license for this module.
        LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/an-dr/Env'

        # ReleaseNotes of this module
        ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

}
