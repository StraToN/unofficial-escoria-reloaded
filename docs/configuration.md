# Game configuration

Aside from the common [Godot project settings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html), Escoria includes some special settings to configuration the Escoria components. These settings can be found in the "Escoria"-section in the project settings:

| Section  | Setting               | Description                                                  |
| -------- | --------------------- | ------------------------------------------------------------ |
| Main     | Game Start Script     | ESC-script that will be executed when the game starts        |
|          | Force Quit            | Allow quitting the game using the operating system's quit commands (Alt-F4 on Windows, Cmd-Q on macOS, etc.) |
| Debug    | Terminate On Warnings | If an Escoria warning is received, quit the game             |
|          | Terminate On Errors   | If an Escoria error is received, quit the game               |
|          | Development Lang      | Basic language the game is developed in. Useful for translation management |
| Ui       | Tooltip Follows Mouse | The tooltips for items in the scene follows the mouse cursor (used e.g. for mouse cursor icons UI) |
|          | Dialogs Folder        | Folder containing all the dialogs                            |
|          | Default Dialog Scene  | The scene used for dialogs                                   |
|          | Main Menu Scene       | The scene used for menus                                     |
|          | Pause Menu Scene      | The scene used when the game is paused                       |
|          | Game Scene            | The game UI used                                             |
| Sound    | Music Volume          | The volume used for music                                    |
|          | Sound Volume          | The volume used for sound                                    |
| Platform | Skip Cache            | Wether to skip caching scenes. Some platforms might not have the enough amount of memory required for this (e.g. mobile platforms) and should have this setting set to true for their respective targets |

