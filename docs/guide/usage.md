StudioComponents must be a sibling of [Roact](https://github.com/Roblox/roact/) in the Roblox instance hierarchy, for example:
```
📂 Plugin
└───📂 Vendor
    └───📃 StudioComponents
    └───📃 Roact
    ...
```

## Notes

### BorderMode
Generally inset: easier to reason about total size + any outer padding

### ColorStyle props
Some -Color3 properties are available as -ColorStyle from Enum.StudioStyleGuideColor

