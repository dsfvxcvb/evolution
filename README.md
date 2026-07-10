# Atlanta UI

Roblox UI library with built-in ESP preview, split into a reusable library and an example usage script.

## Files

- `library.lua` — the UI library itself.
- `example.lua` — example usage / loader that creates the main window, settings panel, visuals, ESP preview, etc.

## Usage

Run `example.lua` in your executor. It loads `library.lua` from the same folder:

```lua
local library, themes = loadfile("library.lua")()
```

If your executor requires a full path, change that line to point to `library.lua`.
