# Changelog

## Unreleased

-   Add usePlugin hook

## 1.1.0

-   Fixed image links in documentation
-   Added OnCompleted prop to Slider
-   Added component: DatePicker

## 1.0.0

Migrated from [Roact](https://github.com/Roblox/roact) to [react-lua](https://github.com/jsdotlua/react-lua)
and rewrote the library from the ground up.

There are many API differences; consult the docs on this. Removal of some components was either due
to no longer being in scope for this project or requiring an API redesign which didn't make it
into v1.0.0.

### Added

-   Full type annotations
-   Components: DropShadowFrame, LoadingDots, NumberSequencePicker, NumericInput, ProgressBar
-   Hooks: useMouseIcon

### Removed

-   Components: BaseButton, Tooltip, VerticalCollapsibleSection, VerticalExpandingList, Widget, withTheme
-   Contexts: ThemeContext
-   Hooks: usePlugin

## 0.1.0 - 0.1.4

Initial release through to the final Roact version. Added various components and changed APIs.
