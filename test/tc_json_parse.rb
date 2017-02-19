require 'test/unit'
require 'contrived_json'

class TestJSON < Test::Unit::TestCase

    include ContrivedJSON

    def test_no_input
        input = ''
        assert_nil(JSON.parse(input))
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

end
