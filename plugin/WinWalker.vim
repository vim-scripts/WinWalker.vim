
"------------------------------------------------------------------------------
"                     WinWalker.vim : Vim windows navigator/manager {{{
"
"
"
" Author:		Eric Arnold ( eric_p_arnold@yahoo.com )
" 							  ^^^^^^^^^^^^^^^^^^^^^^^
" 							  Comments, bugs, feedback welcome.
" Created:		Apr, 2006
" Updated:		Mon Apr 24, 04/24/2006 3:47:09 AM
" Requirements:	Vim 7
" Dependencies:	Char_menu.vim
"
" Version:		1.0		Wed Apr 19, 04/19/2006 4:25:30 AM
" 						-	Initial release
" 				1.1		Fri Apr 21, 04/21/2006 1:33:54 PM
" 						-	Added help extraction to standard help
" 						-	Tweaked to handle Taglist.vim
" 				1.2		Mon Apr 24, 04/24/2006 3:47:09 AM
" 						-	handle copen and exchange/push
" 						-	fixed searching by bufnr bug
" 						-	switch to Unix file format
" 						-	added session quick-save
" 						-	revamped help and help folding
"
"
" }}}
" Help Start:
"*WinWalker.txt* v1.2 : Vim windows navigator/manager 
"
"
"	Table Of Contents: ~
"
"	|WW_Features|
"	|WW_Initial_Set_Up|
"	|WW_Commands|
"		|WW_Starting|
"		|WW_Main_Menu|
"		|WW_Misc_Menu|
"		|WW_Tab_Menu|
"		|WW_Save_Menu|
"		|WW_Customizing|
"	|WW_Notes_Other_Bugs|
"
"
"	|Turn_folding_on|
"	|Turn_folding_off|
"
"
"  Features:                                            *WW_Features* {{{~
"
"	-	Navigate and manage windows and layouts with blinding speed!
"
"	-	Multiple window operations are faster and easier because it creates
"		a window navigation and management mode where all window commands
"		are familiar single chars,  i.e.  h,H,^H  and j,J,^J  etc.  If you
"		weren't using Vim in full-screen mode, you'll start considering it.
"
"	-	More added functionality:
"
"		-	Windows are considered movable objects:
"
"			-	Enhanced push/drag for windows and buffers.
"
"			-	Push/drag/exchange buffers between windows, and windows
"				between tabs.  Use adjacent tabs as if they were extensions
"				of the current visible screen.
"
"		-	Quick search/jump to any window in any tab by giving the first
"			unique char(s).  It jumps to a buffer's window, instead of the
"			default action of editing buffers in the current window.
"
"		-	More intuitive for many operations:
"			
"			-	Incremental resizing is easier, using the [HJKL] and
"				[^h^j^k^l].
"
"			-	Resize in the direction specified, unlike  wincmd + - < > 
"
"			-	Windows move/push past each other more like you'd expect.
"				They can push 'between', instead of just 'maximize at far
"				side'.
"
"		-	Other usability stuff:
"
"			-	A window-level jump list for ^I/^O  movement.
"
"			-	O/^O  as a tab-capable alternative to ^Wo .
"
"	-	All the commands are presented as a prompt menu in the command line
"		so forgetting stuff isn't a problem.
"
"	-	Many of the commands are the same as the default Vim window  ^W  and
"		'wincmd' for easy transition, others are shifted around to be more
"		consistent.
"
"	-	Different invocation modes:  |WW_timeoutlen| for menu, key pass-through.
"		The goal is to have the menu mode there when you want it, and keep
"		quiet otherwise.  Experiment with the different methods to find
"		what works best for you.
"
"
" }}}
"
"
"
"	Initial Set Up:                                 *WW_Initial_Set_Up* {{{~
"
"		-	Unzip the distribution file above your plugin to extract:
">
"				plugin/WinWalker.vim
"				plugin/Char_menu.vim
"				doc/WinWalker.txt
"<
"
"		-	Set up a key map.  I.e.
">
"				nmap <silent> <Leader>w :call WinWalkerMenu()<CR>
"<
"					Default.  I like it mapped to ^W, since I'm used to
"					hitting ^W for windows stuff, and WinWalker is mostly a
"					superset of the standard ^W/wincmd commands.
"
"		-	Look through the |WW_Misc_Menu| and |WW_Customizing| for other
"			options to change.
"
"
"}}}
"
"
"
"                             Commands:                   *WW_Commands*  {{{~
"
"
"	Starting:                                          *WW_Starting*   {{{~
"
"				Assuming you decide to map ^W :
">
"		nnoremap <silent> <C-W> :call WinWalkerMenu()<CR>
"<
"			<C-W>
"
"				-	Type <C-W> and note the delay (~1/2 sec) before the menu
"					starts.  
"
"				-	Type <C-W>j (or whatever) fast together, and it
"					should move down one window without starting the menu.  
"
"				-	Decide whether you want more or less time to type the
"					second char before the menu starts.  
"
"				-	Change the timeoutlen in {m}isc
"					menu -> {t}imeoutlent ( |WW_timeoutlen| ).
"
"			<C-W><SPACE>
"
"				This starts the menu immediately without the initial
"				timeoutlen.  (For us impatient people :-)  Set timeoutlen to 0
"				for a similar effect.
"
"			See also |WW_Customizing|
"
"
"}}}
"
"
"	Main Menu: 	                                     *WW_Main_Menu* {{{~
"
"
"		{w}/{W}/{<C-W>}indow=>Nxt/Prv
"
"				Move through the window list, same as default behavior.
"
"
"		{k}/{K}/{<C-K>}=up
"		{j}/{J}/{<C-J>}=down
"		{h}/{H}/{<C-H>}=left
"		{l}/{L}/{<C-L>}=right
"
"				There are three general kinds of move operations with Vim
"				windows that are handled here:  
"				1)	moving a cursor from one window into another, 
"				2)	moving a buffer from one window to another, without
"					creating or destroying windows , 
"				3)	moving a window (and its buffer and cursor) to a new
"					location, causing the layout to rearrange.
"
"				The above key commands are set up along those lines:
"
"			-	Lowercase='move cursor to another window'
"			-	Uppercase='push the current window up/down/left/right'
"			-	Control='exchange buffers, keep focus with buffer'
"				(when exchanging to an adjacent tab, it relocates the
"				buffer into a new window, since it's more confusing
"				otherwise).
"			-	Arrow keys are mapped to analogous [jkhl] commands, i.e.
"				<S-UP> is mapped to 'K'.
"
"
"		{r}/{R}=rotate wins/buffers
"
"			{r}	Rotates the current window according to new/vnew.  It isn't
"				smart about detecting the orientation of a window it
"				hasn't seen before, so you might have to hit "r" twice to
"				get it started.
"
"			{R}	Rotate all the buffers around the windows in the screen
"				without changing the window layout.
"
"		{o}/{O}='only'/clone
"
"			{o}	The default 'wincmd' behavior where all windows are closed
"				but the current.  
"				
"			{O}	Clone the current buffer in it's own new tab.  This is for
"				when you want to temporarily maximize the current window
"				without changing any others.  If <C-O> ( <C-W><C-O> from Vim
"				Normal ) is the first command used to leave, it will close the
"				window, and return to the origination.
"			
"		{<C-I>}/{<C-O>}=jump forward/back
"
"				Traverses WinWalker's window-level jump list.  (As opposed
"				to the Vim Normal mode ^I/^O, which traverses a buffer-level
"				jump list.)
"
"		{t}ab menu
"			
"				Submenu for handling tabs.  See |WW_Tab_Menu|
"
"		{m}isc menu
"				
"				Submenu for setting options.  See |WW_Misc_Menu|
"
"		{s}ave/restore menu
"
"				Submenu for saving sessions.  See |WW_Save_Menu|
"
"		{g}row
"
"				Toggles "grow" mode where the shift- and control- of [jkhl]
"				keys is changed to do window resizing.  This is also in the
"				|WW_Misc_Menu|, but is also at the top level for convenience.
"				This option is reset each time WinWalkerMenu() is called via
"				^W or whatever.
"				
"		{n}ew win
"		{v}ert new
"
"				Same as  :new  and  :vnew  .
"
"		{=}equalize windows
"
"				Same as Vim default.
"
"		{:}ex
"
"				Prompts for a command and transfers it to  :ex  to execute.
"				Saves time exiting and re-entering the menu.
"
"		{e}dit	
"				A shortcut to |:edit| without exiting the menu first.
"
"		{/}{?}find win
"
"				Submenu of available/loaded buffers.  Typing the first one or
"				so unique leading characters jumps to the matched window.
"				Buffer name or number can be selected. {?} includes hidden
"				buffer names.
"
"		{c}olumn preset ( lines, cols, actually)
"
"				A quick set option to resize the current window to user's
"				preferred working dimensions, I.e. 80 columns, and 15 lines.
"				{C} prompts for lines and cols.
"
"		:{q}uit/:{Q}uit!/{<C-Q>}=tabclose!/{Z}Z
"				
"				Sends various quit commands.
"
"		{<SPACE>}/{<ESC>}=>Exit
"
"				Exit the WinWalker subsytem.  <C-C> and <BS> also work.  If
"				<C-W><SPACE>, <C-W><C-SPACE>, <C-W><CR>, <C-W><C-CR> are
"				entered before the timeoutlen (before the menu starts), it
"				the reverse effect, and bypasses the timeoutlen, and starts
"				the menu immediately.
"
" 		Any other keys
"
" 				... are delivered to Normal mode, and the menu exits.  So,
" 				typing ^U, ^D, ^F, ^B  exits WinWalker, and scroll the
" 				window.
"
" }}}
"
"
"	Misc Menu:                                        *WW_Misc_Menu* {{{~
"
"
"		{g}row
"
"			Toggle whether the [jkhl] uppercase and control keys are used
"			to resize windows.
"
"		{w}rap
"
"			Set wrap behavior:
"				None :	default Vim
"				Win :	wrap at top/bottom/left/right sides of screen
"				tabs :	wrap into adjacent tabs at R/L sides of screen
"
"		{m}enu
"
"			Set whether full prompt is shown for the main menu.
"
"		{h}ighlight current win 
"
"			Toggle highlighting of the current window.  The highlighting is
"			done to help distinguish which window is current, since the
"			cursor won't be visible.
"
"		{e}mpty files
"
"			Same as highlighting, above, but add some text to empty files
"			to help distinguish as current window.
"
"		{t}imeoutlen  *WW_timeoutlen*
"
"			Set the timeoutlen used for the wait for the key press after ^W
"			(or whatever) in Vim Normal mode.  If the second key is
"			received before the timeoutlen, the command is executed and
"			control returns immediately to Vim Normal.  If timeoutlen is
"			reached, the main menu starts and subsequent commands require
"			only one key.  Control is kept by WinWalker until the menu is
"			exited.
"
"			It is analogous to the Vim |timeoutlen|, but it is an
"			independent internal value.
"
"			This also affects the timeoutlen for ambiguous matches in the
"			{/}find command (using the Char_menu function).
"
"		{j}ump list
"
"			Show the window-level jump list (like |:jumps| ).
"
"		{k}ey remap
"
"			Remap single keys.  No nesting.
"
"		{d}ropout keys
"
"			Change keys in the list which causes the main menu to exit
"			after execution.  This is most useful for when |WW_timeoutlen|
"			is set to 0.  See |WW_Customizing|
"
"		Note: the g:WinWalker_opts.rc_file is updated when the Misc menu is
"		exited.
"
"}}}
"
"
"	Tab Menu:                                         *WW_Tab_Menu*   {{{~
"
"				Note:  The prev/next commands for tabs are down in a
"				submenu because I found that, in general, it's more
"				consistent to move through tabs using the window left/right
"				when wrap=tabs.
"
"		{h}/{l}
"				Go to prev/next tab.
"
"		{H}/{L}
"				Move/rotate tab.  Changes the order of the tab in the tab
"				line list.
"
"		{n}ew tab
"
"				See :help tabpage  ;-)
"
"		{t}ab table
"				
"				Run  |:tabs|
"
"		{q}/{C-Q>=:tabclose/:tabclose!
"
" }}}
"
"
"	Save Menu:                                         *WW_Save_Menu*   {{{~
"
"		Save {d}irectory
"				
"				Directory to hold the Session files.  Default is |$HOME|.
"
"		{s}ave session
"				
"				Save the current session with 'tabpages' session option to the
"				file prompted for, using the above directory as the starting
"				point.  Any filename can be used, but the prefix 'Session.' is
"				used as a default to help filter the completion list more
"				quickly.  If the completion key (^D or <TAB>) is pressed when
"				only a single file can be completed, a summary is show, per
"				the {l}ist sessions command format, below.
"
"		{t}ab save session
"
"				Same as above, but without the 'tabpages' session option, so
"				saves only the current tab.
"
"		{r}estore session
"
"				Restore a session file, with the usual defaults and prefixes.
"
"		{l}ist sessions
"			
"				Lists the Session.* files in the current and default
"				directories.  It shows a summary of the buffers, and their tabs,
"				stored in the session files.
"
" }}}
"
"
"	Customizing:                                     *WW_Customizing* {{{~
"
"		-	g:WinWalker_opts.rc_file  sets the filename for the options
"			settings.  Default is  $HOME/.WInWalker.vim .  Most of the
"			global option variables are handled here, so they don't need to
"			go into your .vimrc.  The  g:WinWalker_opts.rc_file  file is
"			sourced once only, when the plugin is first read when Vim
"			starts up.
"		
"		-	Highlighting overrides can be done by copying the  s:Hi_init()
"			function into your  .vimrc , and making changes there. 
"
"		-	You can set certain keys to drop out of (bypass) the menu
"			automatically and return to Vim Normal mode with this var:
">				
"				let g:WinWalker_dropout_keys = [ "\<C-W>", "\<C-P>" ]
"<
"
"
"			This is most useful for when timeoutlen is set to 0.  For example:
"
"			With timeoutlen > 0, typing ^W^W fast from Vim Normal mode will
"			move to the next window without starting the menu.
"
"			With timeoutlen = 0, the first  ^W  will start the menu, and the
"			second  ^W  will move to the next window, and then leave you back
"			in the menu, regardless of how fast you type them.
"
"			With  ^W  set in the dropout keys list,  ^W^W  from Vim Normal
"			mode will behave the same regardless of timeoutlen.
"
"		-	Single keys can be remapped via  g:WinWalker_remap  dict var.
"			You can put it into your .vimrc, but it probably easier to use
"			it through the {m}isc menu.
"	
" }}}
"
" End Commands fold }}}
"
"
"
"{{{	*WW_Notes_Other_Bugs*
"
"
"	Notes: ~
"
"	-	Since this uses Vim7 tabs extensively, see  TabLineSet.vim  for
"		better visual information in the tabs themselves.
"
" 	-	Don't map a key that also has other operator-pending maps, i.e.
" 		trying to map  ^W  while there were still other mappings like
" 		custom  ^W^O  will cause it to wait (forever, possibly) for the
" 		second key, which keeps the main menu from starting.
"
"	-	Removing a tab, or re-arranging windows can invalidate parts of the
"		jumplist, which will become somewhat unpredictable until it clears
"		all the bad jumps as they are encountered.
"
"
"	Other: ~
"
"		-	Make some test tabs:
">
"			map ,t <c-w>Nnvnvnv
"
"			map ,tt <C-W>N:Tlist<CR>hn:Explore<CR><CR>:copen<CR>H:help WinWalker<CR>Lnesomefile<CR>=c<SPACE>asome stuff<ESC>
"				<C-W>				calls WinWalkerMenu function
"				N					opens a new tab
"				:Tlist<CR>			opens Taglist using the  :  pass-through
"				h					move left one window (return into Taglist)
"				n					open a new window horizontally
"				:Explore<CR><CR>	Run Explore in the new window, don't
"									know why it needs two <CR>s
"				:copen<CR>			open the quickfix window
"				H					push it left in line vertically with
"									Tlist and Explore
"				:help WinWalker<CR>	open a help window
"				L					push it right
"				n					open a new window below the help
"				etmpfile<CR>		open 'tmpfile' in it using 'e' quick
"									edit
"				=					equalize all the windows
"				c					resize 'tmpfile' window to preset
"				<SPACE>				exit WinWalker
"				asome stuff<ESC>	put some stuff into 'tmpfile'
"<
"
"		-	Mappings to resize with shift-arrows from Normal mode, using the
"			pass-through of the default  wincmd  resizing commands:
">
"			nmap <c-up> <c-w>+
"			nmap <c-down> <c-w>-
"			nmap <c-left> <c-w><
"			nmap <c-right> <c-w>>
"<
"			Mappings which use the modified resize commands:
">
"			nmap <c-up> <c-w>g<c-k>
"			nmap <c-down> <c-w>g<c-j>
"			nmap <c-left> <c-w>g<c-h>
"			nmap <c-right> <c-w>g<c-l>
"<
"			If timeoutlen is 0, these maps will have to explicitly exit the
"			menu to be used from Vim Normal mode directly.
"
">
"			nmap <expr> <s-up> ( g:WinWalker_opts.timeoutlen ? '<c-w>gK' : '<c-w>gK<space>' )
"			nmap <expr> <s-down> ( g:WinWalker_opts.timeoutlen ? '<c-w>gJ' : '<c-w>gJ<space>' )
"			nmap <expr> <s-left> ( g:WinWalker_opts.timeoutlen ? '<c-w>gH' : '<c-w>gH<space>' )
"			nmap <expr> <s-right> ( g:WinWalker_opts.timeoutlen ? '<c-w>gL' : '<c-w>gL<space>' )
"
"			nmap <expr> <c-up> ( g:WinWalker_opts.timeoutlen ? '<c-w>g<c-k>' : '<c-w>g<c-k><space>' )
"			nmap <expr> <c-down> ( g:WinWalker_opts.timeoutlen ? '<c-w>g<c-j>' : '<c-w>g<c-j><space>' )
"			nmap <expr> <c-left> ( g:WinWalker_opts.timeoutlen ? '<c-w>g<c-h>' : '<c-w>g<c-h><space>' )
"			nmap <expr> <c-right> ( g:WinWalker_opts.timeoutlen ? '<c-w>g<c-l>' : '<c-w>g<c-l><space>' )
"<
"
"	-	Some apps like 'Taglist' and 'quickfix window' set 'bufhidden',
"		which interfers with window moving/exchanging.  This is mostly
"		dealt with, but other app.s like 'Project.vim' reset the window
"		every time the buffer is entered, which isn't handled (probably
"		can't be without changing the application itself).
"
"
"	Bugs:~
"
"	-	The cmdheight isn't always restored correctly at this time.  As of
"		Vim70c, a bug exists for setting/resetting the value in different
"		tabs.  It seems to be better with 70d, but not all cmdheight issues
"		are resolved.
"
"	-	The error message as received by the {:}  and {e} commands sometimes
"		return something which seems unrelated.
"
"	-	As of Vim70d, there is a problem with using <expr>, so this form:
"
"			nnoremap <expr> <c-w> WinWalkerMenu()
"
"		does not allow subsequent mappings like:
"
"			nmap <s-up> <c-w>g<c-k>
"
"		use instead,
"
"			nnoremap <silent> <c-w> :call WinWalkerMenu()<CR>
"	
"	-	Sometimes a weird delay is added to the {m}isc menu as it returns
"		to main.
"
"
"}}} End Notes fold
"
"
"vim7:ft=help:norl:ts=4:sw=4
" Help End:
"
"
"	To Do: {{{
"
"	-	Trapping enough events with eventignore?
"
"	-	Starting Taglist from the ':' passthrough freaks out with 'ml_get'
"		errors.
"
"	-	This used to work, but it broke, probably when I changed <SPACE> in
"		unhuman mode to start the menu.
"
"			map ,t <c-w>tn<space>nvnvnv
"		
"		however, this doesn't work either, sooo
"
"			map ,t <c-w>tn<ESC>nvnvnv
" }}}



