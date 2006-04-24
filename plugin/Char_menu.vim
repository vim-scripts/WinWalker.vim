
"------------------------------------------------------------------------------
"               Char_menu.vim : getchar() based command line menu functions {{{
"
"
"
" Author:		Eric Arnold ( eric_p_arnold@yahoo.com )
" Created:		June '05
" Updated:		Tue Apr 18, 04/18/2006 6:25:14 AM
" Requirements:	Vim 6
" Version:		Not individually released yet.
"

"	Features:
"
"	=	Forget about forgetting what key does what:  Char_menu,
"		is a menu that reminds you of all the available commands while
"		it's prompting you for input.  
"
"	-	Does immediate completion and return by matching input against
"		unambiguous abbreviations.
"
"
"	Usage:
"
"	-	Use Char_menu_display() after Char_menu() if you want to leave the
"		final selection displayed in the command line.
"
"	-	Add misc. highlighting:
"		
"		call Char_menu_wrapAdd( l, '{g}row mode is ' . 
"						\ ( s:grow_mode ? '!%ON%!' : 'OFF' ) )
"
"	Notes:
"
" 	-	It's currently left up the calling function to reset the value of
"	 	cmdheight after it is finished looping over Char_menu.  This is to avoid
" 		flashing.





let g:CMu_menu_hl_text		= 'Directory'
let g:CMu_menu_hl_standout	= 'WarningMsg'
let g:CMu_menu_hl_selection	= 'WildMenu'
let g:CMu_menu_hl_error		= 'Error'
let g:CMu_timeoutlen		= 600


let s:menu_matches_full = 0
let s:menu_matches_partial = 0
let s:received_chars = ""

" Need to give Char_menu() at least on {} field for it to work
" properly, otherwise it will display the prompt, but do odd things with the
" cursor.

" let l:inp = Char_menu( "{o}op1 {c}hoice2  ", "{ANY} {<C-C>}", last_inp )
function! Char_menu( menu_str, ... )

	"set lazyredraw
	let l:restore_cmdheight = &cmdheight

	" The command window can get confused if the above windows didn't take up
	" available space at some point in the past.
	"
	" ******* This might not do anything good:
	"
	"let l:restore_height = winheight(winnr())
	"resize
	"exe 'resize ' . l:restore_height

	" god, newlines suck, all I want is a count of them :(
	let l:nls = a:menu_str
	let c = 0
	let i = 0
	while 1
		let i = stridx( l:nls, "\n" )
		if i < 0 | break | endif
		let l:nls = strpart( l:nls, i + 1 )
		if strlen( l:nls ) < 1 | break | endif
		let c += 1
	endwhile
	if strlen( l:nls ) > 0
		let c += 1
	endif

	"call Clear_cmd_window()
	if &cmdheight < c
		let &cmdheight = c 
	endif

	"???
	"redraw	" otherwise cursor sits at line 1, col 1 instead of at end

	if a:0 > 0
		let l:hidden_options = a:1
	else
		let l:hidden_options = ''
	endif

	if a:0 > 1
		let l:starting_selection = a:2
	else
		let l:starting_selection = ''
	endif

	let l:line = line(".")
	let l:col = col(".")


	let l:received_chars = ""

	while 1

		call Char_menu_display( a:menu_str, l:starting_selection )
		let l:char = getchar()

		if nr2char( l:char ) != ""
			let l:char = nr2char( l:char )
		endif

		let s:menu_matches_full = 0
		let s:menu_matches_partial = 0

		let s:received_chars = l:received_chars . l:char
		" This confuses submatch(): '{\(\([^}]\|\}\)\+\)}'
		let l:ret = substitute( a:menu_str . l:hidden_options, '{\([^}]\+\)}'
							\ , '\=s:Check_menu_submatches()', 'g' )

		let l:received_chars = l:received_chars . l:char

		if l:received_chars != ''
			let l:starting_selection = l:received_chars
		endif


		"call Clear_cmd_window()
		"redraw
		"call Char_menu_display( a:menu_str, l:starting_selection )


		if s:menu_matches_full > 0 || s:menu_matches_partial > 0
		else 
			break
		endif

		if ( s:menu_matches_full == 1 && s:menu_matches_partial == 0 ) 
			  \ || ( s:menu_matches_full == 0 && s:menu_matches_partial == 1 )
			break
		endif

		if strlen( l:received_chars ) > 1
			"call Clear_cmd_window()
			"redraw
			"while getchar(1) == 0 | sleep 100m | endwhile
		endif
		"call Char_menu_display( a:menu_str, l:received_chars )

		if s:menu_matches_full > 0  || s:menu_matches_partial == 1
			call Peek_char_timeout_wait( g:CMu_timeoutlen )
			if getchar(1) == 0
				break
			endif
		endif

		if l:char != "" && l:hidden_options =~ '{ANY}'
			let l:received_chars = l:char
			break
		endif

		if l:char == "\<BS>" 
		endif

		" Panic button:
		if l:char == "\<C-C>" || l:char == "\<ESC>"
			let l:received_chars = l:char
			break
		endif

	endwhile

	" Leave the final selection showing:
	"call Char_menu_display( a:menu_str, l:received_chars )
	
	" does something bad when trying to leave the last selection in view:
	" redraw

	echohl None

	return l:received_chars
