Vim9 plugin to support word completion in the search prompt from the words in the current buffer.

Needs the matchbufline() function introduced in Vim 9.1.0009.

When searching for a match using the `/` or `?` commands, after typing a few characters, press `<Tab>` to complete the word from the current buffer.  This will complete the first match.  Press `<Tab>` again to go to the next match.  Press `<S-Tab>` to go to the previous match.  After reaching the last match, `<Tab>` will wrap around to the first match.

The `wrapscan` and `incsearch` option settings will impact the list of matches that are shown.
