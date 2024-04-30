---
sidebar_position: 1
---

# About

This is a collection of React components for building Roblox Studio plugins. These include common user interface components found in Studio and are made to closely match the look and functionality of their built-in counterparts, including synchronizing with the user's selected theme.

These components are built for [react-lua](https://github.com/jsdotlua/react-lua), Roblox's translation of ReactJS v17 into Luau. A prior version of this project (before v1.0.0) used [Roact](https://github.com/Roblox/roact) and had multiple API differences. For more information, see the [Changelog](../changelog).

:::note
These components are only suitable for use in plugins. This is because they rely on plugin- or Studio-only APIs.
:::

## Why recreate the Studio interface?

Closely replicating the built-in user interface has two main advantages:

1. Roblox Studio users recognise these components and know how to use them.
2. Less adjustment required when switching between third-party and built-in interfaces.

The design of some built-in user interface components has changed in the lifetime of this
project. In some cases, these changes had negative implications for accessiblity or consistency so
their previous versions are used here instead.

## Plugins created with StudioComponents

With wider adoption, using these components to build a plugin will also align it with other third-party plugins in appearance, familiarity, and usability.

Some plugins created with StudioComponents include:

-   [Archimedes 3](https://devforum.roblox.com/t/introducing-archimedes-3-a-building-plugin/1610366), a popular building plugin used to create smooth arcs
-   [Collision Groups Editor](https://github.com/sircfenner/CollisionGroupsEditor), an alternative to the built-in editor for Collision Groups
-   [Layers](https://github.com/call23re/Layers), a tool for working with logical sections of 3D models
-   [Benchmarker](https://devforum.roblox.com/t/benchmarker-plugin-compare-function-speeds-with-graphs-percentiles-and-more/829912), a performance benchmarking tool for Luau code
-   [LampLight](https://devforum.roblox.com/t/lamplight-global-illumination-for-roblox-new-v12/1837877), a tool for baking Global Illumination bounce lighting into scenes
-   [MeshVox](https://devforum.roblox.com/t/meshvox-v10-a-powerful-3d-smooth-terrain-importstamping-tool/2576245), a smooth terrain importing and stamping tool

:::info
Some of these plugins were built with the earlier Roact version (version 0.x, before react-lua was adopted) or the [Fusion port](https://github.com/mvyasu/PluginEssentials) of it.
:::

## Migrating from Roact StudioComponents

Existing users of the Roact version looking to migrate their project to React and the current version of StudioComponents should:

1. Follow the react-lua [guide for migrating from Roact](https://jsdotlua.github.io/react-lua/migrating-from-legacy/minimum-requirements/)
2. Follow this project's [installation guide](./getting-started)
3. Address any [API differences](../changelog) between legacy StudioComponents and this version
