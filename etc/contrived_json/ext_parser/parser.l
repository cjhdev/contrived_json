/* Flex configuration */
%{

#include <ruby.h>
#include "parser.h"

#define YY_USER_ACTION do{\
    yylloc->first_line = yylloc->last_line;\
    yylloc->first_column = yylloc->last_column;\
    yylloc->last_column += yyleng;\
}while(0);    

static VALUE read_wrapper(VALUE arg)
{
    VALUE *aarg = (VALUE *)arg;
    return rb_funcall(aarg[0], rb_intern("readpartial"), 1, aarg[1]);
}

static VALUE read_wrapper_rescue(VALUE arg)
{
    return Qnil;
}

#define YY_INPUT(buf, result, max_size) do {\
    VALUE arg[2];\
    VALUE str;\
    result = 0U;\
    arg[0] = *((VALUE *)yyin);\
    arg[1] = SIZET2NUM(max_size);\
    str = rb_rescue2(read_wrapper, (VALUE)arg, read_wrapper_rescue, Qnil, rb_eEOFError, 0);\
    if(str != Qnil){\
        (void)memcpy(buf, RSTRING_PTR(str), RSTRING_LEN(str));\    
        result = (size_t)RSTRING_LEN(str);\
    }\
} while(0)\    
    
%}

%option bison-locations
%option reentrant
%option fast
%option nounput noyywrap noinput

UNICODE         \\u[0-9a-fA-F]{4}
UNESCAPED       [ !#-\[\]-~]
ESCAPED         \\["\\bfnrt/]
CHAR            {UNESCAPED}|{ESCAPED}|{UNICODE}

EXP             [e|E][+|-]?[0-9]+
FRACTION        [.][0-9]+
INTEGER         [-]?[0-9]+

%%

[ \t]+      { }
[\n]+       { yylloc->last_column = 0; yylloc->last_line += yyleng; }
    
","         |
"{"         |
"}"         |
"["         |
"]"         |
":"         { return *yytext; }

"true"      { *yylval = Qtrue; return TOK_TRUE; }
"false"     { *yylval = Qfalse; return TOK_FALSE; }
"null"      { *yylval = Qnil; return TOK_NULL; }

["]{CHAR}*["]               { *yylval = rb_str_new(&yytext[1], yyleng-2U); return TOK_STRING; }

{INTEGER}{FRACTION}{EXP}    |
{INTEGER}{FRACTION}         |
{INTEGER}{EXP}              { *yylval = rb_funcall(rb_const_get(rb_cObject, rb_intern("BigDecimal")), rb_intern("new"), 1, rb_str_new(yytext, yyleng)); return TOK_NUMBER; }

{INTEGER}                   { *yylval = rb_funcall(rb_str_new(yytext, yyleng), rb_intern("to_i"), 0); return TOK_NUMBER; }

.           { return TOK_UNKNOWN; }

%%
