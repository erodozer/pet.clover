# simple-scene-manager

Simplify complex scene management with safe memory transitioning and dynamic loading of Nodes.  
Scenes are the primary composition of a game's stateful context.
SceneManager introduces additional lifecycle hooks that are useful for Scenes that extend the functionality of Godot's own Node lifecycle.

## Usage

Include in your Main project node and reference it by using the group name `scene_manager` in scripts to be able to switch between scenes.

All states and hooks are async and make use of GDscript coroutines, so all steps of your scenes are awaited.

## Lifecycle hooks

In addition to the basic lifecycle hooks that exist on all Nodes, Scene Manager handles a few specific ones in order to display proper graphical transitions relative to swapping scenes.

These new hooks are fully optional methods.

### _teardown
Called as the current scene is queued to be replaced.  Happens after the transition animation has finished playing

### _setup
Called after the scene has been loaded and inserted into the tree.  Use this to perform any logic after _ready.

If you are passing in a cached scene instead of loading from disk, this is useful as as repeatable post-ready call

### _started
called after the transition animation has faded out and the new scene is visible
