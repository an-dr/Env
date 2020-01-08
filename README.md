# Env
Powershell module to simple setting up your environment from the .environment folder content

![Main picture](https://www.lucidchart.com/publicSegments/view/9f656aca-f10b-47ef-b834-badde3c3a2d9/image.png)

https://www.powershellgallery.com/packages/Env

## Installation

```powershell
Install-Module -Name Env
```

## Usage

#### A. Create

To create a new `.environment` folder:

```powershell
Env-Init
```

#### B. Open

To open an `.environment` folder:

```powershell
Env-Open
```

#### C. Edit

Create scripts that should be executed at your environment

Functions and variable will be loaded, other code will be executed, i.e. scripts will dot-sourced

(see: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scripts?view=powershell-6#script-scope-and-dot-sourcing)

#### D. Run

To run you environment:

```powershell
Env
```

#### E. Finish

To exit from your Environment input `exit`.

## License

This file is licensed under the terms of the MIT license.

For a copy, see: [LICENSE](LICENSE)

- site:    https://agramakov.me
- e-mail:  mail@agramakov.me