if v:version < 700
	echomsg "WinWalker requires Vim 7"
	finish
endif

let s:version = '1.2' 		" must be a string for searches to work


nnoremap <silent> <leader>w :call WinWalkerMenu()<CR>




" ----------------------------------------------------------------------
" Globals, config opts                                               {{{

" --------------------
" These will be overriden by the _rc file:
let g:WinWalker_opts = {}

let g:WinWalker_opts.rc_file = $HOME . '/.WinWalker_rc.vim'
if exists('g:WinWalker_rc')		" backward compatibiity
	let g:WinWalker_opts.rc_file = g:WinWalker_rc
endif

let g:WinWalker_opts.sess_dir		= $HOME
let g:WinWalker_opts.timeoutlen		= 600		" in millisec
let g:WinWalker_opts.wrap			= 'tabs'	" or 'win', 'none'
let g:WinWalker_opts.menu			= 'FULL'
let g:WinWalker_opts.hi_curr		= 'ON'
let g:WinWalker_opts.empty			= 'LABEL'	" or 'nolabel'
let g:WinWalker_opts.preset_lines	= 15
let g:WinWalker_opts.preset_cols	= 80

let g:WinWalker_remap = {}

let g:WinWalker_dropout_keys = [ "\<C-W>", "\<C-P>" ]
"let g:WinWalker_dropout_keys = [ "\<C-W>", "\<C-P>"
"			\ , "\<S-UP>",  "\<S-DOWN>",  "\<S-LEFT>",  "\<S-RIGHT>" ]

" --------------------


" Put a copy of this function in you .vimrc to override the highlighting:
"
function! s:Hi_init()
	hi clear WinWalker_sel
	if g:WinWalker_opts.hi_curr ==? 'ON'
		"hi! WinWalker_sel guibg=DarkGrey ctermfg=DarkGrey
		hi! WinWalker_sel gui=underline cterm=underline
		"hi! WinWalker_sel gui=reverse cterm=reverse
	endif

	" Char_menu settings:
	let g:CMu_menu_hl_text		= 'Directory'
	let g:CMu_menu_hl_standout	= 'WarningMsg'
	let g:CMu_menu_hl_selection	= 'WildMenu'
	let g:CMu_menu_hl_error		= 'Error'
endfunction



" You don't need to change g:CMu_timeoutlen in your .vimrc
if exists( 'g:CMu_timeoutlen' )
	let g:CMu_timeoutlen	= g:WinWalker_opts.timeoutlen
endif




let s:Arrow_key_trans = {
			\ "\<UP>"		:	'k',
			\ "\<DOWN>"		:	'j',
			\ "\<LEFT>"		:	'h',
			\ "\<RIGHT>"	:	'l',
			\ "\<S-UP>"		:	'K',
			\ "\<S-DOWN>"	:	'J',
			\ "\<S-LEFT>"	:	'H',
			\ "\<S-RIGHT>"	:	'L',
			\ "\<C-UP>"		:	"\<C-K>",
			\ "\<C-DOWN>"	:	"\<C-J>",
			\ "\<C-LEFT>"	:	"\<C-H>",
			\ "\<C-RIGHT>"	:	"\<C-L>",
			\ "\<M-UP>"		:	'k',
			\ "\<M-DOWN>"	:	'j',
			\ "\<M-LEFT>"	:	'h',
			\ "\<M-RIGHT>"	:	'l'
			\ }



