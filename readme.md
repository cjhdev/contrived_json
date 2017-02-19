ContrivedJSON
=============

A JSON parser implemented using Flex, Bison, and Ruby.

This project exists to demonstrate what is required to
produce a Ruby native extension from Flex and Bison configuration
files.

## Highlights

- Similar interface to Ruby standard library JSON (`ContrivedJSON::JSON.parse`)
- Big number support
    - Fractions and exponents are captured using `BigDecimal::new`
    - Integers are capured using `String#to_i`
- Syntax error reporting with location and token information
- Generated parser source has no additional runtime dependencies
- Bulk of implementation completed within ~200 LOC
- Faster than standard library `JSON.parse`

## Parser Configuration

The bulk of the implementation is contained within these files:

-   [parser.l](etc/contrived_json/ext_parser/parser.l) (lexer configuration)
-   [parser.y](etc/contrived_json/ext_parser/parser.y) (parser configuration)

## Source Code Generation

The [rakefile](rakefile) task `flexbison` orchestrates generation:

~~~
task :flexbison do    
    system "flex --outfile=#{DIR_SRC}/lexer.c --header-file=#{DIR_SRC}/lexer.h #{DIR_ETC}/parser.l"
    system "bison #{DIR_ETC}/parser.y --output=#{DIR_SRC}/parser.c"
end
~~~

### Benchmark

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

See [parser.rb](benchmark/parse.rb).

## License

ContrivedJSON has an MIT license
