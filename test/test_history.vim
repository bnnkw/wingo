vim9script

import autoload '../autoload/wingo.vim'

def Test_PushHistory_ignore_duplicated()
  wingo.ClearHistory()
  wingo.PushHistory(1000)
  wingo.PushHistory(1000)
  var state = wingo.GetHistoryState()
  assert_equal([1000], state.history)
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
  assert_equal(1, state.pos)
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
  assert_equal(0, state.pos)
enddef

def Test_HistorySize_does_not_exceed_max()
  wingo.ClearHistory()
  for i in range(7)
    wingo.PushHistory(2000 + i)
  endfor
  var state = wingo.GetHistoryState()
  assert_equal([2002, 2003, 2004, 2005, 2006], state.history)
  assert_equal(-1, state.pos)
enddef

Test_PushHistory_ignore_duplicated()
Test_PrevHistory_clamps_at_oldest()
Test_NextHistory_clamps_at_newest()
Test_HistorySize_does_not_exceed_max()

if empty(v:errors)
  writefile(["OK: All tests passed"], 'test_result/ok')
else
  writefile([printf("NG: %d test(s) failed:", len(v:errors))] + v:errors, 'test_result/error')
  cquit!
endif
