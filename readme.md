ContrivedJSON
=============

A Ruby JSON parser implemented using Flex and Bison.

This project is an example of how to use Flex and Bison with Ruby to produce LALR based parsers.

[![Build Status](https://travis-ci.org/cjhdev/contrived_json.svg?branch=master)](https://travis-ci.org/cjhdev/contrived_json)
[![Gem Version](https://badge.fury.io/rb/contrived_json.svg)](https://badge.fury.io/rb/contrived_json)

## ContrivedJSON Highlights

- Can read from a stream or a string
- Big number support
    - Fractions and exponents are captured using `BigDecimal::new`
    - Integers are captured using `String#to_i`
- Syntax error reporting with location and token information
- Bulk of implementation within ~200 lines of configuration ([parser.l](etc/contrived_json/ext_parser/parser.l) and [parser.y](etc/contrived_json/ext_parser/parser.y))
- Works on MRI Ruby 1.9.3 and up

## The Interface

ContrivedJSON implements a parse method similar to the standard library
`JSON.parse`. It looks like this:

~~~ ruby
module ContrivedJSON

    class JSON

        # @param source [String,#readpartial] JSON string or a stream
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

## Under The Hood

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
  
## Further Reading

- [Bison user manual](https://www.gnu.org/software/bison/manual/)
- The Flex user manual is included with the distribution and can be accessed from the terminal via the command `$ info flex`
- [A Flex/Bison tutorial](http://aquamentus.com/flex_bison.html)

## License

ContrivedJSON has an MIT license
