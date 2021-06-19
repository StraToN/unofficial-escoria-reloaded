# ESC language documentation

## Objects

### Global IDs

All objects in the game have a global ID, which is used to identify them in commands. The ID is configured in the object's scene.

### States

Each object can have a "state". The state is stored in the global state of the game, and the savegame, and it's set on the object when the scene is instanced. States can also be animations with the same name in the object's scene, in that case the animation is run when the state is set.

For the [bg_sound](api/EscBackgroundSound.md) and [bg_music](api/EscBackgroundMusic.md) objects, the state also means the currently running music or sound.

### Active objects

Objects can be active or inactive. Inactive objects are hidden and non clickable.

Item activity is also handled as a special case of global flags. If the check starts with "a/", like "a/elaine", you're checking if "elaine" is active.

```
:ready
> [!a/elaine]
    say player player_no_elaine_yet:"It would appear Elaine hasn't arrived yet."
```

### Interactive objects

If you have something that only blocks the terrain, something you can move behind, you probably don't want to hassle with interaction areas and tooltip texts. In this case, just set `is_interactive` to `false` and the item will not be checked for areas and its mouse events will not be connected.

## Global flags

Global flags define the state of the game, and can have any value (true/false, numbers and strings). All commands or groups can be conditioned to the value of a global flag.

### Inventory

The inventory is handled as a special case of global flags. All flags with a name starting with "i/" are considered an inventory object, with the object's global id following. Example:

```
# Waits for 5 seconds if the player has the key in its inventory
wait 5 [i/key]
```

## Events

All ESC scripts are divided into a series of events, which in turn run commands or dialogs.

An event has a name and the prefix ":" like this:

`:setup`

While you can use arbitrary event names (for example to schedule them with the `sched_event`command), there are some special events that are called by Escoria when certaiin things happen:

* `:setup` (on an ESCScene object): Called everytime when the scene is loaded
* `:ready`(on an ESCScene object): Called only when the scene is loaded the first time
* `:use <global id>`(on an ESCItem object): Called when the inventory item `<global id>`was used with this item
* `:<verb>`(on an ESCItem object): Called when a special verb was used on the item (e.g. `:look`)

To initialize a room properly, you may want to use `:setup` like this:

```
:setup
teleport player door1 [eq ESC_LAST_SCENE scene1]
teleport player door2 [eq ESC_LAST_SCENE scene2]
```

This will teleport the player to the respective point in the scene, depending on the last visited scene, which is stored in the special global state `ESC_LAST_SCENE`.

Events understand a series of flags. These flags are currently implemented:

* `TK` stands for "telekinetic". It means the player won't walk over to the item to say the line
* `NO_TT` stands for "No tooltip". It hides the tooltip for the duration of the event
* `NO_HUD` stands for "No HUD". It hides the HUD for the duration of the event. Useful when you want something to look like a cut scene but not disable input for skipping dialog.
* `NO_SAVE` disables saving. Use this in cut scenes and anywhere a badly-timed autosave would leave your game in a messed-up state.
* `CUT_BLACK` applies only to `:setup`. It makes the screen go black during the setup phase. You will probably see a quick black flash, so use it only if you prefer it over the standard cut.
* `LEAVE_BLACK` applies only to `:setup`. In case your `:ready` starts with `cut_scene telon fade_in`, you must apply this flag or you will see a flash of your new scene before going black again for the `fade_in`.

## Commands

Commands consist of one word followed by parameters. Parameters can be one word, or strings in quotes.

```
# one parameter "player", another parameter "hello world"
say player "hello world"
```

### Conditions

In order to run a command conditionally depending on the value of a flag, use `[]` with a list of comma separated conditions. All conditions in the list must be true. The character "!" before a flag can be used to negate it.

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
	anim player pick_up
# end of group
```

Groups cann also use conditions:

```
# Present the key if the player already has it
> [i/key]
	say player "I got the key!"
	anim player show_key
```



### Blocking

Some commands will block execution of the event until they finish, others won't. See the command's reference for details on which commands block.

### List of commands

<!-- ESCCOMMANDS -->
<!-- /ESCCOMMANDS -->

## Dialogs

Dialogs are specified by writing `?` with optional parameters, followed by a list of dialog options starting with `-`. Use `!` to end the dialog.

The following parameters are available:

* type: (default value "default") the type of dialog menu to use.
* avatar: (default value "default") the avatar to use in the dialog ui.
* timeout: (default value 0) timeout to select an option. After the time has passed, the "timeout_option" will be selected automatically. If the value is 0, there's no timeout.
* timeout_option: (default value 0) option selected when timeout is reached.

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

