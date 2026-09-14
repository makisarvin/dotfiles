---
name: luau-roblox
description: Write typed Luau code for Roblox projects using rojo, luau-lsp, pesde, and rokit. Use when editing or creating Luau files, managing Roblox projects, configuring tools, or reviewing Luau code. Covers strict typing, style conventions, project structure, and tooling workflow.
---

# Luau for Roblox Development

## Core Principles

- All code must use **strict mode** (`--!strict` or `.luaurc` with `"languageMode": "strict"`). Never use `nocheck` or `nonstrict` in new files.
- Types are structural. Use explicit annotations for public APIs, let inference handle the rest when it's obvious.
- Local functions: `camelCase`. Global/module-exported functions: `PascalCase`.
- Early returns over deep nesting.
- Prefer immutability. Never deep copy — shallow clone + targeted mutation.
- Comments explain "why", not "what". No historical comments, no changelog blocks, no commented-out code.

## Language Mode

Enable strict mode project-wide:

```json
// .luaurc
{ "languageMode": "strict" }
```

Per-file at the very top:

```luau
--!strict
```

## Type System

### Type annotations vs inference

Type publicly exposed functions fully. Internal helpers can be left untyped if inference is obvious.

```luau
-- Public: fully typed
local function DealDamage(player: Player, item: Item, target: Attackable): number
    local damage = item:Attack(target)
    return damage
end

-- Internal: inference is fine
local function attackMessage(player, damage)
    print(`{player.Name} dealt {damage} damage!`)
end
```

Avoid trivial types that don't help catch bugs:

```luau
-- Bad
local MAX_HEALTH: number = 100
local damage: number = item:Attack(player)

-- Good
local MAX_HEALTH = 100
local damage = item:Attack(player)
```

### Type casts

Use `::` when inference is too generic:

```luau
local names = { "alice", "bob", "charlie" } :: { string }
-- Without cast, Luau might infer { "alice", "bob", "charlie" } (a literal union)
```

### Table types

```luau
-- Dictionary
local scores: { [string]: number } = {}

-- Array
local items: { Item } = {}

-- Mixed: avoid this. Use separate tables.
```

### Enums

Always use string enums, nothing else:

```luau
local StatusEnum = {
    Idle = "Idle",
    Running = "Running",
    Dead = "Dead",
}
```

## Naming Conventions

### Casing rules

| Kind | Case | Example |
| ------ | ------ | --------- |
| Local variables/functions | `camelCase` | `local function processItem()` |
| Module-level locals | `camelCase` | `local currentState = ...` |
| Global/module exports | `PascalCase` | `function InventorySystem.Load()` |
| Types | `PascalCase` | `export type PlayerData = ...` |
| Constants | `UPPER_SNAKE_CASE` | `local MAX_RETRY_COUNT = 3` |
| Roblox services | `PascalCase` | `ReplicatedStorage`, `Players` |
| Roblox instances | `camelCase` | `local humanoid = ...` |

**Critical**: Local functions are `camelCase`. Exported module functions are `PascalCase`. This distinction is intentional and consistent.

### Suffix yielding functions with `Async`

```luau
local function fetchDataAsync(): string
    -- yields
end

local function loadPlayerDataAsync(player: Player): PlayerData
    -- yields
end
```

## File Structure

Files should contain these sections in order:

1. File-level block comment (why this file exists — no author, no date)
2. `--!strict` if not using `.luaurc`
3. Services via `GetService`
4. Requires (sorted alphabetically)
5. Module-level constants
6. Module-level variables and functions
7. The returned object/table
8. Return statement

```luau
--[[
    Handles player inventory state and replication.
]]

--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InventoryEvents = require(ReplicatedStorage.Shared.Events.InventoryEvents)
local ItemTypes = require(ReplicatedStorage.Shared.Types.ItemTypes)

local MAX_INVENTORY_SLOTS = 50

local inventories: { [Player]: ItemTypes.Inventory } = {}

-- ...functions...

local InventorySystem = {}

function InventorySystem.Load(player: Player): ItemTypes.Inventory
    -- ...
end

return InventorySystem
```

## Requires

### Rules

