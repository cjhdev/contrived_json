%{

typedef void * yyscan_t;
#define YY_TYPEDEF_YY_SCANNER_T

#include <ruby.h>

#include "parser.h"
#include "lexer.h"

void yyerror(YYLTYPE *locp, yyscan_t scanner, VALUE *object, char const *msg);

%}

%define api.value.type {VALUE}
%define api.pure full
%define parse.error verbose
%define api.token.prefix {TOK_}

%locations

%lex-param {yyscan_t scanner}
%parse-param {yyscan_t scanner}{VALUE *object}

%token EOF      
%token TRUE     "'true'"
%token FALSE    "'false'"
%token NULL     "'null'"
%token STRING   "String"
%token NUMBER   "Number"
%token UNKNOWN

%%    

top:
    type                { *object = $type; }
    |
    %empty
    ;
    
type:
    array | object
    ;

array:
    '[' ']'             { $$ = rb_ary_new(); }
    |
    '[' values ']'      { $$ = $values; }
    ;

values:
    value               { $$ = rb_ary_new(); rb_ary_push($$, $value); }        
    |
    values ',' value    { rb_ary_push($$, $value); };
    ;

object:
    '{' '}'             { $$ = rb_hash_new(); }
    |
    '{' members '}'     { $$ = $members; }
    ;
    
members:
    STRING ':' value    { $$ = rb_hash_new(); rb_hash_aset($$, $STRING, $value); }
    |
    members ',' STRING ':' value { rb_hash_aset($$, $STRING, $value); }    
    ;

value:
    STRING | TRUE | FALSE | NULL | NUMBER | object | array;
    
%%

void yyerror(YYLTYPE *locp, yyscan_t scanner, VALUE *object, char const *msg)
{
    VALUE message = rb_funcall(INT2NUM(locp->first_line), rb_intern("to_s"), 0);
    rb_str_append(message, rb_str_new2(":"));
    rb_str_append(message, rb_funcall(INT2NUM(locp->first_column), rb_intern("to_s"), 0));
    rb_str_append(message, rb_str_new2(": error: "));    
    rb_str_append(message, rb_funcall(rb_str_new2(msg), rb_intern("sub"), 2, rb_str_new2("UNKNOWN"), rb_str_new2(yyget_text(scanner))));    
    rb_funcall(rb_stderr, rb_intern("puts"), 1, message);
}

static VALUE parse(int argc, VALUE *argv, VALUE self);

void Init_ext_parser(void)
{
    rb_require("bigdecimal");
    VALUE cContrivedJSON = rb_define_module("ContrivedJSON");
    VALUE cJSON = rb_define_class_under(cContrivedJSON, "JSON", rb_cObject);
    rb_define_singleton_method(cJSON, "parse", parse, -1);
    rb_define_class_under(cContrivedJSON, "ParseError", rb_eStandardError);    
}

static VALUE parse(int argc, VALUE *argv, VALUE self)
{
    yyscan_t scanner;    
    VALUE object = Qnil;
    VALUE buffer = Qnil;
    VALUE opt = rb_hash_new();
    int retval = 0;

    rb_scan_args(argc, argv, "11", &buffer, &opt);

    buffer = rb_funcall(buffer, rb_intern("to_s"), 0);

    if(yylex_init(&scanner) == 0){

        if(yy_scan_bytes((const char *)RSTRING_PTR(buffer), RSTRING_LEN(buffer), scanner)){

            retval = yyparse(scanner, &object);
        }

        yylex_destroy(scanner);        
        
        switch(retval){
        case 0:
            break;
        case 1: /* syntax error */
        case 2: /* memory exhaustion - most likely running out of stack */
            rb_raise(rb_const_get(rb_define_module("ContrivedJSON"), rb_intern("ParseError")), "parse error");
            break;
        default:
            rb_bug("unexpected return code");
            break;
        }        
    }

    return object;
}