let s:This_script_fname = expand("<sfile>:p")
" fnamemodify( ... ,":t")


" End Globals, config opts                                           }}}
" ----------------------------------------------------------------------




" ----------------------------------------------------------------------
" WinWalkerMenu main func                                           {{{

let s:Win_orient = {}

"let s:empty_label = "{__E__M__P__T__Y__}"
let s:empty_label = "{  W i n W a l k e r -- E M P T Y  }"

let s:last_start_time = 0
let s:Fast_pass = 0
let s:errmsg = ''
let s:infomsg = ''
let s:Unhuman_input = 0
let s:buf_check = 'loaded'

function! WinWalkerMenu( ... )
	" This must be here for getchar(1) to wake up, for 70c only?:
	"exe "normal! :   <CR>"

	call s:Hi_init()

	" Reset grow mode upon entry so macros will work, i.e.  <c-w>gK
	let s:grow_mode = 0

	let l:inp = ''
	let l:last_inp = ''
	let s:last_inp_time = localtime()
	let ms_sleep = 0
	let test = 0
	let s:save_cmdheight = &cmdheight
	let s:save_switchbuf = &switchbuf
	let &switchbuf = ''
	" Perhaps should start using 'switchbuf=usetab', but I'm not sure of the
	" side effects on other areas.
	let s:Unhuman_input = 0

	while 1

		" As an alternative to creating lots of 'old_bufnr' type vars 
		let s:this_bufnr = bufnr("%")

		if !exists( 'Menu_started' )
			if s:Unhuman_input
				" If we've already seen a Unhuman_input event, then subsequent
				" chars must be coming from mappings,etc. instead of a user,
				" so turn the timeout down, so we won't see a timeout after
				" getting the last char that is part of the key map being
				" deliverd.
				" Note:  it actually requires a timeout of 100, even though
				" it's supposed to be delivered internally.  Maybe it's
				" emulating a user by adding a delay?
				let s:Unhuman_input = Peek_char_timeout_wait( 100 )
				if !s:Unhuman_input  | return | endif
			else
				" The first check for Unhuman_input is done with the longer
				" g:WinWalker_opts.timeoutlen  variable.  Subsequent passes use
				" shorter, as above.
				let s:Unhuman_input = Peek_char_timeout_wait( g:WinWalker_opts.timeoutlen )
			endif
		else
			let s:Unhuman_input = 0
		endif

		if s:Unhuman_input
			let l:inp = getchar()
			if nr2char( l:inp ) != "" | let l:inp = nr2char( l:inp ) | endif
		else

			let Menu_started = 1

			let l = []

			if s:errmsg != ''
				call Char_menu_wrapAdd( l, '%#Error#' . s:errmsg . '%##' )
				let s:errmsg = ''
			endif
			if s:infomsg != ''
				call Char_menu_wrapAdd( l, '%#Special#' . s:infomsg . '%##' )
				let s:infomsg = ''
			endif

			if g:WinWalker_opts.menu ==? 'FULL'

				call Char_menu_wrapAdd( l, "{?}help" )
				call Char_menu_wrapAdd( l, "{w}/{W}/{<C-W>}indow=>Nxt/Prv" )
				call Char_menu_wrapAdd( l, ( s:grow_mode 
							\ ? '(Move/%#DiffChange#grow-one/grow-more%##)==>'
							\ : "(jump/push/exchange)==>" ) )
				call Char_menu_wrapAdd( l, "{k}/{K}/{<C-K>}=up" )
				call Char_menu_wrapAdd( l, "{j}/{J}/{<C-J>}=down" )
				call Char_menu_wrapAdd( l, "{h}/{H}/{<C-H>}=left" )
				call Char_menu_wrapAdd( l, "{l}/{L}/{<C-L>}=right" )
				call Char_menu_wrapAdd( l, "{r}/{R}=rotate wins/buffers" )
				call Char_menu_wrapAdd( l, "{o}/{O}='only'/clone-in-tab" )
				call Char_menu_wrapAdd( l, "{<C-I>/{<C-O>}=jump forward/back" )
				call Char_menu_wrapAdd( l, "{=}equalize" )
				call Char_menu_wrapAdd( l, "{t}ab menu" )
				call Char_menu_wrapAdd( l, "{s}=>save/restore menu" )
				call Char_menu_wrapAdd( l, "[ {m}isc menu--> ", ", " )
				call Char_menu_wrapAdd( l, "{g}row is " 
							\ . ( s:grow_mode ? '%#DiffChange#ON%##' : 'OFF' ) 
							\ , "" )
				call Char_menu_wrapAdd( l, "wrap is " 
							\ . ( g:WinWalker_opts.wrap ==? 'none' 
							\ ? 'OFF' : '%#DiffChange#' . g:WinWalker_opts.wrap . '%##' ) )
				call Char_menu_wrapAdd( l, " ]", "" ) 

				call Char_menu_wrapAdd( l, "{p}/{<C-P>}rev" )
				call Char_menu_wrapAdd( l, "{n}/{N}ew=>win/tab" )
				call Char_menu_wrapAdd( l, "{v}ert new" )
				call Char_menu_wrapAdd( l, "quick {e}dit" )
				call Char_menu_wrapAdd( l, "{:}ex" )
				call Char_menu_wrapAdd( l, "{/}find win" )
				call Char_menu_wrapAdd( l, "{c}olumns preset("
							\ . "%#Tag#" . g:WinWalker_opts.preset_lines . "%##"
							\ . "," 
							\ . "%#Tag#" . g:WinWalker_opts.preset_cols . "%##"
							\ . ")" )

				call Char_menu_wrapAdd( l, "send :{q}uit/:{Q}uit!/{<C-Q>}=tabclose!/{Z}Z" )
			endif " if g:WinWalker_opts.menu ==? 'FULL'


			if g:WinWalker_opts.menu ==? 'FULL'
				call Char_menu_wrapAdd( l, "{<SPACE>}/{<ESC>}=>Exit:  " )
			else
				"call Char_menu_wrapAdd( l, "WinWalker {<ESC>}=>Exit:  " )
				" Need to give Char_menu() at least one {} field for it to work
				" properly.
				"call Char_menu_wrapAdd( l, "WinWalker Main, {m}=>menu opts, {<SPACE>}=>Exit:  " )
				call Char_menu_wrapAdd( l, 'WinWalker' 
							\ . ( s:grow_mode ? ' %#DiffChange#grow mode%##' : '' ) 
							\ . '{ }: ' )
			endif

			" put this here so if it won't draw the menu if the user is
			" typing too fast.
			let s:Fast_pass = ( localtime() - s:last_start_time ) < 1
			let s:last_start_time = localtime()

			if ms_sleep > 300
				let s:Fast_pass = 0
			endif

			if getchar(1)
				let ms_sleep = 0
			else
				let ms_sleep += 100
				sleep 100ms
			endif


			
			"if s:Fast_pass && getchar(1)
			if getchar(1)
				let l:inp = getchar()
				if nr2char( l:inp ) != ""
					let l:inp = nr2char( l:inp )
				endif
			else
				match WinWalker_sel /./
				call s:Empty_fill_fake()

				let l:inp = Char_menu( join( l, '' )
							\ , "{<ESC>} {<C-C>} {<DEL>} {<BS>} {;}"
							\ . "{<UP>} {<DOWN>} {<LEFT>} {<RIGHT}} "
							\ . "{<S-UP>} {<S-DOWN>} {<S-LEFT>} {<S-RIGHT}} "
							\ . "{<C-UP>} {<S-DOWN>} {<C-LEFT>} {<C-RIGHT}} "
							\ . "{<M-UP>} {<M-DOWN>} {<M-LEFT>} {<M-RIGHT}} "
							\ , l:last_inp )

				match
				call s:Empty_empty()

			endif " end Fast_pass check


		endif	" end Unhuman_input check


		let l:last_inp = l:inp

		if exists( 's:Arrow_key_trans[ l:inp ]' )
			let l:inp = s:Arrow_key_trans[ l:inp ]
		endif

		if exists( 'g:WinWalker_remap[ l:inp ]' )
			let l:inp = g:WinWalker_remap[ l:inp ]
		endif

		" ------------------------------------------------------------
		"  Begin command execution:
		"


		if l:inp == '?'
			"
			" ----------------------------------------
			" Help
			"
			help WinWalker
			" Probably should do some cleanup ops before exiting:
			call Clear_cmd_window()
			return


		elseif l:inp =~ '[e;:]'
			"
			" ----------------------------------------
			" Quick :ex command passthrough
			"
			let fake_prompt = '->:'
			let pre_enter = ''
			let compete_opt = ''

			if l:inp == 'e'
				let pre_enter = 'e '
				let compete_opt = 'file'
			elseif l:inp =~ '[;:]'
				"let compete_opt = 'command'
				let compete_opt = 'command'
			endif

				" compete_opt only works for the line as a whole, not
				" individual words.   Crap.
				"
				" Adding a default text will cripple the compete_opt, because
				" the default text is considered to be part of any compete_opt
				" the user attemps.
				"
			try
				let g:redir_tmp = ''
				let ex_input = input( fake_prompt . pre_enter, "", compete_opt )
				if ex_input != ''
					redir => g:redir_tmp
					exe pre_enter . ex_input
					redir END
				endif
			catch
				" getting wrong v:errmsg for failures to execute ex_inpt
				let s:errmsg .= 'Caught: ' . v:errmsg 
							\ . ', exception:' . v:exception
			finally
				if strlen( g:redir_tmp ) > 70
					call getchar()
				else
					let g:redir_tmp = strtrans( g:redir_tmp )
					let s:infomsg .= '['.substitute( g:redir_tmp,
								\ '<\d\d>', ' ', 'g' ) . ']'
				endif
			endtry

			" Completion behavior				*:command" -completion*
			" -complete=augroup	autocmd groups
			" -complete=buffer	buffer names
			" -complete=command	Ex command (and arguments)
			" -complete=dir		directory names
			" -complete=environment	environment variable names
			" -complete=event		autocommand events
			" -complete=expression	Vim expression
			" -complete=file		file and directory names
			" -complete=shellcmd	Shell command
			" -complete=function	function name
			" -complete=help		help subjects
			" -complete=highlight	highlight groups
			" -complete=mapping	mapping name
			" -complete=menu		menus
			" -complete=option	options
			" -complete=tag		tags
			" -complete=tag_listfiles	tags, file names are shown when CTRL-D is hit
			" -complete=var		user variables
			" -complete=custom,{func} custom completion, defined via {func}
			" -complete=customlist,{func} custom completion, defined via {func}



		elseif l:inp ==# 'm'
			"
			" ----------------------------------------
			call s:Misc_menu()


		elseif l:inp ==# 't'
			"
			" ----------------------------------------
			call s:Tab_menu()


		elseif l:inp ==# 's'
			"
			" ----------------------------------------
			" Save layout
			"
			"let s:savesizes = winrestcmd()
			"let s:infomsg .= " Sizes saved"
			call s:Save_menu()


		elseif l:inp ==# 'S'
			"
			" ----------------------------------------
			" Restore layout
			"
			if exists( 's:savesizes' )
				exe s:savesizes
				"call winrestview( s:saveview )
			else
				let s:errmsg .= ' Do a save first. '
			endif


		elseif l:inp ==# 'g'
			"
			" ----------------------------------------
			"  Grow toggle, see also Misc_menu
			if s:grow_mode 
				let s:grow_mode = 0 
			else 
				let s:grow_mode = 1 
			endif


		elseif l:inp ==# 'c'
			"
			" ----------------------------------------
			" Do preset
			"
			if winheight( winnr() ) < g:WinWalker_opts.preset_lines
				exe 'silent! resize ' . g:WinWalker_opts.preset_lines
			endif
			exe 'silent! vert resize ' . g:WinWalker_opts.preset_cols


		elseif l:inp =~# '[/]'
			"
			" ----------------------------------------
			" Find/jump to a window
			"

			let matched = {}
			let matched = s:Pick_buf( )
			let found_wins = []
			let listnr = 0
			if len( matched ) > 0

				for t in range( 1, tabpagenr("$") )
					for b in tabpagebuflist( t )
						if b == matched.bufnr
							let wininfo = {}
							let wininfo.tabnr = t
							" not in correct window for bufwinnr() to work:
							"let wininfo.winnr = bufwinnr( b )
							let wininfo.bufnr = b
							let wininfo.bufname = matched.bufname
							"let wininfo.listnr = listnr
							call add( found_wins, wininfo )
							let listnr += 1
						endif
					endfor
				endfor

				if len( found_wins ) == 0
					if s:buf_check ==? 'loaded'
						let s:infomsg .= ' No window found for selection. '
						continue
					else
						let s:infomsg .= ' No window found, loading '
									\ . matched.bufname
									\ . ', b#' . matched.bufnr . ' in current. '
						exe 'buf '. matched.bufnr
						continue
					endif
				endif

				let picked = found_wins[0]

				if len( found_wins ) > 1
					let l = []
					let i = 1
					for elem in found_wins
						call Char_menu_wrapAdd( l, '{'. i .'}'
									\ . ' = ( '
									\ . fnamemodify( elem.bufname, ':t' ) . ' = b#' . b
									\ . '(tab ' . elem.tabnr
									\ . ' )' )
						"\ . ',win ' . elem['winnr'] 
						let i += 1
					endfor

					if s:Unhuman_input
						let inp = s:Recheck_unhuman()
						if inp == 0 | return | endif
					else
						let inp = Char_menu( join( l, '' )
									\ , "{<ESC>} {<C-C>} {<DEL>} {;}"
									\ , last_inp )
						let last_inp = inp

						if exists( 'found_wins[ inp - 1 ]' )
							let picked = found_wins[ inp - 1 ]
						else
							let s:errmsg .= ' Invalid selection.'
							continue
						endif
					endif

				endif	" if len( found_wins ) > 1

				let s:infomsg .= ' Selected (' . picked.bufname . ')'
				exe 'tabnext ' . picked.tabnr
				exe '' . bufwinnr( picked.bufnr ) . ' wincmd w'

			else
				" Redundant with message in s:Pick_buf()
				"let s:errmsg .= ' No match found. '
			endif

			" End:  Find/jump to a window
			" ----------------------------------------



		elseif l:inp ==# 'o'
			"
			" ----------------------------------------
			" 'only' window command
			"
			echohl StatusLine
			let yesno = input( "Close all other windows? " )
			if yesno =~? '^y'
				wincmd o
			endif


		elseif l:inp ==# 'O'
			"
			" ----------------------------------------
			" Clone window in new tab
			"
			tabnew
			exe 'buf ' . s:this_bufnr

			" Set the new window to be deleted if the next window 
			" motion is ^O
			let s:O_temp_win = {}
			let s:O_temp_win.tabnr = tabpagenr()
			let s:O_temp_win.winnr = winnr()



		elseif l:inp ==# "\<C-I>"
			" ----------------------------------------
			" Jump forward in stack
			call s:Jump_list_forward()


		elseif l:inp ==# "\<C-O>"
			" ----------------------------------------
			" Jump backward in stack
			if exists( 's:O_temp_win' )
				if			s:O_temp_win.tabnr == tabpagenr()
					\ &&	s:O_temp_win.winnr == winnr()
					hide
				endif
				" 'hide' will trigger 'BufLeave' which will unlet it:
				"unlet s:O_temp_win
			endif
			call s:Jump_list_backward()


		elseif s:grow_mode && ( l:inp =~# '[JKHL]'
					\ || l:inp =~ "\\(\<C-J>\\|\<C-K>\\|\<C-H>\\|\<C-L>\\)" )
			"
			" ----------------------------------------
			" Grow or shrink
			"
			let dir_keymap = { 
					\ 'K' : 'up', 'J' : 'down', 'H' : 'left', 'L' : 'right'
					\ , "\<C-K>" : 'up', "\<C-J>" : 'down'
					\ , "\<C-H>" : 'left', "\<C-L>" : 'right'
					\ }
			let dir = dir_keymap[ l:inp ]

			let grow_or_shrink = GetWinAdjacent( dir ) > 0 ? '+' : '-'

			if  dir =~?  '\(up\|down\)'
				if GetWinAdjacent( 'up' ) > 0 && GetWinAdjacent( 'down' ) > 0
							\ && dir ==? 'down'
					let grow_or_shrink = '-'
				endif
			else
				if GetWinAdjacent( 'left' ) > 0 && GetWinAdjacent( 'right' ) > 0
							\ && dir ==? 'left'
					let grow_or_shrink = '-'
				endif
			endif

			if  dir =~?  '\(up\|down\)'
				let do_vert = ''
				let incr = 5
			else
				let do_vert = 'vert ' " non-intuitive
				let incr = 15
			endif

			if l:inp =~# '[JKHL]'
				let incr = 1
			else
				" Default to the control keys
			endif

			exe do_vert . 'resize ' . grow_or_shrink . incr

			" End:  Grow or shrink
			" ----------------------------------------


		elseif l:inp =~# '[JKHL]'
			"
			" ----------------------------------------
			" Window push commands
			"
			let w_other = GetWinAdjacent( l:inp )
			let b_old = bufnr("%")
			let w_old = winnr()
			let lines_old = winheight(winnr())
			let cols_old = winwidth(winnr())

			" Some app.s like 'Taglist' will self-destruct if they are fiddled
			" with, so let's start with 'bufhidden', and eventignore.
			let save_bufnr = s:this_bufnr
			let save_bufhidden = getbufvar( save_bufnr, '&bufhidden' )
			set bufhidden=hide

			let save_eventignore = &eventignore
			set eventignore=BufEnter,BufLeave,WinEnter,WinLeave

			if w_other < 1
				if l:inp ==# 'H' && GetWinAdjacent( 'left' ) < 1
							\ &&  GetWinAdjacent( 'up' ) < 1
							\ &&  GetWinAdjacent( 'down' ) < 1
							\ &&  g:WinWalker_opts.wrap ==? 'tabs'
					" Already maximized
					if tabpagenr("$") == 1
						hide
						tabnew
						let where = min( [0, tabpagenr() - 2 ] )
						exe 'tabmove ' . where
					else
						hide
						tabprev

						let s:Keep_jumps = 1
						silent 99 wincmd l
						let s:Keep_jumps = 0

						call s:New_window( 'new' )
					endif
					exe 'buf ' . s:this_bufnr
				elseif l:inp ==# 'L' && GetWinAdjacent( 'right' ) < 1
							\ &&  GetWinAdjacent( 'up' ) < 1
							\ &&  GetWinAdjacent( 'down' ) < 1
							\ &&  g:WinWalker_opts.wrap ==? 'tabs'
					" Already maximized
					if tabpagenr("$") == 1
						hide
						tabnew
					else
						hide
						tabnext

						let s:Keep_jumps = 1
						silent 99 wincmd h
						let s:Keep_jumps = 0

						call s:New_window( 'new' )

					endif
					exe 'silent buf ' . s:this_bufnr
				else
					" Maximize at wall:
					exe 'silent! wincmd ' . l:inp
					wincmd =
				endif
			else " w_other >= 1
				if l:inp =~# '[JK]'
					let save_splitright = &splitright
					if GetWinAdjacent( 'right' ) < 1
						let &splitright = 1
					elseif GetWinAdjacent( 'left' ) < 1
						let &splitright = 0
					endif

					exe 'wincmd ' . tolower( l:inp )
					call s:New_window( 'vnew' )

					let &splitright = save_splitright

				elseif l:inp =~# '[HL]'
					let save_splitbelow = &splitbelow
					if GetWinAdjacent( 'up' ) < 1
						let &splitbelow = 0
					elseif GetWinAdjacent( 'down' ) < 1
						let &splitbelow = 1
					endif
					exe 'silent wincmd ' . tolower( l:inp )

					call s:New_window( 'new' )

					let &splitbelow = save_splitbelow

				endif

				" [v]new invalidates old window numbers

				let b_temp = winbufnr( winnr() )

				let old_winnr = bufwinnr( b_old )
				exe 'silent ' . old_winnr . 'wincmd w'

				silent hide
				redraw

				exe 'silent ' . bufwinnr( b_temp ) . 'wincmd w'
				exe 'silent buf ' . s:this_bufnr

				" Assume that if it's currently full height/width, then don't
				" resize and squish everything at the destination:
				let avail_lines = &lines - &cmdheight - 2
				if lines_old > winheight(winnr()) && lines_old < avail_lines
					exe 'silent resize ' . lines_old
				endif
				if cols_old > winwidth(winnr()) && cols_old < &columns
					exe 'silent vert resize ' . cols_old
				endif

				call setbufvar( save_bufnr, '&bufhidden', save_bufhidden )
				let &eventignore = save_eventignore

	 		endif " [JK] handling,  w_other <?? 1

			" End:  Window push commands
			" ----------------------------------------


		elseif l:inp ==# 'r'
			"
			" ----------------------------------------
			"  Rotate window

			if &modified
				let s:errmsg = "Cannot rotate modified buffer."
				continue
			endif

			let save_bufnr = s:this_bufnr
			let save_bufhidden = getbufvar( save_bufnr, '&bufhidden' )
			call setbufvar( save_bufnr, '&bufhidden', 'hide' )

			let tabwin = tabpagenr() . ',' . winnr()
			if !exists( 's:Win_orient[ tabwin ]' ) 
					\ || s:Win_orient[ tabwin ] ==? "horizontal"
				" If wrong, will correct with another key press
				quit
				call s:New_window( 'vnew' )
			else
				quit
				call s:New_window( 'new' )
			endif

			exe 'buf ' . s:this_bufnr
			redraw

			wincmd =

			call setbufvar( save_bufnr, '&bufhidden', save_bufhidden )

			"  End: Rotate window
			" ----------------------------------------


		elseif l:inp ==# 'R'
			"
			" ----------------------------------------
			"  Rotate view

			let w_restore = winnr()
			let w = 1
			while w <= winnr("$")
				exe 'silent! ' . w . 'wincmd w'
				if &modified
					let s:errmsg = "Cannot rotate, some buffer is modified."
					break
				endif
				let w += 1
			endwhile
			if w > winnr("$")
				let w = 1
				let b_first = winbufnr( 1 )
				1wincmd w
				while w < winnr("$")
					let w_next = w + 1
					let b_next = winbufnr( w_next )
					exe 'silent! buf ' . b_next
					wincmd w
					let w += 1
				endwhile
				exe 'silent! buf ' . b_first
				exe "silent!" . w_restore . 'wincmd w'
			endif
			" End:  Rotate view
			" ----------------------------------------


		elseif l:inp == "\<C-R>"
			"
			" ----------------------------------------
			"  Rotate tab

			let pg = tabpagenr()
			if pg == tabpagenr("$")
				let new_pg = 0
			else
				let new_pg = pg
			endif
			exe 'tabmove ' . new_pg



		elseif l:inp =~# '[=x+-<>]'
			"
			" ----------------------------------------
			" Misc commands that don't require switched window highlighting:
			"
			exe "silent! wincmd " . l:inp



		elseif   l:inp =~# '[jkhlNtTnvwWtbp]'
			\ || l:inp =~# "\\(\<C-W>\\|\<C-P>\\)"
			"
			" ----------------------------------------
			" Misc ommands that require switched window highlighting:


			if l:inp ==# 't'
				tabnext
			elseif l:inp ==# 'v'
				call s:New_window( 'vnew' )
			elseif l:inp ==# 'T'
				tabprev
			elseif l:inp ==# 'N'
				tabnew
			elseif l:inp ==# 'k'
				if GetWinAdjacent( "up" )   > 0 
					silent wincmd k 
				elseif g:WinWalker_opts.wrap !=? 'none'
					let s:Keep_jumps = 1
					silent 99 wincmd j 
					let s:Keep_jumps = 0
					call WinWalker_BufEnter()
				endif
			elseif l:inp ==# 'j'
				if GetWinAdjacent( "down" ) > 0 
					silent wincmd j 
				elseif g:WinWalker_opts.wrap !=? 'none'
					let s:Keep_jumps = 1
					silent 99 wincmd k 
					let s:Keep_jumps = 0
					call WinWalker_BufEnter()
				endif
			elseif l:inp ==# 'h'
				if GetWinAdjacent( "left" ) > 0 
					silent wincmd h 
				else
					call WinWalker_BufLeave()
					let s:Keep_jumps = 1
					if g:WinWalker_opts.wrap ==? 'win'
						99wincmd l
					elseif g:WinWalker_opts.wrap ==? 'tabs'
						tabprev
						99wincmd l
					endif
					let s:Keep_jumps = 0
					call WinWalker_BufEnter()
				endif
			elseif l:inp ==# 'l'
				if GetWinAdjacent( "right" ) > 0 
					silent! wincmd l 
				else
					call WinWalker_BufLeave()
					let s:Keep_jumps = 1
					if g:WinWalker_opts.wrap ==? 'win'
						99wincmd h
					elseif g:WinWalker_opts.wrap ==? 'tabs'
						tabnext
						99wincmd h
					endif
					let s:Keep_jumps = 0
					call WinWalker_BufEnter()
				endif
			elseif l:inp == "\<C-W>"
				exe "silent! wincmd w"
			elseif l:inp == "\<C-P>"
				exe "silent! wincmd p"
			else
				exe "silent! wincmd " . l:inp
			endif

			" end: Misc ommands that require switched window highlighting:
			" ----------------------------------------



		"
		" ----------------------------------------
		"  Exchange buffers up/down/left/right
		"
		elseif l:inp =~  "\\(\<C-K>\\|\<C-J>\\|\<C-H>\\|\<C-L>\\)"

			if l:inp ==  "\<C-K>"
				let win1 = winnr()
				let win2 = GetWinAdjacent( "up" )
				if win2 < 1
					silent! wincmd b 
					let win2 = winnr()
				endif
				call s:Exchange_win( win1, win2 ) 
				exe 'silent! ' . win2 . ' wincmd w'

			elseif l:inp ==  "\<C-J>"
				let win1 = winnr()
				let win2 = GetWinAdjacent( "down" )
				if win2 < 1
					silent! wincmd t
					let win2 = winnr()
				endif
				call s:Exchange_win( win1, win2 ) 
				exe 'silent! ' . win2 . ' wincmd w'

			elseif l:inp ==  "\<C-H>"
				let win1 = winnr()
				let win2 = GetWinAdjacent( "left" )
				if win2 < 1
					if g:WinWalker_opts.wrap ==? 'win'
						silent! 99 wincmd l
						let win2 = winnr()
					elseif g:WinWalker_opts.wrap ==? 'tabs'
						if winnr("$") == 1
							call s:New_window( 'new' )
							wincmd p
						endif
						hide
						if tabpagenr("$") == 1
							tabnew
							let where = min( [0, tabpagenr() - 2 ] )
							exe 'tabmove ' . where
						else
							tabprev

							let s:Keep_jumps = 1
							silent 99 wincmd l
							let s:Keep_jumps = 0

							call s:New_window( 'new' )
						endif
						exe 'buf ' . s:this_bufnr
					endif
				else
					call s:Exchange_win( win1, win2 ) 
					exe 'silent! ' . win2 . ' wincmd w'
				endif

			elseif l:inp ==  "\<C-L>"
				let win1 = winnr()
				let win2 = GetWinAdjacent( "right" )
				if win2 < 1
					if g:WinWalker_opts.wrap ==? 'win'
						silent! 99 wincmd h
						let win2 = winnr()
					elseif g:WinWalker_opts.wrap ==? 'tabs'
						if winnr("$") == 1
							call s:New_window( 'new' )
							wincmd p
						endif
						hide
						if tabpagenr("$") == 1
							tabnew
						else
							tabnext

							let s:Keep_jumps = 1
							silent 99 wincmd h
							let s:Keep_jumps = 0

							call s:New_window( 'new' )
						endif
						exe 'silent buf ' . s:this_bufnr
					endif
				else
					call s:Exchange_win( win1, win2 ) 
					exe 'silent! ' . win2 . ' wincmd w'
				endif

			endif
		"  End: Exchange buffers up/down/left/right
		" ----------------------------------------


		"
		" ----------------------------------------
		"  Misc commands
		"

		elseif l:inp ==# 'Z'
			let is_last = ( winnr() == winnr("$") )
			normal! ZZ
			if is_last && bufnr("%") != s:this_bufnr
				call s:Jump_list_backward()
			endif

		elseif l:inp ==# 'q'
			let is_last = ( winnr() == winnr("$") )
			quit
			if is_last && bufnr("%") != s:this_bufnr
				call s:Jump_list_backward()
			endif

		elseif l:inp ==# 'Q'
			let is_last = ( winnr() == winnr("$") )
			quit!
			if is_last && bufnr("%") != s:this_bufnr
				call s:Jump_list_backward()
			endif

		elseif l:inp ==  "\<C-Q>"
			tabclose!
			call s:Jump_list_backward()

		elseif l:inp =~  "\\( \\|\<C-SPACE>\\|\<CR>\\|\<C-CR>\\)"
			
			if s:Unhuman_input
				let Menu_started = 1
				continue
			else
				break
			endif

		elseif l:inp =~  "[\eq]" || l:inp ==  "\<C-C>"
			break
		else
			"let s:errmsg = 'Invalid cmd (' . l:inp . ')'
			exe 'silent normal! ' . l:inp
			break
		endif


		let do_break = 0
		for key in g:WinWalker_dropout_keys
			if l:inp ==# key | let do_break = 1 | endif
		endfor
		if do_break | break | endif

		redraw

	endwhile

	if s:Unhuman_input 
	else
		call WinWalker_clean_empties()
		call Clear_cmd_window()
		echohl Special

		echo "Done"

		echohl None

		let &cmdheight = s:save_cmdheight
		let &switchbuf = s:save_switchbuf
	endif


