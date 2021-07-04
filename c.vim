" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
"               Jean-Marie Dormoy <dormoy.jeanmarie@gmail.com>
" Last Change:	2020 Sep 10
"---------------------------------------------
" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:ft = matchstr(&ft, '^\([^.]\)\+')

" A bunch of useful C keywords
syn keyword	cStatement	contained goto 
syn keyword	cStatement	return
syn keyword	cStatement	break continue asm
syn keyword	cLabel		contained case 
syn keyword	cLabel		default
syn keyword	cConditional	else
syn keyword	cConditional	if switch
syn keyword	cRepeat		while for
syn keyword	cRepeat		do

syn keyword	cTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredictable and should be avoided.
syn match	cBadContinuation contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	cCommentGroup	contains=cTodo,cBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match	cSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syn match	cSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif

"JMD try
"let b:c_no_cformat = 1
"let b:c_no_c99 = 1
let s:ft = "c"

if !exists("c_no_cformat")
  " Highlight % items in strings.
  if !exists("c_no_c99") " ISO C99
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syn match	cFormat		display "%%" contained
endif

"JMD added:

" cCppString: same as cString, but ends at end of line
if s:ft ==# "cpp" && !exists("cpp_no_cpp11") && !exists("c_no_cformat")
	" ISO C++11
	syn region	cString
		\ start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ 
		\ skip=+\\\\\|\\"+ end=+"+ 
		\ contains=cSpecial,cFormat,@Spell extend
      	syn region 	cCppString	
		\ start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ 
		\ skip=+\|\\\\\|\\"\|\\$+ excludenl end=+"+ end='$'
		\ contains=cSpecial,cFormat,@Spell

elseif s:ft ==# "c" && !exists("c_no_c11") && !exists("c_no_cformat")
	"ISO C99
	"This is THE configuration!
