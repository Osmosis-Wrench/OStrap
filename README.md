# OStrap
 An OStim Addon that adds modular Strap-on support.
 ![OStim Build Status](https://github.com/Osmosis-Wrench/OStrap/actions/workflows/main.yml/badge.svg)
## Features
 - Includes several pre-packaged strapons, pulling from leito's Skyrim Strapons.
 - Automatic detection of Ostim scenes.
 - Strap-on Randomization.
 - Can apply strap-ons to both NPC's and and the Player.
 - Supports modular, JSON based compatibility patches to allow for easily adding more options.
 - OCum support.
 - MCM Setting saving, and extra loading functionality for Modlist authors.
 - Support includes options for both CBBE and UNP (1.1+)
### Requirements
 - Skyrim: Special Edition (1.5.39+)
 - [Ostim SE](https://github.com/Sairion350/OStim) (and all its requirements.)
### Downloading
 Most recent version will be in the [Releases](https://github.com/Osmosis-Wrench/OStrap/releases) section of the GitHub page.
 Eventually it will be posted to LoversLab and ?Nexus?
### Included Compatibility Files
If any of the following mods are installed, they will appear in the OStrap MCM as options. If you don't see them, press the "Reload Compats" option.
 - [Flower Girls SE](https://www.nexusmods.com/skyrimspecialedition/mods/5941)
 - [Futanari CBBE - SSE](https://www.loverslab.com/files/file/11344-sos-addon-futanari-cbbe-sse/)
 - [Equipable Horse Cocks - SSE](https://www.loverslab.com/files/file/9903-sos-equipable-horse-cocks-sse-port/)

## Intended Features / Future Plans
- Rewrite current JContainers logic to use JDB rather than raw file loads.
- Work out how to implement F/M scenes.

## Known Issues:
Will equip a strapon in all F/F scenes, even ones that don't make a heap of sense like kissing or fingering.

## Contributing
Feel free to fork and make a PR if you feel you have something to add or improve.

## Issues and Suggestions
If you notice any bugs, or have any feature suggestions, create an Issue and outline the problem and I'll take a look.  
  
**Unless it's to ask for a LE port, *I'm not gonna do that*, Sorry.** If you want an LE port, fork this and make your own.

## Compatibility Patches.
OStrap will load any .Json file in \Data\OStrapData\OStrapCompat\ and try and add the files to the Strap-on list.
  
Compatibility patches should be formatted like so:
  
```Json
{
  "Example Strapon": {
    "Enabled": 0,
    "Form": "__formData|Example.esp|0x5e61",
    "OptID": 0
  },
    "Another Example Strapon": {
    "Enabled": 0,
    "Form": "__formData|Example.esp|0x5e62",
    "OptID": 0
  }
}
```
Breaking down what a record looks like:

  ``"Example Strapon"`` <-- This is the name of the strap-on for the MCM. This can be whatever you want.  
  ``"Enabled": 0`` <-- This is whether the strap-on will be enabled by defualt or not.  
  ``"Form": "__formData|Example.esp|0x5e61"`` <-- This is the formData for the armor record. Further info below.  
  ``"OptID": 0`` <-- This is the optionID for its location in the MCM. Just leave this zero and it'll be sorted out automatically.  

### Understanding formData records.
1. Starting at the begining, all formData records start with ``__formData|``
2. The middle section is the name of the mod file you are pulling the strap-on from.
3. The last section is the FormID of the specific Armor record, with the first two bits removed and then all preceeding zeros dropped.
4. So for example, the FormID ``03005E63`` will lose the first two bits and become ``005E63``.
5. Then the preceeding zeros are droped and it becomes ``5E63``
6. Finally add ``0x`` to the begining of the record ``0x5E63`` to indicate that it's in Hex, and you've converted the FormID to a formData record.
