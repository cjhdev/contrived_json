require 'rubygems'
require 'benchmark'
require 'json'
#require 'yajl'
require 'contrived_json'

# taken from yajl
data =
'{"item": {"name": "generated", "cached_tag_list": "", "updated_at": "2009-03-24T05:25:09Z", "updated_by_id": null, "price": 1.99, "delta": false, "cost": 0.597, "account_id": 16, "unit": null, "import_tag": null, "taxable": true, "id": 1, "created_by_id": null, "description": null, "company_id": 0, "sku": "06317-0306", "created_at": "2009-03-24T05:25:09Z", "active": true}}'.freeze

times = 10000

Benchmark.bmbm do |x|

  if defined?(JSON)
    x.report {
      puts "JSON.parse"
      times.times {
        JSON.parse(data, :max_nesting => false)
      }
    }
  end
  if defined?(ContrivedJSON::JSON)
    x.report {
      puts "ContrivedJSON::JSON.parse"
      times.times {
        ContrivedJSON::JSON.parse(data)
      }
    }
  end
  if defined?(Yajl::Parser)
    string_parser = Yajl::Parser.new
    
  x.report {
    puts "Yajl::Parser#parse (from a String)"
    times.times {
      string_parser.parse(json)
    }
  }
  end
  

end



=begin

begin
  require 'json'
rescue LoadError
end
begin
  require 'psych'
rescue LoadError
end
begin
  require 'active_support'
rescue LoadError
end
begin
  require 'contrived_json'
rescue LoadError
end

filename = ARGV[0] || 'benchmark/subjects/item.json'
json = File.new(filename, 'r')

times = ARGV[1] ? ARGV[1].to_i : 10_000
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bmbm { |x|
  io_parser = Yajl::Parser.new
  io_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from an IO)"
    times.times {
      json.rewind
      io_parser.parse(json)
    }
  }
  string_parser = Yajl::Parser.new
  string_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from a String)"
    times.times {
      json.rewind
      string_parser.parse(json.read)
    }
  }
  if defined?(JSON)
    x.report {
      puts "JSON.parse"
      times.times {
        json.rewind
        JSON.parse(json.read, :max_nesting => false)
      }
    }
  end
  if defined?(ContrivedJSON::JSON)
    x.report {
      puts "ContrivedJSON::JSON.parse"
      times.times {
        json.rewind
        ContrivedJSON::JSON.parse(json.read)
      }
    }
  end
  if defined?(ActiveSupport::JSON)
    x.report {
      puts "ActiveSupport::JSON.decode"
      times.times {
        json.rewind
        ActiveSupport::JSON.decode(json.read)
      }
    }
  end
  x.report {
    puts "YAML.load (from an IO)"
    times.times {
      json.rewind
      YAML.load(json)
    }
  }
  x.report {
    puts "YAML.load (from a String)"
    times.times {
      json.rewind
      YAML.load(json.read)
    }
  }
  if defined?(Psych)
    x.report {
      puts "Psych.load (from an IO)"
      times.times {
        json.rewind
        Psych.load(json)
      }
    }
    x.report {
      puts "Psych.load (from a String)"
      times.times {
        json.rewind
        Psych.load(json.read)
      }
    }
  end
}
json.close

=end
