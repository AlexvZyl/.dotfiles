scriptencoding utf-8

if has("nvim")
  " overwrite coc#ui#echo_messages function to use notify
  function! coc#ui#echo_messages(hl, msgs)
    if a:hl !~# 'Error' && (mode() !~# '\v^(i|n)$')
      return
    endif
    let msgs = filter(copy(a:msgs), '!empty(v:val)')
    if empty(msgs)
      return
    endif
    " map a:hl highlight groups to notify levels
    " if hl matches Error then level is error
    " if hl matches Warning then level is warn
    " otherwise level is info
    let level = 'info'
    if a:hl =~# 'Error'
      let level = 'error'
    elseif a:hl =~# 'Warning'
      let level = 'warn'
    endif
    let msg = join(msgs, '\n')
    call v:lua.coc_notify(msg, level)
  endfunction

  function! coc#ui#echo_lines(lines)
    let msg = join(a:lines, "\n")
    call v:lua.coc_notify(msg, 'info')
  endfunction
endif

