# It is a basic Env template. Modify it as you want. All functions and variables will be accessible after
# environment activation via:
#
# `Enable-Environment $EnvironmentName`
#
# For more information see: https://github.com/an-dr/Env

$Greeting = "Hello"

function Hello([string]$What) {
    if(!$What)
    {
        $What = "World"
    }
    "$Greeting $What!"
}
