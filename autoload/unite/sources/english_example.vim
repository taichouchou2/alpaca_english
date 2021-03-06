"=============================================================================
" FILE: example.vim
" AUTHOR: Ishii Hiroyuki <alprhcp666@gmail.com>
" Last Modified: 2013-05-12
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
let s:unite_source = {
      \ 'name': 'english_example',
      \ 'hooks' : {},
      \ 'syntax' : 'uniteSource__Output',
      \ 'description' : 'show example',
      \}

function! s:to_canditates(result) "{{{
  let canditates = []
  for canditate in a:result
    let candidate = {
          \ 'word' : canditate['example'] . "\n" . canditate['transrate'],
          \ '__unite_english' : canditate['example'],
          \ '__unite_transrate' : canditate['transrate'],
          \ 'is_multiline' : 1,
          \ }
    call add(canditates, candidate)
  endfor

  return canditates
endfunction"}}}

function! s:unite_source.gather_candidates(args, context) "{{{
  call alpaca_english#initialize()
  let input = unite#english_util#get_input(a:context)

  " TODO リファクタリング
  ruby << EOF
  require 'mechanize'

  word = RubyVIM.get("input")
  condition = if word.match(/^[a-zA-Z]+$/) then
                %w[qotCE qotCJ]
              else
                %w[qotCJJ qotCJE]
              end

  agent = Mechanize.new
  page = agent.get("http://ejje.weblio.jp/sentence/content/#{word}")
  example_list = page.search(%q!//div[@class='kiji']/div[@class='qotC']!)

  complete = []
  example_list.each do |example|
    res = {}
    res["example"] = example.search(%Q!p[@class='#{condition[0]}']!).first.text.split("\n")[0]
    mean_text = example.search(%Q!p[@class='#{condition[1]}']!).first.text.split("\n")[0]
    mean_array = mean_text.split("-")
    # mean_array = mean_text.split(" - ")
    res["transrate"] = mean_array.first.chomp
    res["dict"] = mean_array.last.chomp
    complete << res
  end

  RubyVIM.let("result", complete)
EOF

  if input =~ '^\s*$' || empty(result)
    return [{"word" : "error occurd", "is_dummy" : 1}]
  else
    return s:to_canditates(result)
  endif
endfunction"}}}

function! s:unite_source.hooks.on_syntax(args, context) "{{{
  " TODO
endfunction"}}}

function! unite#sources#english_example#define() "{{{
  return alpaca_english#is_active() ? s:unite_source : {}
endfunction"}}}
"}}}
