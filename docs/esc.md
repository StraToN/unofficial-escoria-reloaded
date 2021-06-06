# ESC language documentation

## Objects

### Global IDs

All objects in the game have a global ID, which is used to identify them in commands. The ID is configured in the object's scene.

### States

Each object can have a "state". The state is stored in the global state of the game, and the savegame, and it's set on the object when the scene is instanced. States can also be animations with the same name in the object's scene, in that case the animation is run when the state is set.

### Active objects

Objects can be active or not active. Non-active objects are hidden and non clickable.

Item activity is also handled as a special case of global flags. If the check starts with "a/", like "a/elaine", you're checking if "elaine" is active.

```
:ready
> [!a/elaine]
    say player player_no_elaine_yet:"It would appear Elaine hasn't arrived yet."
```

Caveat: This works only when `set_active` has been called. Therefore if "elaine" is not set `active` in the editor but `set_active elaine true` is
called later, everything works as expected. If you have an item that can be picked up, even if it's `active` in the editor, but its state *may* toggle,
you must use this pattern:

```
:setup
set_active broom true [!i/inv_broom]
```

Now it has been explicitly set and it will work. The underlying technical rationale is way beyond the scope of this reference; just trust us
that it's the best way to go.

### Interactive objects

If you have something that only blocks the terrain, something you can move behind, you probably don't want to hassle with interaction areas
and tooltip texts. In this case, just set `is_interactive` to `false` and the item will not be checked for areas and its mouse events will
not be connected.

## Global flags

Global flags define the state of the game, and can have a value of true, false or an integer. All commands or groups can be conditioned to the value of a global flag.

### Inventory

The inventory is handled as a special case of global flags. All flags with a name starting with "i/" are considered an inventory object, with the object's global id following. Example:

```
# adds the object "key" to the inventory
set_global i/key true
```

```
# removes the object "key" to the inventory
set_global i/key false
```

## Game global state

The following values are saved in the global game state and savegames:

* Global flags
* Object's "state" values
* Object's "active" values
* Object's potisions if moved

## Events

When a scene is loaded, it may have events. We will not cover `:load` as it is used only internally for save games, nor will we cover `:start` here.

To initialize a room properly, you may want to use `:setup` like this:

```
:setup
teleport player door1 [eq last_exit door1]
teleport player door2 [eq last_exit door2]
```

It covers the fact that your `player` can be set anywhere in the room and be visible for just a moment before the `teleport` happens.

It's not mandatory, nor mutually exclusive with `:setup` to have a `:ready` event.

```
:ready
say player player_wants_out:"I want out! To live my life and to be free!" [want_out]
```

When the player interacts with an object in the game, the object receives an even. Each event executes a series of commands.

Events start with the character ":" in the Events file. Example:

```
:use
```

Especially useful for fallbacks, you can give flags to events:

```
:use | TK
say player player_does_not_wanna:"I don't wanna."
```

These flags are implemented:

* `TK` stands for "telekinetic". It means the player won't walk over to the item to say the line.
* `NO_TT` stands for "No tooltip". It hides the tooltip for the duration of the event. Probably not very useful, because events having multiple `say` commands in them are automatically hidden.
* `NO_HUD` stands for "No HUD". It hides the HUD for the duration of the event. Useful when you want something to look like a cut scene but not disable input for skipping dialog.
* `NO_SAVE` disables saving. Use this in cut scenes and anywhere a badly-timed autosave would leave your game in a messed-up state.
* `CUT_BLACK` applies only to `:setup`. It makes the screen go black during the setup phase. You will probably see a quick black flash, so use it only if you prefer it over the standard cut.
* `LEAVE_BLACK` applies only to `:setup`. In case your `:ready` starts with `cut_scene telon fade_in`, you must apply this flag or you will see a flash of your new scene before going black again for the `fade_in`.

## Commands

Commands consist of one word followed by parameters. Parameters can be one word, or strings in quotes. A string can also be preceeded by an ID for localization and the ":" character. Example:

```
# one parameter "player", another parameter "hello world", with id "dialog_hello"
say player dialog_hello:"hello world"
```

### Conditions

In order to run a command conditionally dependin on the value of a flag, use [] with a list of conditions. All conditions in the list must be true. The character "!" before a flag can be used to negate it.

Example:

```
# runs the command only if the door_open flag is true
say player "The door is open" [door_open]
```

```
# runs the group only if door_open is false and i/key is true
> [!door_open,i/key]
	say player "The door is close, maybe I can try this key in my inventory"
```

Additionally, there's a set of comparison operators for use with global integers: `eq`, `gt` and `lt`, all of which can be negated.
Example:

```
# runs the command only if the value of pieces_of_eight is greater than 5
set_state inv_pieces_of_eight money_bag [gt pieces_of_eight 5]
```

### Groups

Commands can be grouped using the character ">" to start a group, and incrementing the indentation of the commands that belong to the group. Example:

```
>
	set_global door_open true
	animation player pick_up
# end of group
```

### Blocking

Some commands will block execution of the event until they finish, others won't. See the command's reference for details on which commands block.

### List of commands

