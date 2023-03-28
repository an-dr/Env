# It is a basic Env template. For more information see: https://github.com/an-dr/Env

$host.ui.RawUI.WindowTitle = $(Get-Item -Path $(Get-Location)).BaseName # WindowsTitle is CWD name

function _Start
{
    Write-Output 'Nothing to Start. Overload this function inside $EnvDirName'
    Write-Output 'For details, see: https://github.com/an-dr/Env/wiki'
}

function _Go2Page
{
    Write-Output 'Tha function should be used for '
    Write-Output 'Overload this function inside $EnvDirName'
    Start-Process "https://github.com/an-dr/Env"
}