endfunction

" WinWalkerMenu main func                                           }}}
" ----------------------------------------------------------------------




" ----------------------------------------------------------------------
" Misc_menu                                                         {{{

function! s:Misc_menu()

	let l:last_inp = ''

	while 1
		let l = []

		if s:errmsg != ''
			call Char_menu_wrapAdd( l, '%#Error#' . s:errmsg . '%##' )
			let s:errmsg = ''
		endif
		if s:infomsg != ''
			call Char_menu_wrapAdd( l, '%#Special#' . s:infomsg . '%##' )
			let s:infomsg = ''
		endif

		call Char_menu_wrapAdd( l, "{r}c file is (%#Tag#" . g:WinWalker_opts.rc_file . "%##)" )

		call Char_menu_wrapAdd( l, "{g}row is " 
					\ . ( s:grow_mode ? '%#DiffChange#ON%##' : 'OFF' ) )

		call Char_menu_wrapAdd( l, "{c}=>set preset ("
					\ . "%#Tag#" . g:WinWalker_opts.preset_lines . "%##"
					\ . ","
					\ . "%#Tag#" . g:WinWalker_opts.preset_cols . "%##"
					\ . ")" )

		call Char_menu_wrapAdd( l, "{w}rap is " 
					\ . '%#DiffChange#' . g:WinWalker_opts.wrap . '%##' )

		call Char_menu_wrapAdd( l, "{m}enu is " 
					\ . '%#DiffChange#' . g:WinWalker_opts.menu . '%##' )

		call Char_menu_wrapAdd( l, "{h}ighlight current win " 
					\ . '%#DiffChange#' . g:WinWalker_opts.hi_curr . '%##' )

		call Char_menu_wrapAdd( l, "{e}mpty files == " 
					\ . '%#DiffChange#' . g:WinWalker_opts.empty . '%##' )

		call Char_menu_wrapAdd( l, "{t}imeoutlen is (%#Tag#" . g:WinWalker_opts.timeoutlen . "ms%##)" )

		call Char_menu_wrapAdd( l, "{j}ump list"  )
		call Char_menu_wrapAdd( l, "{k}ey remap"  )
		call Char_menu_wrapAdd( l, "{d}ropout keys "  )
		call Char_menu_wrapAdd( l, "{SPACE}=>main menu :  "  )



		if s:Unhuman_input
			let l:inp = s:Recheck_unhuman()
			if l:inp == 0 | return | endif
		else
			let l:inp = Char_menu( join( l, '' )
						\ , "{<ESC>} {<C-C>} {<DEL>} {;}"
						\ , l:last_inp )
		endif

		let l:last_inp = l:inp

		if l:inp ==# 'r'
			exe 'echohl ' . g:CMu_menu_hl_text
			let rc_file = input( 'Enter file name: ', g:WinWalker_opts.rc_file, 'file' )
			if rc_file != ''
				let g:WinWalker_opts.rc_file = rc_file
			endif

		elseif l:inp ==# 'm'
			if g:WinWalker_opts.menu ==? 'SHORT' 
				let g:WinWalker_opts.menu = 'FULL'
			else 
				let g:WinWalker_opts.menu = 'SHORT'
			endif

		elseif l:inp ==# 'c'
			let i = input( "Lines, columns? " )
			let [ g:WinWalker_opts.preset_lines, g:WinWalker_opts.preset_cols ] = split( i, ', *' )

		elseif l:inp ==# 'h'
			if g:WinWalker_opts.hi_curr ==? 'ON' 
				let g:WinWalker_opts.hi_curr = 'OFF'
			else 
				let g:WinWalker_opts.hi_curr = 'ON'
			endif
			call s:Hi_init()
		elseif l:inp ==# 'e'
			if g:WinWalker_opts.empty ==? 'LABEL' 
				let g:WinWalker_opts.empty = 'NOLABEL'
			else 
				let g:WinWalker_opts.empty = 'LABEL'
			endif
		elseif l:inp ==# 't'
			let g:WinWalker_opts.timeoutlen = input('Enter timeout in millisec: ' )
			if exists( 'g:CMu_timeoutlen' )
				let g:CMu_timeoutlen	= g:WinWalker_opts.timeoutlen
			endif
		elseif l:inp ==# 'g'
			if s:grow_mode 
				let s:grow_mode = 0 
			else 
				let s:grow_mode = 1 
			endif
		elseif l:inp ==# 'w'
			if g:WinWalker_opts.wrap ==? 'none'
				let g:WinWalker_opts.wrap = 'win' 
			elseif g:WinWalker_opts.wrap ==? 'win'
				let g:WinWalker_opts.wrap = 'tabs' 
			elseif g:WinWalker_opts.wrap ==? 'tabs'
				let g:WinWalker_opts.wrap = 'none' 
			endif

		elseif l:inp ==# 'j'
			call WinWalker_show_jump_list()

		elseif l:inp ==# 'k'
			echon "\n"
			for key in keys( g:WinWalker_remap )
				echon '(' . strtrans( key ) . ')->(' 
							\ . strtrans( g:WinWalker_remap[ key ] )
							\ . ")\n"
			endfor
			echon "\nMap (<ESC> to cancel) FROM key:"
			let key1 = getchar()
			if nr2char( key1 ) != "" | let key1 = nr2char( key1 ) | endif
			if key1 != "\<ESC>"
				echon "\nMap (<ESC> to remove '" . key1 . "') TO key:"
				let key2 = getchar()
				if nr2char( key2 ) != "" | let key2 = nr2char( key2 ) | endif
				if key2 == "\<ESC>"
					call remove( g:WinWalker_remap, key1 )
				else
					let g:WinWalker_remap[ key1 ] = key2
				endif
			endif

		elseif l:inp ==# 'd'
			let save_display = &display
			set display-=uhex
			echon "\n"
			echon strtrans( string ( g:WinWalker_dropout_keys ) ) . ', <ESC>=abort : '

			let key1 = getchar()
			if nr2char( key1 ) != "" | let key1 = nr2char( key1 ) | endif

			if key1 != "\<ESC>"
				if count( g:WinWalker_dropout_keys, key1 ) > 0
					let s:infomsg .= ' Removing (' . strtrans( key1 )
								\ . ') from list'
					call filter( g:WinWalker_dropout_keys, 'v:val !=# key1' )
				else
					let s:infomsg .= ' Adding (' . strtrans( key1 )
								\ . ') to list'
					call add( g:WinWalker_dropout_keys, key1 )
				endif
			endif

			let &display = save_display


		elseif l:inp ==# ' ' || l:inp =~ "\\(\<ESC>\\|\<C-C>\\)"
			break
		else
			let s:errmsg .= " Invalid command (" . l:inp . ") "
		endif

	endwhile

	let s:Keep_jumps = 1
	call WinWalker_save_cfg()
	let s:Keep_jumps = 0

