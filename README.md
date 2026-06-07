<p align="center">
  <img src="https://github.com/user-attachments/assets/3974848c-8bcd-4c99-a8e0-27eb7b1559c1" alt="Hue Banner" width="1024">
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
  - [Piped Input](#piped-input)
    - [Inline styles in piped content](#inline-styles-in-piped-content)
    - [Global styles with piped input](#global-styles-with-piped-input)
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
hue() { bash /path/to/hue/src/hue.sh "$@"; }
 
hue :text-green "✔ Done"
hue :text-red   "✘ Failed"
```
 
This is ideal for internal tooling or CI environments where you can't install system binaries.
 
---

## Piped Input
 
Hue can read from stdin, so you can pipe any text source directly into it.
 
```bash
cat content.txt | hue
echo "hello world" | hue
```
 
### Inline styles in piped content
 
Write utility tokens directly inside the piped text — at the start of a line, or anywhere mid-sentence. Hue parses each line the same way it parses command arguments: tokens beginning with `:` or `.` are treated as style utilities, and everything else is printed content.
 
```
# content.txt
:text-green This line is green
:bold :text-red This line is bold red
Just a plain unstyled line
```
 
```bash
cat content.txt | hue
```
 
Styles can also change mid-sentence. Each utility token shifts the active style for the words that follow it on the same line:
 
```
# content.txt
:text-green This line is green except this :text-red red word
The :underline quick :reset brown :bold fox
```
 
Style changes are **line-scoped** — they do not carry over to the next line. Each line starts fresh.
 
### Global styles with piped input
 
Pass utilities after `hue` to set a **global style** that applies to every line of the piped content. Per-line styles in the content layer on top of, or override, the global style.
 
```bash
# Every line is dimmed by default
cat content.txt | hue :dim
```
 
```bash
# Every line is bold white; per-line color overrides still work
cat content.txt | hue :bold :text-white
```
 
A practical use case - tailing a log file with a base style, while the file itself marks warnings and errors with their own colors:
 
```
# app.log
Server started on port 3000
:text-yellow WARN  Missing optional config key "timeout"
:text-red    ERROR Connection refused — retrying in 5s
Request from 192.168.1.1 — 200 OK
```
 
```bash
tail -f app.log | hue :dim
```
 
Plain log lines appear dimmed; warning and error lines override the global dim with their own colors.
 
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
- In piped mode, each line is tokenized and processed independently; styles do not bleed across lines.
The entire tool runs in a single pass over its arguments. No subshells, no temp files, no external commands.
 
---
 
## License
 
MIT — see [LICENSE](LICENSE) for details.
