StudioComponents must be a sibling of [Roact](https://github.com/Roblox/roact/) in the Roblox instance hierarchy, for example:
```
📂 Plugin
└───📂 Vendor
    └───📃 StudioComponents
    └───📃 Roact
    ...
```

## Notes

### Default props
Default props are listed only where they deviate from the Roblox defaults for instance properties

### BorderMode
Generally inset: easier to reason about total size + any outer padding

### ColorStyle props
Some -Color3 properties are available as -ColorStyle from Enum.StudioStyleGuideColor

