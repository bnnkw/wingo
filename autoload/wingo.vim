vim9script

var preview_winid: number = 0
var entries: list<dict<any>> = []

const HISTORY_MAX = 5
var history: list<number> = []
var history_pos: number = -1

def WindowToEntry(win: dict<any>): dict<any>
  var cur_bufnr = winbufnr(0)
  return {
    tabnr: win.tabnr,
    winnr: win.winnr,
    winid: win.winid,
    bufnr: win.bufnr,
    bufname: bufname(win.bufnr),
    modified: getbufvar(win.bufnr, '&modified'),
    current: cur_bufnr == win.bufnr,
  }
enddef

def WindowsToEntries(wins: list<dict<any>>): list<dict<any>>
  return wins->mapnew((_, w) => WindowToEntry(w))
enddef

def FormatEntry(entry: dict<any>): string
  var marker = entry.current ? '>' : ' '
  var mod = entry.modified ? ' [+]' : ''
  var name = empty(entry.bufname) ? '[No Name]' : fnamemodify(entry.bufname, ':~:.')

  return printf('%s Tab:%d Win:%d%s %s', marker, entry.tabnr, entry.winnr, mod, name)
enddef

def FormatEntries(items: list<dict<any>>): list<string>
  return items->mapnew((_, e) => FormatEntry(e))
enddef

def ShowPreview(menu_winid: number, wininfo: dict<any>)
  var bufnr = wininfo.bufnr
  var lines = getbufline(bufnr, wininfo.topline, wininfo.topline + 20)

  var menu_pos = popup_getpos(menu_winid)
  var col = menu_pos.col + menu_pos.width + 1
  var line_nr = menu_pos.line

  preview_winid = popup_create(lines, {
    line: line_nr,
    col: col,
    title: ' Preview ',
    minwidth: 40,
    maxwidth: 40,
    padding: [0, 1, 0, 1],
  })
enddef

def MenuFilter(id: number, key: string): bool
  # Toggle preview
  if key == 'p'
    if preview_winid > 0
      popup_close(preview_winid)
      preview_winid = 0
      return true
    endif
    var info = getwininfo(entries[line('.', id) - 1].winid)
    if !empty(info)
      ShowPreview(id, info[0])
    endif
    return true
  endif

  popup_close(preview_winid)
  preview_winid = 0

  if key == 'J'
    win_execute(id, 'normal j')
    var info = getwininfo(entries[line('.', id) - 1].winid)
    if !empty(info)
      win_gotoid(info[0].winid)
    endif
    return true
  endif

  if key == 'K'
    win_execute(id, 'normal k')
    var info = getwininfo(entries[line('.', id) - 1].winid)
    if !empty(info)
      win_gotoid(info[0].winid)
    endif
    return true
  endif

  return popup_filter_menu(id, key)
enddef

def MenuCallback(id: number, result: number)
  if result > 0
    PushHistory(win_getid())
    win_gotoid(entries[result - 1].winid)
  else
    win_gotoid(entries->copy()->filter((_, e) => e.current)[0].winid)
  endif
enddef

export def GetHistoryState(): dict<any>
  return { history: copy(history), pos: history_pos }
enddef

export def Run()
  var wins = getwininfo()
  entries = WindowsToEntries(wins)
  var menu_id = popup_menu(FormatEntries(entries), {
    pos: 'center',
    title: ' Windows ',
    filter: MenuFilter,
    callback: MenuCallback,
    minwidth: 40,
    maxwidth: 40,
    maxheight: &lines / 3,
    tabpage: -1,
  })
enddef

export def ShowHistory()
  var lines = ['  history tab win bufname']
  var len = len(history)
  for i in range(len)
    var info = getwininfo(history[i])
    if empty(info)
      continue
    endif
    var marker = len - (i + 1) == history_pos ? '>' : ' '
    var win = info[0]
    add(lines, printf('%s %4d %5d %5d %s',
      marker, len - i, win.tabnr, win.winid, bufname(win.bufnr)))
  endfor
  if history_pos == -1
    add(lines, '>')
  endif
  echo join(lines, "\n")
enddef

export def ClearHistory()
  history = []
  history_pos = -1
enddef

export def PushHistory(winid: number)
  if !empty(history) && history[len(history) - 1] == winid
    return
  endif
  if len(history) >= HISTORY_MAX
    history = history[1 : ]
  endif
  add(history, winid)
enddef

export def PrevHistory()
  if history_pos >= len(history) - 1
    echohl ErrorMsg
      | echomsg 'WinGo: already at oldest history entry'
      | echohl None
    return
  endif
  history_pos = history_pos + 1
enddef

export def NextHistory()
  if history_pos <= 0
    echohl ErrorMsg
      | echomsg 'WinGo: already at newest history entry'
      | echohl None
    return
  endif
  history_pos = history_pos - 1
enddef
