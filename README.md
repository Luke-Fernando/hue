<p align="center">
  <img src="https://github.com/user-attachments/assets/3aeb72f8-adf5-4d8a-98b6-8c8c1a1e959b" alt="Hue Banner" width="1024">
</p>

# Hue
 
**Tailwind-flavored terminal colors for your shell scripts.**
 
Hue is a lightweight Bash CLI tool that lets you style terminal output using intuitive, Tailwind-like utility names. No ANSI escape codes to memorize, no dependencies to install. Inspired by [`ansi`](https://github.com/fidian/ansi).
 
```bash
hue :text-green :bold "✔ Build succeeded" :reset " in " :text-cyan "1.42s"
```
 
---
 
## Table of Contents
 
- [Hue](#hue)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
  - [Syntax](#syntax)
    - [How Styles Work](#how-styles-work)
    - [Colors](#colors)
    - [Text Modifiers](#text-modifiers)
    - [Resetting Styles](#resetting-styles)
  - [Examples](#examples)
  - [Using Hue in Scripts](#using-hue-in-scripts)
    - [System-wide install (recommended)](#system-wide-install-recommended)
    - [Inline function (no install needed)](#inline-function-no-install-needed)
  - [NO\_COLOR Support](#no_color-support)
  - [Commands](#commands)
  - [How It Works](#how-it-works)
  - [License](#license)
---
 
## Installation
 
**Clone the repository and run the install script:**
 
```bash
git clone https://github.com/Luke-Fernando/hue.git
cd hue
chmod +x install.sh
./install.sh
```
 
The install script places `hue` on your `PATH` so it's available system-wide as a plain command.
 
> **Requirements:** Bash 4.0 or newer (uses associative arrays).
 
---
 
## Quick Start
 
```bash
hue :text-green "Hello, world!"
hue :text-yellow :bold "Warning: disk space low"
hue :bg-red :text-white " ERROR " :reset " Something went wrong"
```
 
---
 
## Syntax
 
```
hue <content|utility> [<content|utility> ...]
```
 
- **Utility** — starts with `:` (add a style) or `.` (remove a style)
- **Content** — any other argument; printed with the currently active styles
You can chain as many utilities and content strings as you like in a single command.
 
### How Styles Work
 
Hue uses a **global + local** style model:
 
| Phase                           | What happens                                                                                  |
| ------------------------------- | --------------------------------------------------------------------------------------------- |
| Before the first content string | Every utility added becomes a **global style** (applied to all subsequent strings by default) |
| After the first content string  | Utilities only affect the **next** content string, then revert to the global styles           |
 
```bash
# "ERROR" and "WARN" both inherit the global :text-red style.
# "INFO" temporarily overrides it to blue, then reverts.
hue :text-red "ERROR" "WARN" :text-blue "INFO" "WARN again"
```
 
```bash
# Remove a style mid-string without resetting everything.
hue :text-red :bold "bold red" .bold "just red" "still bold red"
```
 
Use `.` to **remove** a specific style from the current context.
 
### Colors
 
The 8 standard terminal colors are supported, each available as foreground, foreground-bright, background, and background-bright (16 total variants).
 
| Color name | Variants                                                                     |
| ---------- | ---------------------------------------------------------------------------- |
| `black`    | `:text-black`, `:text-black-bright`, `:bg-black`, `:bg-black-bright`         |
| `red`      | `:text-red`, `:text-red-bright`, `:bg-red`, `:bg-red-bright`                 |
| `green`    | `:text-green`, `:text-green-bright`, `:bg-green`, `:bg-green-bright`         |
| `yellow`   | `:text-yellow`, `:text-yellow-bright`, `:bg-yellow`, `:bg-yellow-bright`     |
| `blue`     | `:text-blue`, `:text-blue-bright`, `:bg-blue`, `:bg-blue-bright`             |
| `magenta`  | `:text-magenta`, `:text-magenta-bright`, `:bg-magenta`, `:bg-magenta-bright` |
| `cyan`     | `:text-cyan`, `:text-cyan-bright`, `:bg-cyan`, `:bg-cyan-bright`             |
| `white`    | `:text-white`, `:text-white-bright`, `:bg-white`, `:bg-white-bright`         |
 
### Text Modifiers
 
| Utility      | Description                           |
| ------------ | ------------------------------------- |
| `:bold`      | Bold / increased intensity            |
| `:dim`       | Dimmed / faint                        |
| `:italic`    | Italic                                |
| `:underline` | Underline                             |
| `:invert`    | Swap foreground and background colors |
 
Combine freely with color utilities:
 
```bash
hue :text-cyan :underline "Click here"
hue :bg-yellow :text-black :bold " NOTE "
```
 
### Resetting Styles
 
`:reset` clears **all** active styles at that point in the chain.
 
```bash
hue :text-red "This is red" :reset "and this is plain"
```
 
---
 
## Examples
 
**Colored log levels**
```bash
hue :bg-red    :text-white :bold " ERROR " :reset :text-red   " $error_msg"
hue :bg-yellow :text-black :bold " WARN  " :reset :text-yellow " $warn_msg"
hue :bg-green  :text-black :bold "  OK   " :reset :text-green  " $ok_msg"
hue :bg-blue   :text-white :bold " INFO  " :reset              " $info_msg"
```
 
**Build status banner**
```bash
hue :text-green :bold "✔ Build passed" :reset " — " :text-cyan "42 tests" :reset ", " :text-yellow "2 warnings"
```
 
**Highlight a value inside plain text**
```bash
hue "Deploying to " :text-magenta :bold "$ENV" :reset " — please wait..."
```
 
**Mixed modifiers**
```bash
hue :text-blue :underline "https://example.com"
hue :dim "Last updated: " :reset :italic "2 minutes ago"
```
 
**Remove one style without resetting the rest**
```bash
# Start with bold red, then drop bold but keep red, then restore both
hue :text-red :bold "Bold red" .bold "Regular red" :bold "Bold red again"
```
 
**Invert colors for selection/highlight effect**
```bash
hue :invert " selected item " :reset " unselected item"
```
 
---
 
## Using Hue in Scripts
 
### System-wide install (recommended)
 
After running `install.sh`, simply call `hue` anywhere:
 
```bash
#!/bin/bash
hue :text-green "Dependencies installed."
hue :text-yellow "Running tests..."
```
 
### Inline function (no install needed)
 
Embed Hue into a single script without installing it globally:
 
```bash
#!/bin/bash
 
# Point this to wherever you cloned the repo
hue() { bash /path/to/hue/hue.sh "$@"; }
 
hue :text-green "✔ Done"
hue :text-red   "✘ Failed"
```
 
This is ideal for internal tooling or CI environments where you can't install system binaries.
 
---
 
## NO_COLOR Support
 
Hue respects the [`NO_COLOR`](https://no-color.org/) convention. When the `NO_COLOR` environment variable is set, all styling is stripped and only the raw text is printed — great for log files, CI pipelines, and accessibility.
 
```bash
NO_COLOR=1 hue :text-red "This prints as plain text"
```
 
---
 
## Commands
 
| Flag                       | Description               |
| -------------------------- | ------------------------- |
| `hue -h` / `hue --help`    | Show usage information    |
| `hue -v` / `hue --version` | Print the current version |
 
---
 
## How It Works
 
Hue is a single, self-contained Bash script with zero dependencies.
 
- Color codes are **computed on the fly** from lookup tables using standard ANSI offset arithmetic. No hardcoded escape sequences per color.
- Styles accumulate into a **global array** and a **per-string array**; after each content token the per-string array resets to the global state.
- The `.` prefix filters a specific utility out of both arrays without touching the others.
- Output is produced with `printf` and wrapped in `\e[…m … \e[0m` escape sequences.
- When `NO_COLOR` is set, the entire styling path is skipped.
The entire tool runs in a single pass over its arguments. No subshells, no temp files, no external commands.
 
---
 
## License
 
MIT — see [LICENSE](LICENSE) for details.
