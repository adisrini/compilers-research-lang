type svalue = Tokens.svalue
type pos = int
type ('a, 'b) token = ('a, 'b) Tokens.token
type lexresult = (svalue, pos) Tokens.token

exception NumberFormatException

val lineNum = ErrorMsg.lineNum
val linePos = ErrorMsg.linePos
fun err(p1,p2) = ErrorMsg.error p1

val netCommentBalance     = ref 0
val stringLiteralClosed   = ref true
val buffer                = ref ""
val stringStartPosition   = ref 0

fun asciiCode str = let val num = valOf (Int.fromString str) in
  Char.toString (Char.chr num) end

fun convertControlCharacter char = let val num = (Char.ord (List.nth(String.explode char, 0))) - 64 in
  asciiCode (Int.toString num) end

fun count f x = foldr (fn (a, b) => if f a then (b+1) else b) 0 x

fun parseInt yytext radix = valOf(StringCvt.scanString(Int.scan(radix)) yytext)

fun escape "\\\"" = "\""
  | escape "\\n"  = "\n"
  | escape "\\t"  = "\t"
  | escape "\\\\" = "\\"
  | escape x      = x

fun eof() = let val pos = hd(!linePos) in
  if(!netCommentBalance <> 0) then ErrorMsg.error pos ("SyntaxError: Unclosed comment.")
  else if (!stringLiteralClosed = false) then ErrorMsg.error pos ("SyntaxError: Unclosed string literal.")
  else ();
  netCommentBalance := 0;
  stringLiteralClosed := true;
  stringStartPosition := 0;
  buffer := "";
  Tokens.EOF(pos,pos) end

%%
%header (functor GeminiLexFun(structure Tokens: Gemini_TOKENS));
%s STRING COMMENT;
%%

