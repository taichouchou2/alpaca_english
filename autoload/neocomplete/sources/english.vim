let s:source = {
      \ 'name' : 'english',
      \ 'kind' : 'manual',
      \ 'mark' : '[en]',
      \ 'max_candidates' : get(g:, 'alpaca_english_max_candidates', 20),
      \ 'min_pattern_length' : 3,
      \ 'is_volatile': 1,
      \ }

function! neocomplete#sources#english#define() "{{{
  return alpaca_english#is_active() ? s:source : {}
endfunction"}}}

function! neocomplete#sources#english#to_candidates(dict) "{{{
  let result = []
  for record in a:dict
    let candidate = {
          \ 'word' : record[1],
          \ 'abbr' : record[1]. ' '. record[2],
          \ 'menu' : '[EN]',
          \ 'dup' : g:alpaca_english_enable_duplicate_candidates,
          \ 'info': record[2],
          \ }
    call add(result, candidate)
  endfor

  return result
endfunction"}}}

function! s:source.gather_candidates(context) "{{{
  if !get(b:, 'alpaca_english_enable', g:alpaca_english_enable) ||
        \ (neocomplete#is_text_mode() && a:context.complete_str !~# '[[:alpha:]]\+$')
    return []
  endif

  let result = alpaca_english#sqlite#search(a:context.complete_str)

  return neocomplete#sources#english#to_candidates(result)
endfunction"}}}
