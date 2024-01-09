vim9script

var searchMatches: list<string> = []
var prevMatchIndex: number = 0
var prevCmdline: string = ''
var prevCmdlinePrefix: string = ''
var prevPat: string = ''

export def SearchComplete(forward: bool): string
  var cmdtype: string = getcmdtype()
  if cmdtype != '/' && cmdtype != '?'
    feedkeys(forward ? "\<Tab>" : "\<S-Tab>", 'nt')
    return ''
  endif

  var cmdline: string = getcmdline()
  if cmdline != '' && cmdline ==# prevCmdline
    # Jump to the next/previous match
    if (cmdtype == '/' && forward) || (cmdtype == '?' && !forward)
      prevMatchIndex += 1
    else
      prevMatchIndex -= 1
    endif
    if prevMatchIndex < 0
      prevMatchIndex = searchMatches->len() - 1
    elseif prevMatchIndex >= searchMatches->len()
      prevMatchIndex = 0
    endif

    var s: string = searchMatches[prevMatchIndex][strlen(prevPat) : ]

    prevCmdline = prevCmdlinePrefix .. s
    setcmdline(prevCmdlinePrefix)
    return s
  endif

  var cmdpos: number = getcmdpos()

  var start: number = cmdpos - 1
  if start >= strlen(cmdline)
    start -= 1
  endif
  while start > 0 && cmdline[start - 1] =~ '\k'
    start -= 1
  endwhile
  var pat: string = cmdline[start : cmdpos]

  # Get the List of matches
  var start_lnum = &wrapscan || cmdtype == '?' ? 1 : line('.')
  var end_lnum = &wrapscan || cmdtype == '/' ? '$' : line('.')
  var l = matchbufline('', $'\<{pat}\k\+\>', start_lnum, end_lnum)
  if l->empty()
    return ''
  endif

  var curline = line('.')
  var curcol = col('.')
  var patStartByte = curcol - 1 - strlen(pat)

  l->filter((_, v) => v.lnum == curline ? cmdtype == '/' ? v.byteidx >= patStartByte : v.byteidx <= patStartByte : true)
  if l->empty()
    return ''
  endif

  # Sort by matched string
  l->sort((a, b) => {
    if a.text > b.text
      return 1
    elseif a.text == b.text
      if a.lnum > b.lnum
        return 1
      elseif a.lnum == b.lnum
        return a.byteidx > b.byteidx ? 1 : 0
      endif
      return 0
    endif
    return 0
  })
  # Remove duplicates
  l->uniq((a, b) => a.text ==# b.text ? 0 : 1)
  # Sort by byte index and line number
  l->sort((a, b) => a.lnum == b.lnum ? a.byteidx - b.byteidx : a.lnum - b.lnum)

  var startIdx: number
  if cmdtype == '/'
    startIdx = l->indexof((_, v) => v.lnum == curline ? v.byteidx >= patStartByte : v.lnum > curline)
  else
    startIdx = l->copy()->reverse()->indexof((_, v) => v.lnum == curline ? v.byteidx <= patStartByte : v.lnum < curline)
    startIdx = l->len() - startIdx - 1
  endif
  
  if startIdx == -1
    startIdx = forward ? 0 : searchMatches->len() - 1
  endif

  # Save the matched strings
  searchMatches = l->map((_, v) => v.text)

  var s = searchMatches[startIdx][strlen(pat) : ]

  # Save the state for jumping to the next previous match
  prevMatchIndex = startIdx
  prevPat = pat
  prevCmdline = cmdline .. s
  prevCmdlinePrefix = cmdline

  return s
enddef

# vim: ts=8 sw=2 sts=2 expandtab tw=80 fdm=marker
