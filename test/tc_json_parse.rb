require 'test/unit'
require 'contrived_json'

class TestJSON < Test::Unit::TestCase

    include ContrivedJSON

    def test_no_input
      input = ''
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_wrong_type
      input = 42
      assert_raise TypeError do
        JSON.parse(input)
      end
    end

    def test_empty_object
      input = '{}'
      expected = {}
      assert_equal(expected, JSON.parse(input))
    end

    def test_empty_array
      input = '[]'
      expected = []
      assert_equal(expected, JSON.parse(input))
    end
    
    def test_toplevel_true
      input = 'true'
      expected = true
      assert_equal(expected, JSON.parse(input))
    end
    
    def test_toplevel_false
      input = 'false'
      expected = false
      assert_equal(expected, JSON.parse(input))      
    end
    
    def test_toplevel_number
      input = '42'
      expected = 42
      assert_equal(expected, JSON.parse(input))
    end
    
    def test_toplevel_string
      input = "\"hello world\""
      expected ='hello world'
      assert_equal(expected, JSON.parse(input))
    end
    
    def test_toplevel_null
      input = "null"
      expected = nil
      assert_equal(expected, JSON.parse(input))
    end

    def test_unexpected_end_open_brace
      input = '{'
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_unexpected_end_key
      input = '{ "key"'
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_unexpected_end_colon
      input = '{ "key" :'
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_unexpected_end_value
      input = '{ "key" : null'
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_hello_world
      input = <<-eos
      {
          "hello" : "hello",
          "world" : "world"
      }
      eos
      expected = {
          "hello" => "hello",
          "world" => "world"
      }        
      assert_equal(expected, JSON.parse(input))
    end

    def test_unknown_token
      input = "{ !"
      assert_raise ParseError do
        JSON.parse(input)
      end
    end

    def test_unicode_string
      input = '{"test":"\u005C"}'
      JSON.parse(input)
    end

    def test_escaped_characters
      input = '{"test":"\"\\\/\b\f\n\r\t\u005C"}'
      JSON.parse(input)
    end

    def test_hello_world_stream
      input = <<-eos
      {
          "hello" : "hello",
          "world" : "world"
      }
      
      {
          "hello" : "hello",
          "world" : "world"
      }
      eos
      expected = {
          "hello" => "hello",
          "world" => "world"
      }
      assert_equal(expected, JSON.parse(input))
      assert_equal(expected, JSON.parse(input))        
    end
             
    def test_blocking_read
    
      rd, wr = IO.pipe
      
      expected = {
          "hello" => "hello",
          "world" => "world"
      }
      
      t = Thread.new do
        
        wr.write "{\"hello\" : \"hello\","
        
        sleep 0.5
        
        wr.write "\"world\" : \"world\"} "
        
      end
      
      t.run
      
      assert_equal(expected, JSON.parse(rd))
      
      t.join
      
    end

end
