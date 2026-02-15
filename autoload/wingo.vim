vim9script

var winid_opening_popup: number = 0

var preview_winid: number = 0
var entries: list<dict<any>> = []

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
    var selected = entries[result - 1].winid
    if selected != winid_opening_popup
      PushHistory(winid_opening_popup)
    endif
    win_gotoid(selected)
  else
    win_gotoid(entries->copy()->filter((_, e) => e.current)[0].winid)
  endif
enddef

const AUGROUP_WIN_CLOSED = 'wingo_win_closed'
const HISTORY_MAX = 10
var history: list<number> = []
var history_pos: number = -1

def CurrentHistory(): number
  if 0 <= history_pos && history_pos < len(history)
    return history[history_pos]
  else
    return 0
  endif
enddef

def IsOldest(): bool
  return history_pos == 0
enddef

def IsNewest(): bool
  return history_pos == len(history) - 1
enddef

def IndexHistory(winid: number): number
  for i in range(len(history))
    if history[i] == winid
      return i
    endif
  endfor
  return -1
enddef

def OnWinClosed(winid: number)
  var idx = IndexHistory(winid)
  if idx == -1
    throw $'WinGo: attempt to remove winid {winid} from the history, but the window does not exist in the history {history}.'
  endif

  var acmds = []
  for id in history[idx + 1 :]
    add(acmds, {
      group: AUGROUP_WIN_CLOSED,
      event: 'WinClosed',
      pattern: $'{id}',
    })
  endfor
  autocmd_delete(acmds)

  if idx == 0
    history = []
  else
    history = history[0 : idx - 1]
  endif
  history_pos = -1
enddef

export def GetHistoryState(): dict<any>
  return { history: copy(history), pos: history_pos }
enddef

export def Run()
  winid_opening_popup = win_getid()
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
    var marker = i == history_pos ? '>' : ' '
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
  try
    autocmd_delete([{group: AUGROUP_WIN_CLOSED}])
  catch /.*E367/
    # the group does not exist.
    return
  endtry
enddef

export def PushHistory(winid: number)
  if !empty(history) && history[len(history) - 1] == winid
    history_pos = -1
    return
  endif

  if history_pos != -1
    var acmds = []
    for id in history[history_pos + 1 :]
      add(acmds, {
        group: AUGROUP_WIN_CLOSED,
        event: 'WinClosed',
        pattern: $'{id}',
      })
    endfor
    autocmd_delete(acmds)

    history = history[: history_pos]
    history_pos = -1
    return
  endif

  if len(history) >= HISTORY_MAX
    autocmd_delete([{
      group: AUGROUP_WIN_CLOSED,
      event: 'WinClosed',
      pattern: $'{history[0]}',
    }])
    history = history[1 : ]
  endif

  add(history, winid)
  autocmd_add([{
      group: AUGROUP_WIN_CLOSED,
      event: 'WinClosed',
      pattern: $'{winid}',
      once: v:true,
      replace: v:true,
      cmd: "OnWinClosed(str2nr(expand('<amatch>')))",
  }])
  history_pos = -1
enddef

export def PrevHistory()
  if IsOldest()
    echohl ErrorMsg
      | echomsg 'WinGo: already at oldest history entry'
      | echohl None
    return
  endif
  if history_pos == -1
    history_pos = len(history) - 1
  else
    history_pos = history_pos - 1
  endif
enddef

export def NextHistory()
  if IsNewest()
    echohl ErrorMsg
      | echomsg 'WinGo: already at newest history entry'
      | echohl None
    return
  endif
  history_pos = history_pos + 1
enddef

export def GoHistoryPrev(cur: number)
  if IsOldest()
    return
  endif

  if history_pos == -1
    PushHistory(cur)
    history_pos = len(history) - 2
  else
    PrevHistory()
  endif

  var winid = CurrentHistory()
  win_gotoid(winid)
enddef

export def GoHistoryNext()
  if IsNewest()
    return
  endif

  NextHistory()
  var winid = CurrentHistory()
  win_gotoid(winid)
enddef
