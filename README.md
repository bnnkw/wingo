# wingo

![wingo](wingo.png)

A Vim plugin to go to any window across all tabs.

## Requirements

- +vim9script
- +popupwin

## Features

- List all windows across all tab pages
- Go to the selected window
- Preview buffer contents
- History that works like jumplist

## Installation

### vim-plug

```vim
Plug 'bnnkw/wingo'
```

## Command

| Command | Description |
|-----|--------|
| `WinGo` | Open a popup menu listing all windows across all tab pages. |
| `WinGoHistory` | Show the history. |
| `WinGoHistoryClear` | Clear the history. |
| `WinGoHistoryPrev` | Go to the previous window in the history. |
| `WinGoHistoryNext` | Go to the next window in the history. |

## Mapping Example

```vim
nnoremap <C-W>gl <Cmd>WinGo<CR>
tnoremap <C-W>gl <Cmd>WinGo<CR>
nnoremap <C-W>gg <Cmd>WinGoHistory<CR>
tnoremap <C-W>gg <Cmd>WinGoHistory<CR>
nnoremap <C-W>go <Cmd>WinGoHistoryPrev<CR>
tnoremap <C-W>go <Cmd>WinGoHistoryPrev<CR>
nnoremap <C-W>gi <Cmd>WinGoHistoryNext<CR>
tnoremap <C-W>gi <Cmd>WinGoHistoryNext<CR>
```

### WinGo Popup Menu

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
