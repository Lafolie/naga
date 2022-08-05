# Naga
Naga is a declarative, stack-based UI module for [Löve][love] projects, written in Lua.

# Features
Naga is designed to be usable by both games and applications, meaning that a single UI framework can be used by the game and its development tools.

## Core Features
Here is a brief overview of the module:
* **Declarative UI creation** - simple and self-documenting
* **Stack-based element creation** - auto-parenting/nesting
* **Themes** - multiple theme support
* **Mouse & Keyboard support**
* **Gamepad support**
* **Extensible**

## Elements
UI objects created with Naga are called **elements**.
The element is intended to be minimal in that it has all of the most commonly required UI features, and nothing more.
It designed to be a building block, so that more complex/compound elements may be easily created with it.

All elements support the following configurable features:

* **Nesting** - one-to-many parent/child trees
* **Automatic resizing** - fit to children, can also be set to fixed
* **Automatic layouts** - free placement, vertical/horizontal lists, grids
* **Theming** - with cascading styles and substyles
* **Interaction events** - press, release, hover, etc
* **Dragging** - elements marked with `canDrag = true` become draggable
* **Drag & Drop** - draggable elements marked with `canDrop = true` become drag & drop elements
* **Scrollbars** - modern-style overlayed scrollbars that hide when not in use
* **Tooltips** - per-element tooltips
* **Context Menus** - ??? not sure how to do this yet, or whether it should be built-in
* **Labels** - ??? should this be its own element or not?

## Built-in Extensions
Elements created via `naga.create` are the sole element type provided by the module. Therefore, a suite of extensions are provided by default.
Out-of-the-box extension modules include:

* **Windows** - including titlebars & buttons
* **Buttons**
* **Checkboxes**
* **Radio buttons**
* **Drop-downs**
* **Trees**
* **Table Explorer** - for displaying Lua tables
* **Separators**

# Quickstart
Blah blah

# Example
Stupid example
```lua
-- main.lua
local naga = require "naga"

naga.push.create {x = 64, y = 64, width = 128, height = 128, canDrag = true}
	naga.create {x = 64, y = 64, width = 64, height = 64}
naga.pop()

naga.push {x = 0, y = 0, width = 32, height = 32}

function love.draw()
	naga.draw()
end
```

# Tips & Tricks
This section lists a bunch of notes that will eventually be moved to a wiki or something. For now, they live here so I have a place to jot down notes.

### The `none` Style
All themes have an implicit `none` style that can't be overridden. Using this style causes all drawing and interaction with the element to be ignored. However, child elements will still be drawn and can be interacted with, and direct interaction will be passed to the parent (as if it was 'clicked-through').

### Leaf Elements
Elements marked with `isLeaf = true` can't be pushed to the stack and therefore can't have nested elements within them. Leaf elements are typically used for elements at the bottom of the element tree, such as labels, images, or inputs.

### When `element.layout` is Called
To reduce redundant processing, the `layout` function on an element is called when `naga.pop` is called. Calling `naga.popAll` will trigger individual pops for each element on the stack. (Also needs to be called when an element is dirtied?)

Always remember to clear the stack when you're done creating elements!

### Implicit min/max Sizes
If the `width` or `height` properties are set, the size of the element is assumed to be of a fixed size, and the min/max width/height are set to the given value(s), meaning that they don't need to be manually specified.

### The Root Element
Naga manages a root element that is always the same size as the Löve window. Its `layout` property is set to `naga.layout.free`, allowing the creation of
top-level elements at arbitrary screen positions without the need for windows or other containers. All top-level elements are parented to the root element, and its style is set to 'none'.

Though the root element is accessible via the main module, it should not generally be altered.

### Style Cascading
Styles and substyles are inherited from the parent element if not explicitly set. Top-level elements default to the use of the standardised style named `element`.

### Relative Positions
Element positions are relative, and Naga does not store absolute/screen-space coordinates. This allows elements to be moved around, resized, or hidden without expensive tree traversals to update positions. When an element is interacted with via the mouse, the cursor location passed to the relevant function is adjusted relative to the element being interacted with.

# License

Naga is free software, provided under the MIT software license.

[love]: https://www.love2d.org/