endfunction





function! Char_menu_display( menu_str, received_chars )

	call Clear_cmd_window()

	let l:menu_str = a:menu_str
	let l:match_end = 0

	let l:in_standout = 0
	let l:in_custom = 0
	let l:hl = g:CMu_menu_hl_text

	while 1

		let parse = 
					\'^\(%#[^#]*#\|<[^>]\+>\|[{}]\|[^{}% \t]\+\|\s\+\|[%]\)'
		let l:match_end = matchend( l:menu_str, parse )

		if l:match_end <= 0 | break | endif

		let l:tok = matchstr( l:menu_str, parse )

		let l:menu_str = strpart( l:menu_str, l:match_end )

		if l:tok == '{'
			let l:hl = g:CMu_menu_hl_standout
			let l:tok = ''
			let l:in_standout = 1
		elseif l:tok == '}'
			let l:hl = g:CMu_menu_hl_text
			let l:tok = ''
			let l:in_standout = 0
		elseif l:tok =~ '^%#[^#]*#$'
			let l:hl = substitute( l:tok, '^%#\([^#]*\)#$', '\1', '' )
			if l:hl == ''
				let l:hl = 'None'
				let l:in_custom = 0
			else
				let l:in_custom = 1
			endif
			exe 'echohl ' . l:hl
			let l:tok = ''
			continue
		elseif l:tok =~ '\s\+'
			echohl None
			echon l:tok
			let l:tok = ''
		else

			if l:in_custom
			elseif !l:in_standout
				let l:hl = g:CMu_menu_hl_text
			else
				let l:hl = g:CMu_menu_hl_standout

				if a:received_chars != '' && l:in_standout
					"attempt to match codes, i.e. <CR>, against actual ^M
					if l:tok =~ '<[^>]\+>'
						let l:tok_alt = ''
						silent! exe 'let l:tok_alt = "\' . l:tok . '"'
						if stridx( l:tok_alt, a:received_chars ) == 0
							let l:hl = g:CMu_menu_hl_selection
						endif
					elseif stridx( l:tok, a:received_chars ) == 0
						let l:hl = g:CMu_menu_hl_selection
						let l:tok = strpart( l:tok, strlen( a:received_chars) )
						let l:menu_str = l:tok . l:menu_str
						let l:tok = a:received_chars
					endif
				endif
			endif " l:in_standout
		endif " switches for l:tok

		let l:tok = substitute( l:tok, '<.-\(.\)>', '^\1', 'g' )
		exe 'echohl ' . l:hl
		echon l:tok

	endwhile

	echohl warningmsg " Error
endfunction




function! Peek_char_timeout_wait( timeout )
	let l:count = (  a:timeout / 100 )
	while l:count > 0 && getchar(1) < 1
		sleep 100m
		let l:count = l:count - 1
	endwhile
	return max( [0, 100 * l:count ] )
endfunction



"function! Getchar0( e )
"	if exists( 's:Pre_input' ) && s:Pre_input != ''
"		let s = s:Pre_input
"		let s:Pre_input = ''
"		return s
"	endif
"	return getchar( a:e )
"endfunction



function! s:Check_menu_submatches( ... )

	let l:item = submatch( 1 )

	" translate <TAB> to real tab, etc. using "\<TAB>" to do it:
	if l:item =~ '<\w\+\>'
		exe 'let l:item = "\' . l:item . '"'
	endif


	if l:item ==# s:received_chars
		let s:menu_matches_full = s:menu_matches_full + 1
	elseif stridx( l:item, s:received_chars ) == 0   " match only at start
		let s:menu_matches_partial = s:menu_matches_partial + 1
	endif

	echohl None
	return "nada"
endfunction




function! s:Echo_error( msg )
	" echoerr is a little too strong
	echohl Error
	echomsg a:msg
	echohl None
endfunction

function! s:Echo_warning( msg )
	echohl WarningMsg
	echomsg a:msg
	echohl None
endfunction


function! s:Echo_info( msg )
	echohl Special
	echomsg a:msg
	echohl None
endfunction





function! Clear_cmd_window()
	exe "silent! normal! :<CR>"
endfunction



function! Char_menu_wrapAdd( list, s, ... )

	let sep = a:0 == 1 ? a:1 : ',  '

	if len( a:list ) == 0
		call add( a:list, a:s )
		return
	endif
	let l = a:list[ -1 ]
	let l = substitute( l, '{<C-\(.\)>}', '^\1', 'g' )
	let l = substitute( l, '{\([^}]\)}', '\1', 'g' )
	if ( strlen( l . sep ) + strlen( a:s ) ) > &columns
		let a:list[ -1 ] .= "\n"
		call add( a:list, a:s )
	else
		if a:list[ -1 ] != ''
			let a:list[ -1 ] .= sep
		endif
		let a:list[ -1 ] .= a:s
	endif
	return
endfunction