#### `debug string [string2 ...]`

Takes 1 or more strings, prints them to the console.

#### `set_global name value`

Changes the value of the global "name" with the value. Value can be "true", "false" or an integer.

#### `dec_global name value`

Subtracts the value from global with given "name". Value and global must both be integers.

#### `inc_global name value`

Adds the value to global with given "name". Value and global must both be integers.

#### `set_globals pattern value`

Changes the value of multiple globals using a wildcard pattern. Example:

```
# clears the inventory
set_globals i/#### false
```

#### `accept_input [ALL|NONE|SKIP]`

What type of input does the game accept. `ALL` is the default, `SKIP` allows skipping of dialog but nothing else, `NONE` denies all input. Including opening the menu etc.
`SKIP` and `NONE` also disable autosaves.

Note that `SKIP` gets reset to `ALL` when the event is done, but `NONE` persists. This allows you to create cut scenes with `SKIP` where the dialog can be skipped, but also
initiate locked#### down cutscenes with `accept_input NONE` in `:setup` and `accept_input ALL` later in `:ready`.

#### `set_state object state` (Currently not available)

Changes the state of an object, and executes the state animation if present. The command can be used to change the appearance of an item or a player character.

When used on a player object, the command is used to dress the player in a costume identified by the state parameter. An `AnimationPlayer` with the given parameter should be a child of the player node, although one named "animation" is always the fallback when trying set a missing costume.

Items can also change state by playing animations from an `AnimationPlayer` named "animation". The `AnimationPlayer` is typically used to change the texture of a `Sprite` node, but it's also possible to add additional tracks for changing the tooltip and other properties of the item scene. By using keyframes and looping, any given state can also use multiple textures to bring more life to the item.

#### `set_hud_visible visible` (Currently not available)

If you have a cut#### scene#### like sequence where the player doesn't have control, and you also have HUD elements visible, use this to hide the HUD. You want to do that because it explicitly signals the player that there is no control over the game at the moment. "visible" is true or false.

#### `say object text [type] [avatar]`

Runs the specified string as a dialog said by the object. Blocks execution until the dialog finishes playing. Optional parameters:

* "type" determines the type of dialog UI to use. Default value is "default"
* "avatar" determines the avatar to use for the dialog. Default value is "default"

#### `anim object name [reverse] [flip_x] [flip_y]`

Executes the animation specificed with the "name" parameter on the object, without blocking. The next command in the event will be executed immediately after. Optional parameters:

* reverse plays the animation in reverse when true
* flip_x flips the x axis of the object's sprites when true (object's root node needs to be Node2D)
* flip_y flips the y axis of the object's sprites when true (object's root node needs to be Node2D)

#### `cut_scene object name [reverse] [flip_x] [flip_y]`

Executes the animation specificed with the "name" parameter on the object, blocking. The next command in the event will be executed when the animation is finished playing. Optional parameters:

* reverse plays the animation in reverse when true
* flip_x flips the x axis of the object's sprites when true (object's root node needs to be Node2D)
* flip_y flips the y axis of the object's sprites when true (object's root node needs to be Node2D)

#### `play_snd object file [loop]` (Currently not available)

Plays the sound specificed with the "file" parameter on the object, without blocking. You can play background sounds, eg. during scene changes, with `play_snd bg_snd res://...`

#### `set_active object value`

Changes the "active" state of the object, value can be true or false. Inactive objects are hidden in the scene.

#### `set_interactive object value`

Sets whether or not an action menu should be used, and a tooltip shown, on object. It must use the `item.gd` script. Value can be true or false. Useful for "soft#### disabling" objects without removing them by `set_active`.

#### `wait seconds`

Blocks execution of the current script for a number of seconds specified by the "seconds" parameter.

#### `change_scene path run_events`

Loads a new scene, specified by "path". The `run_events` variable is a boolean (default true) which you never want to set manually! It's there only to benefit save games, so they don't conflict with the scene's events.

#### `set_speed object speed`

Sets how fast object moves. It must use the `interactive.gd` script or something extended from it. Value is an integer.

#### `teleport object1 object2 [angle]`

Sets the position of object1 to the position of object2. By default object2's `interact_angle` is used to turn `object1`, but `angle` will override this.
Useful for doors and such with an `interact_angle` you don't always want to adhere to when re#### entering a room.

#### `slide object1 object2 [speed]`

Moves object1 towards the position of object2, at the speed determined by object1's "speed" property, unless overridden. This command is non#### blocking. It does not respect the room's navigation polygons, so you can move items where the player can't walk.

#### `slide_block object1 object2 [speed]`

Moves object1 towards the position of object2, at the speed determined by object1's "speed" propert, unless overriddeny. This command is blocking. It does not respect the room's navigation polygons, so you can move items where the player can't walk.

#### `walk object1 object2 [speed]`

Walks, using the walk animation, object1 towards the position of object2, at the speed determined by object1's "speed" property, unless overridden. This command is non#### blocking.

#### `walk_block object1 object2 [speed]`

Walks, using the walk animation, object1 towards the position of object2, at the speed determined by object1's "speed" property, unless overridden. This command is blocking.

