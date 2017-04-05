ContrivedJSON
=============

A Ruby JSON parser implemented using Flex and Bison.

This project is an example of how to use Flex and Bison with Ruby to quickly produce LALR and GLR based parsers.

[![Build Status](https://travis-ci.org/cjhdev/contrived_json.svg?branch=master)](https://travis-ci.org/cjhdev/contrived_json)
[![Gem Version](https://badge.fury.io/rb/contrived_json.svg)](https://badge.fury.io/rb/contrived_json)

## ContrivedJSON Highlights

- Big number support
    - Fractions and exponents are captured using `BigDecimal::new`
    - Integers are captured using `String#to_i`
- Syntax error reporting with location and token information
- No additional runtime dependencies
- Bulk of implementation within ~200 lines of configuration ([parser.l](etc/contrived_json/ext_parser/parser.l) and [parser.y](etc/contrived_json/ext_parser/parser.y))
- Faster than standard library `JSON.parse`
- Works on MRI Ruby 1.9.3 and up

## The Interface

ContrivedJSON implements a parse method very similar to the standard library
`JSON.parse`. It looks like this:

~~~ ruby
module ContrivedJSON

    class JSON

        # @param source [String] JSON document
        # @param opts   [Hash]
        #
        # @return [Hash,Array]
        #
        # @raise [ArgumentError]
        # @raise [TypeError]
        # @raise [ContrivedJSON::ParseError]
        #
        def self.parse(source, opts={})
        end    

    end

end
~~~

## Usage

Installing:

~~~
$ gem install contrived_json
~~~

Hello world:

~~~
$ irb
2.3.3 :001 > require 'contrived_json'
 => true 
2.3.3 :002 > ContrivedJSON::JSON.parse('{"hello":"world"}')
 => {"hello"=>"world"} 
~~~

Syntax error:

~~~
$ irb
2.3.3 :001 > require 'contrived_json'
 => true 
2.3.3 :002 > ContrivedJSON::JSON.parse('{"hello":"world"')
1:10: error: syntax error, unexpected EOF, expecting ',' or '}'
ContrivedJSON::ParseError: parse error
    from (irb):2:in `parse'
    from (irb):2
    from /home/cjh/.rvm/rubies/ruby-2.3.3/bin/irb:11:in `<main>'
~~~

Benchmark:

~~~
$ rake benchmark

Rehearsal ------------------------------------
 JSON.parse
  0.150000   0.000000   0.150000 (  0.148277)
 ContrivedJSON::JSON.parse
  0.110000   0.000000   0.110000 (  0.106015)
--------------------------- total: 0.260000sec

       user     system      total        real
 JSON.parse
  0.140000   0.000000   0.140000 (  0.149039)
 ContrivedJSON::JSON.parse
  0.100000   0.000000   0.100000 (  0.103996)
~~~

## Under The Hood

Flex generates lexers. Bison generates LALR
and GLR parsers from context free grammar.

In this project the lexer is configured in [parser.l](etc/contrived_json/ext_parser/parser.l) and the parser is configured in [parser.y](etc/contrived_json/ext_parser/parser.y).

The rake task `:flexbison` is used by the developer to convert configuration into source:
~~~
task :flexbison do    
    system "flex --outfile=#{DIR_SRC}/lexer.c --header-file=#{DIR_SRC}/lexer.h #{DIR_ETC}/parser.l"
    system "bison -d #{DIR_ETC}/parser.y --output=#{DIR_SRC}/parser.c"
end
~~~

The result is checked into Git:

- [lexer.c](ext/contrived_json/ext_parser/lexer.c) 
- [lexer.h](ext/contrived_json/ext_parser/lexer.h) 
- [parser.c](ext/contrived_json/ext_parser/parser.c) 
- [parser.h](ext/contrived_json/ext_parser/parser.h) 

The remainder of the code and structure in the repository is for packaging
up the project as a Gem which will handle compilation of the parser
source on installation.

Compared to vanilla C, the Ruby C API makes working with Flex and Bison easier for the following reasons:

- The API manages memory for you since you are effectively writing Ruby in C
- It's easy to build up an Abstract Syntax Tree on the fly with built in types like array and hash
- Flex and Bison actions are simpler since there is only one value type passed around (i.e. `VALUE`)
- Ruby has plenty of functionality for converting between strings and numeric values (e.g. `rb_funcall(rb_str_new(yytext, yyleng), rb_intern("to_i"), 0)` will
  capture an integer of any size)

## Native Extension Pitfalls

It's very easy to write intermittent bugs caused by the garbage collector in Ruby native extensions.

The problem is usually that you have created an object in the VM but
there is no way for the VM to see your reference to it. When the GC runs,
objects without references are freed. You will then get a segfault next
time you try to access the freed object.

Ruby can recognise references in your C extension if:

- They are on the stack
- They are in the registers

This *can* go wrong when the C compiler optimises away references. This *will* go wrong
if references are kept in data or on the heap.

Bison in LALR mode can be configured to keep its data structures on the stack. This
is done in ContrivedJSON and *should* ensure that Ruby can find the token
references in the event that the GC runs (I need to run some tests to prove this).

Bison GLR mode is different in that it stores its data structures on the heap.
In this situation you will need to find some way to connect your references (stored on the heap) to
to ruby VM.
[SlowBlink](https://github.com/cjhdev/slow_blink "SlowBlink") for example solves this problem by pushing
references onto an instance variable Array. 
  
## Further Reading

- [Bison user manual](https://www.gnu.org/software/bison/manual/)
- The Flex user manual is included with the distribution and can be accessed from the terminal via the command `$ info flex`
- [A Flex/Bison tutorial](http://aquamentus.com/flex_bison.html)


## License

ContrivedJSON has an MIT license
