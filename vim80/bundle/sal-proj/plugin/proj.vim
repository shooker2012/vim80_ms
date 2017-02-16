" Copyright (c) 2015
" shooker2012 <lovelywzz@gmail.com>
"
" When open *.vimproj or _vimproj, use some custom settings.
" 
" For Add net type project:
" 1. Write new [Typecustom] for new type.
" 2. Add new map to [TypeMap]
" 3. Add new [TypeAutocmd] for <type>.vimproj

" Do not load a.vim if is has already been loaded.
if exists("loaded_shookerVimProj")
    finish
endif
if (v:progname == "ex")
   finish
endif
let loaded_shookerVimProj = 1

let s:dictionary_postfix = { }
let s:dictionary_postfix[ "vimproj" ] = 1
let s:dictionary_postfix[ "_vimproj" ] = 1

" [Interface] let salproj work!
function! SalProjAwark( )
	" [plugin] SalProj
	command! -nargs=1 SetProjType call SalProjSetType(<f-args>)
	" command! -nargs=* OpenProj call SalChangeProjDir(<f-args>)

	" [TypeAutocmd] set BufReadPost
	for postfixStr in keys( s:dictionary_postfix )
		exe 'autocmd BufReadPost *.'.postfixStr.' call <SID>SalProjHit( )'
	endfor

	autocmd BufReadPost _vimproj call <SID>SalProjHit( )
endfunction

" [Interface] add new postfix to vimproj file type.
function! SalProjAddProjFile( postfixStr )
	let s:dictionary_postfix[postfixStr] = 1
endfunction

" [Interface] use proj's configs by type
function! SalProjSetType( type )
	" set path config
	set noautochdir

	" [plugin]ctrlp
	let g:ctrlp_working_path_mode = 'a'
	
	" Project custom config
	if has_key( g:dictionary_type_2_func, a:type ) == 1
		call g:dictionary_type_2_func[a:type]( )
	end

	call <SID>MapQuickFixWindow()
endfunction

" [TypeCustom]lua
function! <SID>LuaTypeCustom( )
	set grepprg=grep\ -n\ -r\ --include=*.lua\ $*\ *
	" set grepprg=ag\ --column

	let g:agprg="ag --column -G .*\\.lua"

	copen
	autocmd BufRead *.lua UpdateTypesFileOnly

	nnoremap <silent> <F5> :silent !ctags --langdef=MYLUA --langmap=MYLUA:.lua --regex-MYLUA="/^.*\s*function\s*(\w+):(\w+).*$/\2/f/" --regex-MYLUA="/^\s*(\w+)\s*=\s*[0-9]+.*$/\1/e/" --regex-MYLUA="/^.*\s*function\s*(\w+)\.(\w+).*$/\2/f/" --regex-MYLUA="/^.*\s*function\s*(\w+)\s*\(.*$/\1/f/" --regex-MYLUA="/^\s*(\w+)\s*=\s*\{.*$/\1/n/" --regex-MYLUA="/^\s*module\s+\""(\w+)\"".*$/\1/m,module/" --regex-MYLUA="/^\s*module\s+\""[a-zA-Z0-9._]+\.(\w+)\"".*$/\1/m,module/" --languages=MYLUA --excmd=number -R .<CR>
endfunction

" [TypeCustom]py
function! <SID>PythonTypeCustom( )
	set grepprg=grep\ -n\ -r\ --include=*.py\ $*\ *

	" let g:agprg="ag --column -G .*\\.lua"

	" set tab config
	set softtabstop=4
	set shiftwidth=4
	set expandtab

	copen
	autocmd BufRead *.py UpdateTypesFileOnly

    let g:NERDTreeIgnore+=[ '\.pyc', '\.taghl', '__pycache__', '^tags$' ]

endfunction

" [TypeMap]
let dictionary_type_2_func = { }
let dictionary_type_2_func[ "lua" ] = function( "<SID>LuaTypeCustom" )
let dictionary_type_2_func[ "python" ] = function( "<SID>PythonTypeCustom" )
let dictionary_type_2_func[ "py" ] = function( "<SID>PythonTypeCustom" )

" map quick fix window.
function! <SID>MapQuickFixWindow()
	botright copen
	nnoremap <silent> <buffer> h  <C-W><CR><C-w>K
	nnoremap <silent> <buffer> H  <C-W><CR><C-w>K<C-w>b
	nnoremap <silent> <buffer> o  <CR>
	" nnoremap <silent> <buffer> t  <C-w><CR><C-w>T
	nnoremap <silent> <buffer> t  ^<C-w>gF:NERDTreeFind<CR><C-W>l:copen<CR><C-W>k
	" nnoremap <silent> <buffer> T  <C-w><CR><C-w>TgT<C-W><C-W>
	nnoremap <silent> <buffer> T  ^<C-w>gF:NERDTreeFind<CR><C-W>l:copen<CR><C-W>kgT
	" nnoremap <silent> <buffer> v  <C-w><CR><C-w>H<C-W>b<C-W>J<C-W>t

	nnoremap <silent> <buffer> e <CR><C-w><C-w>:cclose<CR>'
	nnoremap <silent> <buffer> go <CR>:copen<CR>
	nnoremap <silent> <buffer> q  :cclose<CR>
	nnoremap <silent> <buffer> gv :let b:height=winheight(0)<CR><C-w><CR><C-w>H:copen<CR><C-w>J:exe printf(":normal %d\<lt>c-w>_", b:height)<CR>
endfunction

function! <SID>SalProjHit( )
	let filename = expand("%:p")
	let filepath = expand("%:p:h")

	let filelist = matchlist( filename, '\v%(^.*[\/]%([^\/]+)@=)?%(%(.+)\.%(.*\.)@=)?%(([^\/.]+)?\.)?\.?([^\/.]+)$' )
	let typeStr = filelist[1]
	let postfixStr = filelist[2]

	"check if file is vimproj file.
	if has_key( s:dictionary_postfix, postfixStr ) == 0
		return
	endif

	" [plugin]NERDTree
	let useNERDTreeInFile = 0
	let filecontent = readfile( filename )
	for line in filecontent
		if match( line, "NERDTree" ) != -1
			let useNERDTreeInFile = 1
			break
		endif
	endfor

	" hide vimproj files and tag files
    let g:NERDTreeIgnore+=[ '_vimproj', '\.vimproj',  '\.taghl', '^tags$' ]

	exe "cd ".filepath
	if useNERDTreeInFile == 0
		exe "silent NERDTree ".filepath
	endif

	command! Copen call <SID>MapQuickFixWindow()

	" set proj type
	call SalProjSetType( typeStr )

	" custom config in vimproj file
	exe "so ".filename
endfunction

if  exists("sal_proj_awake") && g:sal_proj_awake == 1
	call SalProjAwark( )
endif