endfunction

" Misc_menu                                                         }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Tab_menu                                                         {{{

function! s:Tab_menu()

	let l:last_inp = ''

	while 1
		let l = []

		if s:infomsg != ''
			call Char_menu_wrapAdd( l, '%#Special#' . s:infomsg . '%##' )
			let s:infomsg = ''
		endif
		if s:errmsg != ''
			call Char_menu_wrapAdd( l, '%#Error#' . s:errmsg . '%##' )
			let s:errmsg = ''
		endif
		call Char_menu_wrapAdd( l, "{h}/{l}=go prev/next" )
		call Char_menu_wrapAdd( l, "{H}/{L}=move prev/next" )
		call Char_menu_wrapAdd( l, "{n}/{N}ew tab" )
		call Char_menu_wrapAdd( l, "{t}ab table" )
		call Char_menu_wrapAdd( l, "{q}/{C-Q>=tabclose/tabclose!" )

		call Char_menu_wrapAdd( l, "{SPACE}=>main menu :  "  )



		if s:Unhuman_input
			let l:inp = s:Recheck_unhuman()
			if l:inp == 0 | return | endif
		else
			" Almost all the tab commands require a redraw:
			redraw
			let l:inp = Char_menu( join( l, '' )
						\ , "{<ESC>} {<C-C>} {<DEL>} {;}"
						\ , l:last_inp )
		endif

		let l:last_inp = l:inp

		if l:inp ==# 'h'
			tabprev
			"endif
		elseif l:inp ==# 'l'
			tabnext
		elseif l:inp ==# 't'
			redir @">
			tabs
			redir end
			call input( @" . "\<NL>\<NL>Press enter:  " )
		elseif l:inp ==# 'H'
			let t = tabpagenr() - 2
			if t < 0
				tabmove
			else
				exe 'tabmove ' . t
			endif
		elseif l:inp ==# 'L'
			if tabpagenr() == tabpagenr("$")
				tabmove 0
			else
				exe 'tabmove ' . tabpagenr()
			endif
		elseif l:inp =~# '[nN]'
			tabnew
		elseif l:inp ==# "q"
			tabclose
		elseif l:inp ==# "\<C-Q>"
			tabclose!
		elseif l:inp ==# ' ' || l:inp == "\<ESC>" || l:inp == "\<C-C>"
			break
		else
			let s:errmsg .= " Invalid command (" . l:inp . ") "
		endif

	endwhile

endfunction

" Tab_menu                                                         }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Save menu, functions, options                                      {{{

function! s:Save_menu()

	let l:last_inp = ''

	while 1
		let l = []

		if s:infomsg != ''
			call Char_menu_wrapAdd( l, '%#Special#' . s:infomsg . '%##' )
			let s:infomsg = ''
		endif
		if s:errmsg != ''
			call Char_menu_wrapAdd( l, '%#Error#' . s:errmsg . '%##' )
			let s:errmsg = ''
		endif

		call Char_menu_wrapAdd( l, "Save {d}irectory is (%#Tag#" . g:WinWalker_opts.sess_dir . "%##)" )
		call Char_menu_wrapAdd( l, "{s}ave session" )
		call Char_menu_wrapAdd( l, "{t}ab save session" )
		call Char_menu_wrapAdd( l, "{r}estore session" )
		call Char_menu_wrapAdd( l, "{l}ist sessions" )

		call Char_menu_wrapAdd( l, "{SPACE}=>main menu :  "  )



		if s:Unhuman_input
			let l:inp = s:Recheck_unhuman()
			if l:inp == 0 | return | endif
		else
			" Almost all the tab commands require a redraw:
			redraw
			let l:inp = Char_menu( join( l, '' )
						\ , "{<ESC>} {<C-C>} {<DEL>} {;}"
						\ , l:last_inp )
		endif

		let l:last_inp = l:inp


		if l:inp ==# 'd'
			exe 'echohl ' . g:CMu_menu_hl_text
			let sess_dir = input( 'Enter directory : ', g:WinWalker_opts.sess_dir, 'file' )
			if sess_dir != ''
				let g:WinWalker_opts.sess_dir = sess_dir
			endif


		elseif l:inp =~# '[st]'
			call Clear_cmd_window()
			redraw

			let save_sessionoptions = &sessionoptions

			exe 'echohl ' . g:CMu_menu_hl_text

			if l:inp ==# 't'
				echon "Save this tab, "
				set sessionoptions-=tabpages
			else
				echon "Save all tabs, "
				set sessionoptions+=tabpages
			endif

			echon 'Session options=' 
			echohl Tag
			echon &sessionoptions 
			echohl NONE

			exe 'echohl ' . g:CMu_menu_hl_text

			let fname = input( 'Save file? (^C, ^D, <TAB> active): ',
						\ g:WinWalker_opts.sess_dir . '/Session.',
						\ 'customlist,Session_file_complete' )


			if fname != ''
				if fname !~? '\.vim$'
					let fname .= '.vim'
				endif
				try
					exe 'mksession! ' . fname
				catch
					let s:errmsg .= ' Save session failed, ' . v:errmsg
				endtry
			else
				let s:infomsg .= ' Not saved.'
			endif

			let &sessionoptions = save_sessionoptions

		elseif l:inp ==# 'r'
			call Clear_cmd_window()
			redraw

			exe 'echohl ' . g:CMu_menu_hl_text

			let fname = input( 'Restore file? (^C, ^D, <TAB> active): ', 
						\ g:WinWalker_opts.sess_dir . '/Session.',
						\ 'customlist,Session_file_complete' )
			if fname != ''
				try
					exe 'source ' . fname
				catch
					let s:errmsg .= ' Restore session failed, ' . v:exception
				endtry
			endif

		elseif l:inp ==# 'l'
			let files = globpath( g:WinWalker_opts.sess_dir . ',.', 'Session*' )

			echo s:Session_show_details( g:WinWalker_opts.sess_dir . '/Session* Session*' )
			exe 'echohl ' . g:CMu_menu_hl_text
			echon "\nPress any key: "
			call getchar()

		elseif l:inp ==# ' ' || l:inp == "\<ESC>" || l:inp == "\<C-C>"
			break
		else
			let s:errmsg .= " Invalid command (" . l:inp . ") "
		endif

	endwhile

endfunction




function! Session_file_complete( ArgLead, CmdLine, CursorPos )

	"echomsg 'ArgLead, CmdLine, CursorPos =' . a:ArgLead . ',' .  a:CmdLine . ',' .  a:CursorPos 

	let candidates = split( glob( a:ArgLead . '*' ), "\n")

	"echo string( candidates )

	if len( candidates ) == 1

		echo s:Session_show_details( join( candidates, ' ' )  )
		echon "\nPress any key: "
		call getchar()
		call Clear_cmd_window()

		"return s:Session_show_details( candidates[0] . '*' )
		"return
		"return []
	endif
	"return candidates 
	"echomsg 'returning ' . join( candidates, "\n" )
	"return glob( a:ArgLead . '*' )
	"return join( candidates, "\n" )
	return candidates
endfunction




function! s:Session_show_details( ... )
	try
		exe 'silent vimgrep /^\(edit \|tabnew\)/j' . join( a:000, ' ' )
	catch
		let s:errmsg .= ' No session files found.'
		return ''
	endtry

	silent copen
	let matches = getbufline( "%", 1, "$" )
	silent cclose

	let bufs_in_session = {}
	let session_tab_level = {}
	for match in matches
		if match =~ 'tabnew'
			let session_tab_level[ session ] += 1
		else
			let [ junk, session, bufname ] = matchlist( match, '^\([^|]\+\)|[^|]\+|\s*edit\s*\(.*\)' )

			if !exists( 'session_tab_level[ session ] ' )
				let session_tab_level[ session ] = 1
			endif
			if !exists('bufs_in_session[session]' )
				let bufs_in_session[ session ] = {}
			endif
			if !exists('bufs_in_session[session][ session_tab_level[ session ] ]' )
				let bufs_in_session[ session ][  session_tab_level[ session ]  ] = []
			endif
			call add( bufs_in_session[ session ][  session_tab_level[ session ]  ], bufname )
		endif
	endfor

	let out = ''
	for session in sort( keys( bufs_in_session ) )
		let out .= session . '  ' . strftime( "%c", getftime( session ) ) . " :\n    "
		for tabnum in keys( bufs_in_session[ session ] )
			let out .= '  Tab#' . tabnum . '=[' . join( bufs_in_session[ session ][ tabnum ], ', ' ) . ']'
		endfor
		let out .= "\n\n"
	endfor
	return out
endfunction



function! WinWalker_save_cfg()

	1 new

	let s = [ ''
	\ , 'let g:WinWalker_opts = ' . string( g:WinWalker_opts  )
	\ , 'let g:WinWalker_remap = ' . string( g:WinWalker_remap  )
	\ , 'let g:WinWalker_dropout_keys = ' . string( g:WinWalker_dropout_keys )
	\ ]

	call append( 1, s )
	exe 'silent write! ' . g:WinWalker_opts.rc_file
	silent bwipeout

endfunction


let save_opts = deepcopy( g:WinWalker_opts )

exe 'silent! source ' . g:WinWalker_opts.rc_file

" This is for when options are added in new releases:
for key in keys( save_opts )
	if !exists( 'g:WinWalker_opts[key]' )
		let g:WinWalker_opts[ key ] = save_opts[ key ]
	endif
endfor

if exists( 'g:CMu_timeoutlen' )
	let g:CMu_timeoutlen	= g:WinWalker_opts.timeoutlen
endif

" Save menu, functions, options                                    }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Misc functions                                                    {{{



function! s:Recheck_unhuman()
	let s:Unhuman_input = Peek_char_timeout_wait( 100 )
	if !s:Unhuman_input 
		"finish
		return 0
	endif
	let inp = getchar()
	if nr2char( inp ) != "" | let inp = nr2char( inp ) | endif
	return inp
endfunction




" Takes a dict type, with { tab, win, line, col }
function! s:Go_to_location( addr )
	exe 'silent tabnext ' . a:addr.tabnr
	exe 'silent ' . a:addr.winnr . 'wincmd w '
	if a:addr.line && a:addr.col
		call cursor( a:addr.line, a:addr.col )
	endif
endfunction






function! WinWalker_clean_empties()
	let save_bufnr = bufnr("%")
	let save_eventignore = &eventignore
	set eventignore=all

	for bufnr in range( 1, bufnr("$") )
		if !bufexists( bufnr ) || bufloaded( bufnr ) || bufname( bufnr ) != ''
			continue
		endif

		exe 'sbuf ' . bufnr

		if line("$") > 1 || col("$") > 1
				\ || strlen( getline( "$" ) ) > 0 
			hide
		else
			exe 'silent! bwipeout! ' . bufnr
		endif

	endfor
	"exe 'buf ' . save_bufnr
	let &eventignore = save_eventignore
endfunction






function! s:Pad( s, len )
	let s = a:s
	let pads = a:len - strlen( s )
	while pads > 0
		let s .= ' '
		let pads -= 1
	endwhile
	return s
endfunction




" Misc functions                                                    }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Misc window functions                                             {{{



function! s:Recheck_unhuman()
	let s:Unhuman_input = Peek_char_timeout_wait( 100 )
	if !s:Unhuman_input 
		"finish
		return 0
	endif
	let inp = getchar()
	if nr2char( inp ) != "" | let inp = nr2char( inp ) | endif
	return inp
endfunction




function! s:Exchange_win( win1, win2 )

	if a:win1 < 1 || a:win1 > winnr("$") || a:win2 < 1 || a:win2 > winnr("$")
		return
		" It's ok to give invalid arg so it will prop. errors
	endif

	let bufnr1 = winbufnr( a:win1 )
	let bufnr2 = winbufnr( a:win2 )

"	if getbufvar( bufnr1, '&modified' ) 
"		let s:errmsg = " Cannot exchange, b#" . bufnr1 . " is modified"
"		return
"	endif
"	if getbufvar( bufnr2, '&modified' )
"		let s:errmsg = " Cannot exchange, b#" . bufnr2 . " is modified"
"		return
"	endif

	let save_winnr = winnr()

	"Disabling all events caused windows to lose syntax highlighting.
	" To do:  which events should be disabled, i.e.  not FileType
	"
	let save_eventignore = &eventignore
	set eventignore=BufEnter,BufLeave,WinEnter,WinLeave

	" Some app.s like 'Taglist' will self-destruct if they are fiddled
	" with, so let's start with 'bufhidden', and eventignore.
	let win1_bufhidden = getbufvar( bufnr1, '&bufhidden' ) 
	let win2_bufhidden = getbufvar( bufnr2, '&bufhidden' ) 
	call setbufvar( bufnr1, '&bufhidden', 'hide' ) 
	call setbufvar( bufnr2, '&bufhidden', 'hide' ) 

	exe 'silent! ' . a:win1 . 'wincmd w'
	exe 'silent! buf! ' . bufnr2
	exe 'silent! ' . a:win2 . 'wincmd w'
	exe 'silent! buf! ' . bufnr1

	exe "silent! " . save_winnr . "wincmd w"

	call setbufvar( bufnr1, '&bufhidden', win1_bufhidden ) 
	call setbufvar( bufnr2, '&bufhidden', win2_bufhidden ) 

	let &eventignore = save_eventignore
endfunction




"
" Usage:  GetWinAdjacent( dir ) or ( winnr, dir )
" where 'dir'  is  h, l, j, k, up, down, left, right
" Returns:	winnr==success,
" 			0==found no winnr,
" 			-1==usage error
"
function! GetWinAdjacent( ... )
	if a:0 == 1
		let test_winnr = winnr()
		let dir = tolower( a:1 )
	elseif a:0 == 2
		let test_winnr = a:1
		let dir = a:2
	else
		return -1
	endif

	let save_winnr = winnr()

	" This test must come first, because 0 == '.' will succeed
	if test_winnr =~ '[.]'
		let test_winnr = winnr()
	elseif test_winnr < 1 || test_winnr > winnr("$")
		return -1
	else
	endif

	if     dir ==# 'up'		| let dir = 'k' 
	elseif dir ==# 'down'	| let dir = 'j' |
	elseif dir ==# 'left'	| let dir = 'h' |
	elseif dir ==# 'right'	| let dir = 'l' |
	elseif dir ==# 'right'	| let dir = 'l' |
	elseif dir !~# '[jkhl]'
		return -1
	endif

	let save_eventignore = &eventignore
	set eventignore=BufEnter,BufLeave,WinEnter,WinLeave

	exe "silent! " . test_winnr . "wincmd w"
	if winnr() != test_winnr
		let &eventignore = save_eventignore
		return 0
	endif

	exe 'silent! wincmd ' . dir
	if winnr() == test_winnr
		let result = 0
	else
		let result = winnr()
	endif
	exe "silent! " . save_winnr . "wincmd w"
	let &eventignore = save_eventignore
	return result
endfunction





" This is a simple way to give the user a visual que which window
" is current when there is no cursor in it.
"
function! s:Empty_fill_fake()
	if g:WinWalker_opts.empty ==? 'NOLABEL' | return | endif
	if s:Unhuman_input | return | endif
	let b:empty = 0
	let label2 = s:empty_label
	let width = winwidth( winnr() ) - 2
	if width < strlen( label2 )
		let label2 = substitute( label2, ' ', '', 'g' )
	endif
	if line("$") == 1 && col("$") == 1
		let b:empty = 1
		exe 'silent! normal! ' . winheight(winnr()) . "a\n\eM"
		exe 'silent! normal! ' . width . "a \e"
		exe "silent! normal! o\e" . width . "a_\e"
		exe 'silent! normal! 0gm' . ( strlen( label2 ) / 2 ) . "h"
		exe "silent! normal! R" . label2 . "\e"
		exe "silent! normal! o\e" . width . "a \e"
		set nomodified
	endif
	" Need redraw here or 'match' command fails elsewhere
	redraw
endfunction




function! s:Empty_empty()
	if g:WinWalker_opts.empty ==? 'NOLABEL' | return | endif
	if line("$") > 200 | return | endif	" try to short circuit large files

	let look_for = '\(' . s:empty_label . '\|'
				\ . substitute( s:empty_label, ' ', '', 'g' ) . '\)'

	if search( look_for, 'wn' ) > 0
		let s = join( getline(1,"$"), '' )
		if s =~ '\%^\_s*_*' . look_for . '_*\_s*\%$'
			1,$d _
			set nomodified
		endif
	endif
	" Need redraw here or 'match' command fails elsewhere
	redraw
endfunction



" Misc window functions                                             }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Pick_buf, search/find functions                                   {{{

function! s:Pick_buf( )

	let inp = ''
	let last_inp = ''
	let buflist = []

	while 1
		let l = []
		let b = 1

		if s:errmsg != ''
			call Char_menu_wrapAdd( l, '%#Error#' . s:errmsg . '%##  ' )
			let s:errmsg = ''
		endif

		while b <= bufnr("$")
			if s:buf_check == 'loaded' && !bufloaded(b)
				let b += 1
				continue
			endif
			let elem = {}
			let bufname = bufname( b )
			if bufname == '' | let bufname = '[No Name]' | endif
			let elem.bufnr = b
			let elem.bufname = bufname
			call add( buflist, elem )
			if s:buf_check == '' && bufloaded(b)
				call Char_menu_wrapAdd( l, '( {' . fnamemodify( bufname, ':t' ) . '} = #{' . b . '} has win )' )
			else
				call Char_menu_wrapAdd( l, '( {' . fnamemodify( bufname, ':t' ) . '} = #{' . b . '} )' )
			endif
			let b += 1
		endwhile


		let s:errmsg = ''

		" So far this is working.  After going through the pick dialog, it
		" will return and exit out of the menu subsystem.
		if s:Unhuman_input
			"let inp = s:Recheck_unhuman()
			"let s:Unhuman_input = 0
			"if inp == 0 | return | endif
		endif
		"else

			call Char_menu_wrapAdd( l, ' Enter first uniq char(s), {?} to toggle hidden: ' )

			let inp = Char_menu( join( l, '' )
						\ , "{<ESC>} {<C-C>} {<DEL>} {;}"
						\ , last_inp )
			let last_inp = inp
		"endif

		if inp == '?'
			if s:buf_check == 'loaded'
			   let s:buf_check = ''
		   else
			   let s:buf_check = 'loaded'
		   endif
		   continue
	   endif



		" Quick completion:
		"
		let matched = {}
		for elem in buflist
			"if elem['bufname'] != '' && elem['bufname'] =~ '^' . inp
			let i = escape( inp, '.' )
			let n = fnamemodify( elem['bufname'], ':t' )
			if n =~ '^' . i "|| n =~  '^' . i
				let matched = elem
			elseif elem['bufnr'] ==  inp
				let matched = elem
			elseif elem['bufnr'] =~  '^' . inp
				let matched = elem
			endif
		endfor

		if len( matched ) == 0
			if s:Unhuman_input
				break
			endif
			if inp =~ "\\( \\|\<ESC>\\|\<C-C>\\)"
				break
			else
				let s:errmsg = "No match in list for (" . inp . "), try again."
			endif
		else
			break
		endif

	endwhile


	" This sections has the potential to force the cmd window way up the
	" screen.  I don't know what the right way is to lower it back to it's
	" old position, as it usually does automatically.
	"
	" It needs a redraw, but doesn't help to put it here:
	set cmdheight=2

	return matched

endfunction



" Pick_buf, search/find functions                                   }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Help functions                                                   {{{

function! WinWalker_help_extract()

	try
		silent 1 new
		exe "silent read " . s:This_script_fname
		silent 1,/^" Help Start:/ d
		silent /^" Help End:/,$ d
		silent 1,$ s/^"//
	catch
		echomsg 'WinWalker_help_extract() failed read/clean.'
		return
	endtry

	let pathlist = [ fnamemodify( s:This_script_fname, ':h' ) . '/..' ]
	let pathlist += split( &runtimepath, ', *' )

	let cmd = ''
	for docpath in pathlist
		let docpath = docpath . '/' . 'doc'
		if isdirectory( docpath )
			let cmd = 'silent write! ' . docpath . '/WinWalker.txt'
			break
		endif
	endfor

	if cmd != ''
		"if search( 'WinWalker.txt\*\s*\a*' . s:version, 'w' )
			"echomsg 'Skipping extract'
		"else
			echomsg "Extracting : " . docpath
			exe cmd
			let cmd = 'silent helptags ' . docpath
			exe cmd
		"endif
	endif

	silent bwipeout!

endfunction


" Don't re-extract if the version hasn't changed, since it can cause
" debugging problems since it overwrites any user changes to the .txt
" file, see switch inside:

"call WinWalker_help_extract()




aug WinWalker_help
	au!
	au BufEnter * call WinWalker_help_BufEnter()
	au BufLeave * call WinWalker_help_BufLeave()
aug END



function! WinWalker_help_BufEnter()
	if &filetype != 'help' | return | endif

	if !exists( 'b:save_help_foldenable' )
		call WinWalker_save_help_fold_opts()
	endif

	if !exists( 'b:save_other_foldenable' )
		call WinWalker_save_other_fold_opts()
	endif

	call WinWalker_help_init()

	call WinWalker_restore_help_fold_opts()
endfunction



function! WinWalker_help_BufLeave()
	if &filetype != 'help' | return | endif
	call WinWalker_save_help_fold_opts()
	try
		" Throw away problem with the extract function:
		call WinWalker_restore_other_fold_opts()
	catch
	endtry
endfunction



function! WinWalker_help_init()
	nnoremap <buffer> <silent> <c-]> :call WinWalker_help_tag_trap( "\<c-]>" )<CR>
	" I don't understand this magic:  why does \\<  work for special keys, and
	" \<  doesn't.  There are some other weird side effects, but it seems to
	" work.
	nnoremap <buffer> <silent> <2-leftmouse> :call WinWalker_help_tag_trap( "\\<2-leftmouse>" )<CR>
	nnoremap <buffer> <silent> <c-leftmouse> :call WinWalker_help_tag_trap( "\\<c-leftmouse>" )<CR>
	nnoremap <buffer> <silent> g<leftmouse> :call WinWalker_help_tag_trap( "g\\<leftmouse>" )<CR>
