"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4138],{20130:e=>{e.exports=JSON.parse('{"functions":[],"properties":[],"types":[{"name":"Props","desc":"","fields":[{"name":"...","lua_type":"CommonProps","desc":""},{"name":"Value","lua_type":"boolean?","desc":""},{"name":"OnChanged","lua_type":"(() -> ())?","desc":""},{"name":"Label","lua_type":"string?","desc":""},{"name":"ContentAlignment","lua_type":"HorizontalAlignment?","desc":""},{"name":"ButtonAlignment","lua_type":"HorizontalAlignment?","desc":""}],"tags":["Component Props"],"source":{"line":66,"path":"src/Components/Checkbox.luau"}}],"name":"Checkbox","desc":"A box which can be checked or unchecked, usually used to toggle an option. Passing a value to\\nthe `Label` prop is the recommended way to indicate the purpose of a checkbox.\\n\\n| Dark | Light |\\n| - | - |\\n| ![Dark](/StudioComponents/components/checkbox/dark.png) | ![Light](/StudioComponents/components/checkbox/light.png) |\\n\\nAs this is a controlled component, you should pass a value to the `Value` prop representing \\nwhether the box is checked, and a callback value to the `OnChanged`\\tprop which gets run when \\nthe user interacts with the checkbox. For example:\\n\\n```lua\\nlocal function MyComponent()\\n\\tlocal selected, setSelected = React.useState(false)\\n\\treturn React.createElement(StudioComponents.Checkbox, {\\n\\t\\tValue = selected,\\n\\t\\tOnChanged = setSelected,\\n\\t})\\nend\\n```\\n\\nThe default height of a checkbox, including its label, can be found in [Constants.DefaultToggleHeight].\\nThe size of the whole checkbox can be overridden by passing a value to the `Size` prop.\\n\\nBy default, the box and label are left-aligned within the parent frame. This can be overriden by \\npassing an [Enum.HorizontalAlignment] value to the `ContentAlignment` prop.\\n\\nBy default, the box is placed to the left of the label. This can be overriden by passing either\\n`Enum.HorizontalAlignment.Left` or `Enum.HorizontalAlignment.Right` to the\\n`ButtonAlignment` prop.\\n\\nCheckboxes can also represent \'indeterminate\' values, which indicates that it is neither\\nchecked nor unchecked. This can be achieved by passing `nil` to the `Value` prop.\\nThis might be used when a checkbox represents the combined state of two different options, one of\\nwhich has a value of `true` and the other `false`.\\n\\n:::info\\nThe built-in Studio checkboxes were changed during this project\'s lifetime to be smaller and\\nhave a lower contrast ratio, especially in Dark theme. This component retains the old design\\nas it is more accessible.\\n:::","source":{"line":46,"path":"src/Components/Checkbox.luau"}}')}}]);