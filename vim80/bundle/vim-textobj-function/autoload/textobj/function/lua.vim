" textobj-function - Text objects for functions
" Version: 0.4.0
" Copyright (C) 2014 Kana Natsuno <http://whileimautomaton.net/>
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

let s:FUNCTION_PATTERNS = {
\   'begin': '\v(^|\s+)@<=function\s*\([^)]*\)',
\   'end': '\v(^|\s)@<=end($|\s|\))@=',
\ }


function! textobj#function#lua#select(object_type)
  return s:select_{a:object_type}()
endfunction

function! s:select_a()
	let origin_pos = getpos('.')
	while search( s:FUNCTION_PATTERNS.begin, 'bW' ) != 0
		" find the begin of function.
		let temp_start = getpos('.')

		let temp_end = temp_start
		while 1
			" use matchit plugin to find end that match the begin.
			norm %

			let cur_pos = getpos('.')
			if cur_pos[1] < temp_end[1] || cur_pos[1] == temp_end[1] && cur_pos[2] <= temp_end[2]
				break
			endif

			let temp_end = cur_pos
		endwhile

		call setpos( '.', temp_end )

		call search( s:FUNCTION_PATTERNS.end, 'eW' )
		let temp_end = getpos('.')

		if temp_start == temp_end
			return 0
		endif

		" if the match end is behind origin_pos, get it!
		if temp_end[1] > origin_pos[1] || temp_end[1] == origin_pos[1] && temp_end[2] > origin_pos[2]
			return ['v', temp_start, temp_end]
		endif

		call setpos('.', temp_start)
	endwhile

	return 0
endfunction


function! s:select_i()
	let range = s:select_a()
	if range is 0
		return 0
	endif

	let [_, ba, ea] = range
	" move to the end of begin word
	call setpos( '.', ba)
	call search( s:FUNCTION_PATTERNS.begin, 'We' )
	let bi = getpos('.')
	let line_end = len(getline('.'))
	" if is the EOL, move the downward line, else move to right.
	if bi[2] == line_end
		norm! +
	else
		norm! l
	endif
	let bi = getpos('.')

	" move to the begin of end word
	call setpos( '.', ea)
	call search( s:FUNCTION_PATTERNS.end, 'bW' )
	let ei = getpos('.')
	" if is the EOL, move the upward line, else move to left.
	if ei[2] == 1
		norm! -
	else
		norm! h
	endif
	let ei = getpos('.')

	if bi[1] > ei[1]
		return ['v', ba, ea]
	endif

	return ['v', bi, ei]
endfunction

" __END__  "{{{1
" vim: foldmethod=marker
