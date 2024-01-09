vim9script

# Needs the matchbufline() function introduced in 9.1.0009
if !exists('*matchbufline')
  finish
endif

import '../autoload/searchcomplete.vim'

# Map <Tab> and <S-Tab> to complete the match from the words in the current
# buffer
cnoremap <Tab> <C-R>=searchcomplete#SearchComplete(v:true)<CR>
cnoremap <S-Tab> <C-R>=searchcomplete#SearchComplete(v:false)<CR>

# vim: ts=8 sw=2 sts=2 expandtab tw=80 fdm=marker