- All `require` calls must be at the top of the file (static only — no dynamic requires)
- Sort alphabetically by module name
- Group by: packages → shared modules → local modules
- Use a common ancestor variable for project modules
- Never use `script.Parent` outside implementation details; prefer absolute paths

```luau
-- 1. Common ancestor
local Shared = ReplicatedStorage.Shared

-- 2. Packages (pesde-managed)
local Promise = require(ReplicatedStorage.Packages.promise)

-- 3. Shared modules
local Events = require(Shared.Events)
local Types = require(Shared.Types)

-- 4. Local project modules
local MyProject = script.Parent.Parent
local Utils = require(MyProject.Utils)
local Config = require(MyProject.Config)
```

## Functions

### Declare local functions with `function` prefix

```luau
-- Good
local function add(a: number, b: number): number
    return a + b
end

-- Bad: global
function add(a, b)
    return a + b
end

-- Bad: anonymous assigned
local add = function(a, b)
    return a + b
end
```

### Module exports: named variable, then return

```luau
-- Good
local function process()
    -- ...
end

return process

-- Bad (harder to find with text search)
return function()
    -- ...
end
```

### Table methods

Use `.` vs `:` to indicate calling convention:

```luau
-- Called as MyClass.new()
function MyClass.new(name: string): MyClass
    -- ...
end

-- Called as instance:Destroy()
function MyClass:Destroy()
    -- self is implicit
end
```

## Control Flow

### Early returns

```luau
-- Good
local function dealDamage(humanoid: Humanoid, damage: number)
    if damage <= 0 then
        return
    end

    humanoid.Health -= damage
end

-- Bad: pyramid of doom
local function dealDamage(humanoid: Humanoid, damage: number)
    if damage > 0 then
        humanoid.Health -= damage
    end
end
```

### If-then-else expressions

Use Luau's ternary-like syntax. Never use `x and y or z`:

```luau
-- Good
local scale = if someFlag() then 1 else 2

-- Bad
local scale = someFlag() and 1 or 2  -- broken if values can be falsy
```

### Explicit nil checks over truthiness

```luau
-- Good
if x.Parent == nil then
    -- ...
end

-- Bad
if not x.Parent then
    -- ambiguous: nil? false?
end
```

Exception: `and`/`or` for short-circuiting and defaults is fine:

```luau
local volume = volumeOrNil or 0.5
local humanoid = player and player.Character and player.Character:FindFirstChild("Humanoid")
```

## Tables and Iteration

### Generalized iteration

```luau
-- Good
for _, item in items do
    print(item)
end

-- Still acceptable for clarity
for _, item in ipairs(items) do
    print(item)
end
```

### Shallow copy only

```luau
-- Immutable update pattern
items = table.clone(items)
items[1] = table.clone(items[1])
items[1].durability -= 10
```

### Metatables: limited use

Avoid metatables. When needed, use for:

1. Prototype-based classes with `__index`
2. Guarding against typos (throw on missing keys)

```luau
-- Class pattern
local MyClass = {}
MyClass.__index = MyClass

export type ClassType = typeof(setmetatable(
    {} :: { property: number },
    MyClass
))

function MyClass.new(property: number): ClassType
    local self = {
        property = property,
    }
    setmetatable(self, MyClass)
    return self
end

-- Use dot notation for typing self explicitly
function MyClass.AddOne(self: ClassType)
    self.property += 1
end
```

## Project Tooling

### Rojo

Rojo syncs filesystem files into Roblox Studio. Typical project structure:

```
project/
├── default.project.json      # Rojo project config
├── pesde.toml                # Package manifest
├── rokit.toml                # CLI tools manifest
├── src/
│   ├── Client/
│   ├── Server/
│   ├── Shared/
│   └── Assets/
└── .vscode/
    └── settings.json         # luau-lsp config
```

Example `default.project.json`:

```json
{
  "name": "my-game",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/Shared"
      },
      "Packages": {
        "$path": "pesde_packages"
      }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Server": {
        "$path": "src/Server"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Client": {
          "$path": "src/Client"
        }
      }
    }
  }
}
```

### Pesde (package manager)