#### `turn_to object degrees`

Turns `object` to a `degrees` angle with a `directions` animation.

0 sets `object` facing forward, 90 sets it 90 degrees clockwise ("east") etc. When turning to the destination angle, animations are played if they're defined in `animations`.
`object` must be player or interactive.
`degrees` must be between [0, 360] or an error is reported.

#### `set_angle object degrees`

Turns `object` to a `degrees` angle without animations.
0 sets `object` facing forward, 90 sets it 90 degrees clockwise ("east") etc. When turning to the destination angle, animations are played if they're defined in `animations`.

`object` must be player or interactive.
`degrees` must be between [0, 360] or an error is reported.

#### `spawn path [object2]`

Instances a scene determined by "path", and places in the position of object2 (object2 is optional)

#### `stop`

Stops the event's execution.

#### `repeat`

Restarts the execution of the current scope at the start. A scope can be a group or an event.

#### `sched_event time object event`

Schedules the execution of an "event" found in "object" in a time in seconds. If another event is running at the time, execution starts when the running event ends.
`event` can consist of multiple words like in `sched_event 0 tow_hook use inv_rope`

#### `custom obj func_name [params]`

If `obj` has a `(Node2D) custom` node, `func_name` will be searched for in its script and called with `params`. See device/contrib/custom/spine.gd for an example.

#### `camera_set_pos speed x y`

Moves the camera to a position defined by "x" and "y", at the speed defined by "speed" in pixels per second. If speed is 0, camera is teleported to the position.

#### `camera_set_target speed object [object2 object3 ...]`

Configures the camera to follow 1 or more objects, using "speed" as speed limit. This is the default behavior (default follow object is "player"). If there's more than 1 object, the camera follows the average position of all the objects specified.

#### `camera_set_zoom magnitude [time]`yx

Zooms the camera in/out to the desired magnitude. Values larger than 1 zooms the camera out, and smaller values zooms in, relative to the default value of 1. An optional time in seconds controls how long it takes for the camera to zoom into position.

#### `camera_set_zoom_height pixels [time]`

Similar to the command above, but uses pixel height instead of magnitude to zoom.

#### `camera_push target [time] [type]`

Push camera to target. Target must have `camera_pos` set. If it's of type `Camera2D`, its zoom will be used as well as position.
`type` is any of the `Tween.TransitionType` values without the prefix, eg. `LINEAR`, `QUART` or `CIRC`; defaults to `QUART`.
A `time` value of 0 will set the camera immediately.

#### `camera_shift x y [time] [type]`

Shift camera by `x` and `y` pixels over `time` seconds.
`type` is any of the `Tween.TransitionType` values without the prefix, eg. `LINEAR`, `QUART` or `CIRC`; defaults to `QUART`.

#### `queue_resource path front_of_queue`

Queues the load of a resource in a background thread. The path must be a full path inside your game, for example "res://scenes/next_scene.tscn". The "front_of_queue" parameter is optional (default value false), to put the resource in the front of the queue. Queued resources are cleared when a change scene happens (but after the scene is loaded, meaning you can queue resources that belong to the next scene).

#### `queue_animation object animation`

Similar to queue_resource, queues the resources necessary to have an animation loaded on an item. The resource paths are taken from the item placeholders.

#### `game_over continue_enabled show_credits`

Ends the game. Use the "continue_enabled" parameter to enable or disable the continue button in the main menu afterwards. The "show_credits" parameter loads the `ui/end_credits` scene if true. You can configure it to your regular credits scene if you want.

## Dialogs

To start a dialog, use the "?" character, with some parameters, followed by a list of dialog options. This hides the HUD. Each option starts with the "-" character, followed by a parameter with the text to display in the dialog interface. Inside the option, a group of commands is specified using indentation. Use "!" to signify the dialog is over and the HUD may be restored. The HUD will not be restored if the running event is flagged NO_HUD. Either way the Escoria virtual machine will know if the game is in a dialog context.

Example:

```
# character's "talk" event
:talk
? type avatar timeout timeout_option
	- "I'd like to buy a map." [!player_has_map]
		say player "I'd like to buy a map"
		say map_vendor "Do you know the secret code?"
		?
			- "Uncle Sven sends regards."
				say player "Uncle Sven sends regards."

				>	[player_has_money]
					say map_vendor "Here you go."
					say player "Thanks!"
					inventory_add map
					set_global player_has_map true
					stop

				>	[!player_has_money]
					say map_vendor "You can't afford it"
					say player "I'll be back"
          !
					stop

			- "Nevermind"
				say player "Nevermind"
        !
				stop
	- "Nevermind"
		say player "Nevermind"
    !
		stop
repeat
```

All parameters are options:

* type: (default value "default") the type of dialog menu to use. All types are in the "dd_player" scene.
* avatar: (default value "default") the avatar to use in the dialog ui.
* timeout: (default value 0) timeout to select an option. After the time has passed, the "timeout_option" will be selected automatically. If the value is 0, there's no timeout.
* timeout_option: (default value 0) option selected when timeout is reached.