endfunction



function! WinWalker_help_tag_trap( key )
	let tag = expand("<cword>")

	if tag =~ '^call__'
		let func = substitute( tag, '^call__', '', '' )
		call {func}()
	elseif tag == 'Turn_folding_on'
		call WinWalker_set_help_folding()
	elseif tag == 'Turn_folding_off'
		call WinWalker_unset_help_folding()
	else
		exe 'silent normal! ' . a:key
	endif
endfunction



function! WinWalker_save_help_fold_opts()
	let b:save_help_foldenable	= &foldenable
	let b:save_help_foldopen	= &foldopen
	let b:save_help_foldclose	= &foldclose
	let b:save_help_foldmarker	= &foldmarker
	let b:save_help_foldmethod	= &foldmethod
endfunction


function! WinWalker_save_other_fold_opts()
	let b:save_other_foldenable	= &foldenable
	let b:save_other_foldopen	= &foldopen
	let b:save_other_foldclose	= &foldclose
	let b:save_other_foldmarker	= &foldmarker
	let b:save_other_foldmethod	= &foldmethod
endfunction



function! WinWalker_restore_help_fold_opts()
	let &foldenable	= b:save_help_foldenable
	let &foldopen	= b:save_help_foldopen
	let &foldclose	= b:save_help_foldclose
	let &foldmarker	= b:save_help_foldmarker
	let &foldmethod	= b:save_help_foldmethod