```toml
# pesde.toml
name = "my-game"
version = "0.1.0"

[scripts]
rojo = "rojo"
serve = "rojo serve"
build = "rojo build --output game.rbxl"

[target]
environment = "roblox"

[dependencies]
# Add packages with `pesde add <name>`
```

Install packages:

```bash
pesde install
```

### Rokit (CLI tools)

```toml
# rokit.toml
[tools]
rojo = "rojo-rbx/rojo@7.4.4"
lune = "lune-org/lune@0.8.9"
luau-lsp = "JohnnyMorganz/luau-lsp@1.33.0"
stylua = "JohnnyMorganz/StyLua@2.0.2"
```

Install tools:

```bash
rokit install
```

Run tools via rokit:

```bash
rokit run rojo serve
rokit run luau-lsp analyze src/
rokit run stylua --check src/
```

### Luau-LSP

Configure in `.vscode/settings.json`:

```json
{
    "luau-lsp.fflags.enableNewSolver": true,
    "luau-lsp.diagnostics.strict": true,
    "luau-lsp.platform.type": "roblox",
    "luau-lsp.sourcemap.rojoProjectFile": "default.project.json",
    "luau-lsp.completion.imports.enabled": true,
    "luau-lsp.completion.imports.suggestServices": true
}
```

Key features:

- Auto-completion with `require()` suggestions
- Type diagnostics (enable strict mode)
- Sourcemap generation from rojo project
- Go-to-definition across module boundaries

## Code Style (from style guides)

### Whitespace and formatting

- Indent with tabs
- Lines under 100 columns
- Comments wrapped to 80 columns
- One statement per line
- Space before/after operators
- Space after commas
- Trailing commas in multi-line tables
- No vertical alignment
- Single empty line between logical groups
- No semicolons

### Strings

Use double quotes:

```luau
-- Good
print("Here's a message!")

-- Acceptable if string has many double quotes
print('Quoth the raven, "Nevermore"')
```

### pcall patterns

Use explicit anonymous functions over method shorthand:

```luau
-- Good
pcall(function()
    part:Destroy()
end)

-- Bad
pcall(part.Destroy, part)  -- confusing to read
```

### assert usage

Always provide a constant error message:

```luau
-- Good
assert(typeof(x) == "number", "damage must be a number")

-- Bad
assert(typeof(x) == "number", generateErrorMessage(x))
```

## Common Patterns

### Module return pattern

```luau
local MySystem = {}

-- public API
function MySystem.Enable()
    -- ...
end

function MySystem.Process(player: Player): Result
    -- ...
end

return MySystem
```

### Service access

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
```

### UDim2 helpers

```luau
-- Good
local size = UDim2.fromOffset(200, 50)
local scale = UDim2.fromScale(0.5, 0.5)

-- Bad
local size = UDim2.new(0, 200, 0, 50)
```

### Optional arguments

Make optionality explicit with `?`:

```luau
local function playSound(sound: Sound, volume: number?)
    local clone = sound:Clone()
    clone.Volume = volume or 0.5
    clone.Parent = SoundService
    clone:Play()
end
```

## What to Avoid

| Pattern | Why | Alternative |
| --------- | ----- | ------------- |
| Dynamic requires | Breaks static typing | Static requires at top of file |
| Deep copy | Wasteful, unnecessary with immutability | Shallow clone + targeted mutation |
| Metatables for magic | Hard to trace, debug | Plain tables, explicit class pattern |
| `x and y or z` ternary | Breaks with falsy values | `if-then-else` expressions |
| String/table call syntax | Harder to parse | Normal function calls |
| `script.Parent` in public APIs | Brittle to refactoring | Absolute paths via common ancestor |
| Commented-out code | git has history | Delete it |
| Historical comments | Noise for future readers | Explain current intent only |
| Hiding builtins (`local insert = table.insert`) | Outdated optimization | Use `table.insert` directly |

## Roblox-Specific

- Use `GetService` for all services (even if direct access like `game.Players` works)
- Put scripts inside other scripts only as implementation details
- Use absolute paths. Avoid going up more than one `Parent`
- For React/Roact: use `e = React.createElement`, use `native` tables
- Guard enum tables with `__index` that throws on invalid keys
