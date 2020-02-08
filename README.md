# Env

<img src="assets/logo.png" width="250">

Powershell module to simple setting up your environment from the .environment folder content

[@PowershellGallery](https://www.powershellgallery.com/packages/Env)

## Installation

```powershell
Install-Module -Name Env
```

## Usage

<img src="assets/schematic_main.png" width="350">

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

This work is licensed under the terms of the MIT license.

For a copy, see: [LICENSE](LICENSE)

- site:    https://agramakov.me
- e-mail:  mail@agramakov.me

## Support

If you will decide to sopport me, you can send some pretty words on my email or just use the link

[Buy me a cup of tea](https://paypal.me/4ndr/1eur)

Any ammount will motivate me to develop the project. Thanks in advance!

## Todo

[Trello card](https://trello.com/c/A0mWkOqy/1-env-todo)