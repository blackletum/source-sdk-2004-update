# Source SDK 2004 Update

Lightly updated version of the original Half-Life 2/Source SDK 2004 base.

Original project: [blackletum/source-sdk-2004](https://github.com/blackletum/source-sdk-2004)

### Changes
- Integrated VPC system
- Generates up-to-date `.sln` / project files (Windows only, at the moment)
- Fixed various issues so the codebase compiles under Visual Studio 2022

### Building
1. Run the VPC scripts to generate the solution files
2. Open the generated `.sln` in Visual Studio 2022
3. Build
4. Pray

More detailed build instructions may be added later.

# Dev branch

This dev branch is for my own changes to the base 2004 code to make things work with the 2006 SDK on Steam. 

This utilizes the 2006 SDK game files from this repository:

https://github.com/blackletum/source-sdk-2006

If you happen to be wanting to use this to work on the 2004 source code, be aware that everything builds to the `hl2` folder, but you cannot have a sourcemod folder named `hl2`. 