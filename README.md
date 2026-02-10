# wingo

![wingo](wingo.png)

A Vim plugin to go to any window across all tabs.

## Features

- List all windows across all tab pages
- Go to the selected window with Enter
- Preview buffer contents

## Entry Format

```
> Tab:1 Win:2 [+] vimrc
```

| Element | Description |
|---------|-------------|
| `>` | Current window |
| `Tab:N` | Tab number |
| `Win:N` | Window number within the tab |
| `[+]` | Unsaved changes |
| `[No Name]` | Unnamed buffer |

## Installation

### vim-plug

```vim
Plug 'bnnkw/wingo'
```

## Usage

```vim
:WinLs
```

## Mapping Example

```vim
nnoremap gl <Cmd>WinLs<CR>
```

## Key Bindings

| Key | Action |
|-----|--------|
| `j` / `<Down>` / `<C-n>` | Select item below |
| `J` | Select item below and go to the window |
| `k` / `<Up>` / `<C-p>` | Select item above |
| `K` | Select item above and go to the window |
| `<Space>` / `<Enter>` | Accept selection and go |
| `p` | Toggle preview of the selected window |
| `x` / `<Esc>` / `<C-c>` | Cancel |

## Requirements

- +vim9script
- +popupwin
