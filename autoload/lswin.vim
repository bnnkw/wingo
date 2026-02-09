vim9script

var preview_winid: number = 0
var entries: list<dict<any>> = []

def ListWindows(): list<number>
  var result: list<number> = []
  var tabnr_last = tabpagenr('$')

  for tabnr in range(1, tabnr_last)
    var buflist = tabpagebuflist(tabnr)
    for winnr in range(1, len(buflist))
      result->add(win_getid(winnr, tabnr))
    endfor
  endfor

  return result
enddef

def WindowToEntry(winid: number): dict<any>
  var [tabnr, winnr] = win_id2tabwin(winid)
  var bufnr = winbufnr(winid)
  return {
    tabnr: tabnr,
    winnr: winnr,
    winid: winid,
    bufnr: bufnr,
    bufname: bufname(bufnr),
    modified: getbufvar(bufnr, '&modified'),
    current: winid == win_getid(),
  }
enddef

def WindowsToEntries(winids: list<number>): list<dict<any>>
  return winids->mapnew((_, id) => WindowToEntry(id))
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
    win_gotoid(entries[result - 1].winid)
  else
    win_gotoid(entries->copy()->filter((_, e) => e.current)[0].winid)
  endif
enddef

export def Run()
  var winids = ListWindows()
  if empty(winids)
    return
  endif

  entries = WindowsToEntries(winids)

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
