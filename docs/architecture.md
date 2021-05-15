# Escoria architecture

## The plugin script, autoload and classes

According to the [concept of Godot plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html), `Escoria`initializes itself in the plugin script `addons/escoria-core/editor/plugin_escoria.gd`. This script is mostly used to initialize the [Escoria configuration items](configuration.md) and initialize (and later remove) the autoloads.

Escoria is based on an autoload scene available as [`escoria`](api/escoria.gd.md), that binds together all required objects and interfaces in a central place. An additional autoload, [`esctypes`](api/escoria_types.gd.md) defines basic escoria classes.

In addition to this, various classes are defined in the respective class files and build up the various resources used in Escoria.

* `addons/escoria-core/game/inputs_manager`: The central component in Escoria to receive, handle and deliver input events

## Nodes of the Escoria autoload scene

The Escoria autoload scene holds various nodes that take vital parts of the engine.

### Main

`escoria.main` is the main scene manager used in Escoria that allows for switching scenes with transitions

## The Godot main scene of Escoria

The scene, that Godot loads when starting a game (the [*main scene*](https://docs.godotengine.org/en/stable/getting_started/step_by_step/exporting.html#setting-a-main-scene)) is set to `addons/escoria-core/game/main_scene.tscn` and basically instantiates the configured main menu scene and starts it.