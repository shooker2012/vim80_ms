" Copyright (c) 2016
" shooker2012 <lovelywzz@gmail.com>
"
" Clean the new-line char at EOF which auto insert by vim.
"

if exists("load_CleanNLatEOF")
	finish
endif
if v:progname == "ex"
	finish
endif
let load_CleanNLatEOF = 1

function! <SID>SalCleanNLatEOF()

python << END_PYTHON
import vim
file_name = vim.eval( 'expand("%")' )
if not file_name:
	vim.command( "return 0" )

lines = None
with open( file_name, 'r' ) as f:
	lines = f.readlines()

if lines == None:
	vim.command( "return 0" )

if len(lines) == 0:
	vim.command( "return 1" )

lines[-1] = lines[-1].rstrip( '\n' )
with open( file_name, 'w' ) as f:
	f.writelines( lines )
	vim.command( "return 1" )

vim.command( "return 0" )
END_PYTHON

	:redraw
endfunction

command! CleanNL call <SID>SalCleanNLatEOF()

function! <SID>SalAutoCleanNLWhenSave( typeString, is_auto )
	exec "augroup SalTools"
	if a:is_auto == 1
		exec 'autocmd SalTools BufWritePost '.a:typeString.' :CleanNL'
	else
		exec 'autocmd! SalTools BufWritePost '.a:typeString
	endif
endfunction

command! -nargs=1 AutoCleanNLatEOF call <SID>SalAutoCleanNLWhenSave( <f-args>, 1 )
command! -nargs=1 NoAutoCleanNLatEOF call <SID>SalAutoCleanNLWhenSave( <f-args>, 0 )

if exists( 'sal_auto_clean_nl_file_type' ) && g:sal_auto_clean_nl_file_type != []
	for ft in g:sal_auto_clean_nl_file_type
		if type(ft) == 1 && ft != ""
			call <SID>SalAutoCleanNLWhenSave( ft, 1 )
		endif
	endfor
endif
