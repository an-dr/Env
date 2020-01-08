# Env
Powershell module to simple setting up your environment from the .environment folder content

![Main picture](https://www.lucidchart.com/publicSegments/view/9f656aca-f10b-47ef-b834-badde3c3a2d9/image.png)

https://www.powershellgallery.com/packages/Env

## Usage

A. To create a new `.environment` folder:

```powershell
Env-Init
```

B. To open an `.environment` folder:

```powershell
Env-Open
```

C. Create scripts that should be executed at your environment. Functions and variable will be loaded, other code will be executed, i.e. scripts will dot-sourced
(see: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-6#script-scope-and-dot-sourcing)

D. Run you environment:

```powershell
Env
```

E. To exit from your environment input `exit`.

## Installation

```powershell
Install-Module -Name Env
```
