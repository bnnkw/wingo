vim9script

import autoload 'wingo.vim'

command! WinGo wingo.Run()
command! WinGoHistory wingo.ShowHistory()
command! WinGoHistoryClear wingo.ClearHistory()
command! WinGoHistoryPrev wingo.GoHistoryPrev(win_getid())
command! WinGoHistoryNext wingo.GoHistoryNext()
