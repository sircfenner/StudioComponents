StudioComponents is a collection of [Roact](https://github.com/Roblox/roact) implementations of common user interface elements found in Roblox Studio such as checkboxes, input fields, and scrollers. These closely match the look and functionality of their built-in counterparts and should be used to create user plugins.

These components also leverage the theming API to dynamically recolor according to the user's theme setting in Studio. 

!!! warning
    This project is a work in progress - expect breaking changes!

## Why recreate the Studio interface?

Closely replicating the built-in user interface gives user plugins a familiar feel. Studio users already recognise these interface items and understand both what they signify and how to use them. 

Designing a plugin to fit in seamlessly with the rest of Studio also offers a more coherent user experience with less visual distraction and friction when switching between third-party and built-in tools. 

## Plugins created with StudioComponents

The coherence benefit also applies between multiple user plugins. It is preferable for user plugins to share a general appearance rather than every plugin being visually different.

Using StudioComponents will align the appearance of a plugin with existing plugins, including:

- [Collision Groups Editor](https://github.com/sircfenner/CollisionGroupsEditor), an alternative to Studio's built-in Collision Groups Editor

- [Layers](https://github.com/call23re/Layers), a tool for manipulating and visualizing logical sections of 3D models

<sub>If your plugin belongs on this list, file an [issue](https://github.com/sircfenner/StudioComponents/issues)!</sub>