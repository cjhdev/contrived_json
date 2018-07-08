/* Bison configuration */
%{

typedef void * yyscan_t;
#define YY_TYPEDEF_YY_SCANNER_T

#define YYMAXDEPTH YYINITDEPTH

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

%token EOF      0
%token TRUE     "'true'"
%token FALSE    "'false'"
%token NULL     "'null'"
%token STRING   "String"
%token NUMBER   "Number"
%token UNKNOWN

%%    

top:
    type                { *object = $type; YYACCEPT; }
    ;
    
type:
    value
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
    VALUE cContrivedJSON;
    rb_require("bigdecimal");    
    cContrivedJSON = rb_define_module("ContrivedJSON");
    rb_define_singleton_method(rb_define_class_under(cContrivedJSON, "JSON", rb_cObject), "parse", parse, -1);
    rb_define_class_under(cContrivedJSON, "ParseError", rb_eStandardError);    
}

/* parse(source, opts={}) */
static VALUE parse(int argc, VALUE *argv, VALUE self)
{
    yyscan_t scanner;    
    VALUE object = Qnil;
    VALUE source = Qnil;
    VALUE opts = rb_hash_new();
    int retval = 0;
    VALUE input = Qnil;
    VALUE cStringIO = rb_const_get(rb_cObject, rb_intern("StringIO"));
    
    switch(rb_scan_args(argc, argv, "11", &source, &opts)){
    case 1:
    case 2:
        break;
    default:
        rb_raise(rb_eArgError, "wrong number of arguments");
        break;
    }

    if(rb_respond_to(source, rb_intern("read"))){
            
        input = source;        
    }
    else if(rb_obj_is_kind_of(source, rb_cString) == Qtrue){
    
        input = rb_funcall(cStringIO, rb_intern("new"), 1, source);    
    }
    else{
    
        rb_raise(rb_eTypeError, "no implicit conversion to String");
    }

    if(yylex_init(&scanner) == 0){

        yyset_in((FILE*)(&input), scanner);
        
        retval = yyparse(scanner, &object);

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
