vim9script

import autoload '../autoload/wingo.vim'

mkdir('test_result', 'p')

def Test_PushHistory_ignore_duplicated()
  wingo.ClearHistory()
  wingo.PushHistory(1000)
  wingo.PushHistory(1000)
  wingo.PushHistory(1001)
  var state = wingo.GetHistoryState()
  assert_equal([1000, 1001], state.history)
  assert_equal(-1, state.pos)
enddef

def Test_PushHistory_on_middle()
  #   1000 #   1000
  # > 1001 #   1001
  #   1002 # >
  #   1003
  wingo.ClearHistory()
  wingo.PushHistory(1000)
  wingo.PushHistory(1001)
  wingo.PushHistory(1002)
  wingo.PushHistory(1003)
  wingo.PrevHistory()
  wingo.PrevHistory()
  wingo.PrevHistory()
  wingo.PushHistory(1004)
  var state = wingo.GetHistoryState()
  assert_equal([1000, 1001], state.history)
  assert_equal(-1, state.pos)
enddef

def Test_PrevHistory_clamps_at_oldest()
  wingo.ClearHistory()
  wingo.PushHistory(1000)
  wingo.PushHistory(1001)
  wingo.PrevHistory()
  wingo.PrevHistory()
  wingo.PrevHistory()
  var state = wingo.GetHistoryState()
  assert_equal([1000, 1001], state.history)
  assert_equal(0, state.pos)
enddef

def Test_NextHistory_clamps_at_newest()
  wingo.ClearHistory()
  wingo.PushHistory(1000)
  wingo.PushHistory(1001)
  wingo.PrevHistory()
  wingo.PrevHistory()
  wingo.NextHistory()
  wingo.NextHistory()
  var state = wingo.GetHistoryState()
  assert_equal([1000, 1001], state.history)
  assert_equal(1, state.pos)
enddef

def Test_HistorySize_does_not_exceed_max()
  wingo.ClearHistory()
  for i in range(20)
    wingo.PushHistory(1000 + i)
  endfor
  var state = wingo.GetHistoryState()
  assert_equal([
    1010, 1011, 1012, 1013, 1014,
    1015, 1016, 1017, 1018, 1019,
    ], state.history)
  assert_equal(-1, state.pos)
enddef

def Test_GoHistoryPrev()
  wingo.ClearHistory()
  #   1000 #   1000
  #   1001 #   1001
  #   1002 # > 1002
  # >      #   1003
  wingo.PushHistory(1000)
  wingo.PushHistory(1001)
  wingo.PushHistory(1002)
  wingo.GoHistoryPrev(1003)
  var state = wingo.GetHistoryState()
  assert_equal([1000, 1001, 1002, 1003], state.history)
  assert_equal(2, state.pos)
enddef

try
  Test_PushHistory_ignore_duplicated()
  Test_PrevHistory_clamps_at_oldest()
  Test_PushHistory_on_middle()
  Test_NextHistory_clamps_at_newest()
  Test_HistorySize_does_not_exceed_max()
  Test_GoHistoryPrev()
catch /.*/
  writefile([printf("\e[1;31mNG\e[m: caught %s", v:exception)], 'test_result/error')
  cquit!
finally
  if empty(v:errors)
    writefile(["\e[1;32mOK\e[m: All tests passed"], 'test_result/ok')
  else
    writefile([printf("\e[1;31mNG\e[m: %d test(s) failed:", len(v:errors))] + v:errors, 'test_result/error')
    cquit!
  endif
endtry