<INITIAL, COMMENT>\n                           => (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<INITIAL, COMMENT>[ \b\r\t]+                   => (continue());

<INITIAL>"sdatatype"  	                       => (Tokens.SDATATYPE(yypos, yypos + 9));
<INITIAL>"hdatatype"  	                       => (Tokens.HDATATYPE(yypos, yypos + 9));
<INITIAL>"type"  	                             => (Tokens.TYPE(yypos, yypos + 4));
<INITIAL>"val"  	                             => (Tokens.VAL(yypos, yypos + 3));
<INITIAL>"ref"  	                             => (Tokens.REF(yypos, yypos + 3));
<INITIAL>"fun"  	                             => (Tokens.FUN(yypos, yypos + 3));
<INITIAL>"module"  	                           => (Tokens.MODULE(yypos, yypos + 6));
<INITIAL>"structure"  	                       => (Tokens.STRUCTURE(yypos, yypos + 9));
<INITIAL>"struct"  	                           => (Tokens.STRUCT(yypos, yypos + 6));
<INITIAL>"signature"  	                       => (Tokens.SIGNATURE(yypos, yypos + 9));
<INITIAL>"sig"  	                             => (Tokens.SIG(yypos, yypos + 3));
<INITIAL>"list"                                => (Tokens.LIST(yypos, yypos + 4));
<INITIAL>"sw"                                  => (Tokens.SW(yypos, yypos + 2));
<INITIAL>"unsw"                                => (Tokens.UNSW(yypos, yypos + 4));
<INITIAL>"gen"                                 => (Tokens.GEN(yypos, yypos + 3));

<INITIAL>"let"  	                             => (Tokens.LET(yypos, yypos + 3));
<INITIAL>"in"  	                               => (Tokens.IN(yypos, yypos + 2));
<INITIAL>"end"  	                             => (Tokens.END(yypos, yypos + 3));
<INITIAL>"if"  	                               => (Tokens.IF(yypos, yypos + 2));
<INITIAL>"then"  	                             => (Tokens.THEN(yypos, yypos + 4));
<INITIAL>"else"  	                             => (Tokens.ELSE(yypos, yypos + 4));
<INITIAL>"case"                                => (Tokens.CASE(yypos, yypos + 4));

<INITIAL>"orelse"  	                           => (Tokens.ORELSE(yypos, yypos + 6));
<INITIAL>"andalso"  	                         => (Tokens.ANDALSO(yypos, yypos + 7));
<INITIAL>"not"  	                             => (Tokens.NOT(yypos, yypos + 3));

<INITIAL>"nil"  	                             => (Tokens.NIL(yypos, yypos + 3));
<INITIAL>"with"  	                             => (Tokens.WITH(yypos, yypos + 4));
<INITIAL>"of"  	                               => (Tokens.OF(yypos, yypos + 2));
<INITIAL>"op"  	                               => (Tokens.OP(yypos, yypos + 2));
<INITIAL>"and"                                 => (Tokens.AND(yypos, yypos + 3));

<INITIAL>"|:"                                  => (Tokens.PIPE_EQUALS(yypos, yypos + 2));
<INITIAL>"=>"                                  => (Tokens.FAT_ARROW(yypos, yypos + 2));
<INITIAL>"->"                                  => (Tokens.THIN_ARROW(yypos, yypos + 2));

<INITIAL>"|->"                                 => (Tokens.BIT_OR_REDUCE(yypos, yypos + 3));
<INITIAL>"&->"                                 => (Tokens.BIT_AND_REDUCE(yypos, yypos + 3));
<INITIAL>"^->"                                 => (Tokens.BIT_XOR_REDUCE(yypos, yypos + 3));
<INITIAL>"&&"                                  => (Tokens.BIT_DOUBLE_AND(yypos, yypos + 2));
<INITIAL>"||"                                  => (Tokens.BIT_DOUBLE_OR(yypos, yypos + 2));
<INITIAL>"^^"                                  => (Tokens.BIT_DOUBLE_XOR(yypos, yypos + 2));
<INITIAL>"!"	                                 => (Tokens.BIT_NOT(yypos, yypos + 1));
<INITIAL>"|"	                                 => (Tokens.BIT_OR(yypos, yypos + 1));
<INITIAL>"&"	                                 => (Tokens.BIT_AND(yypos, yypos + 1));
<INITIAL>"^"	                                 => (Tokens.BIT_XOR(yypos, yypos + 1));
<INITIAL>"<<"	                                 => (Tokens.BIT_SLL(yypos, yypos + 2));
<INITIAL>">>"	                                 => (Tokens.BIT_SRL(yypos, yypos + 2));
<INITIAL>">>>"	                               => (Tokens.BIT_SRA(yypos, yypos + 3));

<INITIAL>"="                                   => (Tokens.EQ(yypos, yypos + 1));
<INITIAL>">="                                  => (Tokens.GE(yypos, yypos + 2));
<INITIAL>"<="                                  => (Tokens.LE(yypos, yypos + 2));
<INITIAL>"<>"                                  => (Tokens.NEQ(yypos, yypos + 2));
<INITIAL>">"                                   => (Tokens.GT(yypos, yypos + 1));
<INITIAL>"<"                                   => (Tokens.LT(yypos, yypos + 1));

<INITIAL>"~"                                   => (Tokens.UMINUS(yypos, yypos + 1));
<INITIAL>"+"                                   => (Tokens.INT_PLUS(yypos, yypos + 1));
<INITIAL>"-"                                   => (Tokens.INT_MINUS(yypos, yypos + 1));
<INITIAL>"*"                                   => (Tokens.INT_TIMES(yypos, yypos + 1));
<INITIAL>"/"                                   => (Tokens.INT_DIVIDE(yypos, yypos + 1));
<INITIAL>"%"                                   => (Tokens.INT_MOD(yypos, yypos + 1));
<INITIAL>"+."                                  => (Tokens.REAL_PLUS(yypos, yypos + 2));
<INITIAL>"-."                                  => (Tokens.REAL_MINUS(yypos, yypos + 2));
<INITIAL>"*."                                  => (Tokens.REAL_TIMES(yypos, yypos + 2));
<INITIAL>"/."                                  => (Tokens.REAL_DIVIDE(yypos, yypos + 2));

<INITIAL>"["                                   => (Tokens.LBRACK(yypos, yypos + 1));
<INITIAL>"]"                                   => (Tokens.RBRACK(yypos, yypos + 1));
<INITIAL>"{"                                   => (Tokens.LBRACE(yypos, yypos + 1));
<INITIAL>"}"                                   => (Tokens.RBRACE(yypos, yypos + 1));
<INITIAL>"("                                   => (Tokens.LPAREN(yypos, yypos + 1));
<INITIAL>")"                                   => (Tokens.RPAREN(yypos, yypos + 1));
<INITIAL>"<:"                                  => (Tokens.DOUBLE_LANGLE(yypos, yypos + 2));
<INITIAL>":>"                                  => (Tokens.DOUBLE_RANGLE(yypos, yypos + 2));

<INITIAL>"."                                   => (Tokens.DOT(yypos, yypos + 1));
<INITIAL>","                                   => (Tokens.COMMA(yypos, yypos + 1));
<INITIAL>":="                                  => (Tokens.ASSIGN(yypos, yypos + 2));
<INITIAL>"::"                                  => (Tokens.CONS(yypos, yypos + 2));
<INITIAL>":"                                   => (Tokens.COLON(yypos, yypos + 1));
<INITIAL>";"                                   => (Tokens.SEMICOLON(yypos, yypos + 1));
<INITIAL>"#*"                                  => (Tokens.POUND_TIMES(yypos, yypos + 2));
<INITIAL>"#"                                   => (Tokens.POUND(yypos, yypos + 1));
<INITIAL>"@"                                   => (Tokens.AT(yypos, yypos + 1));
<INITIAL>"$"                                   => (Tokens.BANG(yypos, yypos + 1));

<INITIAL>"\'"[a-zA-Z][a-zA-Z0-9_]*             => (Tokens.TID(yytext, yypos, yypos + size(yytext)));
<INITIAL>[a-zA-Z_][a-zA-Z0-9_]*                => (Tokens.ID(yytext, yypos, yypos + size(yytext)));
<INITIAL>[~]?[0-9]+                            => (Tokens.INT(valOf(Int.fromString(yytext)), yypos, yypos + size(yytext)));
<INITIAL>#'b:[0-1]+                            => (Tokens.INT(parseInt (String.substring(yytext, 4, size(yytext) - 4)) StringCvt.BIN, yypos, yypos + size(yytext)));
<INITIAL>#'o:[0-7]+                            => (Tokens.INT(parseInt (String.substring(yytext, 4, size(yytext) - 4)) StringCvt.OCT, yypos, yypos + size(yytext)));
<INITIAL>#'h:[0-9a-fA-F]+                      => (Tokens.INT(parseInt (String.substring(yytext, 4, size(yytext) - 4)) StringCvt.HEX, yypos, yypos + size(yytext)));
<INITIAL>[~]?[0-9]+\.[0-9]*                    => (Tokens.REAL(valOf(Real.fromString(yytext)), yypos, yypos + size(yytext)));
<INITIAL>[~]?[0-9]*\.[0-9]+([eE][~]?[0-9]+)?   => (Tokens.REAL(valOf(Real.fromString(yytext)), yypos, yypos + size(yytext)));
<INITIAL>[~]?[0-9]+[eE][~]?[0-9]+              => (Tokens.REAL(valOf(Real.fromString(yytext)), yypos, yypos + size(yytext)));
<INITIAL>'b:(0|1)                              => (Tokens.BIT(GeminiBit.fromString(yytext), yypos, yypos + size(yytext)));
<INITIAL>"\""                                  => (YYBEGIN STRING; stringLiteralClosed := false; buffer:= ""; stringStartPosition := yypos; continue());
<STRING>[ -!#-\[\]-~]*                         => (buffer := !buffer ^ yytext; continue());
<STRING>\\n                                    => (buffer := !buffer ^ (escape yytext); continue());
<STRING>\\t                                    => (buffer := !buffer ^ (escape yytext); continue());
<STRING>"\\\""                                 => (buffer := !buffer ^ (escape yytext); continue());
<STRING>"\\\\"                                 => (buffer := !buffer ^ (escape yytext); continue());
<STRING>\\[ \b\r\t\n]+\\                       => (lineNum:= !lineNum + (count (fn c => c = #"\n") (String.explode yytext)); linePos := yypos :: !linePos; continue());
<STRING>\\\^[@-_]                              => (buffer := !buffer ^ escape (convertControlCharacter(String.substring (yytext, 2, 1))); continue());
<STRING>\\(0[0-9][0-9]|1[0-1][0-9]|12[0-7])    => (buffer := !buffer ^ escape (asciiCode(String.substring (yytext, 1, 3))); continue());
<STRING>"\""                                   => (YYBEGIN INITIAL; stringLiteralClosed := true; Tokens.STRING(!buffer, !stringStartPosition, yypos));
<STRING>\n                                     => (YYBEGIN INITIAL; stringLiteralClosed := true; ErrorMsg.error yypos ("StringParseError: New-line within string."); lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<STRING>.                                      => (ErrorMsg.error yypos ("StringParseError: Illegal character within string: " ^ yytext); continue());

<INITIAL>"(*"                                  => (YYBEGIN COMMENT; netCommentBalance := 1; continue());
<INITIAL>"*)"                                  => (ErrorMsg.error yypos ("SyntaxError: Cannot close unopened comment."); continue());
<COMMENT>"(*"                                  => (netCommentBalance := (!netCommentBalance) + 1; continue());
<COMMENT>"*)"                                  => (netCommentBalance := (!netCommentBalance) - 1; if !netCommentBalance = 0 then YYBEGIN INITIAL else (); continue());
<COMMENT>.                                     => (continue());

.                                              => (ErrorMsg.error yypos ("SyntaxError: Illegal character: " ^ yytext); continue());
