# Piggy Rescue

🐽⛵🐽🏖️🐽🌊🐽

🐷⛑️Piggy Rescue🐖🐖🐖 is a personal Godot and XR learning project, developed over two months and published with the intention of helping others in their learning.

It was made with Godot 4.1 stable (final version tested in 4.1.2) and uses version 4.1 of Godot XR Tools plugin.

[https://vimeo.com/874560332](https://vimeo.com/874560332)

## Can I just play the game?

The game is available for free in SideQuest 🎉🐖🐖⛑️🐷🐖 [https://sidequestvr.com/app/19654/piggy-rescue](https://sidequestvr.com/app/19654/piggy-rescue)  or directly in Itch.io [https://asturnazari.itch.io/piggy-rescue](https://asturnazari.itch.io/piggy-rescue)

You can also donate if you like :)


## XR Tools Plugin

I packed the addons for this code to be easy to use as learning content.
Note that some files from the XR Tools addon have been modified:

* godot-xr-tools/objects/viewport_2d_in_3d.gd
* godot-xr-tools/objects/virtual_keyboard.tscn
* godot-xr-tools/staging/loading_screen/loading_screen_shader.tres
* godot-xr-tools/staging/loading_screen.tscn
* godot-xr-tools/staging/loading_screen.gd

Many of this changes are related to obtain transparent menus and render them on top of everything, this changes were proposed as a feature and now there is a new and better approach to this provided by Malcolm Nixon in XR Tools v.4.2


## Made with

	Gimp, Inkscape, Penpot, Godot, Blender


# How the code work

There is only an staging system and a single scene. In the main scene you will find a Logic node, wich contains the main part of the code. It's a simple states machine that uses Globals.state to rule the states of the game, and another function that rules wich UI to show according to the global state.

Also there are some interesting pieces of code in a folder scripts/XR_mod. There is a pickable and floatable object, and the amazing 🌊🎥 underwater camera sound fx 🎥🌊.


# Features

Some features you can find inside the code:

* An audio mixer with 6 channels and examples of effects and music controlled by code.

* Logic for floating grabable objects in XR

* A reusable countdown node with his own logic

* Some follow camera logic to position UIs in VR

* A shader for an ocean and another for underwater objects, both rigger by the same global shader properties. (maybe some elements still doesn't use the global shader props, not sure, but main actors does :P)

* A simple spawn system for pigs

* The implementation of a local leaderboard

* Implementation of an online  leaderboard, based on Silentwolf (just put your API key in Globals.gd -> line 6)

* A basic implementation on how to switch render quality settings on PCVR or Android.

* Export settings for Pico4, Quest2 and PCVR (you still need to install XR Loaders, Android templates and configure all the build stuff, android studio, jdk, etc)

* A nice XR 'generic' controller scene to show input actions in controller buttons

* And many other little details.

#

| ⚡       🍜 Code alert!!   |
|-----------------------------------------|

	Please notice the code is not well optimiced, it's quite simple,
	just a prototype well tuned, but is messy and not well ordered, 
	and maybe there are some unused files here and there.... 
	It can be improved, and improvements are welcome.


# Licenses

Please, read the [CREDITS.md](CREDITS.md) file

# MORE PETS???

Wanna add more pets to rescue? 🐑🐇🐄🦄

You just need to modify the pig spawner object 😉

If you need help with this you can open an issue

🐽⛵🐽🏖️🐽🌊🐽