endfunction


function! WinWalker_restore_other_fold_opts()
	let &foldenable	= b:save_other_foldenable
	let &foldopen	= b:save_other_foldopen
	let &foldclose	= b:save_other_foldclose
	let &foldmarker	= b:save_other_foldmarker
	let &foldmethod	= b:save_other_foldmethod
endfunction



function! WinWalker_set_help_folding()
	set foldenable
	set foldopen=all
	set foldclose=all
	set foldmarker={{{,}}}
	set foldmethod=marker
endfunction



function! WinWalker_unset_help_folding()
	set foldenable!
	set foldopen=
	set foldclose=
	"set foldmarker={{{,}}}
	"set foldmethod=marker
endfunction



"function! WinWalker_help_extract_tmp_buf()
"
"	" Grrrr!  No local mode for these:
"	let s:restore_foldopen = &foldopen
"	let s:restore_foldclose = &foldclose
"
"	" Use new then edit, as a simple way to deal with an existing hidden 
"	" help buffer.
"	silent new
"	silent edit! _WinWalker Help_
"	silent setlocal modifiable
"	silent setlocal noreadonly
"	silent setlocal nofoldenable
"	" Refreshing each time is mostly useful for development, but doesn't hurt
"	" in general:
"	silent 1,$d
"	exe "silent read " . s:This_script_fname
"	silent 1,/^" Help Start:/ d
"	silent /^" Help End:/,$ d
"	silent 1,$ s/^"//
"
"	silent 1
"
"	silent setlocal nomodifiable
"	silent setlocal readonly
"	silent setlocal buftype=nofile
"	silent setlocal filetype=help
"	silent setlocal noswapfile
"	silent setlocal foldenable
"	silent set foldopen=hor,jump,mark,search
"	silent set foldclose=all
"	silent setlocal foldmarker={{{,}}}
"	silent setlocal foldmethod=marker
"	"silent setlocal foldtext=RH_foldtext1()
"	"silent setlocal syntax=rh
"endfunction 


