# Env

Env is representing a tool helping programmers to work with the different types of projects, switching their tools according to a project's specialty. Each set of that kind of tools referred to as an 'environment'

The heart of the project is the '.environment' folder. It contains scripts with functions, variables and other logic used at the project and also any other important for project files, like tool applications.

Env is mixing a flexible (but laconic) approach used by huge IDEs which encapsulate all their files into one folder and beautiful and simple (but extremely flexible) approach of '.env'-files (see: [direnv](https://direnv.net/))

Because of cross-platform support of Powershell Emv can be used at any development

## Getting-started

### Creating and setting up the environment

In the beginning, you need to create your environment. Open Powershell and navigate to the project folder (e.g. to root of your C++, Python or other projects)

Run 'Env-Init' to create a default environment. There will be created:

- '.environment' directory
- '.environment/init.ps1' script

The script contains basic functions that should be customized by you:

- '_Start' - intended to apply your environment variables and launch your favorite development tool.
- '_Go2page' - intended to open homepages of the project (for example, a pypi-page or a git-repository page)

Other functions are suggested to name starting with '_' to simply tell what is project specialty and what is global. But it is fully up to you.

### Working with your environment

There is two way to use the module:

- shell mode
- command mode

Both of them is accessible via 'Env' function

1. Shell mode will create a new process of Powershell with loaded scripts from the '.environment' folder. Go to your project directory and run 'Env' without a '-Code' argument. For exit to your parent shell without any environment use 'Exit'

Example:
'''
Env
….
'''

2. Command mode is loading your environment, executes the passed code and exiting. The mode can be used for example for launching your IDE in the specific mode or to build the project using your logic defined inside of the script at the environment-folder

Example:
'''
Env { _build }
'''

## Using with VS Code