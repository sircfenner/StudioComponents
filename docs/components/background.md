A solid-color borderless frame. It provides the same background color as built-in Studio widgets, for example Explorer and Properties.

| Dark | Light |
| ---- | ----- |
| <svg class="swatch" viewbox="0 0 100 100"><rect style="fill:rgb(46,46,46)" width="100%" height="100%" /></svg> | <svg class="swatch" viewbox="0 0 100 100"><rect style="fill:rgb(255,255,255)" width="100%" height="100%" /></svg> |

This is commonly used for containing the main contents of a plugin, for example as a child of a widget with the rest of the plugin elements as its children.

```
🖥️ Widget
└───🖼️ Background
    └───📝 ...
    └───📝 ...
```

## API & Usage 

This component will render all children passed to it.

### Default props

| Property | Value |
| -------- | ----- |
| Size     | `UDim2.fromScale(1, 1)` |

### Other props

These map directly to instance properties of the Frame:

- Position
- AnchorPoint
- LayoutOrder
- ZIndex