" End Help functions                                                   }}}
" ----------------------------------------------------------------------



" ----------------------------------------------------------------------
" Jump funcs                                                        {{{
"

let s:Jump_list_idx = 0
let s:Jump_list = []
let s:Keep_jumps = 0


function! s:Jump_list_forward()
	if s:Jump_list_idx < len( s:Jump_list ) - 1
		let s:Jump_list_idx += 1
		"let s:Keep_jumps = 1
		let elem = {}
		let elem = s:Jump_list[s:Jump_list_idx]
		call s:Go_to_location( elem )
		"if s:Jump_list_idx == len( s:Jump_list ) - 1
			"let s:Keep_jumps = 0
		"endif

		if ! s:In_list( w:Jump_list_valid, s:Jump_list_idx  )
			call s:Jump_list_forward()
		endif

	else
		let s:infomsg .= ' At end of jump list'
	endif
endfunction


function! s:In_list( l, what )
	for elem in a:l
		if elem == a:what
			return 1
		endif
	endfor
	return 0
endfunction



function! s:Jump_list_backward()
	while s:Jump_list_idx > 0 && len ( s:Jump_list )
		let s:Jump_list_idx -= 1
		let elem = {}
		let elem = s:Jump_list[s:Jump_list_idx]
		call s:Go_to_location( elem )

		if !exists( 'w:Jump_list_valid' )
			let s:errmsg .= ' No valid valid list'
			return
		endif

		if s:In_list( w:Jump_list_valid, s:Jump_list_idx  )
			return
		else
			"let s:infomsg .= ' Clearing jump #' . s:Jump_list_idx . ', '
						"\ . 'valid=' . string( w:Jump_list_valid )
			call remove( s:Jump_list, s:Jump_list_idx )
		endif
	endwhile

	let s:infomsg .= ' At start of jump list'
endfunction




function! WinWalker_show_jump_list()
	echon "\n"
	echon "WinWalker jump list.\n"
	echon s:Pad( ' #', 5 ) 
				\ . ' ' .  s:Pad( 'Tab', 4 ) 
				\ . ' ' .  s:Pad( 'Win', 4 ) 
				\ . " Buf\n"
	let i = len( s:Jump_list ) - 1
	while i >= 0
		echon s:Pad( ( i == s:Jump_list_idx ? '>' : ' ' ) . i, 5 ) . "  "
					\ . s:Pad( s:Jump_list[i].tabnr, 4 ) . " "
					\ . s:Pad( s:Jump_list[i].winnr, 4 ) . " "
					\ . bufname(s:Jump_list[i].bufnr) . " "
		"if s:Jump_list[i].tabnr == tabpagenr()
			"echon string( getwinvar( 
							"\ s:Jump_list[i].winnr, 'Jump_list_valid' ) )
		"endif
		echon "\n"
		let i-= 1
	endwhile
	echon "Press any key: "
	call getchar()
	"call Clear_cmd_window()
endfunction



" Clean up the list.  Doesn't do a complete job yet.
"
function! s:Add_valid( l, i )
	let d = {}
	for elem in a:l
		"if elem <= a:i
		if elem <= len( s:Jump_list )
			let d[ elem ] = 1
		endif
	endfor
	let d[ a:i ] = 1
	return keys( d )
endfunction



" Jump funcs                                                        }}}
" ----------------------------------------------------------------------




" ----------------------------------------------------------------------
" Autocommand functions                                             {{{
"



aug WinWalker_aug
	au!
	au BufEnter * call WinWalker_BufEnter()
	au BufLeave * call WinWalker_BufLeave()
	au WinLeave * call WinWalker_WinLeave()
	" This interrupts getchar(), and then resets the event, and loops:
	"au CursorHold * match
aug end

function! WinWalker_BufEnter()

	if exists( 's:O_temp_win' ) | unlet s:O_temp_win | endif

	if s:Keep_jumps	| return | endif

	let elem =  {
				\ "tabnr" : tabpagenr(),
				\ "winnr" : winnr(),
				\ "bufnr" : bufnr("%"),
				\ "line" : 0,
				\ "col" : 0,
				\ }

	if !exists( 'w:Jump_list_valid' )
		let w:Jump_list_valid = []
	else
		"let s:infomsg .= ' ' . string( w:Jump_list_valid )
	endif

	if len( s:Jump_list ) < 1

		call add( s:Jump_list, elem )
		let s:Jump_list_idx = 0
		let w:Jump_list_valid = s:Add_valid( w:Jump_list_valid, s:Jump_list_idx )

	elseif s:Jump_list_idx < ( len( s:Jump_list ) - 1 )
		" Means that that we're somewhere in the jumplist via ^I or ^O

		if 				tabpagenr()	== s:Jump_list[ s:Jump_list_idx ].tabnr
				\ &&	winnr()		== s:Jump_list[ s:Jump_list_idx ].winnr
				"\ &&	bufnr("%")	== s:Jump_list[ s:Jump_list_idx ].bufnr
			" Haven't deviated from list.
			return
		else
			" Have deviated from list, so start it afresh from here.
			call remove( s:Jump_list, s:Jump_list_idx + 1, -1)
			call add( s:Jump_list, elem )
			let s:Jump_list_idx = max( [0, len( s:Jump_list ) - 1 ] )
			let w:Jump_list_valid = 
						\ s:Add_valid( w:Jump_list_valid, s:Jump_list_idx )
		endif

	elseif 				tabpagenr()	== s:Jump_list[ s:Jump_list_idx ].tabnr
				\ &&	winnr()		== s:Jump_list[ s:Jump_list_idx ].winnr
		" Don't add a duplate.
	else
		call add( s:Jump_list, elem )
		let s:Jump_list_idx = max( [0, len( s:Jump_list ) - 1 ] )
		let w:Jump_list_valid = s:Add_valid( w:Jump_list_valid, s:Jump_list_idx )
	endif


	if len( s:Jump_list ) > 1000
		call remove( s:Jump_list, 0 )
		let s:Jump_list_idx -= 1
	endif

endfunction




function! WinWalker_WinLeave()
	"echomsg ' winleave @%=' . @% . ', afile=' . expand("<afile>")
	call WinWalker_BufLeave()
endfunction




function! WinWalker_BufLeave()
	if exists( 's:O_temp_win' ) | unlet s:O_temp_win | endif

	if s:Keep_jumps	| return | endif

	" Don't know what to do about this yet, if anything:
	"let afile = expand("<afile>")
	"if afile != @%
		"let s:errmsg .= ' Warning, BufLeave, afile('.afile.')!=@%('. @% .')'
	"endif

	if !exists( 'w:Jump_list_valid' )
		let w:Jump_list_valid = []
	endif

	if len( s:Jump_list ) < 1
		let s:Jump_list_idx = 0
		let elem = {}
		let elem.tabnr = tabpagenr()
		let elem.winnr = winnr()
		let elem.bufnr = bufnr("%")
		call add( s:Jump_list, elem )
		let w:Jump_list_valid = s:Add_valid( w:Jump_list_valid, 0 )
	endif

	let elem = s:Jump_list[ s:Jump_list_idx ]

	if			elem.tabnr == tabpagenr()
		\ &&	elem.winnr == winnr()
		\ &&	elem.bufnr == bufnr("%")
		let elem.line = line(".")
		let elem.col = col(".")
	endif

endfunction


" Autocommand functions                                             }}}
" ----------------------------------------------------------------------



" vim7:ts=4:sw=4:foldenable:foldmarker={{{,}}}:foldmethod=marker:foldopen=hor,tag,jump,mark,search
