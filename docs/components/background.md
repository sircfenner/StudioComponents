A solid-color borderless frame. It provides the same background color as built-in Studio widgets, for example Explorer and Properties.

| Dark | Light |
| ---- | ----- |
| <svg class="swatch" viewbox="0 0 100 100"><rect style="fill:rgb(46,46,46)" width="100%" height="100%" /></svg> | <svg class="swatch" viewbox="0 0 100 100"><rect style="fill:rgb(255,255,255)" width="100%" height="100%" /></svg> |

This is commonly used for containing the main contents of a plugin, for example as a child of a widget with the rest of the plugin elements as its children.

```
🖥️ Widget
└───🖼️ Background
    └───🔠 ...
    └───🔠 ...
```

## API & Usage 

This component renders a single frame. Any children passed to it will be rendered as children of the frame.

### Default props

| Property    | Value                   |
| ----------- | ----------------------- |
| Size        | `UDim2.fromScale(1, 1)` |
| Position    | `UDim2.fromScale(0, 0)` |
| AnchorPoint | `Vector2.new(0, 0)`     |
| LayoutOrder | 0                       |
| ZIndex      | 1                       |