"		\ contains=ALLBUT,cMacroFunctionCall
	syn region	cString
		\ start=+\%(L\|U\|u8\)\="+ 
		\ skip=+\\\\\|\\"\|["]\s*M\s*["]+ 
		\ end=+"+ 
		\ contains=cFormat,@Spell extend
"		\ contains=ALLBUT,cMacroFunctionCall,cCast

      	"syn region	cCppString	start=+\%(L\|U\|u8\)\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell

	syn region 	cCppString 	
		\ start=+\%(L\|U\|u8\)\="+
		\ skip=+\\\\\|\\"\|\\+
		\ end=+"+ 
		\ contains=cFormat,@Spell extend
"		\ contains=ALLBUT,cCast,cMacroFunctionCall
  "don't contain cSpecial! don't skip \\$ .
  

else
  " older C or C++
  syn match	cFormat		display "%%" contained
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
endif

syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppSkip

syn cluster	cStringGroup	contains=cCppString,cCppSkip

syn match	cCharacter	"L\='[^\\]'"
syn match	cCharacter	"L'[^']*'" contains=cSpecial
if exists("c_gnu")
  syn match	cSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syn match	cSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syn match	cSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	cSpecialCharacter display "'\\x\x\{1,2}'"
syn match	cSpecialCharacter display "L'\\x\x\+'"

if (s:ft ==# "c" && !exists("c_no_c11")) || (s:ft ==# "cpp" && !exists("cpp_no_cpp11"))
  " ISO C11 or ISO C++ 11
  if exists("c_no_cformat")
    syn region	cString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,@Spell extend
  else
    syn region	cString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  endif
  syn match	cCharacter	"[Uu]'[^\\]'"
  syn match	cCharacter	"[Uu]'[^']*'" contains=cSpecial
  if exists("c_gnu")
    syn match	cSpecialError	"[Uu]'\\[^'\"?\\abefnrtv]'"
    syn match	cSpecialCharacter "[Uu]'\\['\"?\\abefnrtv]'"
  else
    syn match	cSpecialError	"[Uu]'\\[^'\"?\\abfnrtv]'"
    syn match	cSpecialCharacter "[Uu]'\\['\"?\\abfnrtv]'"
  endif
  syn match	cSpecialCharacter display "[Uu]'\\\o\{1,3}'"
  syn match	cSpecialCharacter display "[Uu]'\\x\x\+'"
endif

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syn match	cSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syn match	cSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syn match cCurlyError "}"
  syn region	cBlock		start="{" end="}" contains=ALLBUT,cBadBlock,cCurlyError,@cParenGroup,cErrInParen,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell fold
else
  syn region	cBlock		start="{" end="}" transparent fold
endif

" Catch errors caused by wrong parenthesis and brackets.
" Also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syn cluster	cParenGroup	contains=cParenError,cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserLabel,cBitField,cOctalZero,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom
if exists("c_no_curly_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "^^<%\|^%>"
  else
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "^[{}]\|^<%\|^%>"
  endif
elseif exists("c_no_bracket_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "<%\|%>"
  else
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "[{}]\|<%\|%>"
  endif
else
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
    syn match	cParenError	display "[\])]"
    syn match	cErrInParen	display contained "<%\|%>"
    syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@cParenGroup,cErrInParen,cCppParen,cCppBracket,@cStringGroup,@Spell
  else
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
    syn match	cParenError	display "[\])]"
    syn match	cErrInParen	display contained "[\]{}]\|<%\|%>"
    syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cErrInParen,cCppParen,cCppBracket,@cStringGroup,@Spell
  endif
  " cCppBracket: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@cParenGroup,cErrInParen,cParen,cBracket,cString,@Spell
  syn match	cErrInBracket	display contained "[);{}]\|<%\|%>"
endif

if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	cBadBlock	keepend start="{" end="}" contained containedin=cParen,cBracket,cBadBlock transparent fold
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	cNumbers	display transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctalError,cOctal
" Same, but without octal error (for comments)
syn match	cNumbersCom	display contained transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctal
"syn match	cNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"

"JMD cNumber
syn match	cNumber		display contained "\(\w\)\@<!\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	cNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	cOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=cOctalZero
syn match	cOctalZero	display contained "\<0"
syn match	cFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	cFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	cFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	cFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	cFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	cFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	cOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain cString, cCharacter and cNumber.
  " But a "*/" inside a cString in a cComment DOES end the comment!  So we
  " need to use a special type of cString: cCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syn match	cCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syn region cCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,cCommentSkip
  syn region cComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syn region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syn region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell extend
  else
    syn region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell fold extend
  endif
else
  syn region	cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell extend
  else
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syn match	cCommentError	display "\*/"
syn match	cCommentStartError display "/\*"me=e-1 contained

"modified JMD
syn keyword	cOperator	sizeof typeof offsetof contained 
	\ containedin=cSizeofCluster,cMacroFunctionCall,cSizeof

if exists("c_gnu")
  syn keyword	cStatement	__asm__
  syn keyword	cOperator	typeof __real__ __imag__
endif

"syn keyword	cType		int long short char void
"syn keyword	cType		signed unsigned float double

if !exists("c_no_ansi") || exists("c_ansi_typedefs")
  syn keyword   cType		size_t ssize_t off_t wchar_t ptrdiff_t sig_atomic_t fpos_t
  	\ contained
  syn keyword   cType		clock_t time_t va_list jmp_buf FILE DIR div_t ldiv_t
  	\ contained
  syn keyword   cType		mbstate_t wctrans_t wint_t wctype_t
  	\ contained
endif
if !exists("c_no_c99") " ISO C99
  syn keyword	cType		contained _Bool bool _Complex complex _Imaginary imaginary
  syn keyword	cType		contained int8_t int16_t int32_t int64_t
  syn keyword	cType		contained uint8_t uint16_t uint32_t uint64_t
  syn keyword	cType		contained int_least8_t int_least16_t int_least32_t int_least64_t
  syn keyword	cType		contained uint_least8_t uint_least16_t uint_least32_t uint_least64_t
  syn keyword	cType		contained int_fast8_t int_fast16_t int_fast32_t int_fast64_t
  syn keyword	cType		contained uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
  syn keyword	cType		contained intptr_t uintptr_t
  syn keyword	cType		contained intmax_t uintmax_t
endif
if exists("c_gnu")
  syn keyword	cType		__label__ __complex__ __volatile__
endif

"JMD keywords
syn keyword 	cType 		contained List ListNode dd map_type index_map
"syn keyword	cType		contained bierre individu t_individu t_cousin
"syn keyword	cType		contained directory internal info _node
"syn keyword	cType		contained anUnion anUnionBis stat

"syn clear	cType
"syn keyword 	cType 		List ListNode dd map_type index_map
"syn keyword	cType		bierre DArray individu t_individu

syn keyword	cStructure	contained struct union enum 
syn keyword	cStructure	contained typedef 
syn keyword	cStorageClass	contained static 
syn keyword	cStorageClass	contained register auto volatile extern const
if exists("c_gnu")
  "syn keyword	cStorageClass	inline __attribute__
endif
if !exists("c_no_c99") && s:ft !=# 'cpp'
	"Original
	"syn keyword	cStorageClass	inline restrict
  syn keyword	cppModifier 	contained inline restrict
endif
if !exists("c_no_c11")
  syn keyword	cStorageClass	_Alignas alignas
  syn keyword	cOperator	_Alignof alignof
  syn keyword	cStorageClass	_Atomic
  syn keyword	cOperator	_Generic
  syn keyword	cStorageClass	_Noreturn noreturn
  syn keyword	cOperator	_Static_assert static_assert
  syn keyword	cStorageClass	_Thread_local thread_local
  syn keyword   cType		char16_t char32_t
endif

if !exists("c_no_ansi") || exists("c_ansi_constants") || exists("c_gnu")
  if exists("c_gnu")
    syn keyword cConstant __GNUC__ __FUNCTION__ __PRETTY_FUNCTION__ __func__
  endif
  syn keyword cConstant __LINE__ __FILE__ __DATE__ __TIME__ __STDC__
  syn keyword cConstant __STDC_VERSION__
  syn keyword cConstant CHAR_BIT MB_LEN_MAX MB_CUR_MAX
  syn keyword cConstant UCHAR_MAX UINT_MAX ULONG_MAX USHRT_MAX
  syn keyword cConstant CHAR_MIN INT_MIN LONG_MIN SHRT_MIN
  syn keyword cConstant CHAR_MAX INT_MAX LONG_MAX SHRT_MAX
  syn keyword cConstant SCHAR_MIN SINT_MIN SLONG_MIN SSHRT_MIN
  syn keyword cConstant SCHAR_MAX SINT_MAX SLONG_MAX SSHRT_MAX
  if !exists("c_no_c99")
    syn keyword cConstant __func__
    syn keyword cConstant LLONG_MIN LLONG_MAX ULLONG_MAX
    syn keyword cConstant INT8_MIN INT16_MIN INT32_MIN INT64_MIN
    syn keyword cConstant INT8_MAX INT16_MAX INT32_MAX INT64_MAX
    syn keyword cConstant UINT8_MAX UINT16_MAX UINT32_MAX UINT64_MAX
    syn keyword cConstant INT_LEAST8_MIN INT_LEAST16_MIN INT_LEAST32_MIN INT_LEAST64_MIN
    syn keyword cConstant INT_LEAST8_MAX INT_LEAST16_MAX INT_LEAST32_MAX INT_LEAST64_MAX
    syn keyword cConstant UINT_LEAST8_MAX UINT_LEAST16_MAX UINT_LEAST32_MAX UINT_LEAST64_MAX
    syn keyword cConstant INT_FAST8_MIN INT_FAST16_MIN INT_FAST32_MIN INT_FAST64_MIN
    syn keyword cConstant INT_FAST8_MAX INT_FAST16_MAX INT_FAST32_MAX INT_FAST64_MAX
    syn keyword cConstant UINT_FAST8_MAX UINT_FAST16_MAX UINT_FAST32_MAX UINT_FAST64_MAX
    syn keyword cConstant INTPTR_MIN INTPTR_MAX UINTPTR_MAX
    syn keyword cConstant INTMAX_MIN INTMAX_MAX UINTMAX_MAX
    syn keyword cConstant PTRDIFF_MIN PTRDIFF_MAX SIG_ATOMIC_MIN SIG_ATOMIC_MAX
    syn keyword cConstant SIZE_MAX WCHAR_MIN WCHAR_MAX WINT_MIN WINT_MAX
  endif
  syn keyword cConstant FLT_RADIX FLT_ROUNDS
  syn keyword cConstant FLT_DIG FLT_MANT_DIG FLT_EPSILON
  syn keyword cConstant DBL_DIG DBL_MANT_DIG DBL_EPSILON
  syn keyword cConstant LDBL_DIG LDBL_MANT_DIG LDBL_EPSILON
  syn keyword cConstant FLT_MIN FLT_MAX FLT_MIN_EXP FLT_MAX_EXP
  syn keyword cConstant FLT_MIN_10_EXP FLT_MAX_10_EXP
  syn keyword cConstant DBL_MIN DBL_MAX DBL_MIN_EXP DBL_MAX_EXP
  syn keyword cConstant DBL_MIN_10_EXP DBL_MAX_10_EXP
  syn keyword cConstant LDBL_MIN LDBL_MAX LDBL_MIN_EXP LDBL_MAX_EXP
  syn keyword cConstant LDBL_MIN_10_EXP LDBL_MAX_10_EXP
  syn keyword cConstant HUGE_VAL CLOCKS_PER_SEC NULL
  syn keyword cConstant LC_ALL LC_COLLATE LC_CTYPE LC_MONETARY
  syn keyword cConstant LC_NUMERIC LC_TIME
  syn keyword cConstant SIG_DFL SIG_ERR SIG_IGN
  syn keyword cConstant SIGABRT SIGFPE SIGILL SIGHUP SIGINT SIGSEGV SIGTERM
  " Add POSIX signals as well...
  syn keyword cConstant SIGABRT SIGALRM SIGCHLD SIGCONT SIGFPE SIGHUP
  syn keyword cConstant SIGILL SIGINT SIGKILL SIGPIPE SIGQUIT SIGSEGV
  syn keyword cConstant SIGSTOP SIGTERM SIGTRAP SIGTSTP SIGTTIN SIGTTOU
  syn keyword cConstant SIGUSR1 SIGUSR2
  syn keyword cConstant _IOFBF _IOLBF _IONBF BUFSIZ EOF WEOF
  syn keyword cConstant FOPEN_MAX FILENAME_MAX L_tmpnam
  syn keyword cConstant SEEK_CUR SEEK_END SEEK_SET
  syn keyword cConstant TMP_MAX stderr stdin stdout
  syn keyword cConstant EXIT_FAILURE EXIT_SUCCESS RAND_MAX
  " POSIX 2001
  syn keyword cConstant SIGBUS SIGPOLL SIGPROF SIGSYS SIGURG
  syn keyword cConstant SIGVTALRM SIGXCPU SIGXFSZ
  " non-POSIX signals
  syn keyword cConstant SIGWINCH SIGINFO
  " Add POSIX errors as well
  syn keyword cConstant E2BIG EACCES EAGAIN EBADF EBADMSG EBUSY
  syn keyword cConstant ECANCELED ECHILD EDEADLK EDOM EEXIST EFAULT
  syn keyword cConstant EFBIG EILSEQ EINPROGRESS EINTR EINVAL EIO EISDIR
  syn keyword cConstant EMFILE EMLINK EMSGSIZE ENAMETOOLONG ENFILE ENODEV
  syn keyword cConstant ENOENT ENOEXEC ENOLCK ENOMEM ENOSPC ENOSYS
  syn keyword cConstant ENOTDIR ENOTEMPTY ENOTSUP ENOTTY ENXIO EPERM
  syn keyword cConstant EPIPE ERANGE EROFS ESPIPE ESRCH ETIMEDOUT EXDEV
  " math.h
  syn keyword cConstant M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4
  syn keyword cConstant M_1_PI M_2_PI M_2_SQRTPI M_SQRT2 M_SQRT1_2
endif
if !exists("c_no_c99") " ISO C99
  syn keyword cConstant true false
endif

" Accept %: for # (C99)
syn region	cPreCondit	start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" keepend contains=cComment,cCommentL,cCppString,cCharacter,cCppParen,cParenError,cNumbers,cCommentError,cSpaceError
syn match	cPreConditMatch	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  syn cluster	cCppOutInGroup	contains=cCppInIf,cCppInElse,cCppInElse2,cCppOutIf,cCppOutIf2,cCppOutElse,cCppInSkip,cCppOutSkip
  syn region	cCppOutWrapper	start="^\s*\(%:\|#\)\s*if\s\+0\+\s*\($\|//\|/\*\|&\)" end=".\@=\|$" contains=cCppOutIf,cCppOutElse,@NoSpell fold
  syn region	cCppOutIf	contained start="0\+" matchgroup=cCppOutWrapper end="^\s*\(%:\|#\)\s*endif\>" contains=cCppOutIf2,cCppOutElse
  if !exists("c_no_if0_fold")
    syn region	cCppOutIf2	contained matchgroup=cCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell fold
  else
    syn region	cCppOutIf2	contained matchgroup=cCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell
  endif
  syn region	cCppOutElse	contained matchgroup=cCppOutWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=TOP,cPreCondit
  syn region	cCppInWrapper	start="^\s*\(%:\|#\)\s*if\s\+0*[1-9]\d*\s*\($\|//\|/\*\||\)" end=".\@=\|$" contains=cCppInIf,cCppInElse fold
  syn region	cCppInIf	contained matchgroup=cCppInWrapper start="\d\+" end="^\s*\(%:\|#\)\s*endif\>" contains=TOP,cPreCondit
  if !exists("c_no_if0_fold")
    syn region	cCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=cCppInIf contains=cCppInElse2 fold
  else
    syn region	cCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=cCppInIf contains=cCppInElse2
  endif
  syn region	cCppInElse2	contained matchgroup=cCppInWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)\([^/]\|/[^/*]\)*" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell
  syn region	cCppOutSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppOutSkip
  syn region	cCppInSkip	contained matchgroup=cCppInWrapper start="^\s*\(%:\|#\)\s*\(if\s\+\(\d\+\s*\($\|//\|/\*\||\|&\)\)\@!\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" containedin=cCppOutElse,cCppInIf,cCppInSkip contains=TOP,cPreProc
endif

syn match cIncludedLib /[^<>"]\+/ display contained containedin=cIncluded
syn region	cIncluded	display contained 
	\ start=+"+ skip=+\\\\\|\\"+ end=+"+me=e+1 contains=cIncludedDelimiters
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]"
	\ contains=cIncluded

"syn match cLineSkip	"\\$"
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cErrInParen,cErrInBracket,cUserLabel,cSpecial,cOctalZero,cCppOutWrapper,cCppInWrapper,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cString,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cParen,cBracket,cMulti,cBadBlock
"JM MODIFIED THIS
syn region	cDefine		start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
syn region	cPreProc	start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell

" Highlight User Labels
syn cluster	cMultiGroup	contains=cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOutWrapper,cCppInWrapper,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cCppParen,cCppBracket,cCppString
if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	cMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@cMultiGroup,@Spell,@cStringGroup
endif
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	cLabelGroup	contains=cUserLabel
syn match	cUserCont	display "^\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:$" contains=@cLabelGroup
if s:ft ==# 'cpp'
  syn match	cUserCont	display "^\s*\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
  syn match	cUserCont	display ";\s*\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
else
  syn match	cUserCont	display "^\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
  syn match	cUserCont	display ";\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
endif

syn match	cUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	cBitField	display "^\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType
syn match	cBitField	display ";\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cFormat		cSpecial
hi def link cCppString		cString
hi def link cCommentL		cComment
hi def link cCommentStart	cComment
hi def link cLabel		Label
hi def link cUserLabel		Label
hi def link cConditional	Conditional
hi def link cRepeat		Repeat
hi def link cCharacter		Character
hi def link cSpecialCharacter	cSpecial
hi def link cNumber		Number
hi def link cOctal		Number
hi def link cOctalZero		PreProc	 " link this to Error if you want
hi def link cFloat		Float
hi def link cOctalError		cError
hi def link cParenError		cError
hi def link cErrInParen		cError
hi def link cErrInBracket	cError
hi def link cCommentError	cError
hi def link cCommentStartError	cError
hi def link cSpaceError		cError
hi def link cSpecialError	cErrorpper
hi def link cCppOutWrapper	cPreCondit
hi def link cPreConditMatch	cPreCondit
hi def link cPreCondit		PreCondit
hi def link cType		Type
hi def link cConstant		Constant
hi def link cCommentString	cString
hi def link cComment2String	cString
hi def link cCommentSkip	cComment
hi def link cString		String
hi def link cComment		Comment
hi def link cSpecial		SpecialChar
hi def link cTodo		Todo
hi def link cBadContinuation	Error
hi def link cCppOutSkip		cCppOutIf2
hi def link cCppInElse2		cCppOutIf2
hi def link cCppOutIf2		cCppOut
hi def link cCppOut		Comment

let b:current_syntax = "c"

unlet s:ft

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: ts=8


"syn match cFunction "\<[a-zA-Z_][a-zA-Z_0-9]*\>[^()]*)("me=e-2
"\<\*\>
"[^\*]\*
"--->Good \v(.*\*.*)@<!\* for 1st asterisk hl only
syn match cFuncAster "\*" contained containedin=cFunction,cVarDeclar
syn match opParen "("
syn match cloParen ")"
syn match opBracket "{"
syn match cloBracket "}"
syn match comma ","
syn match column ":"
syn match semicolon ";"
syn match cFuncArgsArray "[][]"
syn match cVaArg "\.\.\."

"syn match cFuncArgs "\>\s\+\**\<\w\+\>\(,\|)\|\s\)\(\s*(\)\@!"me=e-1 

let cFuncArgs = "/"
	\ . "\\>\\s\\+\\**"
	\ . "\\w\\+\\_s*"
	\ . "[][]*\\_s*"
	\ . "\\(,\\|)\\)"
	\ . "\\("
		\ . "\\s*("
	\ . "\\)\\@!"
	\ . "/me=e-1 "
	\ . "contained containedin=cFunctionPointerArgs,cFunction,cAllVars "
	\ . "contains=cFuncAster,cFuncArgsArray"
exec 'syn match cFuncArgs' cFuncArgs

let cFuncArgsType = "/"
	\ . "[(,]" 
	\ . "\\_s*"
	\ . "\\("
		\ . "[[:alnum:]_]\\+"
		\ . "[*[:alnum:]_ ]*"
		\ . "\\("
			\ . "\\("
			\ . "\\<\\w\\+\\>"
			\ . "\\)*"
		\ . "\\)\\@="
	\ . "\\|"
		\ . "\\.\\.\\."
	\ . "\\)\\?"
	\ . "/ contained containedin=cFunctionPointer "
	\ . "contains=cStorageClass,cStructure,comma,cVaArg,"
	\ . "cFuncArgs,cFuncAster,opParen,cloParen,cppModifier"
exec 'syn match cFuncArgsType' cFuncArgsType


let cFunctionPointer = "/"
	\ . "\\(return\\)\\@!"
	\ . "\\("
		\ . "[[:alnum:]_]\\+\\s\\+"
	\ . "\\)\\+"
	\ . "\\s*\\**"
	\ . "(\\s*\\**\\s*"
	\ . "\\w\\+"
	\ . "\\s*)\\s*"
	\ . "("
	\ . "/ "

"	\ skip=+(+ keepend


let cFunctionPointer = "/"
	\ . "\\(return\\)\\@<!"
	\ . "\\("
		\ . "[[:alnum:]_]\\+\\s\\+"
	\ . "\\)\\+"
	\ . "\\s*\\**"
	\ . "(\\s*\\**\\s*"
	\ . "\\w\\+"
	\ . "\\s*)"
	\ . "/me=e-1 "
exec 'syn match cFunctionPointer' cFunctionPointer
	\ 'nextgroup=cFunctionPointerArgs'
	\ 'contains=cFuncAster,mycType,'
	\ 'mycTypeFunctionPointer'

let cFunctionPointerArgs = "/"
	\ . "\\("
		\ . ")"
	\ . "\\)\\@<="
	\ . "("
	\ . "/"
exec 'syn region cFunctionPointerArgs start=' cFunctionPointerArgs
	\ 'end=+[{;=]+me=e-1 skip=+(+ '
	\ 'contains=cFuncArgs,cppModifier,cStorageClass,cFuncAster,
	\ opParen,cloParen,comma,cFunctionPointerName'

let cFuncReturnFuncArgs = "/"
	\ . "\\("
		\ . "[[:alnum:]_]\\+"
		\ . "\\s\\+\\**"
		\ . "[(* ]\\+"
		\ . "\\w\\+"
		\ . "\\s*"
	\ . "\\)\\@<="
	\ . "("
	\ . "/"
exec 'syn region cFuncReturnFuncArgs start=' cFuncReturnFuncArgs
	\ 'end=+[{;=]+me=e-1 skip=+(+ '
	\ 'contains=cFuncArgs,cppModifier,cStorageClass,cFuncAster,
	\ opParen,cloParen,comma,cFunctionPointerName'

let cFuncReturnFunc = "/"
	\ . "\\(return\\)\\@<!"
	\ . "[[:alnum:]_]\\+"
	\ . "\\s\\+\\**"
	\ . "[(* ]\\+"
	\ . "\\w\\+"
	\ . "\\s*"
	\ . "[)(]"
	\ . "/me=e-1"
exec 'syn match cFuncReturnFunc' cFuncReturnFunc
	\ 'nextgroup=cFunctionPointerArgs'
	\ 'contains=cFuncAster,mycTypeFunctionPointer,opParen'
"	\ contains=ALLBUT,cVarDeclar'
"	\ contains=cFuncArgsType,cFuncArgs,cFuncAster,cloParen,cVarDeclar,cType,cSizeof,
"	\ cStorageClass,cppModifier,cStructure,cMacroFunctionCallBis,mycTypeFunction'

let cFunctionPointerName = "/"
	\ . "("
	\ . "\\*\\+"
	\ . "\\w*"
	\ . "[][]*"
	\ . "\\s*"
	\ . "[)(]"
	\ . "/ "
exec 'syn match cFunctionPointerName' cFunctionPointerName
	\ 'contained containedin=cFunctionPointerArgs,cFuncReturnFuncArgs '
	\ 'contains=cFuncAster,opParen,cloParen'

let cFunction = "/"
	\ . "\\("
		\ . "^#define.*"
	\ . "\\)\\@<!"
	\ . "\\("
		\ . "[[:alnum:]_-]\\+"
	\ . "\\)\\@<="
	\ . "\\("
		\ . "return"
	\ . "\\|"
		\ . "else"
	\ . "\\|"
		\ . "const"
	\ . "\\)\\@<!"
	\ . "\\s\\+"
	\ . "\\**"
	\ . "[[:alnum:]:_-]\\+"
	\ . "("
	\ . "/ "

"exec 'syn match cFunction' cFunction
"	\ 'nextgroup=cFunctionPointerArgs'
"	\ ''
exec 'syn region cFunction start=' cFunction
	\ 'end=+[{;]+me=e-1 keepend '
	\ 'contains=opParen,cloParen,comma,semicolon,mycType,cFunctionPointer,
	\ cFunctionPointerArgs,cFuncArgs,cFuncArgsType,cCommentL,cComment'


"		\ . "\\("
"			\ . "("
"		\ . "\\|"
"			\ . "\\s\\+="
"		\ . "\\)\\@!"
let mycTypeFunctionPointer = "/"
		\ . "^\\s*"
		\ . "\\(goto\\|return\\)\\@!"
		\ . "\\("
			\ . "[[:alnum:]_*]\\+\\s\\+"
		\ . "\\)\\+"
		\ . "\\("
			\ . "\\**[(* ]\\+"
			\ . "[[:alnum:]_-]\\+[)(]"
		\ . "\\)\\@="
	\ . "/ "
exec 'syn match mycTypeFunctionPointer' mycTypeFunctionPointer
	\ . 'contained containedin=cFunctionPointer '
	\ . 'contains=cStructure,cStorageClass,cppModifier'

let mycType = "/"
		\ . "\\(^\\|;\\)"
		\ . "\\s*"
		\ . "\\(typedef\\)\\@!"
		\ . "\\(for\\s*(\\s*\\)*"
		\ . "\\("
			\ . "[[:alnum:]_*]\\+\\s\\+"
		\ . "\\)\\+"
		\ . "\\s*\\**"
		\ . "\\("
			\ . "[[:alnum:]_-]\\+"
		\ . "\\)\\@="
		\ . "\\("
			\ . "("
		\ . "\\|"
			\ . "\\s\\+="
		\ . "\\)\\@!"
	\ . "/ "
let mycType = "/"
		\ . "\\(^\\|;\\)"
		\ . "\\s*"
		\ . "\\(typedef\\)\\@!"
		\ . "\\(for\\s*(\\s*\\)*"
		\ . "[[:alnum:]_* ]\\+"
		\ . "\\s\\+"
		\ . "\\("
			\ . "\\**[[:alnum:]_-]\\+"
		\ . "\\)\\@="
		\ . "\\("
			\ . "("
		\ . "\\|"
			\ . "\\s\\+="
		\ . "\\|"
			\ . "[-]\\s\\+[[:alnum:]_-]"
		\ . "\\)\\@!"
	\ . "/ "
exec 'syn match mycType' mycType
	\ 'contains=cFuncAster,cStatement,mycLabel,mycGotoCall,
	\ cRepeat,opParen,cStructure,cFunction,cFuncArgs,cVarDeclar,semicolon,cConditional,
	\ cStorageClass,cppModifier'

"		\ . "\\("
"			\ . "\\("
"				\ . "[a-zA-Z_]\\{0,3}"
"			\ . "\\|"
"				\ . "[^e][a-zA-Z_]\\{3}"
"			\ . "\\|"
"				\ . "e[^l][a-zA-Z_]\\{2}"
"			\ . "\\|"
"				\ . "el[^s][a-zA-Z_]\\{1}"
"			\ . "\\|"
"				\ . "els[^e]"
"			\ . "\\|"
"				\ . "[a-zA-Z_]\\{5,}"
"			\ . "\\)"
"		\ . "\\)\\+"

let cVarDeclar = "/"
	\ . "\\("
		\ . "[[:alnum:]_]\\+"
	\ . "\\)\\@<="
	\ . "\\("
		\ . "\\s\\+\\**"
		\ . "[[:alnum:]_]\\+"
		\ . "\\("
			\ . "\\["
			\ . "\\<[[:alnum:]_]\\+\\>"
			\ . "\\]"
		\ . "\\)*"
		\ . "\\("
			\ . "[,;]"
		\ . "\\|"
			\ . "\\s*="
		\ . "\\)\\@="
	\ . "\\)\\+"
	\ . "/"

"let cVarDeclar = "/"
"	\ . "\\("
"		\ . "[[:alnum:]_]\\+"
"	\ . "\\)\\@<="
"	\ . "\\s\\+\\**"
"	\ . "[[:alnum:]_ *]\\+"
"	\ . "[^(]"
"	\ . "/ "
"exec 'syn match cVarDeclar' cVarDeclar
"	\ . 'contains=cFunction,mycType'
let cVarDeclarEnd = "/"
	\ . "\\("
		\ . ";"
	\ . "\\|"
		\ . "\\([[:alnum:]_]\\)\\@<=\\n"
	\ . "\\)"
	\ . "/me=e-1"

exec 'syn region cVarDeclar start=' cVarDeclar
	\ 'end=' cVarDeclarEnd
	\ 'contains=cFunction,cMacroFunctionCall,cSizeOf,cFuncArgsArray,
	\ cUpperCaseMacro,cCast,opBracket,cloBracket,comma,cNumber,mycOperator,
	\ opParen,cloParen,myArrowOperator,cppBoolean,cCppString'


syn match mycLabel "^[a-z][a-z_]*:" contains=column
syn match mycLabel "case\s[0-9]\+:" contains=column,cNumber

"	\ . "\\([A-Z]\\)\\@<!"
	"\ start="\(define\)\@<=\s\+[a-zA-Z_][a-zA-Z_0-9]*(" 
"	\ . "\\("
"		\ . "[[:alnum:]_]\\+"
"	\ . "\\)*"
"let mycDefine = " /"
"	\ . "^\\s*"
"	\ . "\\(%:\\|#\\)"
"	\ . "\\s*"
"	\ . "\\<\\(define\\|undef\\)\\>"
"	\ . "\\s\\+" 
"	\ . "/ "
let cAllVars = "/"
	\ . "\\("
		\ . "\\("
			\ . "define"
			\ . "\\s\\+" 
		\ . "\\)\\?"
	\ . "\\)\\@<="
	\ . "\\("
		\ . "[[:alnum:] *]\\+"
		\ . "(\\*\\+[a-zA-Z_]*"
	\ . "\\)\\{0}"
	\ . "\\("
		\ . "#[a-zA-Z_]*"
	\ . "\\|"
		\ . "^"
	\ . "\\)\\@<!"
	\ . "[a-zA-Z_]"
	\ . "[[:alnum:]_]*"
	\ . "/"
exec 'syn match cAllVars' cAllVars
	\ 'contains=mycType,mycLabel,cmacroName,mycDefine,
	\ cFunction,cFunctionPointer,cFunctionPointerArgs,
	\ cOperator'


"exec 'syn match cVarDeclar' cVarDeclar 
"	\ 'contains=cFuncAster,cStorageClass,cStatement,
"	\ mycGotoCall,cConstant,
"	\ cStructure,cType,mycType,comma,mycGotoCall,mycOperator,semicolon'

"	\ . "[^[:alnum:]_ =,{})!:&|*/+-;]*\\s*(\\?"
let cMacroFunctionCall = "/"
	\ . "(\\?"
	\ . "\\("
		\ . "\\("
			\ . "[[:alnum:]_]\\+"
		\ . "\\)\\+"
		\ . "\\s*\\**"
	\ . "\\)\\@<!"
	\ . "\\("
		\ . "\\w\\+"
	\ . "\\)"
	\ . "(\\_s*"
	\ . "[^%]"
	\ . "/me=e-1 "
exec 'syn match cMacroFunctionCall' cMacroFunctionCall
	\ 'contains=opParen,cConditional,cRepeat,cCast,cStatement
	\ '

let cMacroElseFunctionCall = "/"
	\ . "\\("
		\ . "else\\s\\+"
	\ . "\\)\\@<="
	\ . "\\("
		\ . "\\w\\+"
	\ . "\\)"
	\ . "(\\_s*"
	\ . "[^%]"
	\ . "/me=e-1 "
exec 'syn match cMacroElseFunctionCall' cMacroElseFunctionCall
	\ 'contains=opParen,cConditional,cRepeat,cCast,cStatement
	\ '
let cUpperCaseMacro = "/"
	\ . "\\([a-z]\\)\\@<!"
	\ . "[A-Z0-9_]\\{2,}"
	\ . "\\("
		\ . "[_A-Z0-9a-z:]\\+"
	\ . "\\)\\@!"
	\ . "/ "
exec 'syn match cUpperCaseMacro' cUpperCaseMacro 
	\ 'contains=cFuncArgsArray,cConstant,semicolon,
	\ cMacroFunctionCall,cNumber'

let cMacroFunctionCallSimpleMacro = "/"
	\ . "\\("
		\ . "^#define\\s\\+[A-Z0-9_]\\{2,}\\s\\+"
	\ . "\\)\\@<="
	\ . "(\\?"
	\ . "[[:alnum:]_]\\+"
	\ . "(\\_s*"
	\ . "[^%]"
	\ . "/me=e-1 "
exec 'syn match cMacroFunctionCallSimpleMacro' cMacroFunctionCallSimpleMacro
	\ 'contains=opParen'

let cMacroFunctionCallBis = "/"
	\ . "\\("
		\ . "return\\s\\+"
	\ . "\\)\\@<="
	\ . "[[:alnum:]_]\\+"
	\ . "("
	\ . "/ "
exec 'syn match cMacroFunctionCallBis' cMacroFunctionCallBis
	\ . "contains=opParen,cCast"

let cStructOrUnionStart = "/"
	\ . "\\w*"
	\ . "\\s*"
	\ . "\\("
		\ . "struct"
	\ . "\\|"
		\ . "union"
	\ . "\\)"
	\ . "\\_s*\\w*\\_s*{"
	\ . "/ "
exec 'syn match cStructOrUnionStart' cStructOrUnionStart 
	\ 'contains=cStructure,cType,opBracket'

syn match cStructOrUnionEnd "}\s\+[a-zA-Z_][[:alnum:]_]*\s*;" 
	\ contains=cloBracket

syn match cSimpleTypeDef "^typedef\s\+[a-zA-Z0-9_ *-]\+;"me=e-1
	\ contains=cStructure,cFuncAster

"syn region cTypeDefStruct start="typedef\s\+struct\s*\w*\s*{"
"	\ contains=cStructure,cVarDeclar,cType
"	\ end="}\s\+[a-z_][[:alnum:]_]*\s*;"

"syn match cStructDef "struct\_s*[a-z_]\?[[:alnum:]_]*\s*{"
"	\ contains=cStructure,cType

syn cluster cSizeofCluster 
	\ contains=cType,opParen,cFuncAster,cOperator,
	\ cStructure,cFunctionPointer,cloParen,cMacroFunctionCall
syn region cSizeof 
	\ start=/sizeof(/
	\ end=/)/ keepend
	\ contains=@cSizeofCluster

"exec 'syn region cCast start=' cCast
"	\ ' contains=cStructure,cSizeof,cMacroFunctionCall,
"	\ cFuncAster,opParen,cloParen,comma,cStatement,cString,
"	\ cCppString,cUpperCaseMacro,mycOperator,cNumber,cFuncArgsArray,
"	\ cCharacter, myArrowOperator,cFunctionPointer
"	\ keepend
"	\ end=")"'
"	\ 'contains=ALL

let cCast = "/"
	\ . "\\("
		\ . "\\("
			\ . "\\w\\+"
		\ . "\\)\\@<!"
		\ . "[^a-zA-Z]"
	\ . "\\|"
		\ . "sizeof"
	\ . "\\|"
		\ . "("
	\ . "\\)"
	\ . "\\s*"
	\ . "("
	\ . "\\("
		\ . "[^*]"
		\ . "[[:alnum:]_ *-]*"
	\ . "\\)"
	\ . ")"
	\ . "\\("
		\ . "->"
	\ . "\\|"
		\ . "\\."
	\ . "\\|"
		\ . ")"
	\ . "\\|"
		\ . ","
	\ . "\\|"
		\ . ";"
	\ . "\\)\\@!"
	\ . "/ "

"		\ . "\\s*[<>+/!=^-]"
exec 'syn match cCast' cCast
	\ 'contains=cStructure,cSizeof,cFuncAster,opParen,cloParen'

syn match cFuncMacArgs "" contained containedin=cmacroName contains=cCppString

let cmacroArgComma = "/" 
		\ . "^\\s*"
		\. "\\("
			\ . "%:"
		\ . "\\|"
			\ . "#"
		\ . "\\)"
		\ . "\\s*\\<"
		\. "\\("
			\ . "define"
		\ . "\\|"
			\ . "undef"
		\ . "\\)"
		\ . "\\>\\s\\+"
		\ . "\\<[a-zA-Z_][[:alnum:]_]*\\>("
		\ . "\\("
			\ . "\\("
				\ . "\\s*"
				\ . "\\<\\w\\+\\>"
				\ . "\\s*,\\?"
			\ . "\\|"
				\ . "\\s*"
				\ . "\\.\\.\\."
				\ . "\\s*,\\?"
			\ . "\\)"
		\ ."\\)*"
	\ . "[,]"
	\ . "/ contained containedin=cmacroArg"
"exec 'syn match cmacroArgComma' cmacroArgComma

let cmacroArg ="/"
	\ . "\\("
		\ ."^\\s*"
		\ . "\\(%:\\|#\\)\\s*"
		\ . "\\<\\(define\\|undef\\)\\>\\s\\+"
		\ . "\\<[a-zA-Z_][[:alnum:]_]*\\>"
	\ . "\\)\\@<="
	\ . "\\("
		\ . "[(,]\\s*"
		\ . "\\("
			\ . "\\<\\w\\+\\>"
		\ . "\\|"
			\ . "\\.\\+"
		\ . "\\)"
	\ . "\\)*"
	\ . "/hs=s+1 containedin=cmacroName contained contains=comma,opParen"
exec 'syn match cmacroArg' cmacroArg


syn match cWhiteBackslash "\\" contained containedin=cMacroUniqueFunc
syn region cmacroName 
	\ start="\(define\s\+\)\@<=[a-zA-Z_][a-zA-Z_0-9]*(" 
	\ matchgroup=cloParen end=")" skip=+(+ 
	\ contained containedin=mycDefine 
	\ contains=cmacroArg nextgroup=mycType 
	\ keepend

exec 'syn match cmacroNameNoArg' cUpperCaseMacro
	\ 'contained containedin=mycDefine '
	\ 'contains=cMacroFunctionCall'

let cMacroUniqueFunc = "/" 
	\ . "\\>"	
		\ . "\\s\\+"
		\ . "[[:alnum:]_]\\+"
		\ . "\\("
			\ . "[(,]\\s*"
			\ . "\\("
				\ . "\\<\\w\\+\\>"
			\ . "\\|"
				\ . "\\.\\.\\."
			\ . "\\)*"
		\ . "\\)*"
		\ . ")"
		\ . "[[:space:][:tab:]]*"
		\ . "\\("
			\ . "\\\\\\s*$\\n"
		\ . "\\)*"
		\ . "[[:space:]]*"
	\ . "[[:alnum:]_]\\+"
	\ . "\\("
		\ . "if"
	\ . "\\|"
		\ . "while"
	\ . "\\)\\@<!"
	\ . "("
	\ . "[^$;]\\+"
	\ . ")"
	\ . "\\("
		\ . ";[ ]*[\\\\]"
	\ . "\\)\\@!"
	\ . "/ "
"exec 'syn match cMacroUniqueFunc' cMacroUniqueFunc 
"	\ 'contains=comma,opParen,cloParen,cmacroName,cCppString,cConstant'
"	\ 'contains=ALLBUT,cMacroFunctionCall'

"syn match cMacroVar "(A)" 
"	\ contains=opParen,cloParen contained 
"	\ containedin=cMacroUniqueFunc

let aTest = "/"
	\ . "#test"
	\ . "/"
"	\ . "\\("
"		\ . ");[ ]*[\\\\]"
"	\ . "\\)\\@!"
"exec 'syn match aTest' aTest
"	\ 'end=+)\(;\)\@!$+'
"	\ 'contains=cloParen,cConditional,cRepeat,'
"	\ 'cCast,cmacroName,cWhiteBackslash'

let mycDefine = " /"
	\ . "^\\s*"
	\ . "\\(%:\\|#\\)"
	\ . "\\s*"
	\ . "\\<\\(define\\|undef\\)\\>"
	\ . "\\s\\+" 
	\ . "/ "
exec 'syn match mycDefine' mycDefine 
	\ 'nextgroup=cmacroName,cmacroNameNoArg ' 
	\ 'contains=ALLBUT,cMacroFunctionCall'
"	\ 'contains=cMacroUniqueFunc'


"let mycInclude = "/"
"	\ . "[[:alnum:]<>_.]\\+"
"	\ . "/"
 "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
"syn region mycInclude
"	\ start="^\s*\(%:\|#\)\s*include\>\s*["<]"
"	\ end="[">]"
"	\ contains=cInclude

let cmacroCallX = " /"
	\ . "\\("
		\ . "^\\s*"
		\ . "\\(%:\\|#\\)"
		\ . "\\s*"
		\ . "\\<\\(define\\|undef\\)\>"
		\ . "\\s\\+"
	\ . "\\)\\@<!"
	\ . "\\<[A-Z_]\\+\\>("
	\ . "/me=e-1"
"exec 'syn match cmacroCall' cmacroCallX

"
"------------------------------------"
"	Personal Operators	     "
"------------------------------------"

exec 'syn match mycOperator'	" / "
	\ . "\\("
		\ . "<<"
		\ . "\\|>>"
		\ . "\\|[-+*/%&^|<>!=]"
	\ . "\\)=" 
	\ . "/"
syn match mycOperator	"<<\|>>\|&&\|||"
syn match mycOperator	"\(+\+\)\@<!++\(+\+\)\@!"
syn match mycOperator	"\(-\+\)\@<!--\(-\+\)\@!"
syn match mycOperator	"[.!~&<^|=?+*:]"
syn match mycOperator	"\(-\)\@<!>"
syn match mycOperator   "\s*-\s*\([[:alnum:].(]\)\@="

syn match mycOperator	"/[^/*=]"me=e-1
"syn match mycOperator	"/$"
syn match mycOperator	"%"

syn match mycGotoCall "\(goto\)\@<=\s\+\w\+"  
syn match myArrowOperator "->"


"-------------------------------------------------------"	
"			GARBAGE				"
"-------------------------------------------------------"	
